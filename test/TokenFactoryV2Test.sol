// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";
import {ERC20TokenV2} from "../src/ERC20TokenV2.sol";

contract CounterTest is Test {
    TokenFactoryV2 public factoryv2;
    ERC20TokenV2 public myToken2;
    ERC1967Proxy proxy;
    ERC1967Proxy proxy2;
    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");

    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;
    uint public price = 10 ** 16; // 0.01 ETH in wei

    function setUp() public {
        // vm.startPrank(owner.addr);
        // 部署实现
        ERC20TokenV2 implementation = new ERC20TokenV2();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(
                implementation.initialize,
                (owner.addr, symbol, totalSupply, perMint, price)
            )
        );
        // 用代理关联 MyToken 接口
        myToken2 = ERC20TokenV2(address(proxy));

        TokenFactoryV2 implementationV2 = new TokenFactoryV2();
        proxy2 = new ERC1967Proxy(
            address(implementationV2),
            abi.encodeCall(
                implementationV2.initialize,
                (owner.addr, address(myToken2))
            )
        );
        // 用代理关联 TokenFactoryV2 接口
        factoryv2 = TokenFactoryV2(address(proxy2));
        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
        // vm.stopPrank();
    }

    function testTokenFactoryV2DeployInscriptionFunctionality() public {
        vm.startPrank(owner.addr);
        factoryv2.deployInscription(symbol, totalSupply, perMint, price);

        assertEq(factoryv2.size(), 1);

        // Fetch the deployed token address
        address deployedTokenAddress = factoryv2.deployedTokens(0);
        assertEq(factoryv2.tokenPrices(deployedTokenAddress), price);
        // Create an instance of the deployed token contract
        ERC20TokenV2 deployedToken = ERC20TokenV2(deployedTokenAddress);
        console.log("Deployed token address:", deployedTokenAddress);
        console.log("Deployed token:", address(deployedToken));
        assertEq(address(deployedToken), deployedTokenAddress);
        // Verify token initialization
        // assertEq(deployedToken.symbol(), symbol);
        // assertEq(deployedToken.balanceOf(owner.addr), 0);
        // assertEq(deployedToken.totalSupplyToken(), totalSupply);
        // assertEq(deployedToken.perMint(), perMint);

        // // Optionally verify owner initialization
        // assertEq(deployedToken.owner(), owner.addr);
        vm.stopPrank();
    }

    function testTokenFactoryV2MintInscriptionFunctionality() public {
        vm.prank(owner.addr);
        factoryv2.deployInscription(symbol, totalSupply, perMint, price);

        assertEq(factoryv2.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv2.deployedTokens(0);
        ERC20TokenV2 deployedToken = ERC20TokenV2(deployedTokenAddress);
        vm.startPrank(user.addr);
        vm.deal(user.addr, 1 ether);
        factoryv2.mintInscription{value: price}(deployedTokenAddress);
        // assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        // assertEq(deployedToken.totalSupply(), 10 ether);
        // // Verify the total supply token
        // assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }
}
