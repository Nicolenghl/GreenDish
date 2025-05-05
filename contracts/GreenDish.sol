// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenDish {
    // State Variables
    string public dishName;
    uint public dishPrice;
    uint public Inventory;
    uint public availableInventory;
    uint public CarbonCredits;
    string public mainComponent;
    string public SupplySource;
    mapping(address => uint) public DishesBought;
    address public owner;

    // Event declaration
    event DishPurchased(address buyer, uint numberOfDishes);
    event InventoryUpdated(uint newInventory);

    // Constructor
    constructor(
        string memory _dishName,
        uint _dishPrice,
        uint _Inventory,
        uint _CarbonCredits,
        string memory _mainComponent,
        string memory _SupplySource
    ) {
        dishName = _dishName;
        dishPrice = _dishPrice;
        Inventory = _Inventory;
        availableInventory = _Inventory;
        CarbonCredits = _CarbonCredits;
        mainComponent = _mainComponent;
        SupplySource = _SupplySource;
        owner = msg.sender;
    }

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Functions
    function purchaseDish(uint _numberOfDishes) public payable {
        // Error handling
        require(
            _numberOfDishes <= availableInventory,
            "Not enough dishes available"
        );
        require(
            msg.value >= dishPrice * _numberOfDishes,
            "Insufficient funds sent"
        );

        // Update state
        availableInventory -= _numberOfDishes;
        DishesBought[msg.sender] += _numberOfDishes;

        // Emit event
        emit DishPurchased(msg.sender, _numberOfDishes);

        // Return excess funds if any
        uint excess = msg.value - (dishPrice * _numberOfDishes);
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }

    // New function to update inventory
    function updateInventory(uint _newInventory) public onlyOwner {
        // Update both total and available inventory
        uint additionalInventory = _newInventory > Inventory
            ? _newInventory - Inventory
            : 0;
        Inventory = _newInventory;

        // Only increase available inventory by the additional amount
        // This ensures sold tickets aren't being reset
        availableInventory += additionalInventory;

        // Emit event for the update
        emit InventoryUpdated(_newInventory);
    }

    // Check if there's inventory available
    function hasAvailableInventory() public view returns (bool) {
        return availableInventory > 0;
    }

    function getAvailableSeats() public view returns (uint) {
        return availableInventory;
    }

    function getTotalDishesBought(address _buyer) public view returns (uint) {
        return DishesBought[_buyer];
    }
}