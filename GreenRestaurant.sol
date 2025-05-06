// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenRestaurant {
    // Restaurant information
    string public restaurantName;
    address public owner;

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

    // Token Variables
    string public constant name = "GreenCoin";
    string public constant symbol = "GRC";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000 * 10 ** 18; // Fixed total supply
    uint256 public constant REWARD_PERCENTAGE = 10; // 10% of carbon credits

    // ERC20 token mappings
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    // Restaurant data mappings
    mapping(uint => Dish) public dishes;
    mapping(uint => mapping(address => uint)) public dishesBought;
    uint public dishCount;

    // Reward pool address (contract itself)
    address public immutable rewardPool;

    // Events
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

    // Constructor
    constructor(string memory _restaurantName) {
        restaurantName = _restaurantName;
        owner = msg.sender;
        dishCount = 0;

        // Set up reward pool as the contract itself
        rewardPool = address(this);

        // Create initial token distribution (70% owner, 30% reward pool)
        uint256 ownerAmount = (TOTAL_SUPPLY * 70) / 100;
        uint256 rewardAmount = TOTAL_SUPPLY - ownerAmount;

        balances[owner] = ownerAmount;
        balances[rewardPool] = rewardAmount;

        emit Transfer(address(0), owner, ownerAmount);
        emit Transfer(address(0), rewardPool, rewardAmount);
    }

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Create a new dish
    function createDish(
        string memory _dishName,
        uint _dishPrice,
        uint _inventory,
        uint _carbonCredits,
        string memory _mainComponent,
        string memory _supplySource
    ) public onlyOwner returns (uint) {
        uint dishId = dishCount;
        dishes[dishId] = Dish({
            dishName: _dishName,
            dishPrice: _dishPrice,
            inventory: _inventory,
            availableInventory: _inventory,
            carbonCredits: _carbonCredits,
            mainComponent: _mainComponent,
            supplySource: _supplySource,
            isActive: true
        });

        dishCount++;
        emit DishCreated(dishId, _dishName);
        return dishId;
    }

    // Purchase a dish
    function purchaseDish(uint _dishId, uint _numberOfDishes) public payable {
        Dish storage dish = dishes[_dishId];

        // Error handling
        require(_dishId < dishCount, "Dish does not exist");
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

        // Update state
        dish.availableInventory -= _numberOfDishes;
        dishesBought[_dishId][msg.sender] += _numberOfDishes;

        // Emit event
        emit DishPurchased(_dishId, msg.sender, _numberOfDishes);

        // Return excess funds if any
        uint excess = msg.value - (dish.dishPrice * _numberOfDishes);
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        // If inventory is now zero, set isActive to false
        if (dish.availableInventory == 0) {
            dish.isActive = false;
            emit DishStatusChanged(_dishId, false);
        }

        // Award tokens based on carbon credits
        _awardTokens(msg.sender, dish.carbonCredits * _numberOfDishes);
    }

    // Helper function to award tokens based on carbon credits
    function _awardTokens(address buyer, uint256 carbonCredits) private {
        // Calculate reward based on carbon credits
        uint256 tokenReward = (carbonCredits * REWARD_PERCENTAGE * 10 ** 18) /
            100;

        // Transfer tokens from reward pool if sufficient balance
        if (balances[rewardPool] >= tokenReward) {
            balances[rewardPool] -= tokenReward;
            balances[buyer] += tokenReward;
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

        // Calculate additional inventory
        uint additionalInventory = _newInventory > dish.inventory
            ? _newInventory - dish.inventory
            : 0;

        // Update inventory
        dish.inventory = _newInventory;
        dish.availableInventory += additionalInventory;

        // Emit event
        emit InventoryUpdated(_dishId, _newInventory);

        // Update dish status if needed
        if (dish.availableInventory > 0 && !dish.isActive) {
            dish.isActive = true;
            emit DishStatusChanged(_dishId, true);
        }
    }

    // Set dish status (active/inactive)
    function setDishStatus(uint _dishId, bool _isActive) public onlyOwner {
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];

        // Only update if status is changing
        if (dish.isActive != _isActive) {
            dish.isActive = _isActive;
            emit DishStatusChanged(_dishId, _isActive);
        }
    }

    // Check if a dish has available inventory
    function hasAvailableInventory(uint _dishId) public view returns (bool) {
        require(_dishId < dishCount, "Dish does not exist");
        return dishes[_dishId].availableInventory > 0;
    }

    // Get available inventory for a dish
    function getAvailableInventory(uint _dishId) public view returns (uint) {
        require(_dishId < dishCount, "Dish does not exist");
        return dishes[_dishId].availableInventory;
    }

    // Get dishes bought for a specific dish
    function getTotalDishesBought(
        uint _dishId,
        address _buyer
    ) public view returns (uint) {
        require(_dishId < dishCount, "Dish does not exist");
        return dishesBought[_dishId][_buyer];
    }

    // Get total dishes bought across all dishes
    function getTotalDishesBoughtByUser(
        address _buyer
    ) public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < dishCount; i++) {
            total += dishesBought[i][_buyer];
        }
        return total;
    }

    // ERC20 standard functions
    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
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
    ) public returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(
            allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return allowances[owner][spender];
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

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // Get reward pool balance
    function getRewardPoolBalance() public view returns (uint256) {
        return balances[rewardPool];
    }

    // Handle direct ETH transfers
    receive() external payable {}

    fallback() external payable {}
}
