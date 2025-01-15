// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FraxLendYieldTokenHelpers} from "../src/FraxlendYieldTokenHelpers.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFraxlendPairDeployer} from "../src/interfaces/IFraxlendPairDeployer.sol";
import {IFraxlendPair} from "../src/interfaces/IFraxlendPair.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract DeployFraxlend is Script {
    FraxLendYieldTokenHelpers public yieldtokenhelpers;
    uint256 public localFork;
    address public whale_address = 0xD58E3fCec6f337b9AAB2ed6afA076067C9e35df1;
    address public frxusd_address = 0xFc00000000000000000000000000000000000001;
    address public sfrxusd_address = 0xfc00000000000000000000000000000000000008;
    address public user_address = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public sfrxeth_address = 0xFC00000000000000000000000000000000000005;
    address public rate_contract_address = 0x3Fdb6BC356dAD0D7260E9619efa125409a08C3B2;
    address public fraxlend_pair_deployer_address = 0x4C3B0e85CD8C12E049E07D9a4d68C441196E6a12;
    address public fraxlend_pair_address;
    uint256 public MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // fraxtal rpc: https://rpc.frax.com
    function run() public {
        // vm.selectFork(0);
        address deployer = 0x31562ae726AFEBe25417df01bEdC72EF489F45b3;
        vm.startBroadcast(deployer);
        yieldtokenhelpers = new FraxLendYieldTokenHelpers();
        console.log("YieldTokenHelpers Address: %s", address(yieldtokenhelpers));

        // vm.broadcast(deployer);
        IFraxlendPairDeployer _FraxlendPairDeployer = IFraxlendPairDeployer(fraxlend_pair_deployer_address);
        // abi.encode(address asset, address _collateral, address _oracleMultiply, address _oracleDivide, uint256 _oracleNormalization, address _rateContract, bytes memory _rateInitData)
        bytes memory config_data = abi.encode(
            sfrxusd_address,
            sfrxeth_address,
            0x42805079ed5ff38c0A5A47F38c83F96d348609AA,
            5000,
            rate_contract_address,
            1582470460,
            75000,
            10000,
            9000,
            2000
        );
        // vm.broadcast(deployer);
        address _fraxlendPairAddress = _FraxlendPairDeployer.deploy(config_data);
        console.log("Fraxlend Pair Address %s", _fraxlendPairAddress);

        vm.stopBroadcast();
    }
}
