const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy GreenDish contract
  console.log("Deploying GreenDish...");
  const GreenDish = await hre.ethers.getContractFactory("GreenDish");
  
  // Set initial parameters
  const dishName = "Organic Salad";
  const dishPrice = hre.ethers.parseEther("0.01"); // 0.01 ETH
  const inventory = 50;
  const carbonCredits = 75;
  const mainComponent = "Fresh Greens";
  const supplySource = "Local Farm";
  
  const greenDish = await GreenDish.deploy(
    dishName,
    dishPrice,
    inventory,
    carbonCredits,
    mainComponent,
    supplySource
  );
  
  await greenDish.waitForDeployment();
  const contractAddress = await greenDish.getAddress();
  
  console.log("GreenDish deployed to:", contractAddress);
  
  // Save the contract address to deployments.json
  const deploymentData = {
    contractAddress: contractAddress,
    timestamp: new Date().toISOString()
  };
  
  // Make sure the public directory exists
  if (!fs.existsSync("./public")) {
    fs.mkdirSync("./public", { recursive: true });
  }
  
  fs.writeFileSync(
    "./public/deployments.json",
    JSON.stringify(deploymentData, null, 2)
  );
  
  console.log("Deployment information saved to public/deployments.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
