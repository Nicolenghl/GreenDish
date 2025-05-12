# GreenDish: Blockchain-Based Sustainable Dining Application

GreenDish is a blockchain-powered platform that incentivizes sustainable dining choices through a tokenized rewards system, transparent carbon tracking, and loyalty tiers.

## 🌿 Project Overview

GreenDish connects eco-conscious restaurants with sustainability-minded diners through blockchain technology. Restaurants can showcase their sustainable dishes and track their environmental impact, while customers can make environmentally responsible choices and earn rewards.

Key features:
- Tokenized rewards via GreenCoin (GRC), an ERC-20 token
- Multi-tiered loyalty systems for both restaurants and customers
- Transparent tracking of carbon credits and sustainability metrics
- User-friendly interfaces for restaurants and customers

## Getting Started

### Prerequisites

- Node.js (v16+ recommended)
- npm or yarn
- MetaMask browser extension
- Git (optional)

### Installation

1. Clone the repository or extract the project files
```bash
git clone <repository-url>
cd GreenDish
```

2. Install dependencies
```bash
npm install
```

3. Start the development environment
```bash
# Option 1: Use the start script (recommended)
chmod +x start-local.sh
./start-local.sh

# Option 2: Start services manually
# Terminal 1:
npx hardhat node

# Terminal 2:
npx hardhat run scripts/deploy.js --network localhost

# Terminal 3:
npx http-server ./public -p 3000
```

### Connecting MetaMask

1. Add a local network to MetaMask:
   - Network Name: Hardhat Local
   - RPC URL: http://localhost:8545
   - Chain ID: 31337
   - Currency Symbol: ETH

2. Import a test account:
   - Copy a private key from the Hardhat console output
   - In MetaMask: Account menu → Import Account → Paste the private key

3. If you encounter issues:
   - Reset your account in MetaMask (Settings → Advanced → Reset Account)
   - Make sure you're connected to the Localhost 8545 network

## 🏗️ Project Structure

```
/GreenDish/
├── contracts/              # Smart contracts (Solidity)
│   ├── GreenDish.sol       # Main contract for platform functionality
│   └── GreenCoin.sol       # ERC-20 token implementation
├── scripts/                # Deployment scripts
│   └── deploy.js           # Main deployment script
├── public/                 # Frontend web application
│   ├── index.html          # Landing page
│   ├── marketplace.html    # Browse and purchase dishes
│   ├── customer-profile.html # Customer dashboard
│   ├── restaurant-portal.html # Restaurant management portal
│   ├── js/
│   │   └── contract-config.js # Contract configuration
├── hardhat.config.js       # Hardhat configuration
├── start-local.sh          # Script to start the development environment
└── README.md               # This file
```

## 📑 Contract Details

### GreenDish.sol
The core platform contract implements the following key features:

- **Dish Creation & Management**:
  - Create dishes with name, restaurant info, price, inventory, and carbon credits
  - Carbon credit constraints (0-100) to quantify sustainability impact
  - Inventory tracking and management with dish status controls (active/inactive)
  - Self-dealing prevention (restaurant owners can't purchase their own dishes)

- **Purchase Functionality**:
  - Secure dish purchase system with inventory tracking
  - Transaction processing with real-time availability verification
  - Excess payment handling and refund mechanism

- **Sustainability System**:
  - Carbon credit tracking for both restaurants and customers
  - Multi-tier loyalty system for both customers (Bronze to Platinum) and restaurants (Green Basic to Green Master)
  - Tier-based reward multipliers for enhanced incentives

### GreenCoin.sol
The ERC-20 token contract powering the reward system:

- Standard ERC-20 implementation with added burn functionality
- Fixed maximum supply of 1 million tokens (1,000,000 GRC)
- 30% allocation to ecosystem reward pool
- Token award mechanism for sustainable choices
- Reward distribution between customers (80%) and restaurants (20%)

## 🖥️ Application Pages

### Restaurant Portal
- Create sustainable dishes with carbon credit ratings
- Monitor restaurant loyalty tier status and rewards
- Track inventory and analyze sales data
- Generate carbon credit reports

### Marketplace
- Browse available sustainable dishes
- View detailed sustainability information about each dish
- Purchase dishes using MetaMask
- Filter by restaurant, carbon credits, and more

### Customer Profile
- Track purchase history and carbon credit impact
- View and manage GreenCoin (GRC) reward tokens
- Monitor loyalty tier status and progress
- See detailed purchase analytics

## 🔄 Testing Workflow

For testing, use different MetaMask accounts to simulate different users:

1. **Restaurant Owner Role**:
   - Use Account #0 (default deployer) for the restaurant
   - Create dishes in the restaurant portal
   - Manage inventory and view statistics

2. **Customer Role**:
   - Switch MetaMask to a different account (#1, #2, etc.)
   - Browse and purchase dishes in the marketplace
   - Check your profile to see purchase history and rewards

## 📝 Common Issues & Troubleshooting

### Port Conflicts
If you see `Error: listen EADDRINUSE: address already in use` for port 8545 or 3000:

```bash
# Find the process using the port
lsof -i :8545  # For Hardhat
lsof -i :3000  # For HTTP server

# Kill the process
kill -9 <PID>

# Or use different ports
npx hardhat node --port 8546
npx http-server ./public -p 8080
```

### MetaMask Issues
If transactions fail or the app can't connect to contracts:

1. Make sure you're on the correct network (Localhost 8545)
2. Reset your account in MetaMask (Settings → Advanced → Reset Account)
3. Verify that the contracts are deployed (check Hardhat console output)
4. Restart the Hardhat node and redeploy if needed

### Escaping Directory Path with Parentheses
If your project path contains parentheses and you encounter shell escaping issues:

```bash
# Use quotes around paths with special characters
cd "/Users/yourname/path/Project(with token)"
npx http-server "./public" -p 3000
```

## 💡 Future Improvements

- Integration with real-world carbon footprint tracking APIs
- Cross-restaurant analytics and promotions
- Enhanced token utility for rewards
- Mobile application development
- Advanced governance systems for community involvement

## 📄 License

ISOM 3270 Final Project

---

**Note**: This project is a demonstration of blockchain technology applied to sustainability in the food industry. It showcases the use of smart contracts, tokenized rewards, and transparent tracking mechanisms.
