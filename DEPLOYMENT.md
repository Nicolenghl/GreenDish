# GreenDish Platform Deployment Guide

This guide will walk you through the process of deploying the GreenDish platform, including both the smart contracts and the frontend web application.

## Prerequisites

Before starting the deployment process, ensure you have the following:

1. Node.js (v16.x or later) and npm installed
2. MetaMask extension installed in your browser
3. Sufficient ETH in your wallet for deployment gas fees
4. If deploying to a testnet:
   - A testnet (Sepolia) RPC URL (from Infura, Alchemy, etc.)
   - Testnet ETH in your wallet
   - (Optional) Etherscan API key for contract verification

## Step 1: Set Up Your Environment

1. Clone the GreenDish repository and navigate to the project directory:
   ```bash
   git clone <repository-url>
   cd greendish-platform
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the project root with your configuration:
   ```
   # Network settings
   SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
   ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
   
   # Wallet settings - BE CAREFUL WITH THIS! Never share your private key!
   PRIVATE_KEY=YOUR_WALLET_PRIVATE_KEY
   
   # Frontend settings
   FRONTEND_PORT=3000
   ```

4. Make sure the `public/js` directory exists:
   ```bash
   mkdir -p public/js
   ```

## Step 2: Deploy Smart Contracts

The GreenDish platform consists of two main contracts:
- `GreenCoin.sol`: The ERC20 token used for rewards
- `GreenDish.sol`: The main contract that handles restaurants, dishes, and loyalty program

### Deploy to a Local Network (for testing)

1. Start a local Hardhat node:
   ```bash
   npx hardhat node
   ```

2. Deploy the contracts to the local network:
   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

### Deploy to Sepolia Testnet

1. Deploy the contracts to Sepolia:
   ```bash
   npx hardhat run scripts/deploy.js --network sepolia
   ```

The deployment script will:
1. Deploy the GreenCoin token contract
2. Deploy the GreenDish main contract with the GreenCoin address
3. Allocate 30% of tokens to the GreenDish contract for rewards
4. Create an initial restaurant and dish
5. Save the deployment information to:
   - `deployment-info.json` (detailed deployment info)
   - `public/deployments.json` (frontend deployment info)
   - Update `public/js/contract-config.js` with the new addresses

## Step 3: Update Contract Addresses

If you need to manually update the contract addresses in the frontend files, you can use the provided script:

```bash
node scripts/update-contract-addresses.js <greenCoinAddress> <greenDishAddress>
```

For example:
```bash
node scripts/update-contract-addresses.js 0xabcdef1234567890abcdef1234567890abcdef12 0x1234567890abcdef1234567890abcdef12345678
```

This will update the addresses in:
- `public/deployments.json`
- `public/js/contract-config.js`

## Step 4: Start the Frontend

1. Start the frontend server:
   ```bash
   npm run start
   ```

2. Open your browser and navigate to `http://localhost:3000` (or the port you specified in the `.env` file)

## Step 5: Verify Contracts (Optional)

If you deployed to a public testnet or mainnet, it's a good practice to verify your contracts on Etherscan:

```bash
npx hardhat verify --network sepolia <greenCoinAddress>
npx hardhat verify --network sepolia <greenDishAddress> <greenCoinAddress>
```

## Troubleshooting

### Contract Connection Issues

If the frontend is having trouble connecting to your contracts:

1. Check that the contract addresses in `public/deployments.json` and `public/js/contract-config.js` are correct
2. Ensure you're connected to the correct network in MetaMask
3. Verify that the contracts were deployed successfully

### MetaMask Issues

If MetaMask isn't connecting or transactions are failing:

1. Make sure you have the correct network selected in MetaMask
2. Check that you have sufficient ETH for gas fees
3. Try resetting your MetaMask account (Settings > Advanced > Reset Account)

### Frontend Issues

If the frontend isn't displaying correctly:

1. Check the browser console for errors
2. Ensure all HTML files include the shared contract configuration:
   ```html
   <script src="js/contract-config.js"></script>
   ```

## Deployment Configuration

The smart contract deployment logic uses the following files:

1. `hardhat.config.js`: Network configuration
2. `scripts/deploy.js`: Contract deployment logic
3. `scripts/update-contract-addresses.js`: Updates frontend files with contract addresses

The key frontend files for contract integration are:

1. `public/js/contract-config.js`: Shared contract configuration
2. `public/deployments.json`: Contract addresses for the frontend
3. HTML files: `marketplace.html`, `customer-profile.html`, `restaurant-portal.html`

## Contract Address Configuration JSON Format

The `public/deployments.json` file should have the following format:

```json
{
  "greenCoinAddress": "0xabcdef1234567890abcdef1234567890abcdef12",
  "greenDishAddress": "0x1234567890abcdef1234567890abcdef12345678",
  "timestamp": "2023-05-06T07:17:57.737Z",
  "restaurantName": "Green Eatery"
}
```

## Next Steps After Deployment

After successful deployment:

1. Connect your MetaMask wallet to the application
2. Create more restaurants and dishes
3. Test the purchase functionality
4. Verify the loyalty tier system is working correctly
5. Check token rewards and balances 