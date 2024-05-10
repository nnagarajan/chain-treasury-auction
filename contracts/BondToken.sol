// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// Bond Token Contract
contract BondToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public couponRate;
    uint public maturityInYears;
    address contractOwner;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    constructor(string memory _name, string memory _symbol, uint _maturityInYears, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        maturityInYears = _maturityInYears;
        decimals = 0; // Assuming standard 18 decimal places for ERC20 tokens
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
        console.log(string.concat("Token Balance: ", Strings.toString(balances[msg.sender])));
        contractOwner = msg.sender;
    }

    function findBalance(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        console.log(
            string.concat(
                "ERC20: transfer amount ",
                Strings.toString(amount),
                " balance ",
                Strings.toString(balances[contractOwner])
            )
        );

        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount <= balances[msg.sender],
            string.concat(
                "ERC20: transfer amount ",
                Strings.toString(amount),
                " exceeds balance ",
                Strings.toString(balances[msg.sender])
            )
        );

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowed[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balances[sender], "ERC20: transfer amount exceeds balance");
        require(amount <= allowed[sender][msg.sender], "ERC20: transfer amount exceeds allowance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, allowed[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowed[msg.sender][spender];
        require(subtractedValue <= currentAllowance, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // function derivedPrice(uint bidYield) external view returns (uint) {
    //     uint256 r = (100 + bidYield) ** maturityInYears;
    //     uint derivedBondPrice = ((couponRate * 100) / bidYield) * 100 * (10000 - (1e24 / r)) + 1e28 / r;
    //     derivedBondPrice = derivedBondPrice / 1e6;
    //     console.log(string.concat("Derived Bond Price ", Strings.toString(derivedBondPrice)));
    //     return derivedBondPrice;
    // }

    function derivedPrice(uint256 bidYield) external view returns (uint) {
        console.log(string.concat("bidYield ", Strings.toString(bidYield)));
        console.log(string.concat("maturityInYears ", Strings.toString(maturityInYears)));
        uint256 r = (10000 + bidYield) ** maturityInYears;
        console.log(string.concat("r ", Strings.toString(r)));
        console.log(string.concat("1e44/r ", Strings.toString(1e46 / r)));
        console.log(string.concat("(10000 - (1e44 / r)) ", Strings.toString((1000000 - (1e46 / r)))));
        console.log(
            string.concat(
                "((couponRate * 100) / bidYield) * 100 ",
                Strings.toString((((couponRate * 10000) / (bidYield))))
            )
        );
        uint256 a = (((couponRate * 10000) / (bidYield))) * 100 * (1000000 - (1e46 / r));
        console.log(string.concat("a ", Strings.toString(a)));
        uint256 b = 1e52 / r;
        console.log(string.concat("b ", Strings.toString(b)));
        uint256 derivedBondPrice = (a + b) / 1e8;
        console.log(string.concat("Derived Bond Price ", Strings.toString(derivedBondPrice)));
        return derivedBondPrice;
    }

    function setCouponRate(uint256 rate) external {
        couponRate = rate;
    }
}
