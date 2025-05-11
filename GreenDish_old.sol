// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenDish {
    // Token Variables
    string public constant name = "GreenCoin";
    string public constant symbol = "GRC";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000 * 10 ** 18; // Fixed total supply of 1 million tokens
    uint256 public constant REWARD_PERCENTAGE = 10; // 10% of carbon credits

    // Restaurant information
    string public restaurantName;
    address public owner;
    bool public initialized = false;

    // Dish struct to hold all dish details
    struct Dish {
        string dishName;
        uint dishPrice;
        uint inventory;
        uint availableInventory;
        uint carbonCredits;
        string mainComponent;
        string supplySource;
        bool isActive;
    }

    // ERC20 token mappings
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    // Restaurant data mappings
    mapping(uint => Dish) public dishes;
    mapping(uint => mapping(address => uint)) public dishesBought;
    uint public dishCount;

    // Reward pool address
    address public rewardPool;

    // Simple reentrancy protection
    bool private _locked;

    // Events
    event RestaurantInitialized(string restaurantName, address owner);
    event DishCreated(uint dishId, string dishName);
    event DishPurchased(uint dishId, address buyer, uint numberOfDishes);
    event InventoryUpdated(uint dishId, uint newInventory);
    event DishStatusChanged(uint dishId, bool isActive);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event TokensRewarded(address indexed buyer, uint256 amount);

    // Constructor only initializes the token supply
    constructor() {
        // Set contract as its own reward pool
        rewardPool = address(this);

        // Initialize token supply
        balances[rewardPool] = TOTAL_SUPPLY;

        // Emit token creation event
        emit Transfer(address(0), rewardPool, TOTAL_SUPPLY);

        // Initialize reentrancy guard
        _locked = false;
    }

    // Simple reentrancy guard
    modifier nonReentrant() {
        require(!_locked, "ReentrancyGuard: reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        require(initialized, "Restaurant not initialized");
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Create a dish and initialize restaurant if not already initialized
    function createDish(
        string memory _restaurantName,
        string memory _dishName,
        uint _dishPrice,
        uint _inventory,
        uint _carbonCredits,
        string memory _mainComponent,
        string memory _supplySource
    ) public returns (uint) {
        // Handle restaurant initialization if needed
        if (!initialized) {
            require(
                bytes(_restaurantName).length > 0,
                "Restaurant name cannot be empty"
            );
            restaurantName = _restaurantName;
            owner = msg.sender;
            initialized = true;
            emit RestaurantInitialized(_restaurantName, msg.sender);
        } else {
            // If already initialized, ensure caller is the owner
            require(
                msg.sender == owner,
                "Only the owner can call this function"
            );
        }

        // Validate dish parameters
        require(
            _carbonCredits <= 100,
            "Carbon credits must be between 0 and 100"
        );

        // Create dish
        uint dishId = dishCount++;
        Dish storage newDish = dishes[dishId];
        newDish.dishName = _dishName;
        newDish.dishPrice = _dishPrice;
        newDish.inventory = _inventory;
        newDish.availableInventory = _inventory;
        newDish.carbonCredits = _carbonCredits;
        newDish.mainComponent = _mainComponent;
        newDish.supplySource = _supplySource;
        newDish.isActive = true;

        emit DishCreated(dishId, _dishName);
        return dishId;
    }

    // Purchase a dish
    function purchaseDish(
        uint _dishId,
        uint _numberOfDishes
    ) public payable nonReentrant {
        require(initialized, "Restaurant not initialized");
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];
        require(
            dish.isActive,
            "This dish is not currently available for purchase"
        );
        require(
            _numberOfDishes <= dish.availableInventory,
            "Not enough dishes available"
        );
        require(
            msg.value >= dish.dishPrice * _numberOfDishes,
            "Insufficient funds sent"
        );

        // Update state before external calls (reentrancy protection)
        dish.availableInventory -= _numberOfDishes;
        dishesBought[_dishId][msg.sender] += _numberOfDishes;
        uint totalPrice = dish.dishPrice * _numberOfDishes;
        uint excess = msg.value - totalPrice;
        uint carbonReward = dish.carbonCredits * _numberOfDishes;

        emit DishPurchased(_dishId, msg.sender, _numberOfDishes);

        // If inventory is now zero, set isActive to false
        if (dish.availableInventory == 0) {
            dish.isActive = false;
            emit DishStatusChanged(_dishId, false);
        }

        // Award tokens - must be called before external transfers
        _awardTokens(msg.sender, carbonReward);

        // Return excess funds if any - do this last to prevent reentrancy
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }

    // Helper function to award tokens based on carbon credits
    function _awardTokens(address buyer, uint256 carbonCredits) private {
        // Calculate reward
        uint256 tokenReward = (carbonCredits * REWARD_PERCENTAGE * 10 ** 18) /
            100;

        // Safe check rewards don't exceed pool balance
        uint256 availableTokens = balances[rewardPool];
        if (tokenReward > availableTokens) {
            tokenReward = availableTokens; // Cap the reward to available tokens
        }

        if (tokenReward > 0) {
            // Update state before any potential callbacks
            balances[rewardPool] -= tokenReward;
            balances[buyer] += tokenReward;

            // Emit events
            emit Transfer(rewardPool, buyer, tokenReward);
            emit TokensRewarded(buyer, tokenReward);
        }
    }

    // Update a dish's inventory
    function updateInventory(
        uint _dishId,
        uint _newInventory
    ) public onlyOwner {
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];

        // Make sure the new inventory value is valid
        require(
            _newInventory >= dish.inventory - dish.availableInventory,
            "New inventory cannot be less than dishes already sold"
        );

        uint additionalInventory = _newInventory > dish.inventory
            ? _newInventory - dish.inventory
            : 0;

        // Update total inventory
        dish.inventory = _newInventory;

        // Only increase available inventory by the additional amount
        // This prevents resetting sold dishes to unsold
        dish.availableInventory += additionalInventory;

        // Safety check: available inventory should never exceed total inventory
        require(
            dish.availableInventory <= dish.inventory,
            "Available inventory cannot exceed total inventory"
        );

        emit InventoryUpdated(_dishId, _newInventory);

        if (dish.availableInventory > 0 && !dish.isActive) {
            dish.isActive = true;
            emit DishStatusChanged(_dishId, true);
        }
    }

    // Set dish status (active/inactive)
    function setDishStatus(uint _dishId, bool _isActive) public onlyOwner {
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];

        // Don't allow activating dishes with no inventory
        if (_isActive) {
            require(
                dish.availableInventory > 0,
                "Cannot activate dish with no inventory"
            );
        }

        if (dish.isActive != _isActive) {
            dish.isActive = _isActive;
            emit DishStatusChanged(_dishId, _isActive);
        }
    }

    // Get dishes bought for a specific dish or across all dishes
    function getTotalDishesBought(
        address _buyer,
        uint _dishId
    ) public view returns (uint) {
        require(initialized, "Restaurant not initialized");
        if (_dishId == type(uint).max) {
            uint total = 0;
            uint maxDishes = dishCount > 100 ? 100 : dishCount;

            for (uint i = 0; i < maxDishes; ) {
                uint batchEnd = i + 10 < maxDishes ? i + 10 : maxDishes;

                while (i < batchEnd) {
                    uint purchased = dishesBought[i][_buyer];
                    if (purchased > 0) {
                        total += purchased;
                    }
                    unchecked {
                        ++i;
                    }
                }

                if (gasleft() < 100000) {
                    return total;
                }
            }
            return total;
        } else {
            require(_dishId < dishCount, "Dish does not exist");
            return dishesBought[_dishId][_buyer];
        }
    }

    // Check if a dish has available inventory
    function hasAvailableInventory(uint _dishId) public view returns (bool) {
        require(initialized, "Restaurant not initialized");
        require(_dishId < dishCount, "Dish does not exist");
        return dishes[_dishId].availableInventory > 0;
    }

    // Get available inventory for a dish
    function getAvailableInventory(uint _dishId) public view returns (uint) {
        require(initialized, "Restaurant not initialized");
        require(_dishId < dishCount, "Dish does not exist");
        return dishes[_dishId].availableInventory;
    }

    // ERC20 standard functions
    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public nonReentrant returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public nonReentrant returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(
            allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        // Update state before potential callbacks
        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function allowance(
        address tokenOwner,
        address spender
    ) public view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    // Internal transfer function
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        // Update state before any potential callback
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // Get reward pool balance
    function getRewardPoolBalance() public view returns (uint256) {
        return balances[rewardPool];
    }

    // Send tokens from contract to owner (for distribution if needed)
    function withdrawTokens(uint256 amount) public onlyOwner nonReentrant {
        require(balances[rewardPool] >= amount, "Not enough tokens in pool");

        // Update state before transfer
        balances[rewardPool] -= amount;
        balances[owner] += amount;

        emit Transfer(rewardPool, owner, amount);
    }

    receive() external payable {}

    fallback() external payable {}
}
