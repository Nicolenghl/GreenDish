# GreenDish: Blockchain-Based Sustainable Dining Platform - Developer Guide

This document provides guidance on how to modify, update, and develop the GreenDish platform, including both the smart contracts and the frontend UI.

## Project Structure Overview

```
/Project(with token)/
├── contracts/              # Smart contracts (Solidity)
│   ├── GreenDish.sol       # Main contract for restaurant/dish management
│   └── GreenCoin.sol       # ERC-20 token implementation for rewards
├── scripts/                # Deployment scripts
│   ├── deploy.js           # Main deployment script
│   └── start-local.sh      # Script to start local development environment
├── public/                 # Frontend web application
│   ├── index.html          # Landing page
│   ├── marketplace.html    # Browse and purchase dishes
│   ├── customer-profile.html # Customer profile/dashboard
│   ├── restaurant-portal.html # Restaurant management portal
│   ├── js/
│   │   └── contract-config.js # Contract addresses and configuration
│   └── css/                # Stylesheets (if separate from HTML)
├── hardhat.config.js       # Hardhat configuration
├── deployments.json        # Contract deployment information for the frontend
└── README.md               # Project documentation
```

## Smart Contract Modification

### Main Contract Files

The primary smart contracts are:

1. `GreenDish.sol` in the `contracts/` directory, which handles:
   - Restaurant registration and dish creation
   - Dish purchasing and inventory management
   - Loyalty tier systems for restaurants and customers
   - Carbon credit tracking

2. `GreenCoin.sol` in the `contracts/` directory, which is:
   - An ERC-20 token for rewards
   - Includes functionality for allocating tokens to the GreenDish ecosystem

When making changes to contracts:

1. Understand the existing function flow (especially for purchasing and rewards)
2. The `GreenDish` contract follows a model with these key functions:
   - `createDish()` - For restaurant owners to create new dishes
   - `purchaseDish()` - For customers to buy dishes and earn rewards
   - `updateInventory()` - For restaurants to manage inventory
   - `getRestaurantLoyaltyInfo()` and `getCustomerLoyaltyInfo()` - For loyalty tier status

### Contract Deployment Process

To update and deploy the contracts:

1. Modify the contract code as needed
2. Update the deployment script (`scripts/deploy.js`) if your contract changes require different constructor parameters
3. Compile the contract with: `npx hardhat compile`
4. Deploy using: `npx hardhat run scripts/deploy.js --network localhost`

## Frontend UI Modification

The system includes four main UI files:

### 1. Landing Page (index.html)

**File location:** `public/index.html`

This is the main entry point that displays:
- Project introduction and value proposition
- Customer and restaurant loyalty tier information
- Navigation to marketplace and profiles

**Key components to modify:**
- Hero section for project introduction
- Loyalty tier displays
- Call-to-action buttons

### 2. Marketplace (marketplace.html)

**File location:** `public/marketplace.html`

Allows customers to browse and purchase sustainable dishes.

**Key components to modify:**
- Dish card display grid
- Purchase modal
- Filtering and sorting options
- Restaurant information display

**JavaScript functions to update if needed:**
- `loadAllDishes()` - Loads and displays available dishes
- `purchaseDish()` - Handles the dish purchase transaction
- `updateUI()` - Updates the interface after transactions

### 3. Customer Profile (customer-profile.html)

**File location:** `public/customer-profile.html`

Shows the customer's purchased dishes, loyalty tier, and carbon credit impact.

**Key components to modify:**
- Profile stats section
- Loyalty tier display
- Purchase history table
- GreenCoin token balance

**JavaScript functions to update if needed:**
- `loadUserInfo()` - Retrieves and displays user loyalty info
- `loadUserDishes()` - Loads the user's purchased dishes
- `updateLoyaltyTierUI()` - Updates the loyalty tier information

### 4. Restaurant Portal (restaurant-portal.html)

**File location:** `public/restaurant-portal.html`

Interface for restaurant owners to create and manage dishes.

**Key components to modify:**
- Restaurant stats dashboard
- Dish creation form
- Inventory management section
- Carbon credit reporting

**JavaScript functions to update if needed:**
- `createDish()` - Creates new dishes
- `loadRestaurantData()` - Loads the restaurant's dishes and stats
- `updateDishInventory()` - Updates dish inventory
- `generateCarbonReport()` - Generates sustainability reports

## Integration Between UI and Smart Contract

The integration between the UI and smart contract is managed through:

1. **Contract ABIs and Addresses**: Located in `public/js/contract-config.js`
   - The file contains addresses and ABIs needed for contract interaction
   - Frontend pages load this to interact with contracts

