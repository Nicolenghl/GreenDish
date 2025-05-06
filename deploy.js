// This is a deployment script example for Hardhat or Truffle
// Replace this with the actual framework you're using

const hre = require("hardhat");

async function main() {
    console.log("Deploying GreenRestaurant contract...");

    // Get the contract factory
    const GreenRestaurant = await hre.ethers.getContractFactory("GreenRestaurant");

    // Deploy the contract with a restaurant name
    // Note: The updated contract requires a restaurant name to be passed to createDish for initialization
    const restaurant = await GreenRestaurant.deploy();

    // Wait for deployment to finish
    await restaurant.deployed();

    console.log(`GreenRestaurant deployed to: ${restaurant.address}`);

    // Save deployment info to a file for the frontend to use
    const fs = require("fs");
    const deployData = {
        contractAddress: restaurant.address,
        timestamp: new Date().toISOString()
    };

    fs.writeFileSync(
        "./public/deployments.json",
        JSON.stringify(deployData, null, 2)
    );

    console.log("Deployment info saved to public/deployments.json");

    // Output verification command
    console.log(`To verify on Etherscan, run: npx hardhat verify --network <network> ${restaurant.address}`);
}

// Execute deployment
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    }); 