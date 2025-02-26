// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {FraxlendLenderHelpers} from "../src/FraxlendLenderHelpers.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        new FraxlendLenderHelpers(0x689087338CFbD1D268AD361F7759Fb1200c921e2);

        vm.stopBroadcast();
    }
}
