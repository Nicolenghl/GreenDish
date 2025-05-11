    enum LoyaltyTier {
        BRONZE,
        SILVER,
        GOLD,
        PLATINUM



    event LoyaltyTierUpdated(
        address indexed customer,
        LoyaltyTier tier,
        uint256 multiplier
    );



       event LoyaltyTierUpdated(
        address indexed customer,
        LoyaltyTier tier,
        uint256 multiplier
    );





        function _updateLoyaltyTier(address customer) internal {
        uint credits = customerCarbonCredits[customer];
        LoyaltyTier oldTier = customerTier[customer];
        LoyaltyTier newTier;

        if (credits >= 5000) newTier = LoyaltyTier.PLATINUM;
        else if (credits >= 2000) newTier = LoyaltyTier.GOLD;
        else if (credits >= 500) newTier = LoyaltyTier.SILVER;
        else newTier = LoyaltyTier.BRONZE;

        if (
            newTier != oldTier ||
            (customer != address(0) &&
                oldTier == LoyaltyTier(0) &&
                credits == 0)
        ) {
            customerTier[customer] = newTier;
            emit LoyaltyTierUpdated(
                customer,
                newTier,
                tierMultipliers[uint(newTier)]
            );
        }
    }