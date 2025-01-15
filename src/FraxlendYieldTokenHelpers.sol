// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IFraxlendPair} from "./interfaces/IFraxlendPair.sol";

// Me, Myself, and I
contract FraxLendYieldTokenHelpers {
    // TODO: Factor out MinterRedeemerContract and make it changeable.

    // TODO: Add maxWithdraw(address _fraxlendPairAddress) helper

    // TODO: Change from using msg.sender to passing in user to all functions
    constructor() {}

    // Requires approval of StakedTokenContract and FraxlendSharesContract.
    function convertAndDeposit(uint256 _depositAmount, address _fraxlendPairAddress)
        external
        returns (bool _success, uint256 _fraxlendSharesReceived)
    {
        IFraxlendPair _FraxlendPairContract = IFraxlendPair(_fraxlendPairAddress);
        IERC4626 _MinterRedeemerContract = IERC4626(address(0xBFc4D34Db83553725eC6c768da71D2D9c1456B55));
        address _stakedTokenAddress = _FraxlendPairContract.asset();
        IERC20 _StakedTokenContract = IERC20(_stakedTokenAddress);

        // Get the token address and transfer funds to this contract
        address _deposit_token_address = _MinterRedeemerContract.asset();
        IERC20 _DepositTokenContract = IERC20(_deposit_token_address);
        _DepositTokenContract.transferFrom(msg.sender, address(this), _depositAmount);

        // Send staked tokens to this contract
        _DepositTokenContract.approve(address(_MinterRedeemerContract), _depositAmount);
        uint256 _stakedTokensReceived = _MinterRedeemerContract.deposit(_depositAmount, address(this));
        if (_stakedTokensReceived > 0) {
            _StakedTokenContract.approve(_fraxlendPairAddress, _stakedTokensReceived);
            // send FraxLend tokens directly to user
            _fraxlendSharesReceived = _FraxlendPairContract.deposit(_stakedTokensReceived, msg.sender);
            if (_fraxlendSharesReceived > 0) {
                _success = true;
            }
        }
    }

    function withdrawAndConvert(uint256 _withdrawAmount, address _fraxlendPairAddress)
        external
        returns (bool _success, uint256 _amountWithdrawn)
    {
        // address _tokenAddress = fraxlend_pair_address_to_erc20_address[_contractAddress];
        IFraxlendPair _FraxlendPairContract = IFraxlendPair(_fraxlendPairAddress);
        IERC4626 _MinterRedeemerContract = IERC4626(address(0xBFc4D34Db83553725eC6c768da71D2D9c1456B55));
        uint256 _withdrawStakedTokenAmount = _MinterRedeemerContract.previewWithdraw(_withdrawAmount);
        uint256 _withdrawFraxlendShareAmount = _FraxlendPairContract.previewWithdraw(_withdrawStakedTokenAmount);
        uint256 _fraxlendWithdrawnStakedTokenAmount =
            _FraxlendPairContract.redeem(_withdrawFraxlendShareAmount, address(this), msg.sender);
        if (_fraxlendWithdrawnStakedTokenAmount > 0) {
            IERC20 _StakedTokenContract = IERC20(_FraxlendPairContract.asset());
            _StakedTokenContract.approve(address(_MinterRedeemerContract), _fraxlendWithdrawnStakedTokenAmount);
            _amountWithdrawn =
                _MinterRedeemerContract.redeem(_fraxlendWithdrawnStakedTokenAmount, msg.sender, address(this));
            _success = true;
        }
    }

    function maxWithdrawable(address user, address _fraxlendPairAddress)
        external
        view
        returns (uint256 maxWithdrawAmount)
    {
        IFraxlendPair _FraxlendPairContract = IFraxlendPair(_fraxlendPairAddress);
        uint256 _fraxlendAssetBalance = _FraxlendPairContract.maxWithdraw(user);
        IERC4626 _MinterRedeemerContract = IERC4626(address(0xBFc4D34Db83553725eC6c768da71D2D9c1456B55));
        maxWithdrawAmount = _MinterRedeemerContract.previewRedeem(_fraxlendAssetBalance);
    }
}
