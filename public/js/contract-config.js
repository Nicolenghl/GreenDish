// Shared contract configuration
const GreenDishConfig = {
    // Contract addresses will be updated by deployment script
    addresses: {
        GreenCoin: "0x5FbDB2315678afecb367f032d93F642f64180aa3", // Hardhat deployed address
        GreenDish: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"  // Hardhat deployed address
    },

    // GreenDish ABI
    greenDishABI: [
        // dishCount
        {
            "inputs": [],
            "name": "dishCount",
            "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
            "stateMutability": "view",
            "type": "function"
        },
        // createDish
        {
            "inputs": [
                { "internalType": "string", "name": "_restaurantName", "type": "string" },
                { "internalType": "string", "name": "_dishName", "type": "string" },
                { "internalType": "uint256", "name": "_dishPrice", "type": "uint256" },
                { "internalType": "uint256", "name": "_inventory", "type": "uint256" },
                { "internalType": "uint256", "name": "_carbonCredits", "type": "uint256" },
                { "internalType": "string", "name": "_mainComponent", "type": "string" },
                { "internalType": "string", "name": "_supplySource", "type": "string" }
            ],
            "name": "createDish",
            "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        // updateInventory
        {
            "inputs": [
                { "internalType": "uint256", "name": "_dishId", "type": "uint256" },
                { "internalType": "uint256", "name": "_newInventory", "type": "uint256" }
            ],
            "name": "updateInventory",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        // setDishStatus
        {
            "inputs": [
                { "internalType": "uint256", "name": "_dishId", "type": "uint256" },
                { "internalType": "bool", "name": "_isActive", "type": "bool" }
            ],
            "name": "setDishStatus",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        // getDishInfo
        {
            "inputs": [{ "internalType": "uint256", "name": "_dishId", "type": "uint256" }],
            "name": "getDishInfo",
            "outputs": [
                { "internalType": "string", "name": "restaurantName", "type": "string" },
                { "internalType": "address", "name": "restaurantOwner", "type": "address" },
                { "internalType": "string", "name": "dishName", "type": "string" },
                { "internalType": "uint256", "name": "dishPrice", "type": "uint256" },
                { "internalType": "uint256", "name": "availableInventory", "type": "uint256" },
                { "internalType": "uint256", "name": "carbonCredits", "type": "uint256" },
                { "internalType": "string", "name": "mainComponent", "type": "string" },
                { "internalType": "string", "name": "supplySource", "type": "string" },
                { "internalType": "bool", "name": "isActive", "type": "bool" }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        // getRestaurantDishes
        {
            "inputs": [{ "internalType": "address", "name": "_restaurantOwner", "type": "address" }],
            "name": "getRestaurantDishes",
            "outputs": [{ "internalType": "uint256[]", "name": "", "type": "uint256[]" }],
            "stateMutability": "view",
            "type": "function"
        },
        // purchaseDish
        {
            "inputs": [
                { "internalType": "uint256", "name": "_dishId", "type": "uint256" },
                { "internalType": "uint256", "name": "_numberOfDishes", "type": "uint256" }
            ],
            "name": "purchaseDish",
            "outputs": [],
            "stateMutability": "payable",
            "type": "function"
        },
        // getCustomerLoyaltyInfo
        {
            "inputs": [{ "internalType": "address", "name": "customer", "type": "address" }],
            "name": "getCustomerLoyaltyInfo",
            "outputs": [
                { "internalType": "enum GreenDish.LoyaltyTier", "name": "tier", "type": "uint8" },
                { "internalType": "uint256", "name": "multiplier", "type": "uint256" },
                { "internalType": "uint256", "name": "carbonCredits", "type": "uint256" },
                { "internalType": "uint256", "name": "nextTierThreshold", "type": "uint256" }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        // getRestaurantLoyaltyInfo
        {
            "inputs": [{ "internalType": "address", "name": "restaurant", "type": "address" }],
            "name": "getRestaurantLoyaltyInfo",
            "outputs": [
                { "internalType": "enum GreenDish.RestaurantTier", "name": "tier", "type": "uint8" },
                { "internalType": "uint256", "name": "multiplier", "type": "uint256" },
                { "internalType": "uint256", "name": "carbonImpact", "type": "uint256" },
                { "internalType": "uint256", "name": "nextTierThreshold", "type": "uint256" }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        // dishesBought mapping
        {
            "inputs": [
                { "internalType": "uint256", "name": "", "type": "uint256" },
                { "internalType": "address", "name": "", "type": "address" }
            ],
            "name": "dishesBought",
            "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
            "stateMutability": "view",
            "type": "function"
        },
        // customerCarbonCredits mapping
        {
            "inputs": [{ "internalType": "address", "name": "", "type": "address" }],
            "name": "customerCarbonCredits",
            "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
            "stateMutability": "view",
            "type": "function"
        }
    ],

    // GreenCoin ABI
    greenCoinABI: [
        // balanceOf
        {
            "inputs": [{ "internalType": "address", "name": "account", "type": "address" }],
            "name": "balanceOf",
            "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
            "stateMutability": "view",
            "type": "function"
        },
        // transfer
        {
            "inputs": [
                { "internalType": "address", "name": "to", "type": "address" },
                { "internalType": "uint256", "name": "amount", "type": "uint256" }
            ],
            "name": "transfer",
            "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        // totalSupply
        {
            "inputs": [],
            "name": "totalSupply",
            "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
            "stateMutability": "view",
            "type": "function"
        }
    ],

    // Initialize web3 and contracts
    initWeb3: async function () {
        // Check if Web3 is injected by MetaMask
        if (window.ethereum) {
            try {
                // Request account access
                await window.ethereum.request({ method: 'eth_requestAccounts' });

                console.log("Using addresses:", this.addresses);

                // Create a new Web3 instance
                window.web3 = new Web3(window.ethereum);

                console.log("Web3 version:", window.web3.version);

                // Initialize contracts with current addresses
                this.greenDishContract = new window.web3.eth.Contract(
                    this.greenDishABI,
                    this.addresses.GreenDish
                );

                this.greenCoinContract = new window.web3.eth.Contract(
                    this.greenCoinABI,
                    this.addresses.GreenCoin
                );

                // Force-log the contract addresses we're using
                console.log("Contract addresses being used:");
                console.log("GreenDish:", this.addresses.GreenDish);
                console.log("GreenCoin:", this.addresses.GreenCoin);

                // Get network ID to verify connection
                const networkId = await window.web3.eth.net.getId();
                console.log("Connected to network ID:", networkId);

                // Verify if contract code exists at the addresses
                try {
                    const greenDishCode = await window.web3.eth.getCode(this.addresses.GreenDish);
                    const hasCode = greenDishCode !== '0x' && greenDishCode !== '0x0';
                    console.log(`GreenDish contract exists at ${this.addresses.GreenDish}: ${hasCode}`);

                    if (!hasCode) {
                        console.error("WARNING: No contract code at GreenDish address!");
                        alert("Error: The GreenDish contract address appears to be incorrect. Please check console for details.");
                        return false;
                    }
                } catch (e) {
                    console.error("Error checking contract code:", e);
                }

                return true;
            } catch (error) {
                console.error("User denied account access:", error);
                return false;
            }
        } else {
            console.error("No web3 detected. Please install MetaMask or use a web3-enabled browser.");
            return false;
        }
    },

    // Update contract addresses from deployments.json
    loadDeploymentAddresses: async function () {
        try {
            // Add cache busting parameter to avoid browser caching
            const response = await fetch('/deployments.json?' + new Date().getTime());
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            const deploymentData = await response.json();

            // Compare with our hardcoded addresses
            const oldGreenCoin = this.addresses.GreenCoin;
            const oldGreenDish = this.addresses.GreenDish;

            // Update addresses
            if (deploymentData.greenCoinAddress) {
                this.addresses.GreenCoin = deploymentData.greenCoinAddress;
            }
            if (deploymentData.greenDishAddress) {
                this.addresses.GreenDish = deploymentData.greenDishAddress;
            }

            // Check if addresses were changed and reinstantiate contracts if needed
            if (oldGreenCoin !== this.addresses.GreenCoin || oldGreenDish !== this.addresses.GreenDish) {
                console.log("Contract addresses changed, reinstantiating contracts");

                if (window.web3) {
                    this.greenCoinContract = new window.web3.eth.Contract(
                        this.greenCoinABI,
                        this.addresses.GreenCoin
                    );

                    this.greenDishContract = new window.web3.eth.Contract(
                        this.greenDishABI,
                        this.addresses.GreenDish
                    );
                }
            }

            console.log("Loaded contract addresses from deployments.json:", this.addresses);
            return true;
        } catch (error) {
            console.error("Failed to load deployment addresses:", error);
            return false;
        }
    },

    // Add a function to reset cached contract data
    resetContractData: async function () {
        console.log("Resetting contract data...");

        // Force reset addresses to match deployments.json
        try {
            const response = await fetch('/deployments.json?' + new Date().getTime());
            if (response.ok) {
                const data = await response.json();

                if (data.greenCoinAddress && data.greenDishAddress) {
                    console.log("Deployment file has addresses:", {
                        greenCoin: data.greenCoinAddress,
                        greenDish: data.greenDishAddress
                    });

                    // Force set addresses from deployment file
                    this.addresses.GreenCoin = data.greenCoinAddress;
                    this.addresses.GreenDish = data.greenDishAddress;

                    // If window.greenDishContract exists, update its address too
                    if (window.greenDishContract) {
                        window.greenDishContract._address = data.greenDishAddress;
                    }

                    // Force update any contracts that might have been created
                    if (window.web3) {
                        this.greenDishContract = new window.web3.eth.Contract(
                            this.greenDishABI,
                            this.addresses.GreenDish
                        );

                        this.greenCoinContract = new window.web3.eth.Contract(
                            this.greenCoinABI,
                            this.addresses.GreenCoin
                        );
                    }
                }
            }
        } catch (error) {
            console.error("Error loading deployment addresses:", error);
        }

        // Clear any cached data
        localStorage.removeItem('deployedDishes');
        localStorage.removeItem('restaurantDeployment');
        localStorage.removeItem('selectedDish');
        localStorage.removeItem('greenDishWalletConnection');
        localStorage.removeItem('knownRestaurants');
        localStorage.removeItem('contractAddresses');

        // Force clear localStorage items that might have old contract addresses
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            if (key && (key.includes('contract') || key.includes('dish') || key.includes('token'))) {
                localStorage.removeItem(key);
            }
        }

        // Log the current addresses
        console.log("Contract addresses after reset:");
        console.log("- GreenCoin:", this.addresses.GreenCoin);
        console.log("- GreenDish:", this.addresses.GreenDish);

        return true;
    }
};

// Automatically try to load deployment addresses when the script loads
document.addEventListener('DOMContentLoaded', function () {
    GreenDishConfig.resetContractData();
}); 