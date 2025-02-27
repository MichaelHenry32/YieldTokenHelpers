// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {FraxlendLenderHelpers} from "../src/FraxlendLenderHelpers.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        bytes32 salt = keccak256(abi.encodePacked("MY_UNIQUE_SALT"));
        address predictableAddress = Create2.computeAddress(
            salt,
            keccak256(
                abi.encodePacked(
                    type(FraxlendLenderHelpers).creationCode,
                    abi.encode(0x689087338CFbD1D268AD361F7759Fb1200c921e2)
                )
            )
        );

        // Deploy
        FraxlendLenderHelpers _helpers = new FraxlendLenderHelpers{salt: salt}(
            predictableAddress
        );

        vm.stopBroadcast();
    }
}
