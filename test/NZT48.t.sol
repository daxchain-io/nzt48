// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Test} from "forge-std/Test.sol";
import {NZT48} from "../src/NZT48.sol";

contract NZT48Test is Test {
    NZT48 private token;

    address private admin = address(0xA11CE);
    address private alice = address(0xA11CE01);
    address private bob = address(0xB0B);
    address private carol = address(0xCA401);
    address private spender = address(0x5EED);

    function setUp() public {
        token = new NZT48(admin);
    }

    function testFreshAccountReadsAsDefaultBalance() public view {
        assertEq(token.owner(), admin);
        assertEq(token.getDefaultAmount(), token.INITIAL_DEFAULT_AMOUNT());
        assertEq(token.balanceOf(alice), 5_000 ether);
        assertEq(token.totalSupply(), 0);
    }

    function testRejectsZeroOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        new NZT48(address(0));
    }

    function testZeroAddressDoesNotReadAsDefaultBalance() public view {
        assertEq(token.balanceOf(address(0)), 0);
    }

    function testTransferMaterializesDefaultBalances() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 100 ether));

        assertEq(token.balanceOf(alice), 4_900 ether);
        assertEq(token.balanceOf(bob), 5_100 ether);
        assertEq(token.totalSupply(), 10_000 ether);
    }

    function testZeroValueTransferStillMaterializesDefaultBalances() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 0));

        assertEq(token.balanceOf(alice), 5_000 ether);
        assertEq(token.balanceOf(bob), 5_000 ether);
        assertEq(token.totalSupply(), 10_000 ether);
    }

    function testSelfTransferMaterializesOnlyOneDefaultBalance() public {
        vm.prank(alice);
        assertTrue(token.transfer(alice, 100 ether));

        assertEq(token.balanceOf(alice), 5_000 ether);
        assertEq(token.totalSupply(), 5_000 ether);
    }

    function testMaterializedRecipientDoesNotReceiveDefaultAgain() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 100 ether));

        vm.prank(carol);
        assertTrue(token.transfer(bob, 25 ether));

        assertEq(token.balanceOf(alice), 4_900 ether);
        assertEq(token.balanceOf(bob), 5_125 ether);
        assertEq(token.balanceOf(carol), 4_975 ether);
        assertEq(token.totalSupply(), 15_000 ether);
    }

    function testAccountDrainedToZeroReadsAsDefaultAgain() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 5_000 ether));

        assertEq(token.balanceOf(alice), 5_000 ether);
        assertEq(token.balanceOf(bob), 10_000 ether);
        assertEq(token.totalSupply(), 10_000 ether);
    }

    function testDrainedAccountCanMaterializeAgain() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 5_000 ether));

        vm.prank(alice);
        assertTrue(token.transfer(carol, 1 ether));

        assertEq(token.balanceOf(alice), 4_999 ether);
        assertEq(token.balanceOf(bob), 10_000 ether);
        assertEq(token.balanceOf(carol), 5_001 ether);
        assertEq(token.totalSupply(), 20_000 ether);
    }

    function testTransferFromMaterializesDefaultBalances() public {
        vm.prank(alice);
        assertTrue(token.approve(spender, 100 ether));

        vm.prank(spender);
        assertTrue(token.transferFrom(alice, bob, 100 ether));

        assertEq(token.balanceOf(alice), 4_900 ether);
        assertEq(token.balanceOf(bob), 5_100 ether);
        assertEq(token.allowance(alice, spender), 0);
        assertEq(token.totalSupply(), 10_000 ether);
    }

    function testOwnerCanChangeDefaultAmount() public {
        vm.prank(admin);
        vm.expectEmit(address(token));
        emit NZT48.DefaultAmountUpdated(5_000 ether, 123 ether);
        token.setDefaultAmount(123 ether);

        assertEq(token.getDefaultAmount(), 123 ether);
        assertEq(token.balanceOf(alice), 123 ether);
    }

    function testDefaultChangeDoesNotRewriteMaterializedBalances() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 100 ether));

        vm.prank(admin);
        token.setDefaultAmount(123 ether);

        assertEq(token.balanceOf(alice), 4_900 ether);
        assertEq(token.balanceOf(bob), 5_100 ether);
        assertEq(token.balanceOf(carol), 123 ether);
    }

    function testNonOwnerCannotChangeDefaultAmount() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        token.setDefaultAmount(1 ether);
    }

    function testFreshAccountCannotSendMoreThanDefault() public {
        // Alice reads as holding the default, but only that default materializes,
        // so she cannot move more than it.
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 5_000 ether, 5_001 ether)
        );
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        token.transfer(bob, 5_001 ether);
    }

    function testTransferFromRevertsWithoutSufficientAllowance() public {
        vm.prank(alice);
        assertTrue(token.approve(spender, 10 ether));

        vm.prank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, spender, 10 ether, 100 ether)
        );
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        token.transferFrom(alice, bob, 100 ether);
    }
}
