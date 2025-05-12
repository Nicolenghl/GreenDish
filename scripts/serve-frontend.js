const handler = require('serve-handler');
const http = require('http');
const path = require('path');
const fs = require('fs');

// Check if there's a deployment
const deploymentFile = path.join(__dirname, '../public/deployments.json');
let contractAddress = null;

if (fs.existsSync(deploymentFile)) {
  try {
    const deployment = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
    contractAddress = deployment.contractAddress;
    console.log('Found contract deployment:', contractAddress);
  } catch (error) {
    console.error('Error parsing deployments.json:', error);
  }
}

// Create HTTP server
const server = http.createServer((request, response) => {
  return handler(request, response, {
    public: path.join(__dirname, '../public')
  });
});

// Select port
const port = process.env.PORT || 3000;

// Start server
server.listen(port, () => {
  console.log(`Frontend server running at http://localhost:${port}`);

  if (contractAddress) {
    console.log('Contract address:', contractAddress);
    console.log(`Admin panel: http://localhost:${port}/admin.html`);
    console.log(`User interface: http://localhost:${port}/index.html`);
    console.log(`User profile: http://localhost:${port}/profile.html`);
  } else {
    console.log('No contract deployment found. Please deploy a contract first:');
    console.log('  npm run deploy');
  }

  console.log('\nPress Ctrl+C to stop the server');
});
