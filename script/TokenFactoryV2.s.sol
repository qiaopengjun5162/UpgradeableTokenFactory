// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";

contract TokenFactoryV2Script is Script {
    address public proxy = 0x90635Ff2Ff7E64872848612ad6B943b04B089Db0;
    address public erc20Token = 0x65869BaA9336F8968704F2dd60C40959a7bD202b;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        Upgrades.upgradeProxy(address(proxy), "TokenFactoryV2.sol:TokenFactoryV2", "", deployerAddress);
        (bool successful,) =
            address(proxy).call(abi.encodeWithSelector(TokenFactoryV2.setTokenAddress.selector, address(erc20Token)));
        console.log("setTokenAddress success:", successful);

        vm.stopBroadcast();
    }
}
