// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FraxLendYieldTokenHelpers} from "../src/FraxlendYieldTokenHelpers.sol";

contract CounterScript is Script {
    FraxLendYieldTokenHelpers public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new FraxLendYieldTokenHelpers();

        vm.stopBroadcast();
    }
}
