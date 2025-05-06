require("@nomicfoundation/hardhat-toolbox");

// Handle cases where dotenv cannot find .env file
try {
  require("dotenv").config();
} catch (error) {
  console.warn("No .env file found. Using default configuration.");
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    // Localhost network for testing
    localhost: {
      url: "http://127.0.0.1:8546",
      chainId: 31337,
    },
    // Sepolia testnet configuration
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "https://rpc.sepolia.org",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
    },
    // Add mainnet configuration if needed
    // mainnet: {
    //   url: process.env.MAINNET_RPC_URL,
    //   accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    //   chainId: 1,
    // },
  },
  paths: {
    artifacts: "./public/artifacts",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
};
