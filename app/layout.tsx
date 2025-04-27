   'use client';
   
   import './globals.css';
   import { Web3Provider } from './context/Web3Context';
   import { ToastContainer } from 'react-toastify';
   import 'react-toastify/dist/ReactToastify.css';
   
   export default function RootLayout({
     children,
   }: {
     children: React.ReactNode;
   }) {
     return (
       <html lang="en">
         <body>
           <Web3Provider>
             <ToastContainer position="top-right" autoClose={5000} />
             {children}
           </Web3Provider>
         </body>
       </html>
     );
   }