2. **Web3/Ethers.js Integration**: Each page uses JavaScript to:
   - Connect to MetaMask
   - Initialize contract instances
   - Call contract functions
   - Listen for blockchain events

If you modify the contracts, ensure the following:
1. Update ABIs in `contract-config.js` if you change function signatures
2. Test new functions in all relevant UI files
3. Update any affected JavaScript functions that call the contract

## Testing Your Changes

After making changes:

1. Compile the contracts: `npx hardhat compile`
2. Start a local node: `npx hardhat node`
3. Deploy the contracts: `npx hardhat run scripts/deploy.js --network localhost`
4. Start the frontend: `npx http-server ./public -p 3000`
5. Visit http://localhost:3000 in your browser

### Using the start-local.sh Script

Alternatively, use the provided script to handle all steps at once:

```bash
chmod +x start-local.sh  # Make executable (Unix/Mac only)
./start-local.sh         # Run the script
```

## Common Modification Scenarios

### 1. Adding a New Contract Feature

1. Update `GreenDish.sol` or `GreenCoin.sol` with your new function
2. Recompile the contracts
3. Add corresponding UI elements and JavaScript functions to call your new feature

### 2. Updating the UI Design

1. Modify the relevant HTML and CSS in the specific page file
2. Test the changes at different screen sizes for responsiveness
3. Ensure consistent styling across all pages

### 3. Adding User Feedback

1. Update the UI to provide visual feedback for actions (loading spinners, alerts, etc.)
2. Add error handling in JavaScript functions
3. Ensure all blockchain interactions have proper error and success messaging

## Debugging Common Issues

### 1. MetaMask Connection Issues

If MetaMask can't connect or transactions are failing:

1. Make sure you've selected the correct network (Localhost 8545)
2. Reset your account in MetaMask:
   - Open MetaMask
   - Go to Settings → Advanced
   - Click "Reset Account"
3. Ensure contracts are correctly deployed (check terminal output for addresses)

### 2. Port Conflicts

If you see `EADDRINUSE` errors:

```bash
# Find the process using port 8545 (Hardhat) or 3000 (HTTP server)
lsof -i :8545
lsof -i :3000

# Kill the process
kill -9 [PID]

# Or use different ports
npx hardhat node --port 8546
npx http-server ./public -p 8080
```

### 3. Path Escaping Issues

If your project path contains parentheses or spaces and you encounter shell escaping issues:

```bash
# Use quotes around paths with special characters
cd "/Users/yourname/path/Project(with token)"
npx http-server "./public" -p 3000
```

### 4. Contract Interaction Errors

If you encounter errors when calling contract functions:

1. Check the browser console for specific error messages
2. Verify that the contract addresses in `contract-config.js` match the deployed addresses
3. Make sure the function signatures and parameters match what the contract expects
4. For "restaurant owner buying own dish" errors, this is intentional protection

## Tracking Inventory and Sales

The restaurant portal has a unique feature to track both inventory reductions and actual sales:

1. **Inventory Reduction**: Tracks changes in inventory (both from sales and manual updates)
2. **Actual Sales**: Tracks only purchases made by customers through transactions

When updating inventory manually, be aware:
- The system tracks the difference between initial inventory and current inventory as "Inventory Reduction"
- This is distinct from "Actual Sales" which only counts blockchain transactions

## Best Practices

1. **Smart Contract:**
   - Always test new functions thoroughly
   - Consider gas efficiency
   - Keep functions simple and focused
   - Follow the existing patterns for permission checks

2. **UI Design:**
   - Maintain consistent styling across pages
   - Test UI changes in multiple browsers
   - Consider mobile responsiveness

3. **Integration:**
   - Always check if your contract changes break existing UI functionality
   - Update the ABI references if you change function signatures
   - Add proper error handling for contract interactions

## Test Accounts

The Hardhat node provides 20 test accounts with 10,000 ETH each. Here are a few examples:

```
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

Account #2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
```

**WARNING**: These accounts and private keys are publicly known. Only use them for testing on local networks.

## Recent Improvements

Recent updates to the platform include:

1. **Enhanced Inventory Tracking**: Clarified the difference between inventory reduction (from manual updates) and actual sales
2. **UI Improvements**: Made buttons and tier cards more visible and aligned
3. **Restaurant Portal Updates**: Added better carbon credit reporting
4. **Loyalty Tier Display**: Improved the visibility of tier status and rewards
5. **Error Handling**: Added more robust error handling, especially for restaurant owners trying to purchase their own dishes 