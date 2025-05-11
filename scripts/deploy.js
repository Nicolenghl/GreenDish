// This script deploys the GreenCoin token contract and the GreenDish contract
// Following the flow: Deploy token → Deploy restaurant → Connect them

const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

// Helper function to safely convert BigInt to string in JSON
function replaceBigInt(key, value) {
  // Convert BigInt to string during JSON serialization
  if (typeof value === 'bigint') {
    return value.toString();
  }
  return value;
}

async function main() {
  console.log("Starting deployment process...");

  // Get contract factories
  const GreenCoin = await hre.ethers.getContractFactory("GreenCoin");
  const GreenDish = await hre.ethers.getContractFactory("GreenDish");

  // Step 1: Deploy the GreenCoin token contract first
  console.log("Deploying GreenCoin token contract...");
  const greenCoin = await GreenCoin.deploy();
  await greenCoin.waitForDeployment();
  const greenCoinAddress = await greenCoin.getAddress();
  console.log(`GreenCoin token deployed to: ${greenCoinAddress}`);

  // Step 2: Deploy the GreenDish contract with the token address
  console.log("Deploying GreenDish contract with token address...");
  const greenDish = await GreenDish.deploy(greenCoinAddress);
  await greenDish.waitForDeployment();
  const greenDishAddress = await greenDish.getAddress();
  console.log(`GreenDish deployed to: ${greenDishAddress}`);

  // Step 3: Allocate tokens to the GreenDish contract (which acts as reward pool)
  console.log("Allocating 30% of tokens to the GreenDish reward pool...");

  // Get token supply for logging
  const totalSupply = await greenCoin.totalSupply();
  const ecosystemPercentage = await greenCoin.ECOSYSTEM_PERCENTAGE();
  const ecosystemAmount = totalSupply * BigInt(ecosystemPercentage) / BigInt(100);

  // Allocate tokens to reward pool - this will transfer 30% of tokens
  const allocateTx = await greenCoin.allocateToRewardPool(greenDishAddress);
  await allocateTx.wait();
  console.log(`Allocated ${ecosystemAmount} tokens (30% of total supply) to the GreenDish reward pool`);

  // Step 4: Create the initial restaurant and first dish
  console.log("Initializing the restaurant...");
  const createTx = await greenDish.createDish(
    "Green Eatery", // Restaurant name
    "Organic Salad", // Dish name
    hre.ethers.parseEther("0.01"), // Price in ETH
    100, // Initial inventory
    25, // Carbon credits
    "Leafy Greens", // Main component
    "Local Farm" // Supply source
  );
  await createTx.wait();
  console.log("Restaurant initialized and first dish created!");

  // Verify restaurant is now using the token
  const tokenAddress = await greenDish.tokenContract();
  const isTokenInitialized = await greenDish.tokenInitialized();
  console.log(`Restaurant token contract address: ${tokenAddress}`);
  console.log(`Token initialized: ${isTokenInitialized}`);

  // Check the actual token balance of the restaurant
  const restaurantBalance = await greenCoin.balanceOf(greenDishAddress);
  console.log(`Restaurant token balance: ${restaurantBalance} (${restaurantBalance * BigInt(100) / totalSupply}% of total supply)`);

  console.log("Deployment completed successfully!");
  console.log("Contract addresses:");
  console.log("  GreenCoin: " + greenCoinAddress);
  console.log("  GreenDish: " + greenDishAddress);
  console.log("\nIf you're having issues with MetaMask, reset your account");
  console.log("in MetaMask settings and make sure you're connected to");
  console.log("http://localhost:8545 network.");

  // Create frontend deployment info for both internal and external use

  // 1. Save detailed deployment info to a file for reference
  const deploymentInfo = {
    greenCoinAddress,
    greenDishAddress,
    networkName: hre.network.name,
    networkId: (await hre.ethers.provider.getNetwork()).chainId.toString(), // Convert to string
    deploymentTime: new Date().toISOString()
  };

  fs.writeFileSync(
    "deployment-info.json",
    JSON.stringify(deploymentInfo, replaceBigInt, 2)
  );
  console.log("Detailed deployment info saved to deployment-info.json");

  // 2. Save simplified deployment info for frontend to public/deployments.json
  const frontendDeploymentInfo = {
    greenCoinAddress,
    greenDishAddress,
    timestamp: new Date().toISOString(),
    restaurantName: "Green Eatery"
  };

  const frontendPath = path.join(__dirname, "..", "public", "deployments.json");
  fs.writeFileSync(
    frontendPath,
    JSON.stringify(frontendDeploymentInfo, replaceBigInt, 2)
  );
  console.log(`Frontend deployment info saved to ${frontendPath}`);

  // 3. Update contract-config.js with current addresses (direct replacement)
  try {
    const configPath = path.join(__dirname, "..", "public", "js", "contract-config.js");
    if (fs.existsSync(configPath)) {
      let configContent = fs.readFileSync(configPath, 'utf8');

      // Replace GreenCoin address
      configContent = configContent.replace(
        /GreenCoin: "0x[0-9a-fA-F]{40}"/,
        `GreenCoin: "${greenCoinAddress}"`
      );

      // Replace GreenDish address
      configContent = configContent.replace(
        /GreenDish: "0x[0-9a-fA-F]{40}"/,
        `GreenDish: "${greenDishAddress}"`
      );

      fs.writeFileSync(configPath, configContent);
      console.log(`Updated contract addresses in ${configPath}`);
    }
  } catch (error) {
    console.error("Error updating contract-config.js:", error);
  }
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
