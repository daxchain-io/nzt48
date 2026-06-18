// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
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
}
