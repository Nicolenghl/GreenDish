# GreenDish DApp Deployment Guide

This guide will walk you through the deployment of the GreenDish decentralized application (DApp) with GreenCoin token rewards.

## Project Structure

```
GreenDish/
├── contracts/
│   ├── GreenDish.sol        # Main contract for restaurant dishes
│   └── token.sol            # GreenCoin ERC20 token contract
├── public/
│   ├── index.html           # Main dashboard page
│   ├── profile.html         # User profile page
│   ├── admin.html           # Admin dashboard
│   ├── token-init.js        # Token initialization script
│   └── reset-contracts.js   # Helper script for resetting contracts
├── artifacts/               # Compiled contract artifacts
├── deploy.js                # Deployment script for both contracts
└── DEPLOYMENT.md            # This deployment guide
```

## Prerequisites

- [Node.js](https://nodejs.org/) (v14+)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- [MetaMask](https://metamask.io/) browser extension
- [Hardhat](https://hardhat.org/) or [Truffle](https://www.trufflesuite.com/)
- Test ETH for deployment (for Sepolia testnet: [Sepolia Faucet](https://sepoliafaucet.com/))

## Step-by-Step Deployment Guide

### 1. Clone and Set Up the Project

```bash
# Clone the repository (if applicable)
git clone <repository-url>
cd GreenDish

# Install dependencies
npm install
```

### 2. Compile Smart Contracts

```bash
# If using Hardhat
npx hardhat compile

# If using Truffle
truffle compile
```

This will create the `artifacts` directory with compiled contract files.

### 3. Deploy the Contracts

You have two options for deployment:

#### Option A: Using the Deployment Script

1. Update the `deploy.js` script with your desired configuration:
   - Set the dish name, price, inventory, carbon credits
   - Adjust the token reward rate (currently set to 10%)

2. Run the deployment script:
   ```bash
   # If using Hardhat
   npx hardhat run deploy.js --network sepolia

   # If using Truffle
   truffle migrate --network sepolia
   ```

3. The script will:
   - Deploy the GreenCoin token contract first
   - Deploy the GreenDish contract
   - Connect the GreenDish contract to the GreenCoin contract
   - Transfer initial tokens to the GreenDish contract for rewards

4. Save the deployed contract addresses for the frontend.

#### Option B: Deploy via the Admin Dashboard

1. Start the local development server:
   ```bash
   # If using a development server like lite-server
   npm run dev
   ```

2. Navigate to `http://localhost:3000/admin.html`

3. Connect your MetaMask wallet.

4. Use the admin interface to:
   - Initialize the GreenCoin token
   - Create a new dish with carbon credits and token reward settings

### 4. Configure the Frontend

1. If you used Option A (deployment script), update the contract addresses in the frontend:
   - Create a file named `deployments.json` in the public directory:
     ```json
     {
       "contractAddress": "YOUR_GREENDISH_CONTRACT_ADDRESS",
       "tokenAddress": "YOUR_GREENCOIN_CONTRACT_ADDRESS"
     }
     ```

2. If using Option B, the addresses will be automatically saved in localStorage.

### 5. Launch the Application

```bash
# Start the local server
npm run dev
```

Navigate to `http://localhost:3000` in your browser.

## Using the Application

### As a Restaurant Owner (Admin)

1. Navigate to `/admin.html`
2. Connect your MetaMask wallet
3. Initialize the GreenCoin token (if not already deployed)
4. Create a new dish by filling out the form with:
   - Dish name, price, and inventory
   - Carbon credits (1-100)
   - Main component and supply source

### As a Customer

1. Navigate to the main dashboard
2. Connect your MetaMask wallet
3. Browse available dishes
4. Purchase dishes to earn carbon credits and GreenCoin tokens
5. View your collection and rewards in the profile page

## Contract Interaction

### GreenDish Contract Functions

- `purchaseDish(uint _numberOfDishes)` - Buy dishes and earn tokens
- `updateInventory(uint _newInventory)` - Update dish inventory (owner only)
- `setDishStatus(bool _isActive)` - Enable/disable a dish (owner only)

### GreenCoin Token Functions

- `transfer(address recipient, uint256 amount)` - Transfer tokens to another address
- `balanceOf(address account)` - Check token balance
- `approve(address spender, uint256 amount)` - Approve another address to spend tokens

## Token Reward System

The token reward is calculated as:
```
Reward = numberOfDishes * carbonCredits * tokenRewardRate
```

Where:
- `tokenRewardRate` is set to 0.1 (10% of a token per carbon credit)

## Testnet Deployment

For production-like testing, deploy to a testnet:

```bash
# Deploy to Sepolia testnet
npx hardhat run deploy.js --network sepolia
```

Make sure your `hardhat.config.js` or `truffle-config.js` includes the Sepolia network configuration.

## Troubleshooting

- **MetaMask Connection Issues**: Ensure you're on the correct network (e.g., Sepolia testnet)
- **Transaction Failing**: Check you have sufficient ETH for gas
- **Contract Not Found**: Verify the contract addresses are correctly set
- **Token Rewards Not Showing**: Ensure the GreenCoin token is properly initialized and the GreenDish contract has sufficient tokens

## Next Steps

- Add more restaurant dishes to the platform
- Implement token staking for additional benefits
- Create a marketplace for using GreenCoins to purchase real goods
- Add more detailed analytics for carbon credit impact 