// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";

contract CounterTest is Test {
    TokenFactoryV2 public factoryv2;
    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");

    function setUp() public {
        factoryv2 = new TokenFactoryV2();
    }
}
