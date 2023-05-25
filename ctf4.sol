// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
It is a contract which helps you to unwrap your Debt tokens and get your Collateral back.
At the beginning you are gifted with some Debt tokens.
To complete this level you need to redeem more Collateral tokens than Debt tokens you initially had.
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Unwrapper is ERC20 {
    IERC20 public debtToken;

    mapping(address => uint256) public redeemed;

    constructor(address _debtToken) ERC20("Collateral Token", "CTKN") {
        debtToken = IERC20(_debtToken);
    }

    function getRedeemable(uint256 amount) public view returns (uint256) {
        return debtToken.balanceOf(msg.sender) / amount;
    }

    function redeem(uint256 amount, uint256 toRedeem) public {
        require(amount <= debtToken.balanceOf(msg.sender), "Insufficient balance");

        uint256 redeemable = this.getRedeemable(amount);
        require(toRedeem <= redeemable, "Attempt to redeem more than expected");

        redeemed[msg.sender] += toRedeem;

        debtToken.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, toRedeem);
    }

}