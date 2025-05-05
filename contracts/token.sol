// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenCoin {
    // Token Variables
    string public name = "GreenCoin";
    string public symbol = "GRC";
    uint8 public decimals = 18;
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18; // 1 million tokens with 18 decimals
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // Constructor - mint all tokens to deployer
    constructor() {
        totalSupply = MAX_SUPPLY;
        balances[msg.sender] = MAX_SUPPLY;
        emit Transfer(address(0), msg.sender, MAX_SUPPLY);
    }

    // Standard ERC20 functions
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return allowances[owner][spender];
    }

    // =============== TOKEN FUNCTIONS =============== //
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(
            allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    receive() external payable {}

    fallback() external payable {}
}
