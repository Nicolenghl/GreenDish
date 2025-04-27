   'use client';
   
   import { useState } from 'react';
   import Link from 'next/link';
   import { useWeb3 } from '../context/Web3Context';
   
   export default function Navbar() {
     const { connect, disconnect, account, isConnected, isRestaurant } = useWeb3();
     
     const shortenAddress = (address: string) => {
       return `${address.slice(0, 6)}...${address.slice(-4)}`;
     };
   
     return (
       <header className="bg-white shadow">
         <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8" aria-label="Top">
           <div className="flex w-full items-center justify-between border-b border-green-500 py-6 lg:border-none">
             <div className="flex items-center">
               <Link href="/" className="text-2xl font-bold text-green-600">
                 GreenDish
               </Link>
               <div className="ml-10 hidden space-x-8 lg:block">
                 <Link href="/marketplace" className="text-base font-medium text-gray-700 hover:text-green-600">
                   Marketplace
                 </Link>
                 {isConnected && (
                   <Link href="/profile" className="text-base font-medium text-gray-700 hover:text-green-600">
                     Profile
                   </Link>
                 )}
                 {isRestaurant && (
                   <Link href="/restaurant/dashboard" className="text-base font-medium text-gray-700 hover:text-green-600">
                     Restaurant Dashboard
                   </Link>
                 )}
                 {!isRestaurant && isConnected && (
                   <Link href="/restaurant/register" className="text-base font-medium text-gray-700 hover:text-green-600">
                     Register Restaurant
                   </Link>
                 )}
               </div>
             </div>
             <div className="ml-10 space-x-4">
               {isConnected ? (
                 <div className="flex items-center space-x-4">
                   <span className="text-sm text-gray-700">{shortenAddress(account || '')}</span>
                   <button
                     onClick={disconnect}
                     className="inline-block rounded-md border border-transparent bg-red-500 py-2 px-4 text-base font-medium text-white hover:bg-red-600"
                   >
                     Disconnect
                   </button>
                 </div>
               ) : (
                 <button
                   onClick={connect}
                   className="inline-block rounded-md border border-transparent bg-green-600 py-2 px-4 text-base font-medium text-white hover:bg-green-700"
                 >
                   Connect Wallet
                 </button>
               )}
             </div>
           </div>
         </nav>
       </header>
     );
   }
