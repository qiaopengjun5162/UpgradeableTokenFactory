// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token myToken;
    ERC1967Proxy proxy;
    Account public owner = makeAccount("owner");
    Account public newOwner = makeAccount("newOwner");
    Account public user = makeAccount("user");
    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;

    function setUp() public {
        // 部署实现
        ERC20Token implementation = new ERC20Token();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(
                implementation.initialize,
                (owner.addr, symbol, totalSupply, perMint)
            )
        );
        // 用代理关联 MyToken 接口
        myToken = ERC20Token(address(proxy));
        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
    }

    // Test the basic ERC20 functionality of the MyToken contract
    function testERC20Functionality() public {
        // Impersonate the owner to call mint function
        vm.prank(owner.addr);
        // Mint tokens to address(2) and assert the balance
        myToken.mint(user.addr);
        assertEq(myToken.balanceOf(user.addr), 10 ether);
    }

    // 测试升级
    function testUpgradeability() public {
        // Upgrade the proxy to a new version; ERC20TokenV2
        Upgrades.upgradeProxy(
            address(proxy),
            "ERC20TokenV2.sol:ERC20TokenV2",
            "",
            owner.addr
        );
    }
}