// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GreenCoin
 * @dev ERC20 Token for the GreenDish ecosystem
 * Rewards users for sustainable food choices with carbon credits
 */
contract GreenCoin is ERC20, ERC20Burnable, Ownable {
    // Maximum supply of tokens (1 million tokens)
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18;

    // Percentage for ecosystem rewards (30%)
    uint256 public constant ECOSYSTEM_PERCENTAGE = 30;

    // Amount allocated to reward pool
    uint256 public rewardPoolAllocation;

    /**
     * @dev Constructor initializes the token with name and symbol
     * Mints the total supply to the deployer
     */
    constructor() ERC20("GreenCoin", "GRC") Ownable(msg.sender) {
        // Mint all tokens to the deployer
        _mint(msg.sender, MAX_SUPPLY);
    }

    /**
     * @dev Allocates 30% of tokens to the reward pool
     * @param rewardPool The address of the reward pool (GreenDish contract)
     */
    function allocateToRewardPool(address rewardPool) external onlyOwner {
        require(rewardPool != address(0), "Invalid reward pool address");

        // Calculate 30% of total supply for ecosystem rewards
        uint256 ecosystemAmount = (MAX_SUPPLY * ECOSYSTEM_PERCENTAGE) / 100;

        require(
            balanceOf(msg.sender) >= ecosystemAmount,
            "Insufficient balance"
        );

        // Transfer tokens to reward pool
        _transfer(msg.sender, rewardPool, ecosystemAmount);
        rewardPoolAllocation = ecosystemAmount;
    }

    /**
     * @dev Award tokens to users based on their sustainable choices
     * @param from The address sending the tokens (should be the reward pool)
     * @param recipient The address receiving the rewards
     * @param amount The amount of tokens to reward
     */
    function awardTokens(
        address from,
        address recipient,
        uint256 amount
    ) external {
        require(balanceOf(from) >= amount, "Insufficient reward pool balance");
        require(recipient != address(0), "Cannot reward zero address");
        require(amount > 0, "Reward amount must be greater than zero");

        // Only the token owner or the reward pool itself can call this
        require(
            msg.sender == owner() || msg.sender == from,
            "Unauthorized: only owner or reward pool can award tokens"
        );

        _transfer(from, recipient, amount);
    }
}
