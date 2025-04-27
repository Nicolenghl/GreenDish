    'use client';
    
    import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
    import GreenDishABI from '../contracts/GreenDish.json';
    
    // We'll load ethers from CDN in a script tag
    declare const ethers: any;
    declare const Web3Modal: any;
    
    interface Web3ContextType {
      connect: () => Promise<void>;
      disconnect: () => void;
      account: string | null;
      provider: any | null;
      signer: any | null;
      contract: any | null;
      isConnected: boolean;
      isRestaurant: boolean;
      loading: boolean;
    }
    
    const Web3Context = createContext<Web3ContextType>({
      connect: async () => { },
      disconnect: () => { },
      account: null,
      provider: null,
      signer: null,
      contract: null,
      isConnected: false,
      isRestaurant: false,
      loading: false,
    });
    
    export const useWeb3 = () => useContext(Web3Context);
    
    // Contract address - replace with your deployed contract address
    const CONTRACT_ADDRESS = '0xa0F34A0678692D9CaB997435958effAC4B709582';
    
    export const Web3Provider = ({ children }: { children: ReactNode }) => {
      const [account, setAccount] = useState<string | null>(null);
      const [provider, setProvider] = useState<any | null>(null);
      const [signer, setSigner] = useState<any | null>(null);
      const [contract, setContract] = useState<any | null>(null);
      const [isConnected, setIsConnected] = useState(false);
      const [isRestaurant, setIsRestaurant] = useState(false);
      const [loading, setLoading] = useState(false);
      const [ethersLoaded, setEthersLoaded] = useState(false);
    
      // Load ethers and web3modal from CDN
      useEffect(() => {
        const loadEthers = async () => {
          // Check if already loaded
          if (typeof window !== 'undefined' && !window.ethers) {
            const ethersScript = document.createElement('script');
            ethersScript.src = 'https://cdn.ethers.io/lib/ethers-5.7.umd.min.js';
            ethersScript.async = true;
            ethersScript.onload = () => {
              const web3ModalScript = document.createElement('script');
              web3ModalScript.src = 'https://unpkg.com/web3modal@1.9.12/dist/index.js';
              web3ModalScript.async = true;
              web3ModalScript.onload = () => {
                setEthersLoaded(true);
              };
              document.body.appendChild(web3ModalScript);
            };
            document.body.appendChild(ethersScript);
          } else {
            setEthersLoaded(true);
          }
        };
    
        loadEthers();
      }, []);
    
      const connect = async () => {
        if (!ethersLoaded) return;
        
        try {
          setLoading(true);
          const web3Modal = new Web3Modal({
            cacheProvider: true,
            providerOptions: {},
          });
    
          const instance = await web3Modal.connect();
          const provider = new ethers.providers.Web3Provider(instance);
          const signer = provider.getSigner();
          const accounts = await provider.listAccounts();
          const account = accounts[0];
    
          const contract = new ethers.Contract(
            CONTRACT_ADDRESS,
            GreenDishABI.abi,
            signer
          );
    
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
          instance.on('accountsChanged', (accounts: string[]) => {
            setAccount(accounts[0]);
            window.location.reload();
          });
    
          // Handle chain changes
          instance.on('chainChanged', () => {
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
        localStorage.removeItem('WEB3_CONNECT_CACHED_PROVIDER');
      };
    
      useEffect(() => {
        if (ethersLoaded && localStorage.getItem('WEB3_CONNECT_CACHED_PROVIDER')) {
          connect();
        }
      }, [ethersLoaded]);
    
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
            loading,
          }}
        >
          {children}
        </Web3Context.Provider>
      );
    };
