// This is a deployment script example for Hardhat or Truffle
// Replace this with the actual framework you're using

async function main() {
    console.log("Deploying contracts...");

    // Deploy GreenCoin first
    const GreenCoin = await ethers.getContractFactory("GreenCoin");
    const greenCoin = await GreenCoin.deploy();
    await greenCoin.waitForDeployment();
    const greenCoinAddress = await greenCoin.getAddress();
    console.log("GreenCoin deployed to:", greenCoinAddress);

    // Set token reward rate - tokens per carbon credit per dish
    // 10% of a token per carbon credit per dish (with 18 decimals)
    const tokenRewardRate = ethers.parseEther("0.1"); // 0.1 = 10%

    // Deploy GreenDish with GreenCoin address
    const GreenDish = await ethers.getContractFactory("GreenDish");
    const greenDish = await GreenDish.deploy(
        "Organic Salad",            // dishName
        ethers.parseEther("0.01"),  // dishPrice (0.01 ETH)
        100,                        // Inventory
        80,                         // CarbonCredits (80 out of 100)
        "Lettuce",                  // mainComponent
        "Local Farm",               // SupplySource
        greenCoinAddress,           // greenCoinAddress
        tokenRewardRate             // tokenRewardRate
    );
    await greenDish.waitForDeployment();
    const greenDishAddress = await greenDish.getAddress();
    console.log("GreenDish deployed to:", greenDishAddress);

    // Transfer some tokens to the GreenDish contract for rewards
    // You can adjust this amount based on your expected reward needs
    const tokensForRewards = ethers.parseEther("10000"); // 10,000 tokens
    await greenCoin.transfer(greenDishAddress, tokensForRewards);
    console.log("Transferred", ethers.formatEther(tokensForRewards), "tokens to GreenDish contract");

    // Save deployment info to a file for the frontend
    const fs = require("fs");
    const deployData = {
        contractAddress: greenDishAddress,
        tokenAddress: greenCoinAddress,
        timestamp: new Date().toISOString()
    };

    fs.writeFileSync(
        "./public/deployments.json",
        JSON.stringify(deployData, null, 2)
    );
    console.log("Deployment information saved to public/deployments.json");

    console.log("Deployment complete!");
}

// Execute the deployment
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    }); 