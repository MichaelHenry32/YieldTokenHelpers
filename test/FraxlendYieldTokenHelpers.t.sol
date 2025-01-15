// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FraxLendYieldTokenHelpers} from "../src/FraxlendYieldTokenHelpers.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFraxlendPairDeployer} from "../src/interfaces/IFraxlendPairDeployer.sol";
import {IFraxlendPair} from "../src/interfaces/IFraxlendPair.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract FraxLendYieldTokenHelpersTest is Test {
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

    function deployFraxlend() public returns (address _fraxlendPairAddress) {
        vm.startPrank(address(0x31562ae726AFEBe25417df01bEdC72EF489F45b3));
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
        _fraxlendPairAddress = _FraxlendPairDeployer.deploy(config_data);
        console.log("Fraxlend Pair Address %s", _fraxlendPairAddress);
        vm.stopPrank();
    }

    function setUp() public {
        yieldtokenhelpers = new FraxLendYieldTokenHelpers();
        localFork = vm.createFork("http://localhost:8545");
        vm.selectFork(localFork);
        fraxlend_pair_address = deployFraxlend();
        assertTrue(fraxlend_pair_address != address(0), "fraxlend pair deployment failed");
        deal(frxusd_address, user_address, 1000 ether);
        uint256 user_frxusd_balance = IERC20(frxusd_address).balanceOf(user_address);
        console.log("Frxusd balance %d", user_frxusd_balance);
        // IERC20 FrxUSD_Contract = IERC20(frxusd_address);
        // FrxUSD_Contract.approve();
    }

    function test_fraxlend_yield_helpers() public {
        vm.startPrank(user_address);
        uint256 user_frxusd_balance = IERC20(frxusd_address).balanceOf(user_address);
        console.log("Frxusd balance %d", user_frxusd_balance);
        // Approve Fraxlend Helpers for frxUSD
        IERC20(frxusd_address).approve(address(yieldtokenhelpers), 10 ether);
        (bool success, uint256 fraxlendShares) = yieldtokenhelpers.convertAndDeposit(1 ether, fraxlend_pair_address);
        uint256 fraxlend_share_count = IFraxlendPair(fraxlend_pair_address).balanceOf(user_address);
        console.log("fraxlend_share_count %s", fraxlend_share_count);
        // deposit and convert call
        assertTrue(address(yieldtokenhelpers) != address(0), "Contract not deployed");
        assertTrue(success, "convert_and_deposit was successful");
        assertTrue(fraxlendShares > 0, "More than 0 fraxlend shares were received");

        // test withdraw_and_convert()
        uint256 withdrawAmount = yieldtokenhelpers.maxWithdrawable(user_address, fraxlend_pair_address);
        IFraxlendPair(fraxlend_pair_address).approve(address(yieldtokenhelpers), withdrawAmount);
        (bool success2, uint256 amountWithdrawn) =
            yieldtokenhelpers.withdrawAndConvert(withdrawAmount, fraxlend_pair_address);
        user_frxusd_balance = IERC20(frxusd_address).balanceOf(user_address);
        console.log("Frxusd end balance %d", user_frxusd_balance);
        uint256 maxWithdrawable = yieldtokenhelpers.maxWithdrawable(user_address, fraxlend_pair_address);
        console.log("Remaining Fraxlend Balance %d", maxWithdrawable);

        assertTrue(success2, "withdraw_and_convert was successful");
        assertTrue(amountWithdrawn == withdrawAmount, "Withdrew 1 ether worth!");
        vm.stopPrank();
    }

    function test_hit_yield_helpers_endpoint() public {
        vm.startPrank(user_address);
        address _yieldTokenHelpersAddress = address(0x4DF9de8dB48fa683A4254454A735526603c75D95);
        // fraxlend_pair_address = 0x689087338CFbD1D268AD361F7759Fb1200c921e2;
        FraxLendYieldTokenHelpers _yieldTokenHelpers = FraxLendYieldTokenHelpers(_yieldTokenHelpersAddress);

        // Approve frxused
        // IERC20(frxusd_address).approve(address(_yieldTokenHelpers), 10 ether);
        console.log("yieldTokenHelpers Address: %s", address(_yieldTokenHelpers));
        // vm.prank(user_address);
        (bool _success, uint256 _fraxlendSharesReceived) =
            _yieldTokenHelpers.convertAndDeposit(10 ether, fraxlend_pair_address);
        assertTrue(_success, "convert and deposit succeeded");
        console.log("Success: %s", _success);
        console.log("Shares received: %s", _fraxlendSharesReceived);

        uint256 max_withdrawable = _yieldTokenHelpers.maxWithdrawable(user_address, fraxlend_pair_address);
        console.log("Max Withdrawable: %s", max_withdrawable);
        vm.stopPrank();
    }
}
