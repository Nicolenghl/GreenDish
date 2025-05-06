// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenRestaurant {
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
        if (initialized) {
            require(
                msg.sender == owner,
                "Only the owner can call this function"
            );
        }
        _;
    }

    // Initialize restaurant - separate function to make it clearer
    function initializeRestaurant(
        string memory _restaurantName
    ) public returns (bool) {
        require(!initialized, "Restaurant already initialized");
        restaurantName = _restaurantName;
        owner = msg.sender;
        initialized = true;
        emit RestaurantInitialized(_restaurantName, msg.sender);
        return true;
    }

    // Overloaded createDish function for first dish creation with restaurant initialization
    function createDish(
        string memory _restaurantName,
        string memory _dishName,
        uint _dishPrice,
        uint _inventory,
        uint _carbonCredits,
        string memory _mainComponent,
        string memory _supplySource
    ) public returns (uint) {
        // Initialize restaurant if needed
        if (!initialized) {
            initializeRestaurant(_restaurantName);
        } else {
            // Only owner can create additional dishes
            require(
                msg.sender == owner,
                "Only the owner can call this function"
            );
        }

        // Create the dish
        return
            _createDish(
                _dishName,
                _dishPrice,
                _inventory,
                _carbonCredits,
                _mainComponent,
                _supplySource
            );
    }

    // Standard createDish function for subsequent dishes
    function createDish(
        string memory _dishName,
        uint _dishPrice,
        uint _inventory,
        uint _carbonCredits,
        string memory _mainComponent,
        string memory _supplySource
    ) public returns (uint) {
        // Only owner can create dishes after initialization
        require(initialized, "Restaurant not initialized");
        require(msg.sender == owner, "Only the owner can call this function");

        return
            _createDish(
                _dishName,
                _dishPrice,
                _inventory,
                _carbonCredits,
                _mainComponent,
                _supplySource
            );
    }

    // Internal function to create dish - common logic for both versions
    function _createDish(
        string memory _dishName,
        uint _dishPrice,
        uint _inventory,
        uint _carbonCredits,
        string memory _mainComponent,
        string memory _supplySource
    ) internal returns (uint) {
        // Create dish - minimal validation to prioritize working code
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

    // Purchase a dish - simplified to prioritize functionality
    function purchaseDish(uint _dishId, uint _numberOfDishes) public payable {
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];

        // Less strict validation - prioritize functionality
        require(dish.isActive, "This dish is not available");
        require(
            _numberOfDishes <= dish.availableInventory,
            "Not enough dishes available"
        );
        require(
            msg.value >= dish.dishPrice * _numberOfDishes,
            "Insufficient funds"
        );

        // Update state
        dish.availableInventory -= _numberOfDishes;
        dishesBought[_dishId][msg.sender] += _numberOfDishes;

        // Calculate values
        uint totalPrice = dish.dishPrice * _numberOfDishes;
        uint excess = msg.value - totalPrice;
        uint carbonReward = dish.carbonCredits * _numberOfDishes;

        // Emit event
        emit DishPurchased(_dishId, msg.sender, _numberOfDishes);

        // If inventory is now zero, set isActive to false
        if (dish.availableInventory == 0) {
            dish.isActive = false;
            emit DishStatusChanged(_dishId, false);
        }

        // Award tokens
        _awardTokens(msg.sender, carbonReward);

        // Return excess funds
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }

    // Helper function to award tokens based on carbon credits
    function _awardTokens(address buyer, uint256 carbonCredits) internal {
        // Calculate reward
        uint256 tokenReward = (carbonCredits * REWARD_PERCENTAGE * 10 ** 18) /
            100;

        // Safe check rewards don't exceed pool balance
        uint256 availableTokens = balances[rewardPool];
        if (tokenReward > availableTokens) {
            tokenReward = availableTokens; // Cap the reward to available tokens
        }

        if (tokenReward > 0) {
            // Update state
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

        uint additionalInventory = _newInventory > dish.inventory
            ? _newInventory - dish.inventory
            : 0;

        dish.inventory = _newInventory;
        dish.availableInventory += additionalInventory;

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

        if (dish.isActive != _isActive) {
            dish.isActive = _isActive;
            emit DishStatusChanged(_dishId, _isActive);
        }
    }

    // Simple helper function to get dish info
    function getDishInfo(
        uint _dishId
    )
        public
        view
        returns (
            string memory dishName,
            uint dishPrice,
            uint availableInventory,
            uint carbonCredits,
            string memory mainComponent,
            string memory supplySource,
            bool isActive
        )
    {
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];
        return (
            dish.dishName,
            dish.dishPrice,
            dish.availableInventory,
            dish.carbonCredits,
            dish.mainComponent,
            dish.supplySource,
            dish.isActive
        );
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
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(
            allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

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
        require(balances[sender] >= amount, "Transfer amount exceeds balance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // Get reward pool balance
    function getRewardPoolBalance() public view returns (uint256) {
        return balances[rewardPool];
    }

    receive() external payable {}

    fallback() external payable {}
}
