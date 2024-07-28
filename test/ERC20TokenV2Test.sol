// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ERC20TokenV2} from "../src/ERC20TokenV2.sol";

contract ERC20TokenV2Test is Test {
    ERC20TokenV2 public myToken2;
    ERC1967Proxy proxy;
    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");

    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;
    uint public price = 10 ** 16; // 0.01 ETH in wei

    function setUp() public {
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
        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
    }

    function testERC20Functionality() public {
        // Impersonate the owner to call mint function
        vm.prank(owner.addr);
        deal(owner.addr, price);
        assertEq(owner.addr.balance, 10 ** 16);
        // Mint tokens to address(2) and assert the balance
        myToken2.mint{value: price}(user.addr);

        assertEq(myToken2.balanceOf(user.addr), 10 ether);
        assertEq(address(owner.addr).balance, price - price);
    }
}
