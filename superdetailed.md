# GreenDish: Blockchain-Based Sustainable Dining Platform

## Table of Contents
1. [Project Overview](#project-overview)
2. [Features](#features)
3. [File Structure](#file-structure)
4. [Technical Stack](#technical-stack)
5. [Setup & Installation](#setup--installation)
6. [Running the Application](#running-the-application)
7. [Project Architecture](#project-architecture)
8. [Smart Contract Overview](#smart-contract-overview)
9. [Frontend Components](#frontend-components)
10. [Testing & Debugging](#testing--debugging)
11. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
12. [Future Improvements](#future-improvements)

## Project Overview

GreenDish is a blockchain-based sustainable dining platform that incentivizes eco-friendly dining choices through tokenized rewards and transparent carbon credit tracking. By leveraging blockchain technology, GreenDish creates a verifiable and transparent system where:

- Restaurants can showcase their sustainable dishes and earn loyalty status
- Customers can make environmentally conscious dining decisions with real-time carbon credit tracking
- A tokenized rewards system (GreenCoin) reinforces sustainable choices

The platform addresses the critical need for sustainability in the food industry by providing transparent metrics and rewards that encourage both restaurants and customers to prioritize environmentally friendly options.

## Features

### For Restaurants
- Register sustainable dishes with carbon credit ratings
- Track inventory and sales
- Earn loyalty tier status based on carbon impact
- Monitor restaurant sustainability metrics
- Receive GreenCoin tokens for maintaining eco-friendly options

### For Customers
- Browse and purchase sustainable food options
- Track personal carbon credit impact
- Earn loyalty tier upgrades based on sustainable purchases
- Collect GreenCoin (GRC) tokens as rewards
- View purchase history and environmental impact

### Smart Contract Features
- Tokenized rewards using ERC-20 standard (GreenCoin)
- Transparent tracking of carbon credits
- Multi-tiered loyalty system for both restaurants and customers
- Secure dish ownership and purchase verification
- Automated reward distribution

## File Structure

```
/GreenDish/
├── contracts/              # Smart contracts (Solidity)
│   ├── GreenDish.sol       # Main contract for restaurant/dish management
│   └── GreenCoin.sol       # ERC-20 token implementation for rewards
├── scripts/                # Deployment scripts
│   ├── deploy.js           # Main deployment script
│   └── verify.js           # Contract verification script (optional)
├── test/                   # Contract test files
│   ├── GreenDish.test.js   # Tests for GreenDish contract
│   └── GreenCoin.test.js   # Tests for GreenCoin contract
├── public/                 # Frontend web application
│   ├── index.html          # Landing page
│   ├── marketplace.html    # Browse and purchase dishes
│   ├── customer-profile.html # Customer profile/dashboard
│   ├── restaurant-portal.html # Restaurant management portal
│   ├── js/
│   │   ├── contract-config.js # Contract addresses and configuration
│   │   └── web3-utils.js      # Web3 helper functions (if applicable)
│   └── css/                # Stylesheets (if separate from HTML)
├── hardhat.config.js       # Hardhat configuration
├── start-local.sh          # Script to start local development environment
├── package.json            # Project dependencies
├── deployments.json        # Contract deployment information for the frontend
└── README.md               # Project documentation (this file)
```

## Technical Stack

### Blockchain & Smart Contracts
- **Solidity**: Programming language for Ethereum smart contracts
- **Hardhat**: Development environment for compiling, deploying, and testing
- **Ethers.js/Web3.js**: JavaScript libraries for interacting with the Ethereum blockchain

### Frontend
- **HTML/CSS/JavaScript**: Core web technologies
- **MetaMask**: Wallet integration for blockchain transactions
- **HTTP-Server**: Simple static file server for development

### Development Tools
- **Node.js**: JavaScript runtime for development
- **npm/yarn**: Package management

## Setup & Installation

### Prerequisites
- Node.js (v16+ recommended)
- npm or yarn
- MetaMask browser extension
- Git (optional, for cloning the repository)

### Installation Steps

1. **Clone or download the repository**
   ```bash
   git clone <repository-url> GreenDish
   cd GreenDish
   ```
   Or extract the ZIP file to a directory named "GreenDish"

2. **Install dependencies**
   ```bash
   npm install
   ```
   This will install all the required packages including Hardhat, Ethers.js, and other dependencies.

3. **Install MetaMask**
   - Install the [MetaMask browser extension](https://metamask.io/download.html)
   - Create a wallet or import an existing wallet
   - MetaMask will be used to interact with the blockchain

## Running the Application

### Step 1: Start the Local Blockchain and Deploy Contracts

The project includes a script (`start-local.sh`) that handles starting a local blockchain network, deploying the contracts, and starting the web server. If you encounter any issues, you can also run these steps manually.

#### Option 1: Using the start script (recommended)

1. **Make the script executable (Unix/Mac only)**
   ```bash
   chmod +x start-local.sh
   ```

2. **Run the script**
   ```bash
   ./start-local.sh
   ```
   
   The script will:
   - Start a Hardhat node (local blockchain)
   - Deploy the GreenCoin and GreenDish contracts
   - Allocate initial tokens
   - Update contract addresses in the frontend files
   - Start the HTTP server

#### Option 2: Manual setup

If the script doesn't work, or if you're on Windows, you can run these steps manually:

1. **Start Hardhat node in a separate terminal**
   ```bash
   npx hardhat node
   ```
   This will start the local blockchain at http://localhost:8545 and display 20 test accounts with private keys.

2. **Deploy contracts in another terminal**
   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```
   This deploys the contracts to your local blockchain.

3. **Start the HTTP server**
   ```bash
   npx http-server ./public -p 3000
   ```
   This will serve the frontend files at http://localhost:3000.

### Step 2: Configure MetaMask

1. **Connect MetaMask to the local blockchain**
   - Open MetaMask
   - Click the network dropdown (usually says "Ethereum Mainnet")
   - Select "Add Network"
   - Enter the following details:
     - Network Name: Hardhat Local
     - New RPC URL: http://localhost:8545
     - Chain ID: 31337
     - Currency Symbol: ETH
   - Click "Save"

2. **Import a test account**
   - In MetaMask, click on your account icon, then "Import Account"
   - Copy one of the private keys from the Hardhat console output
   - Paste it into MetaMask
   - Click "Import"
   - You should now have 10,000 test ETH in your account

### Step 3: Access the application

1. **Open your browser** and go to http://localhost:3000
2. **Connect your wallet** when prompted by clicking the "Connect Wallet" button
3. You can now interact with the GreenDish platform using the test account

## Project Architecture

### Contract Architecture

GreenDish uses two main smart contracts:

1. **GreenCoin (GRC)**: An ERC-20 token used for rewards
   - Standard token functionality (transfer, balanceOf, etc.)
   - Additional functions for reward allocation

2. **GreenDish**: The main platform contract
   - Manages restaurants, dishes, and carbon credits
   - Handles purchase logic and inventory tracking
   - Implements loyalty tier systems for both restaurants and customers
   - Distributes GreenCoin rewards based on carbon credits

### Data Flow

1. Restaurant owners register dishes with sustainable attributes
2. Customers browse and purchase dishes
3. Smart contracts verify and record purchases
4. Carbon credits are tracked for both restaurants and customers
5. Loyalty tiers are updated based on accumulated carbon impact
6. GreenCoin rewards are distributed based on carbon credits

## Smart Contract Overview

### GreenCoin.sol

An ERC-20 token with additional functionality for ecosystem allocations:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GreenCoin is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1 million tokens
    uint256 public constant ECOSYSTEM_PERCENTAGE = 30; // 30% for ecosystem rewards
    
    address public rewardPool;
    
    constructor() ERC20("GreenCoin", "GRC") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    function allocateToRewardPool(address _rewardPool) external onlyOwner {
        require(rewardPool == address(0), "Reward pool already set");
        rewardPool = _rewardPool;
        
        // Calculate and transfer ecosystem allocation
        uint256 ecosystemAllocation = (INITIAL_SUPPLY * ECOSYSTEM_PERCENTAGE) / 100;
        _transfer(owner(), rewardPool, ecosystemAllocation);
    }
    
    // Additional reward functions can be added here
}
```

### GreenDish.sol

The main contract managing the platform's functionality:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GreenCoin.sol";

contract GreenDish {
    // Enums for loyalty tiers
    enum CustomerTier { BRONZE, SILVER, GOLD, PLATINUM }
    enum RestaurantTier { GREEN_BASIC, GREEN_PLUS, GREEN_ELITE, GREEN_MASTER }
    
    // Dish struct
    struct Dish {
        string restaurantName;
        address restaurantOwner;
        string name;
        uint256 price;
        uint256 inventory;
        uint256 carbonCredits;
        string mainComponent;
        string supplySource;
        bool isActive;
    }
    
    // State variables
    GreenCoin public tokenContract;
    bool public tokenInitialized;
    uint256 public dishCount;
    mapping(uint256 => Dish) public dishes;
    mapping(address => uint256[]) public restaurantDishes;
    mapping(uint256 => mapping(address => uint256)) public dishesBought;
    
    // Loyalty tracking
    mapping(address => uint256) public customerCarbonCredits;
    mapping(address => uint256) public restaurantCarbonImpact;
    
    // Events
    event DishCreated(uint256 dishId, address owner, string name);
    event DishPurchased(uint256 dishId, address buyer, uint256 quantity);
    event InventoryUpdated(uint256 dishId, uint256 newInventory);
    
    // Tier thresholds and multipliers
    uint256[] public customerTierThresholds = [0, 500, 2000, 5000];
    uint256[] public restaurantTierThresholds = [0, 2500, 10000, 25000];
    uint256[] public tierMultipliers = [100, 110, 125, 150]; // Base 100 = 1.0x
    
    // Constructor and initialization functions
    // ...

    // Create a new dish
    function createDish(
        string memory _restaurantName,
        string memory _name,
        uint256 _price,
        uint256 _inventory,
        uint256 _carbonCredits,
        string memory _mainComponent,
        string memory _supplySource
    ) external {
        require(_inventory > 0, "Inventory must be greater than zero");
        require(_carbonCredits <= 100, "Carbon credits must be 0-100");
        
        uint256 dishId = dishCount;
        
        dishes[dishId] = Dish({
            restaurantName: _restaurantName,
            restaurantOwner: msg.sender,
            name: _name,
            price: _price,
            inventory: _inventory,
            carbonCredits: _carbonCredits,
            mainComponent: _mainComponent,
            supplySource: _supplySource,
            isActive: true
        });
        
        restaurantDishes[msg.sender].push(dishId);
        dishCount++;
        
        emit DishCreated(dishId, msg.sender, _name);
    }
    
    // Purchase dish function
    function purchaseDish(uint256 _dishId, uint256 _quantity) external payable {
        Dish storage dish = dishes[_dishId];
        
        require(dish.isActive, "Dish is not active");
        require(dish.restaurantOwner != msg.sender, "Restaurant owners cannot purchase their own dishes");
        require(dish.inventory >= _quantity, "Not enough inventory");
        require(msg.value >= dish.price * _quantity, "Insufficient payment");
        
        // Process purchase
        dish.inventory -= _quantity;
        dishesBought[_dishId][msg.sender] += _quantity;
        
        // Transfer payment to restaurant
        payable(dish.restaurantOwner).transfer(msg.value);
        
        // Update carbon credits for both customer and restaurant
        uint256 carbonImpact = dish.carbonCredits * _quantity;
        customerCarbonCredits[msg.sender] += carbonImpact;
        restaurantCarbonImpact[dish.restaurantOwner] += carbonImpact;
        
        // Reward tokens if token contract is initialized
        if (tokenInitialized) {
            // Get customer tier multiplier
            CustomerTier customerTier = getCustomerTier(msg.sender);
            uint256 multiplier = tierMultipliers[uint256(customerTier)];
            
            // Calculate reward with multiplier (10% of carbon impact * multiplier)
            uint256 reward = (carbonImpact * multiplier * 10**18) / 1000; // 0.1 tokens per credit with multiplier
            tokenContract.transfer(msg.sender, reward);
        }
        
        emit DishPurchased(_dishId, msg.sender, _quantity);
    }
    
    // Get dish information
    function getDishInfo(uint256 _dishId) external view returns (
        string memory, address, string memory, uint256, uint256, uint256, string memory, string memory, bool
    ) {
        Dish storage dish = dishes[_dishId];
        return (
            dish.restaurantName,
            dish.restaurantOwner,
            dish.name,
            dish.price,
            dish.inventory,
            dish.carbonCredits,
            dish.mainComponent,
            dish.supplySource,
            dish.isActive
        );
    }
    
    // Additional functions for inventory management, loyalty tiers, etc.
    // ...
}
```

## Frontend Components

### index.html (Landing Page)
- Project introduction and value proposition
- User journey explanation
- Loyalty tier information
- Navigation to marketplace and profiles

### marketplace.html
- Browse available dishes
- Filter by restaurant, carbon credits, etc.
- Purchase dishes with MetaMask integration
- View dish details including sustainability metrics

### customer-profile.html
- View purchase history
- Track carbon credit impact
- Monitor loyalty tier and progress
- View and manage GreenCoin token balance

### restaurant-portal.html
- Create and manage sustainable dishes
- Track inventory and sales
- Monitor restaurant sustainability metrics
- View customer purchase information
- Generate carbon credit reports

### contract-config.js
Contains contract addresses and ABIs for frontend interaction with the blockchain:

```javascript
// Contract configuration for frontend
const GreenDishConfig = {
    // Contract addresses (updated by deployment scripts)
    addresses: {
        GreenCoin: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
        GreenDish: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
    },
    
    // ABIs
    greenDishABI: [...], // Abbreviated for README
    greenCoinABI: [...], // Abbreviated for README
    
    // Contract instances
    greenDishContract: null,
    greenCoinContract: null,
    
    // Initialize web3 and contract instances
    async initWeb3() {
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum);
            try {
                // Initialize contract instances
                this.greenDishContract = new window.web3.eth.Contract(
                    this.greenDishABI,
                    this.addresses.GreenDish
                );
                
                this.greenCoinContract = new window.web3.eth.Contract(
                    this.greenCoinABI,
                    this.addresses.GreenCoin
                );
                
                return true;
            } catch (error) {
                console.error("Error initializing contracts:", error);
                return false;
            }
        } else {
            console.error("No ethereum browser extension detected");
            return false;
        }
    },
    
    // Load deployment addresses from file
    async loadDeploymentAddresses() {
        try {
            const response = await fetch('/deployments.json');
            if (response.ok) {
                const data = await response.json();
                this.addresses.GreenCoin = data.greenCoinAddress;
                this.addresses.GreenDish = data.greenDishAddress;
                console.log("Loaded contract addresses:", this.addresses);
                return true;
            }
            return false;
        } catch (error) {
            console.error("Error loading deployment addresses:", error);
            return false;
        }
    }
};
```

## Testing & Debugging

### Manual Testing

1. **Test Accounts**: The Hardhat node provides 20 test accounts with 10,000 ETH each. Use different accounts to test restaurant and customer interactions.

2. **Restaurant Flow**:
   - Connect with Account #0 (default deployer account)
   - Go to restaurant-portal.html
   - Create dishes with varying carbon credits
   - Update inventory and monitor stats

3. **Customer Flow**:
   - Connect with Account #1 or another account
   - Go to marketplace.html
   - Purchase dishes
   - Check customer-profile.html to see purchase history and carbon credits

4. **Common Test Cases**:
   - Verify that restaurants cannot purchase their own dishes
   - Ensure inventory updates properly after purchases
   - Check that carbon credits are awarded correctly
   - Verify loyalty tier upgrades with sufficient credits
   - Test GreenCoin token rewards

### Automated Testing

Run automated tests for the smart contracts:

```bash
npx hardhat test
```

### Debugging

1. **MetaMask Issues**:
   - If transactions fail, check the MetaMask error message
   - Ensure you're connected to the correct network (Localhost 8545)
   - Reset your account in MetaMask settings if issues persist

2. **Contract Errors**:
   - Check the browser console for error messages
   - Review the Hardhat node console for transaction details
   - Ensure contract addresses match between frontend and blockchain

3. **Server Issues**:
   - If the HTTP server fails to start with "EADDRINUSE" errors:
     ```bash
     # Find and kill the process using the port
     lsof -i :3000
     kill -9 [PID]
     # Or use a different port
     npx http-server ./public -p 8080
     ```

## Common Issues & Troubleshooting

### MetaMask Configuration

**Issue**: "No ethereum provider found" or "Cannot read properties of undefined"
**Solution**: Ensure MetaMask is installed and connected to the correct network (Localhost 8545)

### Contract Deployment

**Issue**: "Cannot find contract at address"
**Solution**: 
1. Check the Hardhat console for the correct contract addresses
2. Verify that contract-config.js has the correct addresses
3. Re-deploy contracts if necessary:
   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

### Port Conflicts

**Issue**: "EADDRINUSE: address already in use"
**Solution**:
1. Find the process using the port:
   ```bash
   lsof -i :8545  # For Hardhat node
   lsof -i :3000  # For HTTP server
   ```
2. Kill the process:
   ```bash
   kill -9 [PID]
   ```
3. Or use different ports:
   ```bash
   # For Hardhat node
   npx hardhat node --port 8546
   
   # For HTTP server
   npx http-server ./public -p 8080
   ```

### Transaction Failures

**Issue**: "Transaction failed" or "Gas estimation failed"
**Solution**:
1. Check the transaction parameters
2. Ensure sufficient ETH balance
3. For restaurant owners buying their own dishes: This is intentionally disallowed
4. Reset MetaMask account if you have an inconsistent state:
   - Open MetaMask
   - Go to Settings > Advanced
   - Scroll down and click "Reset Account"

## Future Improvements

1. **Multi-Restaurant Ecosystem**: Enable cross-restaurant analytics and promotions
2. **Advanced Carbon Tracking**: Integrate with external carbon footprint APIs
3. **Enhanced Token Utility**: Additional uses for GreenCoin tokens
4. **Mobile Application**: Develop a mobile app for easier access
5. **Governance System**: Community voting for sustainability metrics
6. **Real-Time Analytics**: Enhanced dashboard for deeper insights

---

## Submission Notes

This project demonstrates the use of blockchain technology to promote sustainable dining practices through transparent carbon credit tracking and tokenized rewards. The combination of smart contracts and an intuitive web interface creates a platform where both restaurants and customers are incentivized to make environmentally conscious choices.

Key technical elements include:
- ERC-20 token implementation
- Tiered loyalty systems
- Carbon credit tracking mechanisms
- Transaction verification
- MetaMask integration
- Responsive web design

The project showcases understanding of:
- Smart contract development
- Blockchain transaction management
- Web3 integration
- Frontend-blockchain communication
- Environmental tokenomics
