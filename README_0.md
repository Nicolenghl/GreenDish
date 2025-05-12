# GreenDish - Blockchain-based Restaurant Application

This project implements a smart contract for a sustainable restaurant application on the blockchain with a web-based UI for users to interact with the contract.

## Getting Started

Follow these steps to get the application running on your local machine:

### Prerequisites

- Node.js (v14 or later)
- npm or pnpm
- MetaMask browser extension

### Installation

1. Clone this repository:
   ```
   git clone <repository-url>
   cd <repository-folder>
   ```

2. Install dependencies:
   ```
   npm install
   ```
   or
   ```
   pnpm install
   ```

### Running the Application

**Method 1: Using the combined dev command**

This will start the Hardhat node, deploy the contract, and serve the frontend in one command:

```
npm run dev
```

**Method 2: Step by step (recommended if you encounter errors)**

1. Start the Hardhat node in one terminal:
   ```
   npm run node
   ```

2. Deploy the contract in another terminal:
   ```
   npm run deploy
   ```

3. Start the frontend server:
   ```
   npm run frontend
   ```

4. Open your browser and navigate to:
   - http://localhost:3000 (Customer Interface)
   - http://localhost:3000/admin.html (Admin Interface)
   - http://localhost:3000/profile.html (Profile Page)

### Troubleshooting Contract Address Issues

If you encounter errors related to contract addresses (e.g., "Error loading dish at 0x..."), the application might be using an outdated contract address. Fix this by:

1. Open your browser's developer tools (press F12 or right-click and select "Inspect")
2. Go to the "Application" tab
3. In the left sidebar, under "Storage", select "Local Storage"
4. Find and select the "localhost:3000" entry
5. Delete all items, especially:
   - `latestDeployment`
   - `deployedDishes`
   - `walletConnection`
6. Refresh the page

**Automatic Fix:** The application now includes a reset script that will automatically fix contract address issues when the page loads.

### MetaMask Setup

1. Install MetaMask browser extension
2. Connect MetaMask to Hardhat network:
   - Network Name: Hardhat
   - RPC URL: http://127.0.0.1:8545
   - Chain ID: 31337
   - Currency Symbol: ETH

3. Import a test account:
   - In MetaMask, go to "Import Account"
   - Paste a private key from the Hardhat node output
   - Recommended: Use Account #0 for admin tasks and a different account for customer interface

## Features

- **Admin Interface**: Restaurants can create and manage dishes, update inventory, and set availability
- **Customer Interface**: Users can browse available dishes, purchase them, and view their purchases
- **Carbon Credits**: Each dish has associated carbon credits
- **Wallet Integration**: Connect with MetaMask for blockchain transactions

## Contract Details

The `GreenDish.sol` contract includes:

- Dish creation with name, price, inventory, and carbon credits
- Purchase functionality with inventory tracking
- Self-dealing prevention (owners can't buy their own dishes)
- Carbon credit constraints (0-100)
- Dish status management (active/inactive)

## License

[Insert your license here]
