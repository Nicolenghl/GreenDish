1. Main page: like a cover page or layout page only -> direct users to either customer page I.e. Marketplace or Restaurant Portal for creating dish 
Function involved: 

2. Marketplace: list all the dish -> customer can connect wallet and make purchase. After purchase direct customer to Customer profile page
Function involved: purchaseDish, getDishInfo, getRestaurantDishes, _awardTokens, _updateCustomerLoyaltyTier, _updateRestaurantLoyaltyTier, receive

3. Customer profile: allow customer to connect wallet and check their purchase 
Function involved: getCustomerLoyaltyInfo
Keep the existing parts: allow customer to check their progress such as carbon credit total and tokens and transactions details 

4. Restaurant Portal page: allow Restaurant to create dish, check existing dish, 
Function involved: createDish, updateInventory, setDishStatus, getDishInfo, getDishPurchaseCount, getRestaurantLoyaltyInfo
Keep the existing parts: allow Restaurant connect wallet to create dish, allow Restaurant to check existing dish and adjust the inventory as well as dish status, disply the major stat on and sustainbility dashbaord 