// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/ERC20Token.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/Script.sol";
import {TokenFactoryV1} from "../src/TokenFactoryV1.sol";

contract DeployUUPSProxy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);
        // address _implementation = 0xa8672dfDb0d5A672CC599C3E8D77F8E807cEc6d6; // Replace with your token address
        TokenFactoryV1 _implementation = new TokenFactoryV1(); // Replace with your token address
        console.log("TokenFactoryV1 deployed to:", address(_implementation));

        // Encode the initializer function call
        bytes memory data = abi.encodeCall(_implementation.initialize, deployerAddress);

        // Deploy the proxy contract with the implementation address and initializer
        ERC1967Proxy proxy = new ERC1967Proxy(address(_implementation), data);

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}
