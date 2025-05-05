const fs = require('fs');
const path = require('path');

// Function to save the contract address to a deployments.json file
// This will be used by the frontend to know where the contract is deployed
async function saveDeployment(contractAddress) {
    const deploymentsPath = path.join(__dirname, '../public/deployments.json');

    const deploymentData = {
        contractAddress: contractAddress,
        timestamp: new Date().toISOString()
    };

    fs.writeFileSync(
        deploymentsPath,
        JSON.stringify(deploymentData, null, 2)
    );

    console.log(`Deployment information saved to ${deploymentsPath}`);
}

module.exports = {
    saveDeployment
}; 