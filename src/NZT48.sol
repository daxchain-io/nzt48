// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20FlashMint} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

contract NZT48 is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ERC20Permit, ERC20Votes, ERC20FlashMint {
    event TokensBurned(address indexed account, uint256 amount);

    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TOKEN_MANAGER = keccak256("TOKEN_MANAGER");

    uint256 private defaultAmount;

    constructor(address defaultAdmin) ERC20("NZT-48", "NZT-48") ERC20Permit("NZT-48") {
        _grantRole(BURNER_ROLE, defaultAdmin);
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, defaultAdmin);
        _grantRole(TOKEN_MANAGER, defaultAdmin);

        defaultAmount = 5_000 * 10 ** decimals();
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

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    function forceBurn(address account, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(account, amount);

        emit TokensBurned(account, amount);
    }

    function forceBurnAll(address account) public onlyRole(BURNER_ROLE) {
        uint256 balance = super.balanceOf(account);
        _burn(account, balance);

        emit TokensBurned(account, balance);
    }

    function getDefaultAmount() public view returns (uint256) {
        return defaultAmount;
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function setDefaultAmount(uint256 amount) public onlyRole(TOKEN_MANAGER) {
        defaultAmount = amount;
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable, ERC20Votes) {
        if (from != address(0) && super.balanceOf(from) == 0) {
            super._update(address(0), from, defaultAmount);
        }
        if (to != address(0) && super.balanceOf(to) == 0) {
            super._update(address(0), to, defaultAmount);
        }
        super._update(from, to, value);
    }
}
