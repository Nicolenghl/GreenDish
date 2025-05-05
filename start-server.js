// start-server.js - Serve the frontend for GreenDish token system
const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Configuration
const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.join(__dirname, 'public');

// MIME types for different file extensions
const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
};

// Create HTTP server
const server = http.createServer((req, res) => {
    console.log(`${req.method} ${req.url}`);

    // Handle root path
    let filePath = req.url === '/'
        ? path.join(PUBLIC_DIR, 'index.html')
        : path.join(PUBLIC_DIR, req.url);

    // Get file extension
    const ext = path.extname(filePath);

    // Set content type based on file extension
    const contentType = MIME_TYPES[ext] || 'text/plain';

    // Read file and send response
    fs.readFile(filePath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                // File not found
                res.writeHead(404);
                res.end('File not found');
            } else {
                // Server error
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
            }
        } else {
            // Success - send file content
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content);
        }
    });
});

// Check if contracts are deployed
function checkDeployments() {
    const deploymentPath = path.join(PUBLIC_DIR, 'deployments.json');

    if (!fs.existsSync(deploymentPath)) {
        console.log('\n❌ No deployments found. You need to deploy the contracts first.');
        console.log('\nTo deploy contracts:');
        console.log('1. Start a local Hardhat node in a separate terminal:');
        console.log('   npx hardhat node');
        console.log('\n2. Deploy contracts in another terminal:');
        console.log('   npx hardhat run scripts/deploy-factory.js --network localhost');
        return false;
    }

    try {
        const deploymentData = JSON.parse(fs.readFileSync(deploymentPath));

        if (!deploymentData.tokenAddress || !deploymentData.factoryAddress) {
            console.log('\n⚠️ Deployment file exists but is missing token or factory addresses.');
            return false;
        }

        console.log('\n✅ Contracts deployed:');
        console.log(`   Token Address:   ${deploymentData.tokenAddress}`);
        console.log(`   Factory Address: ${deploymentData.factoryAddress}`);
        return true;
    } catch (error) {
        console.log('\n❌ Error reading deployment file:', error.message);
        return false;
    }
}

// Start the server
server.listen(PORT, () => {
    console.log('\n=== GreenDish Token Reward System ===');
    console.log('\n🚀 Frontend server is running on:');
    console.log(`   http://localhost:${PORT}`);

    // Check for deployments
    const deployed = checkDeployments();

    if (!deployed) {
        console.log('\n💡 Remember, you need a hardhat node running in a separate terminal.');
        console.log('   Check the Hardhat documentation for more details.');
    }

    console.log('\n🔍 Press Ctrl+C to stop the server.');
});

// Listen for SIGINT signal (Ctrl+C)
process.on('SIGINT', () => {
    console.log('\n🛑 Stopping server...');
    server.close(() => {
        console.log('Server closed.');
        process.exit(0);
    });
}); 