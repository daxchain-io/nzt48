// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {NZT48} from "../src/NZT48.sol";

contract NZT48Test is Test {
    NZT48 private token;

    address private admin = address(0xA11CE);
    address private alice = address(0xA11CE01);
    address private bob = address(0xB0B);

    function setUp() public {
        token = new NZT48(admin);
    }

    function testFreshAccountReadsAsDefaultBalance() public view {
        assertEq(token.getDefaultAmount(), 5_000 ether);
        assertEq(token.balanceOf(alice), 5_000 ether);
        assertEq(token.totalSupply(), 0);
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

    function testBurnerCanForceBurnMaterializedBalance() public {
        vm.prank(alice);
        assertTrue(token.transfer(bob, 100 ether));

        vm.prank(admin);
        token.forceBurn(bob, 50 ether);

        assertEq(token.balanceOf(bob), 5_050 ether);
        assertEq(token.totalSupply(), 9_950 ether);
    }

    function testTokenManagerCanChangeDefaultAmount() public {
        vm.prank(admin);
        token.setDefaultAmount(123 ether);

        assertEq(token.getDefaultAmount(), 123 ether);
        assertEq(token.balanceOf(alice), 123 ether);
    }

    function testNonTokenManagerCannotChangeDefaultAmount() public {
        vm.prank(alice);
        vm.expectRevert();
        token.setDefaultAmount(1 ether);
    }
}
