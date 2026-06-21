// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title NZT-48
/// @notice An experimental ERC20 where every ordinary address appears to already
///         hold a default balance. An account with no real balance reads as
///         `defaultAmount` from {balanceOf}, and that default is lazily minted
///         into the account the first time it sends or receives.
/// @dev Standalone, simplified source kept for inspection and local experiments.
///      This is not the source of the live Mainnet/Sepolia deployments; see
///      `deployments/` for the deployed (legacy) source and its provenance.
contract NZT48 is ERC20, Ownable {
    /// @notice Emitted when the owner changes the default balance.
    /// @param previousAmount The default in effect before the change.
    /// @param newAmount The new default applied to not-yet-materialized accounts.
    event DefaultAmountUpdated(uint256 previousAmount, uint256 newAmount);

    /// @notice The default balance set at construction (5,000 NZT-48).
    uint256 public constant INITIAL_DEFAULT_AMOUNT = 5_000 ether;

    /// @dev Balance reported for, and materialized into, accounts with no real balance.
    uint256 private defaultAmount;

    constructor(address initialOwner) ERC20("NZT-48", "NZT-48") Ownable(initialOwner) {
        defaultAmount = INITIAL_DEFAULT_AMOUNT;
    }

    /// @notice Returns the account's balance, substituting the current default for
    ///         any account that has no real balance.
    /// @dev The zero address is excluded and always reads as 0. A returned value
    ///      equal to `defaultAmount` is ambiguous: it may mean "freshly defaulted"
    ///      or "materialized to exactly that amount" — callers cannot tell which.
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

    /// @notice Returns the default balance currently applied to not-yet-materialized accounts.
    function getDefaultAmount() public view returns (uint256) {
        return defaultAmount;
    }

    /// @notice Sets the default balance for accounts that have not yet materialized.
    /// @dev Only affects still-virtual accounts; already-materialized balances are
    ///      left unchanged. Restricted to the owner.
    function setDefaultAmount(uint256 amount) public onlyOwner {
        emit DefaultAmountUpdated(defaultAmount, amount);
        defaultAmount = amount;
    }

    /// @dev Materializes the current default into either side of a transfer that has
    ///      no real balance yet (minting `defaultAmount` to it), then applies the
    ///      transfer. Reads `super.balanceOf` so an already-materialized account is
    ///      not topped up again. Runs for every transfer, including zero-value and
    ///      self-transfers.
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
