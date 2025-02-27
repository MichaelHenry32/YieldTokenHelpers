import "./interfaces/IFraxlendPair.sol";
import {IFraxtalERC4626MintRedeemer} from "./interfaces/IFraxtalERC4626MintRedeemer.sol";
import {ISfrxUsdFrxUsdOracle} from "./interfaces/ISfrxUsdFrxUsdOracle.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity >=0.8.19;

// TODO: It might make sense to just infinite approve everything on creation. That could result in significant gas savings.

contract FraxlendLenderHelpers {
    address private fraxlendPairAddress; // Needs to be first to ensure memory alignment with FraxlendYieldTokenProxy

    constructor(address _fraxlendPairAddress) {
        fraxlendPairAddress = _fraxlendPairAddress;
    }

    struct VaultAccount {
        uint128 amount;
        uint128 shares;
    }

    function RATE_PRECISION() external view returns (uint256) {
        return getFraxlendPair().RATE_PRECISION();
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

    function UTIL_PREC() external view returns (uint256) {
        return getFraxlendPair().UTIL_PREC();
    }

    function getFraxlendPairAddress() internal view returns (address) {
        return fraxlendPairAddress;
    }

    function getMinterRedeemerAddress() internal view returns (address) {
        return address(0xBFc4D34Db83553725eC6c768da71D2D9c1456B55);
    }

    function getSfrxUsdAddress() internal view returns (address) {
        return address(0xfc00000000000000000000000000000000000008);
    }

    function getSfrxUsdRPS() internal view returns (uint256) {
        ISfrxUsdFrxUsdOracle _SfrxUsdOracle = ISfrxUsdFrxUsdOracle(
            0x1B680F4385f24420D264D78cab7C58365ED3F1FF
        );

        (
            uint40 _cycleEnd,
            uint40 _lastSync,
            uint216 _rewardCycleAmount
        ) = _SfrxUsdOracle.rewardsCycleData();
        uint256 _totalAssets = _SfrxUsdOracle.storedTotalAssets();
        return
            _rewardCycleAmount /
            (((_cycleEnd - _lastSync) * _totalAssets) / this.RATE_PRECISION());
    }

    function getSfrxUsdContract()
        internal
        view
        returns (IERC20 SfrxUsdContract)
    {
        return IERC20(getSfrxUsdAddress());
    }

    function getFrxUsdAddress() internal view returns (address) {
        return address(0xFc00000000000000000000000000000000000001);
    }

    function getFrxUsdContract()
        internal
        view
        returns (IERC20 SfrxUsdContract)
    {
        return IERC20(getFrxUsdAddress());
    }

    function getFraxlendPair() internal view returns (IFraxlendPair pair) {
        return IFraxlendPair(getFraxlendPairAddress());
    }

    // TODO: Actually generate a specific MinterRedeemer Interface so I have access to all methods.
    function getMinterRedeemer()
        internal
        view
        returns (IFraxtalERC4626MintRedeemer minterRedeemer)
    {
        return IFraxtalERC4626MintRedeemer(getMinterRedeemerAddress());
    }

    function previewConvertSfrxUsd(
        uint256 _amountSfrxUsd
    ) internal view returns (uint256 _amountFrxUsd) {
        uint256 _pricePerShare = getMinterRedeemer().pricePerShare();
        _amountFrxUsd = (_amountSfrxUsd * _pricePerShare) / 1e18;
    }

    function previewDepositSfrxUsd(
        uint256 frxUsdAmount
    ) internal view returns (uint256) {
        return getMinterRedeemer().previewDeposit(frxUsdAmount);
    }

    function previewMintSfrxUsd(
        uint256 sfrxUsdAmount
    ) internal view returns (uint256) {
        return getMinterRedeemer().previewMint(sfrxUsdAmount);
    }

    function previewWithdrawSfrxUsd(
        uint256 frxUsdAmount
    ) internal view returns (uint256) {
        return getMinterRedeemer().previewWithdraw(frxUsdAmount);
    }

    // TODO: Verify this is being used where it should be
    function previewRedeemSfrxUsd(
        uint256 sfrxUsdAmount
    ) internal view returns (uint256) {
        return getMinterRedeemer().previewRedeem(sfrxUsdAmount);
    }

    function approveAndRedeemSfrxUsd(
        uint256 _sfrxUsdAmount,
        address _receiver
    ) internal returns (uint256 _amountReceived) {
        IFraxtalERC4626MintRedeemer _MinterRedeemer = getMinterRedeemer();
        IERC20 SfrxUSDContract = getSfrxUsdContract();
        SfrxUSDContract.approve(address(_MinterRedeemer), _sfrxUsdAmount);
        _amountReceived = _MinterRedeemer.redeem(
            _sfrxUsdAmount,
            _receiver,
            address(this)
        );
    }

    function approveAndMintSfrxUsd(
        uint256 _frxUsdAmount,
        address _receiver
    ) internal returns (uint256 _amountReceived) {
        IFraxtalERC4626MintRedeemer _MinterRedeemer = getMinterRedeemer();
        IERC20 _FrxUsdContract = getFrxUsdContract();
        _FrxUsdContract.approve(address(_MinterRedeemer), _frxUsdAmount);
        _amountReceived = _MinterRedeemer.deposit(_frxUsdAmount, _receiver);
    }

    function approveSfrxUSDToFraxlend(uint256 _sfrxUsdAmount) internal {
        IERC20 SfrxUSDContract = getSfrxUsdContract();
        SfrxUSDContract.approve(getFraxlendPairAddress(), _sfrxUsdAmount);
    }

    function convertAndDeposit(
        uint256 _amount,
        address _receiver
    ) internal returns (uint256 _sharesReceived) {
        IFraxlendPair _FraxlendPair = getFraxlendPair();
        IERC20 _SfrxUsdContract = getSfrxUsdContract();
        IERC20 _FrxUsdContract = getFrxUsdContract();

        // Get the token address and transfer funds to this contract
        _FrxUsdContract.transferFrom(msg.sender, address(this), _amount);

        // Send staked tokens to this contract
        uint256 _sfrxUsdAmount = approveAndMintSfrxUsd(_amount, address(this));
        if (_sfrxUsdAmount > 0) {
            _SfrxUsdContract.approve(address(_FraxlendPair), _sfrxUsdAmount);
            // send FraxLend tokens directly to user
            _sharesReceived = _FraxlendPair.deposit(_sfrxUsdAmount, _receiver);
        }
    }

    // User must approve this contract to transfer Fraxlend shares on their behalf:
    // uint256 allowed = allowance(_owner, msg.sender);
    function withdrawAndConvert(
        uint256 _amount,
        address _receiver,
        address _owner
    ) internal returns (uint256 _sharesToBurn) {
        require(_owner == msg.sender, "Owner and Sender must be identical");
        // address _tokenAddress = fraxlend_pair_address_to_erc20_address[_contractAddress];
        IFraxlendPair _FraxlendPair = getFraxlendPair();
        IFraxtalERC4626MintRedeemer _MinterRedeemer = getMinterRedeemer();
        uint256 _withdrawStakedTokenAmount = _MinterRedeemer.previewWithdraw(
            _amount
        );
        _sharesToBurn = _FraxlendPair.previewWithdraw(
            _withdrawStakedTokenAmount
        );
        uint256 _amountToReturnSfrxUsd = _FraxlendPair.redeem(
            _sharesToBurn,
            address(this),
            _owner
        );
        if (_amountToReturnSfrxUsd > 0) {
            uint256 _amountToReturn = approveAndRedeemSfrxUsd(
                _amountToReturnSfrxUsd,
                _receiver
            );
        }
    }

    function transferAndApproveCollateral(
        uint256 _collateralAmount
    ) internal returns (bool) {
        IFraxlendPair _FraxlendPair = getFraxlendPair();
        IERC20 _CollateralContract = IERC20(_FraxlendPair.collateralContract());
        _CollateralContract.transferFrom(
            msg.sender,
            address(this),
            _collateralAmount
        );
        return
            _CollateralContract.approve(
                address(_FraxlendPair),
                _collateralAmount
            );
    }

    // function addInterest(bool _returnAccounting)
    //     external
    //     returns (
    //         uint256 _interestEarned,
    //         uint256 _feesAmount,
    //         uint256 _feesShare,
    //         FraxlendPairCore.CurrentRateInfo memory _currentRateInfo,
    //         IFraxlendPair.VaultAccount memory _totalAsset,
    //         IFraxlendPair.VaultAccount memory _totalBorrow
    //     )
    // {
    //     (_interestEarned, _feesAmount, _feesShare, _currentRateInfo, _totalAsset, _totalBorrow) =
    //         getFraxlendPair().addInterest(_returnAccounting);
    // }

    // This is for the yFraxlendPair token, so we forward to the pair
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return getFraxlendPair().allowance(owner, spender);
    }

    // This doesn't work...
    function approve(address spender, uint256 amount) external returns (bool) {
        revert("Can't approve indirectly");
        return getFraxlendPair().approve(spender, amount);
    }

    function asset() external view returns (address) {
        return getFrxUsdAddress();
    }

    function balanceOf(address account) external view returns (uint256) {
        return getFraxlendPair().balanceOf(account);
    }

    function convertToAssets(
        uint256 _shares
    ) external view returns (uint256 _assets) {
        uint256 _assetsSfrxUsd = getFraxlendPair().convertToAssets(_shares);
        _assets = previewRedeemSfrxUsd(_assetsSfrxUsd);
    }

    function convertToShares(
        uint256 _assets
    ) external view returns (uint256 _shares) {
        uint256 _assetsSfrxUsd = previewDepositSfrxUsd(_assets);
        _shares = getFraxlendPair().convertToShares(_assetsSfrxUsd);
    }

    function currentRateInfo()
        external
        view
        returns (
            uint32 _lastBlock,
            uint32 _feeToProtocolRate,
            uint64 _lastTimestamp,
            uint64 _ratePerSec, // Give RPS of all tokens which differs from IFraxlendPair RPS which gives the _ratePerSecond of lent tokens.
            uint64 _fullUtilizationRate
        )
    {
        IFraxlendPair _FraxlendPair = getFraxlendPair();
        uint256 _rpsLentSfrxUsd;
        uint256 _fullUtilizationRateSfrxUSD;
        (
            _lastBlock,
            _feeToProtocolRate,
            _lastTimestamp,
            _rpsLentSfrxUsd,
            _fullUtilizationRateSfrxUSD
        ) = _FraxlendPair.currentRateInfo();
        (
            uint128 _totalAssetAmount,
            ,
            uint128 _totalBorrowAmount,
            ,

        ) = _FraxlendPair.getPairAccounting();
        uint256 _lent_rps = (_rpsLentSfrxUsd * _totalBorrowAmount) /
            _totalAssetAmount;
        uint256 _uinlent_rps = (getSfrxUsdRPS() *
            (_totalAssetAmount - _totalBorrowAmount)) / _totalAssetAmount;
        _ratePerSec = uint64(previewConvertSfrxUsd(_lent_rps + _uinlent_rps));
        _fullUtilizationRate = uint64(
            previewConvertSfrxUsd(_fullUtilizationRateSfrxUSD)
        );
    }

    function decimals() external view returns (uint8) {
        return getFraxlendPair().decimals();
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external returns (bool) {
        return getFraxlendPair().decreaseAllowance(spender, subtractedValue);
    }

    function deposit(
        uint256 _amount,
        address _receiver
    ) external returns (uint256 _sharesReceived) {
        _sharesReceived = convertAndDeposit(_amount, _receiver);
    }

    function depositLimit() external view returns (uint256) {
        uint256 _depositLimitSfrxUsd = getFraxlendPair().depositLimit();
        return previewRedeemSfrxUsd(_depositLimitSfrxUsd);
    }

    function exchangeRateInfo()
        external
        view
        returns (
            address _oracle,
            uint32 _maxOracleDeviation,
            uint184 _lastTimestamp,
            uint256 _lowExchangeRate,
            uint256 _highExchangeRate
        )
    {
        uint256 _lowExchangeRateSfrxUsd;
        uint256 _highExchangeRateSfrxUsd;
        (
            _oracle,
            _maxOracleDeviation,
            _lastTimestamp,
            _lowExchangeRateSfrxUsd,
            _highExchangeRateSfrxUsd
        ) = getFraxlendPair().exchangeRateInfo();
        _lowExchangeRate = previewConvertSfrxUsd(_lowExchangeRateSfrxUsd);
        _highExchangeRate = previewConvertSfrxUsd(_highExchangeRateSfrxUsd);
    }

    function getConstants()
        external
        view
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

    function getUserSnapshot(
        address _address
    )
        external
        view
        returns (
            uint256 _userAssetShares,
            uint256 _userBorrowShares,
            uint256 _userCollateralBalance
        )
    {
        return getFraxlendPair().getUserSnapshot(_address);
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
        uint128 _totalAssetAmountSfrxUsd;
        uint128 _totalBorrowAmountSfrxUsd;
        (
            _totalAssetAmountSfrxUsd,
            _totalAssetShares,
            _totalBorrowAmountSfrxUsd,
            _totalBorrowShares,
            _totalCollateral
        ) = getFraxlendPair().getPairAccounting();
        _totalAssetAmount = uint128(
            previewConvertSfrxUsd(_totalAssetAmountSfrxUsd)
        );
        _totalBorrowAmount = uint128(
            previewConvertSfrxUsd(_totalBorrowAmountSfrxUsd)
        );
    }

    function maxDeposit(
        address _receiver
    ) external view returns (uint256 _maxAssets) {
        uint256 maxAssetsSfrxUsd = getFraxlendPair().maxDeposit(_receiver);
        _maxAssets = previewMintSfrxUsd(maxAssetsSfrxUsd);
    }

    function maxLTV() external view returns (uint256) {
        return getFraxlendPair().maxLTV();
    }

    function maxMint(
        address _receiver
    ) external view returns (uint256 _maxShares) {
        _maxShares = getFraxlendPair().maxMint(_receiver);
    }

    function maxRedeem(
        address _owner
    ) external view returns (uint256 _maxShares) {
        _maxShares = getFraxlendPair().maxRedeem(_owner);
    }

    function maxWithdraw(
        address _owner
    ) external view returns (uint256 _maxAssets) {
        uint256 _maxWithdrawSfrxUsd = getFraxlendPair().maxWithdraw(_owner);
        _maxAssets = previewRedeemSfrxUsd(_maxWithdrawSfrxUsd);
    }

    function name() external view returns (string memory) {
        return getFraxlendPair().name();
    }

    function collateralContract() external view returns (address) {
        return getFraxlendPair().collateralContract();
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
        )
    {
        revert("I need to find an onchain sfrxUSD RPS oracle");
    }

    function previewDeposit(
        uint256 _assets
    ) external view returns (uint256 _sharesReceived) {
        uint256 _assetsSfrxUsd = previewDepositSfrxUsd(_assets);
        _sharesReceived = getFraxlendPair().previewDeposit(_assetsSfrxUsd);
    }

    function previewMint(
        uint256 _shares
    ) external view returns (uint256 _amount) {
        uint256 _amountSfrxUsd = getFraxlendPair().previewMint(_shares);
        _amount = previewMintSfrxUsd(_amountSfrxUsd);
    }

    function previewRedeem(
        uint256 _shares
    ) external view returns (uint256 _assets) {
        uint256 assetsSfrxUsd = getFraxlendPair().previewRedeem(_shares);
        _assets = previewRedeemSfrxUsd(assetsSfrxUsd);
    }

    function previewWithdraw(
        uint256 _amount
    ) external view returns (uint256 _sharesToBurn) {
        uint256 _amountSfrxUsd = previewDepositSfrxUsd(_amount);
        _sharesToBurn = getFraxlendPair().previewWithdraw(_amountSfrxUsd);
    }

    function pricePerShare() external view returns (uint256 _amount) {
        _amount = previewConvertSfrxUsd(getFraxlendPair().pricePerShare());
    }

    function rateContract() external view returns (address) {
        return getFraxlendPair().rateContract();
    }

    // User must approve this contract to transfer Fraxlend shares on their behalf:
    // uint256 allowed = allowance(_owner, msg.sender);
    // This also breaks the interface...
    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    ) external returns (uint256 _amountToReturn) {
        require(
            _owner == msg.sender,
            "Owner and sender must be identical to prevent fund stealing."
        );
        IFraxlendPair _FraxlendPair = getFraxlendPair();

        // Redeem requires (msg.sender == owner), so this contract needs to hold the assets
        _FraxlendPair.transferFrom(_owner, address(this), _shares);

        // Approve Fraxlend
        getSfrxUsdContract().approve(address(_FraxlendPair), _shares);
        uint256 _amountToReturnSfrxUsd = getFraxlendPair().redeem(
            _shares,
            address(this),
            address(this)
        );
        _amountToReturn = approveAndRedeemSfrxUsd(
            _amountToReturnSfrxUsd,
            _receiver
        );
    }

    // TODO: Decide how to change this for ease of access
    function symbol() external view returns (string memory) {
        return getFraxlendPair().symbol();
    }

    function toAssetAmount(
        uint256 _shares,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _amount) {
        uint256 _amountSfrxUsd = getFraxlendPair().toAssetAmount(
            _shares,
            _roundUp,
            _previewInterest
        );
        _amount = previewRedeemSfrxUsd(_amountSfrxUsd);
    }

    function toAssetShares(
        uint256 _amount,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _shares) {
        uint256 _amountSfrxUsd = previewDepositSfrxUsd(_amount);
        _shares = getFraxlendPair().toAssetShares(
            _amountSfrxUsd,
            _roundUp,
            _previewInterest
        );
    }

    function totalAsset()
        external
        view
        returns (uint128 amount, uint128 shares)
    {
        uint128 _amountSfrxUSD;
        (_amountSfrxUSD, shares) = getFraxlendPair().totalAsset();
        amount = uint128(previewRedeemSfrxUsd(_amountSfrxUSD));
    }

    function totalAssets() external view returns (uint256) {
        uint256 _amountSfrxUSD = getFraxlendPair().totalAssets();
        return previewRedeemSfrxUsd(_amountSfrxUSD);
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(
            msg.sender == from,
            "msg.sender and from address must be identical to prevent stealing funds"
        );
        IFraxlendPair _FraxlendPair = getFraxlendPair();

        // Redeem requires (msg.sender == owner), so this contract needs to hold the assets
        _FraxlendPair.transferFrom(from, address(this), amount);
        return _FraxlendPair.transfer(to, amount);
    }

    // TODO: Change return to match withdrawAndConvert info
    // User must approve this contract to transfer Fraxlend shares on their behalf:
    // uint256 allowed = allowance(_owner, msg.sender);
    function withdraw(
        uint256 _amount,
        address _receiver,
        address _owner
    ) external returns (uint256 _sharesToBurn) {
        require(_owner == msg.sender, "Owner and Sender must be identical");
        _sharesToBurn = withdrawAndConvert(_amount, _receiver, _owner);
    }

    function mint(
        uint256 _shares,
        address _receiver
    ) external returns (uint256 _amount) {
        // TODO: The shares stuff. Still don't understand why anyone would mint in this way though
        revert("Not fully implemented");
    }
}
