// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TokenFactoryV1} from "../src/TokenFactoryV1.sol";

contract TokenFactoryV1Script is Script {
    TokenFactoryV1 public factoryv1;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        factoryv1 = new TokenFactoryV1();
        factoryv1.initialize(deployerAddress);
        console.log("TokenFactoryV1 deployed to:", address(factoryv1));

        vm.stopBroadcast();
    }
}
