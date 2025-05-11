// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGreenCoin {
    function balanceOf(address account) external view returns (uint256);

    function awardTokens(
        address from,
        address recipient,
        uint256 amount
    ) external;
}

contract GreenDish {
    struct Dish {
        string restaurantName;
        address restaurantOwner;
        string dishName;
        uint dishPrice;
        uint inventory;
        uint availableInventory;
        uint carbonCredits;
        string mainComponent;
        string supplySource;
        bool isActive;
    }

    uint256 public constant REWARD_PERCENTAGE = 10; // 10% of carbon credits
    uint256 public totalHistoricalCarbonCredits;
    uint public dishCount;
    IGreenCoin public tokenContract; // Token contract reference
    bool public tokenInitialized = true;
    bool private _locked; // Simple reentrancy protection

    // Customer loyalty tier system
    enum LoyaltyTier {
        BRONZE,
        SILVER,
        GOLD,
        PLATINUM
    }
    // Restaurant sustainability tier system - different from customer tiers
    enum RestaurantTier {
        GREEN_BASIC,
        GREEN_PLUS,
        GREEN_ELITE,
        GREEN_MASTER
    }

    // Restaurant data mappings
    mapping(uint => Dish) public dishes;
    mapping(uint => mapping(address => uint)) public dishesBought;

    /**
     * @notice Tier multiplier for token rewards (in basis points, 100 = 1x, 125 = 1.25x, etc.)
     * @dev This single mapping is used for both customer and restaurant tiers
     * Since both enum types have the same ordinal values (0,1,2,3), we can use a single mapping:
     * - BRONZE (0) shares multiplier with GREEN_BASIC (0)
     * - SILVER (1) shares multiplier with GREEN_PLUS (1)
     * - GOLD (2) shares multiplier with GREEN_ELITE (2)
     * - PLATINUM (3) shares multiplier with GREEN_MASTER (3)
     * This design simplifies the code while providing appropriate naming for each user type
     */
    mapping(uint256 => uint256) public tierMultipliers;

    mapping(address => LoyaltyTier) public customerTier;
    mapping(address => RestaurantTier) public restaurantTier;
    mapping(address => uint256) public customerCarbonCredits;
    mapping(address => uint256) public restaurantCarbonImpact;

    // Events
    event RestaurantDishCreated(
        uint dishId,
        string restaurantName,
        address restaurantOwner,
        string dishName
    );
    event TokenContractSet(address tokenAddress);
    event DishPurchased(uint dishId, address customer, uint numberOfDishes);
    event InventoryUpdated(uint dishId, uint newInventory);
    event DishStatusChanged(uint dishId, bool isActive);
    event TokensRewarded(address indexed recipient, uint256 amount);
    event RewardPoolDepleted(uint256 requestedAmount, uint256 remainingBalance);
    event CustomerLoyaltyTierUpdated(
        address indexed customer,
        LoyaltyTier tier,
        uint256 multiplier
    );
    event RestaurantLoyaltyTierUpdated(
        address indexed restaurant,
        RestaurantTier tier,
        uint256 multiplier
    );

    constructor(address _tokenAddress) {
        _locked = false;

        // Set up tier multipliers for both customer and restaurant tiers
        // These values apply to both customer tiers (BRONZE->PLATINUM)
        // and equivalent restaurant tiers (GREEN_BASIC->GREEN_MASTER)
        tierMultipliers[uint256(LoyaltyTier.BRONZE)] = 100; // 1.00x for BRONZE & GREEN_BASIC
        tierMultipliers[uint256(LoyaltyTier.SILVER)] = 110; // 1.10x for SILVER & GREEN_PLUS
        tierMultipliers[uint256(LoyaltyTier.GOLD)] = 125; // 1.25x for GOLD & GREEN_ELITE
        tierMultipliers[uint256(LoyaltyTier.PLATINUM)] = 150; // 1.50x for PLATINUM & GREEN_MASTER

        // Connect to the token contract
        require(_tokenAddress != address(0), "Token address cannot be zero");

        // Basic validation that this is a valid contract with the expected function
        IGreenCoin potentialToken = IGreenCoin(_tokenAddress);
        try potentialToken.balanceOf(address(this)) returns (uint256) {
            // If this doesn't revert, it's likely a valid token contract
            tokenContract = potentialToken;
            emit TokenContractSet(_tokenAddress);
        } catch {
            revert("Invalid token contract");
        }
    }

    // Simple reentrancy guard
    modifier nonReentrant() {
        require(!_locked, "ReentrancyGuard: reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    // Modifier to restrict function access to the restaurant owner
    modifier onlyRestaurantOwner(uint _dishId) {
        require(_dishId < dishCount, "Dish does not exist");
        require(
            msg.sender == dishes[_dishId].restaurantOwner,
            "Only the restaurant owner can call this function"
        );
        _;
    }

    // Create dish function for any restaurant
    function createDish(
        string calldata _restaurantName,
        string calldata _dishName,
        uint256 _dishPrice,
        uint256 _inventory,
        uint256 _carbonCredits,
        string calldata _mainComponent,
        string calldata _supplySource
    ) public returns (uint256) {
        require(
            bytes(_restaurantName).length > 0 &&
                bytes(_restaurantName).length <= 50,
            "Restaurant name must be between 1 and 50 characters"
        );
        require(
            bytes(_dishName).length > 0 && bytes(_dishName).length <= 50,
            "Dish name must be between 1 and 50 characters"
        );
        require(_dishPrice > 0, "Dish price must be greater than zero");
        require(_inventory <= 10000, "Inventory cannot exceed 10000 units");
        require(_carbonCredits <= 100, "Carbon credits cannot exceed 100");

        uint256 dishId = dishCount;
        dishes[dishId] = Dish({
            restaurantName: _restaurantName,
            restaurantOwner: msg.sender,
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
        emit RestaurantDishCreated(
            dishId,
            _restaurantName,
            msg.sender,
            _dishName
        );

        return dishId;
    }

    // Purchase a dish with optimized flow and security checks
    function purchaseDish(
        uint256 _dishId,
        uint256 _numberOfDishes
    ) public payable nonReentrant {
        require(tokenInitialized, "Token contract not initialized");
        require(_dishId < dishCount, "Dish does not exist");
        require(_numberOfDishes > 0, "Must purchase at least one dish");

        Dish storage dish = dishes[_dishId];

        require(
            msg.sender != dish.restaurantOwner,
            "Restaurant owner cannot purchase their own dish"
        );
        require(dish.isActive, "This dish is not available");
        require(
            _numberOfDishes <= dish.availableInventory,
            "Not enough dishes available"
        );

        uint256 totalPrice = dish.dishPrice * _numberOfDishes;
        require(msg.value >= totalPrice, "Insufficient funds");

        uint256 excess = msg.value - totalPrice;
        uint256 carbonReward = dish.carbonCredits * _numberOfDishes;

        // --- State changes after all validations (CEI pattern) ---

        // Update state
        dish.availableInventory -= _numberOfDishes;
        dishesBought[_dishId][msg.sender] += _numberOfDishes;

        // Update loyalty tiers and carbon tracking
        customerCarbonCredits[msg.sender] += carbonReward;
        restaurantCarbonImpact[dish.restaurantOwner] += carbonReward;
        totalHistoricalCarbonCredits += carbonReward;

        // Update loyalty tiers
        _updateCustomerLoyaltyTier(msg.sender);
        _updateRestaurantLoyaltyTier(dish.restaurantOwner);

        // Update dish status if inventory depleted
        if (dish.availableInventory == 0) {
            dish.isActive = false;
            emit DishStatusChanged(_dishId, false);
        }

        emit DishPurchased(_dishId, msg.sender, _numberOfDishes);

        // External interactions (after state changes)
        if (carbonReward > 0) {
            _awardTokens(msg.sender, carbonReward, dish.restaurantOwner);
        }

        // Send payment to restaurant owner
        (bool success, ) = payable(dish.restaurantOwner).call{
            value: totalPrice
        }("");
        require(success, "Payment to restaurant owner failed");

        // Return excess payment if any
        if (excess > 0) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: excess}(
                ""
            );
            require(refundSuccess, "Refund failed");
        }
    }

    // Helper function to award tokens based on carbon credits with loyalty multiplier
    function _awardTokens(
        address customer,
        uint256 carbonCredits,
        address restaurantOwner
    ) internal {
        require(tokenInitialized, "Token contract not initialized");
        require(customer != address(0), "Cannot reward zero address");
        require(
            restaurantOwner != address(0),
            "Restaurant cannot be zero address"
        );
        require(carbonCredits > 0, "No carbon credits to reward");

        // Apply appropriate tier multipliers from shared multiplier mapping
        // Each user type uses their appropriate tier enum but shares multiplier values
        uint256 customerTierMultiplier = tierMultipliers[
            uint256(customerTier[customer])
        ];
        uint256 restaurantTierMultiplier = tierMultipliers[
            uint256(restaurantTier[restaurantOwner])
        ];

        // Calculate base reward with diminishing returns
        uint256 baseReward = (carbonCredits * REWARD_PERCENTAGE * 10 ** 18) /
            100;

        if (totalHistoricalCarbonCredits > 0) {
            uint256 adjustmentFactor;
            if (totalHistoricalCarbonCredits >= 1000000) {
                adjustmentFactor = 500000; // 50% reduction at 1M+ credits
            } else {
                adjustmentFactor =
                    (totalHistoricalCarbonCredits * 500000) /
                    1000000;
            }
            baseReward = (baseReward * (1000000 - adjustmentFactor)) / 1000000;
        }

        // Split rewards between customer and restaurant
        uint256 customerReward = (baseReward * 80 * customerTierMultiplier) /
            10000; // 80% with tier multiplier
        uint256 restaurantReward = (baseReward *
            20 *
            restaurantTierMultiplier) / 10000; // 20% with tier multiplier

        if (customerReward == 0 && restaurantReward == 0) return;        // Check available balance in reward pool
        uint256 availableTokens = tokenContract.balanceOf(address(this));
        if (availableTokens == 0) {
            emit RewardPoolDepleted(customerReward + restaurantReward, 0);
            return;
        }
        if (customerReward + restaurantReward > availableTokens) {
            emit RewardPoolDepleted(
                customerReward + restaurantReward,
                availableTokens
            );

            uint256 totalReward = customerReward + restaurantReward;
            if (totalReward > 0) {
                customerReward =
                    (availableTokens * customerReward) /
                    totalReward;
            } else {
                customerReward = 0;
            }
            restaurantReward = availableTokens - customerReward;
        }
        if (customerReward > 0) {
            tokenContract.awardTokens(address(this), customer, customerReward);
            emit TokensRewarded(customer, customerReward);
        }

        if (restaurantReward > 0) {
            tokenContract.awardTokens(
                address(this),
                restaurantOwner,
                restaurantReward
            );
            emit TokensRewarded(restaurantOwner, restaurantReward);
        }
    }

    // Update customer loyalty tier based on accumulated carbon credits
    function _updateCustomerLoyaltyTier(address customer) internal {
        uint256 credits = customerCarbonCredits[customer];
        LoyaltyTier oldTier = customerTier[customer];
        LoyaltyTier newTier;

        // Assign tier based on accumulated carbon credits
        if (credits >= 5000) newTier = LoyaltyTier.PLATINUM;
        else if (credits >= 2000) newTier = LoyaltyTier.GOLD;
        else if (credits >= 500) newTier = LoyaltyTier.SILVER;
        else newTier = LoyaltyTier.BRONZE;

        // Only update and emit event if tier changed
        if (newTier != oldTier) {
            customerTier[customer] = newTier;
            emit CustomerLoyaltyTierUpdated(
                customer,
                newTier,
                tierMultipliers[uint256(newTier)]
            );
        }
    }

    // Update restaurant tier based on accumulated carbon impact
    function _updateRestaurantLoyaltyTier(address restaurant) internal {
        uint256 impact = restaurantCarbonImpact[restaurant];
        RestaurantTier oldTier = restaurantTier[restaurant];
        RestaurantTier newTier;

        // Assign tier based on accumulated carbon impact
        if (impact >= 15000) newTier = RestaurantTier.GREEN_MASTER;
        else if (impact >= 7500) newTier = RestaurantTier.GREEN_ELITE;
        else if (impact >= 2500) newTier = RestaurantTier.GREEN_PLUS;
        else newTier = RestaurantTier.GREEN_BASIC;

        // Only update and emit event if tier changed
        if (newTier != oldTier) {
            restaurantTier[restaurant] = newTier;
            emit RestaurantLoyaltyTierUpdated(
                restaurant,
                newTier,
                tierMultipliers[uint256(newTier)]
            );
        }
    }

    // Get customer loyalty tier info
    function getCustomerLoyaltyInfo(
        address customer
    )
        public
        view
        returns (
            LoyaltyTier tier,
            uint256 multiplier,
            uint256 carbonCredits,
            uint256 nextTierThreshold
        )
    {
        tier = customerTier[customer];
        multiplier = tierMultipliers[uint256(tier)];
        carbonCredits = customerCarbonCredits[customer];

        // Calculate credits needed for next tier
        if (tier == LoyaltyTier.BRONZE) {
            nextTierThreshold = 500; // Silver threshold
        } else if (tier == LoyaltyTier.SILVER) {
            nextTierThreshold = 2000; // Gold threshold
        } else if (tier == LoyaltyTier.GOLD) {
            nextTierThreshold = 5000; // Platinum threshold
        } else {
            nextTierThreshold = 0; // Already at highest tier
        }
    }

    // Get restaurant sustainability tier info
    function getRestaurantLoyaltyInfo(
        address restaurant
    )
        public
        view
        returns (
            RestaurantTier tier,
            uint256 multiplier,
            uint256 carbonImpact,
            uint256 nextTierThreshold
        )
    {
        tier = restaurantTier[restaurant];
        multiplier = tierMultipliers[uint256(tier)];
        carbonImpact = restaurantCarbonImpact[restaurant];

        // Calculate impact needed for next tier
        if (tier == RestaurantTier.GREEN_BASIC) {
            nextTierThreshold = 2500; // Green Plus threshold
        } else if (tier == RestaurantTier.GREEN_PLUS) {
            nextTierThreshold = 7500; // Green Elite threshold
        } else if (tier == RestaurantTier.GREEN_ELITE) {
            nextTierThreshold = 15000; // Green Master threshold
        } else {
            nextTierThreshold = 0; // Already at highest tier
        }
    }

    // Update a dish's inventory with improved validation and efficiency
    function updateInventory(
        uint256 _dishId,
        uint256 _newInventory
    ) public onlyRestaurantOwner(_dishId) {
        require(_newInventory <= 10000, "Inventory cannot exceed 10000 units");

        Dish storage dish = dishes[_dishId];

        // Calculate how many dishes have been sold so far
        uint256 soldDishes = dish.inventory - dish.availableInventory;
        require(
            _newInventory >= soldDishes,
            "New inventory must cover already sold dishes"
        );

        // Store original status for comparison
        bool wasActive = dish.isActive;

        // Update dish inventory state
        dish.inventory = _newInventory;
        dish.availableInventory = _newInventory - soldDishes;

        emit InventoryUpdated(_dishId, _newInventory);

        // Handle status changes if needed
        if (!wasActive && dish.availableInventory > 0) {
            dish.isActive = true;
            emit DishStatusChanged(_dishId, true);
        } else if (wasActive && dish.availableInventory == 0) {
            dish.isActive = false;
            emit DishStatusChanged(_dishId, false);
        }
    }

    // Set dish status (active/inactive) with improved validation
    function setDishStatus(
        uint256 _dishId,
        bool _isActive
    ) public onlyRestaurantOwner(_dishId) {
        Dish storage dish = dishes[_dishId];

        // If attempting to activate, ensure dish has inventory
        if (_isActive) {
            require(
                dish.availableInventory > 0,
                "Cannot activate dish with no available inventory"
            );
        }

        // Only update if status is actually changing to save gas
        if (dish.isActive != _isActive) {
            dish.isActive = _isActive;
            emit DishStatusChanged(_dishId, _isActive);
        }
    }

    // Get detailed information about a specific dish
    function getDishInfo(
        uint256 _dishId
    )
        public
        view
        returns (
            string memory restaurantName,
            address restaurantOwner,
            string memory dishName,
            uint256 dishPrice,
            uint256 availableInventory,
            uint256 carbonCredits,
            string memory mainComponent,
            string memory supplySource,
            bool isActive
        )
    {
        require(_dishId < dishCount, "Dish does not exist");
        Dish storage dish = dishes[_dishId];

        return (
            dish.restaurantName,
            dish.restaurantOwner,
            dish.dishName,
            dish.dishPrice,
            dish.availableInventory,
            dish.carbonCredits,
            dish.mainComponent,
            dish.supplySource,
            dish.isActive
        );
    }

    // Get all dish IDs created by a specific restaurant owner
    function getRestaurantDishes(
        address _restaurantOwner
    ) public view returns (uint256[] memory) {
        require(
            _restaurantOwner != address(0),
            "Invalid restaurant owner address"
        );

        // First pass: count dishes owned by this restaurant
        uint256 count = 0;
        for (uint256 i = 0; i < dishCount; i++) {
            if (dishes[i].restaurantOwner == _restaurantOwner) {
                count++;
            }
        }

        // If no dishes found, return empty array early to save gas
        if (count == 0) {
            return new uint256[](0);
        }

        // Second pass: populate array with dish IDs
        uint256[] memory ownerDishes = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < dishCount; i++) {
            if (dishes[i].restaurantOwner == _restaurantOwner) {
                ownerDishes[index] = i;
                index++;
            }
        }

        return ownerDishes;
    }

    // Get total purchases for a specific dish by the caller
    function getDishPurchaseCount(
        uint256 _dishId
    ) public view returns (uint256) {
        require(_dishId < dishCount, "Dish does not exist");
        return dishesBought[_dishId][msg.sender];
    }

    receive() external payable {}

    fallback() external payable {}
}
