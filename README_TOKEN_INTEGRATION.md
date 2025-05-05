# GreenDish Token Integration Guide

This guide explains how to deploy and use the integrated GreenDishWithToken contract which combines the GreenDish food platform with the GreenCoin ERC20 token system for carbon credit rewards.

## Overview

The GreenDishWithToken contract is a combined solution that:

1. Manages restaurant dishes with carbon credit ratings
2. Handles token rewards directly within the same contract
3. Eliminates cross-contract interactions that were causing issues
4. Simplifies deployment and reduces gas costs

## Key Benefits Over Separate Contracts

1. **Simplified Token Ownership**: The contract itself owns all tokens initially, eliminating transfer permission issues
2. **No ABI Compatibility Issues**: Everything is in one contract, so there are no cross-contract calls
3. **Reduced Gas Costs**: Direct token balance updates instead of token transfers
4. **Simplified Deployment**: Only one contract to deploy instead of two
5. **Atomic Operations**: Purchase and reward occur in a single transaction

## Deployment Instructions

### Option 1: Using the Deployment Script

1. Use the provided `scripts/deploy-combined.js` script to deploy the combined contract:

```bash
npx hardhat run scripts/deploy-combined.js --network <your-network>
```

2. The script will:
   - Deploy the GreenDishWithToken contract
   - Set the token reward rate to 0.1 (10% per carbon credit per dish)
   - Save deployment information to `public/deployments.json`

### Option 2: Manual Deployment

If you prefer to deploy manually:

1. Compile the contract:

```bash
npx hardhat compile
```

2. Deploy using your preferred method, passing in these constructor parameters:
   - `_dishName`: Name of the dish (e.g., "Organic Salad")
   - `_dishPrice`: Price in ETH (e.g., 0.01 ETH)
   - `_Inventory`: Initial inventory (e.g., 100)
   - `_CarbonCredits`: Carbon credit rating (0-100)
   - `_mainComponent`: Main ingredient (e.g., "Lettuce")
   - `_SupplySource`: Supply source (e.g., "Local Farm") 
   - `_tokenRewardRate`: Token reward rate (e.g., 0.1 ETH = 10%)

3. Manually update `public/deployments.json` with the new contract address:

```json
{
  "combinedContractAddress": "YOUR_DEPLOYED_CONTRACT_ADDRESS",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Integration with Frontend

The frontend has been updated to support both separate contracts and the combined contract:

1. **Index Page**: Displays user token balance
2. **Profile Page**: Shows total earned tokens 

The frontend code automatically detects whether to use the combined contract or separate contracts based on the deployment configuration.

## Token Reward System

Token rewards are calculated using this formula:

```
TokenReward = numberOfDishes * CarbonCredits * tokenRewardRate
```

For example, with:
- 2 dishes purchased
- 80 carbon credits per dish
- 0.1 token reward rate (10%)

The user would receive: 2 * 80 * 0.1 = 16 GreenCoins

## Key Contract Functions

### For Users

- `purchaseDish(uint _numberOfDishes)`: Purchase dishes and receive token rewards
- `tokenBalanceOf(address account)`: Check token balance
- `transferTokens(address recipient, uint256 amount)`: Transfer tokens to another address

### For Admins

- `updateInventory(uint _newInventory)`: Update dish inventory
- `setDishStatus(bool _isActive)`: Enable/disable dish availability
- `setTokenRewardRate(uint256 _newRate)`: Update token reward rate
- `adminTransferTokens(address recipient, uint256 amount)`: Transfer tokens from contract to recipient
- `withdrawETH()`: Withdraw collected ETH from the contract

## Troubleshooting

If you encounter issues:

1. **Token Balance Not Showing**: Ensure you're using the right contract address in deployments.json
2. **Purchase Transaction Failing**: Check that the dish is active and has available inventory
3. **Reward Calculation Issues**: Verify the tokenRewardRate is set correctly

## Migration from Separate Contracts

If you're migrating from separate contracts:

1. Deploy the new combined contract
2. Update `public/deployments.json` to include the `combinedContractAddress`
3. The frontend will automatically detect and use the combined contract

Note that token balances from the previous system won't automatically transfer to the new contract. 