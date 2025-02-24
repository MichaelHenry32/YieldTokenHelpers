// SPDX-License-Identifier: ISC
import "./interfaces/IFraxlendPair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

pragma solidity >=0.8.19;

// library FraxlendPairCore {
//     struct CurrentRateInfo {
//         uint32 lastBlock;
//         uint32 feeToProtocolRate;
//         uint64 lastTimestamp;
//         uint64 ratePerSec;
//         uint64 fullUtilizationRate;
//     }
// }

abstract contract FraxlendYieldTokenCore {
    function getFraxlendPairAddress() internal returns (address) {
        return address(this);
    }

    struct VaultAccount {
        uint128 amount;
        uint128 shares;
    }

    function getMinterRedeemerAddress() internal view returns (address) {
        return address(0xBFc4D34Db83553725eC6c768da71D2D9c1456B55);
    }

    function getSfrxUsdAddress() internal view returns (address) {
        return address(0xfc00000000000000000000000000000000000008);
    }

    function getSfrxUsdContract() internal view returns (IERC20 SfrxUsdContract) {
        return IERC20(getSfrxUsdAddress());
    }

    function getFrxUsdAddress() internal view returns (address) {
        return address(0xFc00000000000000000000000000000000000001);
    }

    function getFrxUsdContract() internal view returns (IERC20 SfrxUsdContract) {
        return IERC20(getFrxUsdAddress());
    }

    function getFraxlendPair() internal view returns (IFraxlendPair pair) {
        return IFraxlendPair(getFraxlendPairAddress());
    }

    function getMinterRedeemer() internal view returns (IERC4626 minterRedeemer) {
        return IERC4626(getMinterRedeemerAddress());
    }

    function previewMintSfrxUsd(uint256 frxUsdAmount) internal view returns (uint256) {
        return getMinterRedeemer().previewDeposit(frxUsdAmount);
    }

    function previewRedeemSfrxUsd(uint256 sfrxUsdAmount) internal view returns (uint256) {
        return getMinterRedeemer().previewRedeem(sfrxUsdAmount);
    }

    function approveAndRedeemSfrxUsd(uint256 _sfrxUsdAmount, address _receiver)
        internal
        returns (uint256 _amountReceived)
    {
        IERC4626 _MinterRedeemer = getMinterRedeemer();
        IERC20 SfrxUSDContract = getSfrxUsdContract();
        SfrxUSDContract.approve(address(_MinterRedeemer), _sfrxUsdAmount);
        _amountReceived = _MinterRedeemer.redeem(_sfrxUsdAmount, _receiver, address(this));
    }

    function approveSfrxUSDToFraxlend(uint256 _sfrxUsdAmount) internal {
        IERC20 SfrxUSDContract = getSfrxUsdContract();
        SfrxUSDContract.approve(getFraxlendPairAddress(), _sfrxUsdAmount);
    }

    function convertAndDeposit(uint256 _amount, address _receiver) internal returns (uint256 _sharesReceived) {
        IFraxlendPair _FraxlendPair = getFraxlendPair();
        IERC4626 _MinterRedeemer = getMinterRedeemer();
        address _stakedTokenAddress = _FraxlendPair.asset();
        IERC20 _StakedTokenContract = IERC20(_stakedTokenAddress);

        // Get the token address and transfer funds to this contract
        address _deposit_token_address = _MinterRedeemer.asset();
        IERC20 _DepositTokenContract = IERC20(_deposit_token_address);
        _DepositTokenContract.transferFrom(msg.sender, address(this), _amount);

        // Send staked tokens to this contract
        _DepositTokenContract.approve(address(_MinterRedeemer), _amount);
        uint256 _stakedTokensReceived = _MinterRedeemer.deposit(_amount, address(this));
        if (_stakedTokensReceived > 0) {
            _StakedTokenContract.approve(address(_FraxlendPair), _stakedTokensReceived);
            // send FraxLend tokens directly to user
            _sharesReceived = _FraxlendPair.deposit(_stakedTokensReceived, _receiver);
        }
    }

    function withdrawAndConvert(uint256 _amount, address _receiver, address _owner)
        internal
        returns (uint256 _amountToReturn)
    {
        require(_owner == msg.sender, "Owner and Sender must be identical");
        // address _tokenAddress = fraxlend_pair_address_to_erc20_address[_contractAddress];
        IFraxlendPair _FraxlendPair = getFraxlendPair();
        IERC4626 _MinterRedeemer = getMinterRedeemer();
        uint256 _withdrawStakedTokenAmount = _MinterRedeemer.previewWithdraw(_amount);
        uint256 _withdrawFraxlendShareAmount = _FraxlendPair.previewWithdraw(_withdrawStakedTokenAmount);
        uint256 _amountToReturnSfrxUsd = _FraxlendPair.redeem(_withdrawFraxlendShareAmount, address(this), _owner);
        if (_amountToReturnSfrxUsd > 0) {
            _amountToReturn = approveAndRedeemSfrxUsd(_amountToReturnSfrxUsd, _receiver);
        }
    }

    function DEPLOYER_ADDRESS() external view returns (address) {
        return getFraxlendPair().DEPLOYER_ADDRESS();
    }

    function DEVIATION_PRECISION() external view returns (uint256) {
        return getFraxlendPair().DEVIATION_PRECISION();
    }

    function EXCHANGE_PRECISION() external view returns (uint256) {
        return getFraxlendPair().DEVIATION_PRECISION();
    }

    function FEE_PRECISION() external view returns (uint256) {
        return getFraxlendPair().FEE_PRECISION();
    }

    function LIQ_PRECISION() external view returns (uint256) {
        return getFraxlendPair().LIQ_PRECISION();
    }

    function LTV_PRECISION() external view returns (uint256) {
        return getFraxlendPair().LTV_PRECISION();
    }

    function MAX_PROTOCOL_FEE() external view returns (uint256) {
        return getFraxlendPair().MAX_PROTOCOL_FEE();
    }

    function RATE_PRECISION() external view returns (uint256) {
        return getFraxlendPair().RATE_PRECISION();
    }

    function UTIL_PREC() external view returns (uint256) {
        return getFraxlendPair().UTIL_PREC();
    }

    function acceptOwnership() external {
        return getFraxlendPair().acceptOwnership();
    }

    function acceptTransferTimelock() external {
        return getFraxlendPair().acceptTransferTimelock();
    }

    function addCollateral(uint256 _collateralAmount, address _borrower) external;

    function addInterest(bool _returnAccounting)
        external
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            FraxlendPairCore.CurrentRateInfo memory _currentRateInfo,
            IFraxlendPair.VaultAccount memory _totalAsset,
            IFraxlendPair.VaultAccount memory _totalBorrow
        )
    {
        (_interestEarned, _feesAmount, _feesShare, _currentRateInfo, _totalAsset, _totalBorrow) =
            getFraxlendPair().addInterest(_returnAccounting);
    }

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function asset() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function borrowAsset(uint256 _borrowAmount, uint256 _collateralAmount, address _receiver)
        external
        returns (uint256 _shares);
    function borrowLimit() external view returns (uint256);
    function changeFee(uint32 _newFee) external;
    function circuitBreakerAddress() external view returns (address);
    function cleanLiquidationFee() external view returns (uint256);
    function collateralContract() external view returns (address);
    function convertToAssets(uint256 _shares) external view returns (uint256 _assets);
    function convertToShares(uint256 _assets) external view returns (uint256 _shares);
    function currentRateInfo()
        external
        view
        returns (
            uint32 lastBlock,
            uint32 feeToProtocolRate,
            uint64 lastTimestamp,
            uint64 ratePerSec,
            uint64 fullUtilizationRate
        );

    function decimals() external view returns (uint8) {
        return getFraxlendPair().decimals();
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function deposit(uint256 _amount, address _receiver) external returns (uint256 _sharesReceived) {
        _sharesReceived = convertAndDeposit(_amount, _receiver);
    }

    function depositLimit() external view returns (uint256);
    function dirtyLiquidationFee() external view returns (uint256);
    function exchangeRateInfo()
        external
        view
        returns (
            address oracle,
            uint32 maxOracleDeviation,
            uint184 lastTimestamp,
            uint256 lowExchangeRate,
            uint256 highExchangeRate
        )
    {}

    function getConstants()
        external
        pure
        returns (
            uint256 _LTV_PRECISION,
            uint256 _LIQ_PRECISION,
            uint256 _UTIL_PREC,
            uint256 _FEE_PRECISION,
            uint256 _EXCHANGE_PRECISION,
            uint256 _DEVIATION_PRECISION,
            uint256 _RATE_PRECISION,
            uint256 _MAX_PROTOCOL_FEE
        )
    {
        // TODO: Verify these don't actually change
        (
            _LTV_PRECISION,
            _LIQ_PRECISION,
            _UTIL_PREC,
            _FEE_PRECISION,
            _EXCHANGE_PRECISION,
            _DEVIATION_PRECISION,
            _RATE_PRECISION,
            _MAX_PROTOCOL_FEE
        ) = getFraxlendPair().getConstants();
    }

    function getPairAccounting()
        external
        view
        returns (
            uint128 _totalAssetAmount,
            uint128 _totalAssetShares,
            uint128 _totalBorrowAmount,
            uint128 _totalBorrowShares,
            uint256 _totalCollateral
        )
    {
        // TODO: These should probably be converted but also it's just a division on _totalAssetAmount, _totalBorrowAmount, and _totalCollateral
        (_totalAssetAmount, _totalAssetShares, _totalBorrowAmount, _totalBorrowShares, _totalCollateral) =
            getFraxlendPair().getPairAccounting();
    }

    function getUserSnapshot(address _address)
        external
        view
        returns (uint256 _userAssetShares, uint256 _userBorrowShares, uint256 _userCollateralBalance);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function isBorrowAccessControlRevoked() external view returns (bool) {
        return getFraxlendPair().isBorrowAccessControlRevoked();
    }

    function isDepositAccessControlRevoked() external view returns (bool) {
        return getFraxlendPair().isDepositAccessControlRevoked();
    }

    function isInterestAccessControlRevoked() external view returns (bool) {
        return getFraxlendPair().isInterestAccessControlRevoked();
    }

    function isInterestPaused() external view returns (bool) {
        return getFraxlendPair().isInterestPaused();
    }

    function isLiquidateAccessControlRevoked() external view returns (bool) {
        return getFraxlendPair().isLiquidateAccessControlRevoked();
    }

    function isLiquidatePaused() external view returns (bool) {
        return getFraxlendPair().isLiquidatePaused();
    }

    function isLiquidationFeeSetterRevoked() external view returns (bool) {
        return getFraxlendPair().isLiquidationFeeSetterRevoked();
    }

    function isMaxLTVSetterRevoked() external view returns (bool) {
        return getFraxlendPair().isMaxLTVSetterRevoked();
    }

    function isOracleSetterRevoked() external view returns (bool) {
        return getFraxlendPair().isOracleSetterRevoked();
    }

    function isRateContractSetterRevoked() external view returns (bool) {
        return getFraxlendPair().isRateContractSetterRevoked();
    }

    function isRepayAccessControlRevoked() external view returns (bool) {
        return getFraxlendPair().isRepayAccessControlRevoked();
    }

    function isRepayPaused() external view returns (bool) {
        return getFraxlendPair().isRepayPaused();
    }

    function isWithdrawAccessControlRevoked() external view returns (bool) {
        return getFraxlendPair().isWithdrawAccessControlRevoked();
    }

    function isWithdrawPaused() external view returns (bool) {
        return getFraxlendPair().isWithdrawPaused();
    }

    function leveragedPosition(
        address _swapperAddress,
        uint256 _borrowAmount,
        uint256 _initialCollateralAmount,
        uint256 _amountCollateralOutMin,
        address[] memory _path
    ) external returns (uint256 _totalCollateralBalance);
    function liquidate(uint128 _sharesToLiquidate, uint256 _deadline, address _borrower)
        external
        returns (uint256 _collateralForLiquidator);
    function maxDeposit(address _receiver) external view returns (uint256 _maxAssets);
    function maxLTV() external view returns (uint256);
    function maxMint(address _receiver) external view returns (uint256 _maxShares);
    function maxRedeem(address _owner) external view returns (uint256 _maxShares);
    function maxWithdraw(address _owner) external view returns (uint256 _maxAssets);
    function mint(uint256 _shares, address _receiver) external returns (uint256 _amount);

    function name() external view returns (string memory) {
        return getFraxlendPair().name();
    }

    function owner() external view returns (address) {
        return getFraxlendPair().owner();
    }

    function pause() external {
        return getFraxlendPair().pause();
    }

    function pauseBorrow() external {
        return getFraxlendPair().pauseBorrow();
    }

    function pauseDeposit() external {
        return getFraxlendPair().pauseDeposit();
    }

    function pauseInterest(bool _isPaused) external {
        return getFraxlendPair().pauseInterest(_isPaused);
    }

    function pauseLiquidate(bool _isPaused) external {
        return getFraxlendPair().pauseLiquidate(_isPaused);
    }

    function pauseRepay(bool _isPaused) external {
        return getFraxlendPair().pauseRepay(_isPaused);
    }

    function pauseWithdraw(bool _isPaused) external {
        return getFraxlendPair().pauseWithdraw(_isPaused);
    }

    function pendingOwner() external view returns (address) {
        return getFraxlendPair().pendingOwner();
    }

    function pendingTimelockAddress() external view returns (address) {
        return getFraxlendPair().pendingTimelockAddress();
    }

    function previewAddInterest()
        external
        view
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            FraxlendPairCore.CurrentRateInfo memory _newCurrentRateInfo,
            VaultAccount memory _totalAsset,
            VaultAccount memory _totalBorrow
        );
    function previewDeposit(uint256 _assets) external view returns (uint256 _sharesReceived);
    function previewMint(uint256 _shares) external view returns (uint256 _amount);

    function previewRedeem(uint256 _shares) external view returns (uint256 _assets) {
        uint256 assetsSfrxUsd = getFraxlendPair().previewRedeem(_shares);
        _assets = getMinterRedeemer().previewRedeem(assetsSfrxUsd);
    }

    function previewWithdraw(uint256 _amount) external view returns (uint256 _sharesToBurn);
    function pricePerShare() external view returns (uint256 _amount);
    function protocolLiquidationFee() external view returns (uint256);

    function rateContract() external view returns (address) {
        return getFraxlendPair().rateContract();
    }

    /* Needs to approve Fraxlend Pair */
    // TODO: I think the approval leads us open to vulnerability here. Because somebody could snipe post-return and use this contract. I probably have to force msg.sender to be _receiver.
    function redeem(uint256 _shares, address _receiver, address _owner) external returns (uint256 _amountToReturn) {
        require(_owner == msg.sender, "Owner and sender must be identical to prevent fund stealing.");
        IFraxlendPair _FraxlendPair = getFraxlendPair();

        // Redeem requires (msg.sender == owner), so this contract needs to hold the assets
        _FraxlendPair.transferFrom(_owner, address(this), _shares);

        // Approve Fraxlend
        getSfrxUsdContract().approve(address(_FraxlendPair), _shares);
        uint256 _amountToReturnSfrxUsd = getFraxlendPair().redeem(_shares, address(this), address(this));
        _amountToReturn = approveAndRedeemSfrxUsd(_amountToReturnSfrxUsd, _receiver);
    }

    function removeCollateral(uint256 _collateralAmount, address _receiver) external;

    function renounceOwnership() external {
        return getFraxlendPair().renounceOwnership();
    }

    function renounceTimelock() external {
        return getFraxlendPair().renounceTimelock();
    }

    // TODO: Obviously this doesn't work
    function repayAsset(uint256 _shares, address _borrower) external returns (uint256 _amountToRepay) {
        uint256 _amountToRepaySfrxUsd = getFraxlendPair().repayAsset(_shares, _borrower);
    }

    function repayAssetWithCollateral(
        address _swapperAddress,
        uint256 _collateralToSwap,
        uint256 _amountAssetOutMin,
        address[] memory _path
    ) external returns (uint256 _amountAssetOut);
    function revokeBorrowLimitAccessControl(uint256 _borrowLimit) external;
    function revokeDepositLimitAccessControl(uint256 _depositLimit) external;

    function revokeInterestAccessControl() external {
        return getFraxlendPair().revokeInterestAccessControl();
    }

    function revokeLiquidateAccessControl() external {
        return getFraxlendPair().revokeLiquidateAccessControl();
    }

    function revokeLiquidationFeeSetter() external {
        return getFraxlendPair().revokeLiquidationFeeSetter();
    }

    function revokeMaxLTVSetter() external {
        return getFraxlendPair().revokeMaxLTVSetter();
    }

    function revokeOracleInfoSetter() external {
        return getFraxlendPair().revokeOracleInfoSetter();
    }

    function revokeRateContractSetter() external {
        return getFraxlendPair().revokeRateContractSetter();
    }

    function revokeRepayAccessControl() external {
        return getFraxlendPair().revokeRepayAccessControl();
    }

    function revokeWithdrawAccessControl() external {
        return getFraxlendPair().revokeWithdrawAccessControl();
    }

    function setBorrowLimit(uint256 _limit) external;

    function setCircuitBreaker(address _newCircuitBreaker) external {
        return getFraxlendPair().setCircuitBreaker(_newCircuitBreaker);
    }

    function setDepositLimit(uint256 _limit) external;
    function setLiquidationFees(
        uint256 _newCleanLiquidationFee,
        uint256 _newDirtyLiquidationFee,
        uint256 _newProtocolLiquidationFee
    ) external;

    function setMaxLTV(uint256 _newMaxLTV) external {
        return getFraxlendPair().setMaxLTV(_newMaxLTV);
    }

    function setOracle(address _newOracle, uint32 _newMaxOracleDeviation) external {
        return getFraxlendPair().setOracle(_newOracle, _newMaxOracleDeviation);
    }

    function setRateContract(address _newRateContract) external {
        return getFraxlendPair().setRateContract(_newRateContract);
    }

    function setSwapper(address _swapper, bool _approval) external {
        return getFraxlendPair().setSwapper(_swapper, _approval);
    }

    // TODO: This is an auto generated method on IFraxlendPair. Make sure it's correct
    function swappers(address _address) external view returns (bool) {
        return getFraxlendPair().swappers(_address);
    }

    // TODO: Decide how to change this for ease of access
    function symbol() external view returns (string memory) {
        return getFraxlendPair().symbol();
    }

    function timelockAddress() external view returns (address) {
        return getFraxlendPair().timelockAddress();
    }

    function toAssetAmount(uint256 _shares, bool _roundUp, bool _previewInterest)
        external
        view
        returns (uint256 _amount)
    {
        uint256 _amountSfrxUsd = getFraxlendPair().toAssetAmount(_shares, _roundUp, _previewInterest);
        _amount = previewRedeemSfrxUsd(_amountSfrxUsd);
    }

    function toAssetShares(uint256 _amount, bool _roundUp, bool _previewInterest)
        external
        view
        returns (uint256 _shares)
    {
        uint256 _amountSfrxUsd = previewMintSfrxUsd(_amount);
        _shares = getFraxlendPair().toAssetShares(_amountSfrxUsd, _roundUp, _previewInterest);
    }

    function toBorrowAmount(uint256 _shares, bool _roundUp, bool _previewInterest)
        external
        view
        returns (uint256 _amount)
    {
        uint256 amountSfrxUsd = getFraxlendPair().toBorrowAmount(_shares, _roundUp, _previewInterest);
        _amount - previewRedeemSfrxUsd(amountSfrxUsd);
    }

    function toBorrowShares(uint256 _amount, bool _roundUp, bool _previewInterest)
        external
        view
        returns (uint256 _shares)
    {
        uint256 _amountSfrxUsd = previewMintSfrxUsd(_amount);
        _shares = getFraxlendPair().toBorrowShares(_amountSfrxUsd, _roundUp, _previewInterest);
    }

    function totalAsset() external view returns (uint128 amount, uint128 shares) {
        uint128 _amountSfrxUSD;
        (_amountSfrxUSD, shares) = getFraxlendPair().totalAsset();
        amount = uint128(previewRedeemSfrxUsd(_amountSfrxUSD));
    }

    function totalAssets() external view returns (uint256) {
        uint256 _amountSfrxUSD = getFraxlendPair().totalAssets();
        return previewRedeemSfrxUsd(_amountSfrxUSD);
    }

    function totalBorrow() external view returns (uint128 amount, uint128 shares) {
        uint128 _amountSfrxUSD;
        (_amountSfrxUSD, shares) = getFraxlendPair().totalBorrow();
        amount = uint128(previewRedeemSfrxUsd(_amountSfrxUSD));
    }

    function totalCollateral() external view returns (uint256) {
        return getFraxlendPair().totalCollateral();
    }

    // Returns shares
    function totalSupply() external view returns (uint256) {
        return getFraxlendPair().totalSupply();
    }

    // Transfer functions transfer shares, as a result we inherit from FraxlendPair
    function transfer(address to, uint256 amount) external returns (bool) {
        require(1 == 0, "This method is not supported");
        return getFraxlendPair().transfer(to, amount);
    }

    // Transfer functions transfer shares, as a result we inherit from FraxlendPair
    // Users will exlusively be approving this contract, so there's an intermediate transfer.
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(msg.sender == from, "msg.sender and from address must be identical to prevent stealing funds");
        IFraxlendPair _FraxlendPair = getFraxlendPair();

        // Redeem requires (msg.sender == owner), so this contract needs to hold the assets
        _FraxlendPair.transferFrom(from, address(this), amount);
        return _FraxlendPair.transfer(to, amount);
    }

    function transferOwnership(address newOwner) external {
        return getFraxlendPair().transferOwnership(newOwner);
    }

    function transferTimelock(address _newTimelock) external {
        return getFraxlendPair().transferTimelock(_newTimelock);
    }

    function unpause() external {
        return getFraxlendPair().unpause();
    }

    function updateExchangeRate()
        external
        returns (bool _isBorrowAllowed, uint256 _lowExchangeRate, uint256 _highExchangeRate);
    function userBorrowShares(address) external view returns (uint256);
    function userCollateralBalance(address) external view returns (uint256);

    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch) {
        (_major, _minor, _patch) = getFraxlendPair().version();
    }

    // TODO: Change return to match withdrawAndConvert info
    function withdraw(uint256 _amount, address _receiver, address _owner) external returns (uint256 _sharesToBurn) {
        _sharesToBurn = withdrawAndConvert(_amount, _receiver, _owner);
    }

    function withdrawFees(uint128 _shares, address _recipient) external returns (uint256 _amountToTransfer);
}
