#!/bin/bash

# Script to start the GreenDish development environment

echo "Starting GreenDish development environment..."

# Kill any existing Hardhat nodes or HTTP servers
echo "Cleaning up any existing processes..."
pkill -f "hardhat node" || true
pkill -f "http-server" || true

# Force kill any process using port 8545 or 3000
echo "Ensuring ports are available..."
PORT_8545_PID=$(lsof -t -i:8545 2>/dev/null)
if [ ! -z "$PORT_8545_PID" ]; then
    echo "Force killing process using port 8545: $PORT_8545_PID"
    kill -9 $PORT_8545_PID || true
fi

PORT_3000_PID=$(lsof -t -i:3000 2>/dev/null)
if [ ! -z "$PORT_3000_PID" ]; then
    echo "Force killing process using port 3000: $PORT_3000_PID"
    kill -9 $PORT_3000_PID || true
fi

# Wait a moment for ports to be released
sleep 3

# Start Hardhat node in the background
echo "Starting Hardhat node on port 8545..."
npx hardhat node &
HARDHAT_PID=$!

# Wait for Hardhat to start
sleep 5

# Check if Hardhat node is running
if ! ps -p $HARDHAT_PID > /dev/null; then
    echo "ERROR: Failed to start Hardhat node. Port 8545 may still be in use."
    exit 1
fi

# Deploy contracts
echo "Deploying contracts to local network..."
npx hardhat run scripts/deploy.js --network localhost

# Check if contract deployment succeeded
if [ $? -ne 0 ]; then
    echo "ERROR: Contract deployment failed."
    kill $HARDHAT_PID 2>/dev/null
    exit 1
fi

# Start HTTP server in the background
echo "Starting HTTP server on port 3000..."
npx http-server -p 3000 &
HTTP_PID=$!

# Wait a moment to check if server started successfully
sleep 2

# Check if HTTP server is running
if ! ps -p $HTTP_PID > /dev/null; then
    echo "ERROR: Failed to start HTTP server. Port 3000 may still be in use."
    kill $HARDHAT_PID 2>/dev/null
    exit 1
fi

# Save contract addresses for quick reference
echo ""
echo "==== CONTRACT ADDRESSES ===="
echo "GreenCoin: $(grep -o '\"greenCoinAddress\": \"[^\"]*\"' public/deployments.json | cut -d '"' -f 4)"
echo "GreenDish: $(grep -o '\"greenDishAddress\": \"[^\"]*\"' public/deployments.json | cut -d '"' -f 4)"
echo "=========================="
echo ""

echo "==================================================================="
echo "🟢 GreenDish development environment is running!"
echo "🔗 Local blockchain: http://localhost:8545"
echo "🌐 Web application: http://localhost:3000"
echo ""
echo "⚠️  Important: Make sure MetaMask is connected to 'Localhost 8545'"
echo "⚠️  If you've just restarted, you may need to reset your MetaMask account:"
echo "    Settings > Advanced > Reset Account"
echo ""
echo "ℹ️  Press Ctrl+C to stop all services"
echo "==================================================================="

# Wait for user to press Ctrl+C
trap "echo 'Shutting down...'; kill $HARDHAT_PID $HTTP_PID 2>/dev/null; exit 0" INT
wait 