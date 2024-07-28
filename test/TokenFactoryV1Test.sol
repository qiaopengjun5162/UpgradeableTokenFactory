// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ERC20Token} from "../src/ERC20Token.sol";
import {TokenFactoryV1} from "../src/TokenFactoryV1.sol";

contract TokenFactoryV1Test is Test {
    TokenFactoryV1 public factoryv1;
    ERC20Token public myToken;
    ERC1967Proxy proxy;
    Account public owner = makeAccount("owner");
    Account public newOwner = makeAccount("newOwner");
    Account public user = makeAccount("user");

    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;

    function setUp() public {
        factoryv1 = new TokenFactoryV1();
        // 部署实现
        TokenFactoryV1 implementation = new TokenFactoryV1();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(implementation.initialize, owner.addr)
        );
        // 用代理关联 TokenFactoryV1 接口
        factoryv1 = TokenFactoryV1(address(proxy));
        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
    }

    function testTokenFactoryV1DeployInscriptionFunctionality() public {
        vm.prank(owner.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);

        assertEq(factoryv1.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv1.deployedTokens(0);

        // Create an instance of the deployed token contract
        ERC20Token deployedToken = ERC20Token(deployedTokenAddress);

        // Verify token initialization
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.totalSupply(), 0);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        assertEq(deployedToken.perMint(), perMint);

        // Optionally verify owner initialization
        assertEq(deployedToken.owner(), owner.addr);
    }

    function testTokenFactoryV1MintInscriptionFunctionality() public {
        vm.prank(owner.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);

        assertEq(factoryv1.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv1.deployedTokens(0);
        ERC20Token deployedToken = ERC20Token(deployedTokenAddress);
        vm.startPrank(user.addr);
        factoryv1.mintInscription(deployedTokenAddress);
        assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        assertEq(deployedToken.totalSupply(), 10 ether);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }

    // // 测试升级
    function testUpgradeability() public {
        // Upgrade the proxy to a new version; TokenFactoryV2
        Upgrades.upgradeProxy(
            address(proxy),
            "TokenFactoryV2.sol:TokenFactoryV2",
            "",
            owner.addr
        );
    }
}
