# Movie Ticket Booking System - Developer Guide

This document provides guidance on how to modify and update the Movie Ticket Booking system, including both the smart contract and the frontend UI.

## Project Structure Overview

```
├── contracts/                 # Smart contract files
│   ├── MovieTicketBooking.sol # Main contract for movie ticket booking
├── scripts/                   # Deployment and utility scripts
│   ├── deploy.js              # Script to deploy the contract
│   ├── save-deployment.js     # Helper to save deployment info
│   ├── serve-frontend.js      # Script to serve the frontend
├── public/                    # Frontend files
│   ├── index.html             # Dashboard page
│   ├── profile.html           # User profile page
│   ├── admin.html             # Admin panel
│   ├── artifacts/             # Compiled contract artifacts
│   ├── deployments.json       # Deployment information
├── hardhat.config.js          # Hardhat configuration
├── MovieTicketBooking.sol     # Copy of main contract in root directory
```

## Smart Contract Modification

### Main Contract File

The primary smart contract is `MovieTicketBooking.sol`, which can be found in:

1. Root directory: `./MovieTicketBooking.sol`
2. Contracts directory: `./contracts/MovieTicketBooking.sol`

When making changes to the contract:

1. Update both copies of the contract to ensure consistency
2. The contract follows a simple model with these key functions:
   - `buyTicket()` - For purchasing tickets
   - `getAvailableSeats()` - To check availability 
   - `getTotalTicketsBought()` - To check tickets owned by an address

### Contract Deployment Process

To update and deploy the contract:

1. Modify the contract code as needed
2. Update the deployment script (`scripts/deploy.js`) if your contract changes require different constructor parameters
3. Compile the contract with: `npx hardhat compile`
4. Deploy using: `npx hardhat run scripts/deploy.js --network localhost`

## Frontend UI Modification

The system includes three main UI files:

### 1. Dashboard (index.html)

**File location:** `public/index.html`

This is the main user interface where users can:
- Browse available movies in a card-based layout
- Select and buy tickets for movies
- Check available seats

**Key components to modify:**
- Movie card grid (CSS: `.movie-card` and related classes)
- Movie information display (`.info-container`)
- Ticket purchase form (`.ticket-section`)

**JavaScript functions to update if needed:**
- `loadAllMovies()` - Loads and displays movie cards
- `selectMovie()` - Handles movie selection
- `buyTickets()` - Processes ticket purchases

### 2. User Profile (profile.html)

**File location:** `public/profile.html`

Shows the user's purchased tickets across all movies.

**Key components to modify:**
- Profile header (`.profile-header`)
- Ticket statistics (`.ticket-stats` and `.stat-card`)
- Tickets table (`.tickets-container` and `#tickets-table`)

**JavaScript functions to update if needed:**
- `loadTickets()` - Retrieves and displays the user's tickets

### 3. Admin Panel (admin.html)

**File location:** `public/admin.html`

Interface for admins to create and manage movie contracts.

**Key components to modify:**
- Movie creation form (`#deploy-form`)
- Deployed movies list (`.movie-item`)

**JavaScript functions to update if needed:**
- `deployNewMovieContract()` - Creates new movie contracts
- `renderMovieList()` - Displays deployed movies

## Integration Between UI and Smart Contract

The integration between the UI and smart contract is managed through:

1. **Contract ABI**: Located at `public/artifacts/contracts/MovieTicketBooking.sol/MovieTicketBooking.json`
   - This is automatically generated when compiling the contract
   - The UI loads this to know how to interact with the contract

2. **Contract Addresses**: Stored in:
   - `public/deployments.json` - For server-side access
   - Browser's `localStorage` - For client-side access under keys:
     - `'latestDeployment'` - Currently selected movie
     - `'deployedMovies'` - List of all deployed movies

If you modify the contract, ensure the following:
1. Recompile to update the ABI
2. Test new functions in all relevant UI files
3. Update any affected JavaScript functions that call the contract

## Testing Your Changes

After making changes:

1. Compile the contract: `npx hardhat compile`
2. Start a local node: `npx hardhat node`
3. Deploy the contract: `npx hardhat run scripts/deploy.js --network localhost`
4. Start the frontend: `npx hardhat serve`
5. Visit http://localhost:3000 in your browser

## Common Modification Scenarios

### 1. Adding a New Contract Feature

1. Update `MovieTicketBooking.sol` with your new function
2. Recompile the contract
3. Add corresponding UI elements and JavaScript functions to call your new feature

### 2. Updating the UI Design

1. Modify the relevant HTML and CSS in the specific page file
2. Test the changes at different screen sizes for responsiveness
3. Ensure consistent styling across all three pages

### 3. Adding a New Page

1. Create a new HTML file in the `public/` directory
2. Copy the header, navigation, and basic structure from an existing page
3. Update the navigation links in all pages to include your new page
4. Add the necessary JavaScript to interact with the contract

## Best Practices

1. **Smart Contract:**
   - Always test new functions thoroughly
   - Consider gas efficiency
   - Keep functions simple and focused

2. **UI Design:**
   - Maintain consistent styling across pages
   - Test UI changes in multiple browsers
   - Consider mobile responsiveness

3. **Integration:**
   - Always check if your contract changes break existing UI functionality
   - Update the ABI references if you change function signatures 