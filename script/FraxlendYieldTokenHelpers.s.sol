// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {FraxLendYieldTokenHelpers} from "../src/FraxlendYieldTokenHelpers.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        new FraxLendYieldTokenHelpers();

        vm.stopBroadcast();
    }
}
