# GreenDish Factory Pattern Testing Guide

This guide provides a structured approach to testing the GreenDish Factory pattern implementation. Follow these steps to verify that all components are working correctly.

## Prerequisites

- Hardhat environment set up
- Node.js and npm installed
- MetaMask browser extension

## Initial Setup

1. Start a local Hardhat node in a terminal window:
```bash
npx hardhat node
```

2. Deploy the contracts in another terminal:
```bash
npx hardhat run scripts/deploy-factory.js --network localhost
```

3. Start the frontend server:
```bash
node start-server.js
```

## Test 1: Verify Contract Deployment

1. Check the terminal output for successful contract deployment
2. Verify that `public/deployments.json` was created and contains:
   - `tokenAddress`
   - `factoryAddress`
   - `timestamp`
3. Check that ABI files were generated in the `public` directory:
   - `TokenABI.json`
   - `FactoryABI.json`
   - `DishABI.json`

## Test 2: Admin Panel Functionality

1. Open http://localhost:3000/admin.html in your browser
2. Connect your MetaMask to the local Hardhat network:
   - Network Name: Localhost 8545
   - RPC URL: http://127.0.0.1:8545
   - Chain ID: 31337
   - Currency Symbol: ETH

3. Import a test account using one of the private keys from the Hardhat node output

4. Click "Connect Wallet" in the admin panel

5. Verify the Factory Card appears showing:
   - Factory Address
   - Token Address
   - Default Reward Rate
   - Dish Count

6. Deploy a test dish through the factory:
   - Name: "Test Salad"
   - Price: 0.01 ETH
   - Inventory: 10
   - Carbon Credits: 50
   - Main Component: "Fresh Greens"
   - Supply Source: "Local Farm"

7. Confirm the transaction in MetaMask

8. Verify the dish appears in "Your Deployed Dish Contracts" section

## Test 3: Token Approval Verification

1. Open your browser developer console (F12)
2. Run this code to check token approvals:

```javascript
// Get the deployment data
fetch('./deployments.json')
  .then(response => response.json())
  .then(async data => {
    // Connect to token contract
    const tokenABI = await fetch('./TokenABI.json').then(r => r.json());
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const token = new ethers.Contract(data.tokenAddress, tokenABI, signer);
    
    // Get deployed dishes
    const dishes = JSON.parse(localStorage.getItem('deployedDishes'));
    if (dishes && dishes.length > 0) {
      // Check allowance for the first dish
      const dishAddress = dishes[0].address;
      const allowance = await token.allowance(data.factoryAddress, dishAddress);
      console.log(`Factory approved ${ethers.formatEther(allowance)} tokens for dish at ${dishAddress}`);
    }
  });
```

3. Verify that the allowance is a non-zero value

## Test 4: Purchase and Token Rewards

1. Open http://localhost:3000/index.html
2. Connect your MetaMask (use a different account than the admin for testing)
3. Verify your dish is visible in the available dishes
4. Purchase 1 dish by clicking "Buy Now" and confirm the transaction
5. Check the transaction in MetaMask for success
6. Open the browser console and run:

```javascript
// Check token balance for current user
fetch('./deployments.json')
  .then(response => response.json())
  .then(async data => {
    const tokenABI = await fetch('./TokenABI.json').then(r => r.json());
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const userAddress = await signer.getAddress();
    const token = new ethers.Contract(data.tokenAddress, tokenABI, signer);
    
    const balance = await token.balanceOf(userAddress);
    console.log(`Your token balance: ${ethers.formatEther(balance)}`);
  });
```

7. Verify that your token balance increased after the purchase

## Test 5: Error Handling

1. In the admin panel, deploy a new dish with very high carbon credits (e.g., 100)
2. Check that the factory properly approves tokens for this high-reward dish
3. Purchase multiple dishes with another account to test bulk purchasing
4. Try purchasing more dishes than available to test inventory checks

## Debugging Common Issues

### Issue: "Factory has not approved enough tokens for rewards"

**Solution**: Increase the approval buffer in the factory contract:
1. Edit the `_approveTokensForDish` function in `GreenDishFactory.sol`
2. Increase the multiplier in: `_inventory * _carbonCredits * defaultTokenRewardRate * 2`
3. Redeploy the contracts

### Issue: "MetaMask can't find the RPC URL"

**Solution**:
1. Make sure your Hardhat node is running
2. Check that the RPC URL in MetaMask is set to `http://127.0.0.1:8545`
3. Ensure the Chain ID is set to `31337`

### Issue: "Token transfer fails"

**Solution**:
1. Check token balances: Does the factory have enough tokens?
2. Check token approvals: Has the factory approved enough tokens?
3. Check contract addresses: Are you using the correct deployment?

## Testing Token Transfer Flow

Here's what happens in a successful token transfer:

1. User purchases a dish through the GreenDish contract
2. GreenDish calculates token reward based on carbon credits
3. GreenDish contract checks if it has direct token balance
4. If not, it uses `transferFrom` to pull tokens from the factory
5. The factory must have previously approved the GreenDish contract
6. Tokens are transferred directly from factory to user

You can trace this flow by:
1. Watching the Events tab in blockchain explorers like Etherscan
2. Logging all transactions in your MetaMask Activity
3. Using the `TokensRewarded` event emitted by the GreenDish contract 