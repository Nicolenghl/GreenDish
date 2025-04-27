   'use client';
   
   import Navbar from './components/Navbar';
   import Link from 'next/link';
   import { useWeb3 } from './context/Web3Context';
   
   export default function Home() {
     const { isConnected } = useWeb3();
   
     return (
       <main className="min-h-screen bg-gradient-to-b from-green-50 to-green-100">
         <Navbar />
   
         <div className="relative isolate">
           <div className="py-24 sm:py-32 lg:pb-40">
             <div className="mx-auto max-w-7xl px-6 lg:px-8">
               <div className="mx-auto max-w-2xl text-center">
                 <h1 className="text-4xl font-bold tracking-tight text-green-900 sm:text-6xl">
                   Sustainable Dining with GreenDish
                 </h1>
                 <p className="mt-6 text-lg leading-8 text-gray-600">
                   A revolutionary platform connecting eco-conscious diners with sustainable restaurants.
                   Earn rewards while reducing your carbon footprint.
                 </p>
                 <div className="mt-10 flex items-center justify-center gap-x-6">
                   <Link
                     href="/marketplace"
                     className="rounded-md bg-green-600 px-5 py-3 text-md font-semibold text-white shadow-sm hover:bg-green-500"
                   >
                     Browse Marketplace
                   </Link>
                   <Link
                     href="/restaurant/register"
                     className="text-md font-semibold leading-6 text-gray-900"
                   >
                     Restaurant Sign-up <span aria-hidden="true">→</span>
                   </Link>
                 </div>
               </div>
             </div>
           </div>
         </div>
   
         <footer className="bg-green-900 text-white">
           <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
             <div className="mt-8 border-t border-green-800 pt-8 text-center">
               <p className="text-green-200 text-sm">
                 &copy; {new Date().getFullYear()} GreenDish. All rights reserved.
               </p>
             </div>
           </div>
         </footer>
       </main>
     );
   }
