// This script helps during development to reset contract addresses in localStorage

(function () {
    // Force reset on page load for testing
    const forceReset = false;

    // Check if the URL has the reset parameter or we need to force reset
    const urlParams = new URLSearchParams(window.location.search);
    const resetParam = urlParams.get('reset');

    if (resetParam === 'true' || forceReset) {
        // Clear all restaurant and dish related data from localStorage
        localStorage.removeItem('restaurantDeployment');
        localStorage.removeItem('selectedDish');
        localStorage.removeItem('deployedDishes');
        localStorage.removeItem('greenDishWalletConnection');
        localStorage.removeItem('knownRestaurants');
        localStorage.removeItem('walletAddress');

        // Remove the reset parameter from URL only if it was explicitly set
        if (resetParam === 'true') {
            urlParams.delete('reset');
            const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
            window.history.replaceState({}, document.title, newUrl);
        }

        console.log('Contract addresses and localStorage data have been reset');

        // Only show alert if it wasn't force-reset by code
        if (resetParam === 'true') {
            alert('Contract data has been reset. Please refresh the page.');
        }
    }
})(); 