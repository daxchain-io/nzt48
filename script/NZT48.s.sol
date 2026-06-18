// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {NZT48} from "../src/NZT48.sol";

contract DeployNZT48 is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address owner = vm.envAddress("OWNER");
        NZT48 tokenContract = new NZT48(owner);
        console.log("NZT-48 deployed at:", address(tokenContract));
        vm.stopBroadcast();
    }
}
