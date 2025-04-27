'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';

// Create a simplified context
const Web3Context = createContext({
  connect: async () => {},
  disconnect: () => {},
  account: null,
  provider: null,
  signer: null,
  contract: null,
  isConnected: false,
  isRestaurant: false,
  loading: false,
});

export const useWeb3 = () => useContext(Web3Context);

// Replace with your actual contract address
const CONTRACT_ADDRESS = '0xa0F34A0678692D9CaB997435958effAC4B709582';

export const Web3Provider = ({ children }) => {
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [contract, setContract] = useState(null);
  const [isConnected, setIsConnected] = useState(false);
  const [isRestaurant, setIsRestaurant] = useState(false);
  const [loading, setLoading] = useState(false);
  const [ethersLoaded, setEthersLoaded] = useState(false);

  // Load ethers from CDN
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const loadEthers = async () => {
        if (!window.ethers) {
          const script = document.createElement('script');
          script.src = 'https://cdn.ethers.io/lib/ethers-5.7.umd.min.js';
          script.async = true;
          script.onload = () => setEthersLoaded(true);
          document.body.appendChild(script);
        } else {
          setEthersLoaded(true);
        }
      };
      loadEthers();
    }
  }, []);

  const connect = async () => {
    if (!ethersLoaded || typeof window === 'undefined') return;
    
    try {
      setLoading(true);
      
      // Check if MetaMask is installed
      if (!window.ethereum) {
        alert("Please install MetaMask to use this application");
        return;
      }
      
      // Request accounts from MetaMask
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const account = accounts[0];
      
      // Create provider and signer
      const provider = new window.ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      
      // Create contract instance
      // Note: We'll load the ABI dynamically to avoid TypeScript errors
      // In a real app, you'd import the ABI and use it here
      const contractAbi = [
        // Basic ABI functions - you can expand this as needed
        "function verifiedRestaurants(address) view returns (bool)",
        "function getDishes() view returns (uint[])",
        "function getDishDetails(uint) view returns (string, string, uint, uint, address, bool, bool)",
        "function purchaseDishWithEth(uint) payable",
        "function getCustomerCarbonCredits() view returns (uint)",
        "function getCustomerTokenBalance() view returns (uint)",
        "function getUserTransactions(uint, uint) view returns (tuple(uint, uint, uint, uint)[])",
        "function userTransactionCount(address) view returns (uint)",
        "function rateDish(uint, uint, string) returns (bool)",
        "function registerRestaurant(uint8, string) payable"
      ];
      
      const contract = new window.ethers.Contract(CONTRACT_ADDRESS, contractAbi, signer);
      
      setProvider(provider);
      setSigner(signer);
      setAccount(account);
      setContract(contract);
      setIsConnected(true);
      
      // Check if connected account is a verified restaurant
      try {
        const isVerified = await contract.verifiedRestaurants(account);
        setIsRestaurant(isVerified);
      } catch (error) {
        console.error("Error checking restaurant status:", error);
        setIsRestaurant(false);
      }
      
      // Handle account changes
      window.ethereum.on('accountsChanged', (accounts) => {
        setAccount(accounts[0]);
        window.location.reload();
      });
      
      // Handle chain changes
      window.ethereum.on('chainChanged', () => {
        window.location.reload();
      });
      
    } catch (error) {
      console.error("Error connecting to wallet:", error);
    } finally {
      setLoading(false);
    }
  };
  
  const disconnect = () => {
    setAccount(null);
    setProvider(null);
    setSigner(null);
    setContract(null);
    setIsConnected(false);
    setIsRestaurant(false);
  };
  
  return (
    <Web3Context.Provider
      value={{
        connect,
        disconnect,
        account,
        provider,
        signer,
        contract,
        isConnected,
        isRestaurant,
        loading
      }}
    >
      {children}
    </Web3Context.Provider>
  );
};
