const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy GreenRestaurant
  console.log("Deploying GreenRestaurant...");
  const GreenRestaurant = await hre.ethers.getContractFactory("GreenRestaurant");

  // The new contract doesn't require restaurant name in constructor
  const restaurant = await GreenRestaurant.deploy();
  await restaurant.waitForDeployment();

  const restaurantAddress = await restaurant.getAddress();
  console.log("GreenRestaurant deployed to:", restaurantAddress);

  // Save deployment info
  const deploymentInfo = {
    contractAddress: restaurantAddress,
    timestamp: new Date().toISOString(),
    restaurantName: "My Green Restaurant" // This will be set later when creating the first dish
  };

  // Make sure the public directory exists
  if (!fs.existsSync("./public")) {
    fs.mkdirSync("./public", { recursive: true });
  }

  fs.writeFileSync(
    "./public/deployments.json",
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("Deployment information saved to public/deployments.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
