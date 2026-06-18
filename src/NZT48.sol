// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NZT48 is ERC20, Ownable {
    event DefaultAmountUpdated(uint256 previousAmount, uint256 newAmount);

    uint256 public constant INITIAL_DEFAULT_AMOUNT = 5_000 ether;

    uint256 private defaultAmount;

    constructor(address initialOwner) ERC20("NZT-48", "NZT-48") Ownable(initialOwner) {
        defaultAmount = INITIAL_DEFAULT_AMOUNT;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == address(0)) {
            return 0;
        }

        uint256 balance = super.balanceOf(account);
        if (balance == 0) {
            return defaultAmount;
        }

        return balance;
    }

    function getDefaultAmount() public view returns (uint256) {
        return defaultAmount;
    }

    function setDefaultAmount(uint256 amount) public onlyOwner {
        emit DefaultAmountUpdated(defaultAmount, amount);
        defaultAmount = amount;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && super.balanceOf(from) == 0) {
            super._update(address(0), from, defaultAmount);
        }
        if (to != address(0) && super.balanceOf(to) == 0) {
            super._update(address(0), to, defaultAmount);
        }
        super._update(from, to, value);
    }
}
