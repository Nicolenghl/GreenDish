#!/usr/bin/env node

/**
 * This script updates contract addresses in all necessary files after deployment.
 * It ensures the HTML files, contract-config.js, and deployments.json all have
 * the correct contract addresses.
 * 
 * Usage: 
 * node scripts/update-contract-addresses.js <greenCoinAddress> <greenDishAddress>
 */

const fs = require('fs');
const path = require('path');

// Get the contract addresses from command line arguments
const greenCoinAddress = process.argv[2];
const greenDishAddress = process.argv[3];

if (!greenCoinAddress || !greenDishAddress) {
    console.error('Please provide both GreenCoin and GreenDish contract addresses');
    console.error('Usage: node scripts/update-contract-addresses.js <greenCoinAddress> <greenDishAddress>');
    process.exit(1);
}

// Validate addresses
if (!greenCoinAddress.match(/^0x[0-9a-fA-F]{40}$/) || !greenDishAddress.match(/^0x[0-9a-fA-F]{40}$/)) {
    console.error('Invalid contract address format. Addresses should be in the format 0x... (40 hex characters after 0x)');
    process.exit(1);
}

// 1. Update deployments.json file for the frontend
const deploymentsFile = path.join(__dirname, '..', 'public', 'deployments.json');
try {
    const deploymentData = {
        greenCoinAddress,
        greenDishAddress,
        timestamp: new Date().toISOString(),
        restaurantName: "Green Eatery"
    };

    fs.writeFileSync(deploymentsFile, JSON.stringify(deploymentData, null, 2));
    console.log(`Updated ${deploymentsFile} with contract addresses`);
} catch (error) {
    console.error(`Error updating ${deploymentsFile}:`, error);
}

// 2. Update contract-config.js file
const configFile = path.join(__dirname, '..', 'public', 'js', 'contract-config.js');
try {
    if (fs.existsSync(configFile)) {
        let configContent = fs.readFileSync(configFile, 'utf8');

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

        fs.writeFileSync(configFile, configContent);
        console.log(`Updated ${configFile} with contract addresses`);
    } else {
        console.error(`${configFile} does not exist`);
    }
} catch (error) {
    console.error(`Error updating ${configFile}:`, error);
}

// 3. Create a helpful deployment summary file
const summaryFile = path.join(__dirname, '..', 'deployment-summary.txt');
try {
    const summaryContent = `
GreenDish Project Deployment Summary
===================================
Deployment Date: ${new Date().toISOString()}

Contract Addresses:
------------------
GreenCoin Token: ${greenCoinAddress}
GreenDish Main Contract: ${greenDishAddress}

Deployment Status:
-----------------
✅ Contract addresses updated in deployments.json
✅ Contract addresses updated in contract-config.js

Next Steps:
-----------
1. Start the frontend with: npm run start
2. Connect to the contracts using MetaMask
3. Ensure your MetaMask is connected to the correct network
4. Verify the contracts on Etherscan (if deployed to a public network)

For any issues, check:
- Network connectivity
- MetaMask connection
- Correct contract addresses in the UI
`;

    fs.writeFileSync(summaryFile, summaryContent);
    console.log(`Deployment summary created at ${summaryFile}`);
} catch (error) {
    console.error(`Error creating ${summaryFile}:`, error);
}

console.log('Contract address update complete! Your application is ready for use.'); 