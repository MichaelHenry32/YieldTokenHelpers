// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IFraxtalERC4626MintRedeemer {
    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);
    error InitializeFailed();
    error InvalidOraclePrice(string symbol);
    error InvalidOracleRoundID(string symbol);
    error InvalidOwnershipAcceptance();
    error OnlyOwner();
    error OracleIsStale(string symbol);
    error OwnerCannotBeZero();
    error TokenOwnerShouldBeSender();

    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerNominated(address newOwner);
    event RecoveredERC20(address token, uint256 amount);
    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    function acceptOwnership() external;
    function asset() external view returns (address _underlying);
    function balanceOf(address _addr) external view returns (uint256 _balance);
    function convertToAssets(uint256 _shares) external view returns (uint256 _assets);
    function convertToShares(uint256 _assets) external view returns (uint256 _shares);
    function decimals() external view returns (uint8);
    function deposit(uint256 _assetsIn, address _receiver) external returns (uint256 _sharesOut);
    function fee() external view returns (uint256);
    function getLatestUnderlyingPriceE18() external view returns (int256 _price);
    function getLatestVaultTknPriceE18() external view returns (int256 _price);
    function getVaultTknPriceStoredE18() external view returns (uint256 _price);
    function initialize(
        address _owner,
        address _underlyingTkn,
        address _vaultTkn,
        address _underlyingOracle,
        address _vaultOracle,
        uint256 _fee,
        uint256 _initialVaultTknPrice
    ) external;
    function lastVaultTknOracleRead() external view returns (uint256);
    function maxDeposit(address _addr) external view returns (uint256 _maxAssetsIn);
    function maxMint(address _addr) external view returns (uint256 _maxSharesOut);
    function maxRedeem(address _owner) external view returns (uint256 _maxSharesIn);
    function maxWithdraw(address _owner) external view returns (uint256 _maxAssetsOut);
    function mdwrComboView()
        external
        view
        returns (
            uint256 _maxAssetsDepositable,
            uint256 _maxSharesMintable,
            uint256 _maxAssetsWithdrawable,
            uint256 _maxSharesRedeemable
        );
    function mint(uint256 _sharesOut, address _receiver) external returns (uint256 _assetsIn);
    function nominateNewOwner(address _owner) external;
    function nominatedOwner() external view returns (address);
    function oracleTimeTolerance() external view returns (uint256);
    function owner() external view returns (address);
    function previewDeposit(uint256 _assetsIn) external view returns (uint256 _sharesOut);
    function previewMint(uint256 _sharesOut) external view returns (uint256 _assetsIn);
    function previewRedeem(uint256 _sharesIn) external view returns (uint256 _assetsOut);
    function previewWithdraw(uint256 _assetsOut) external view returns (uint256 _sharesIn);
    function priceFeedUnderlying() external view returns (address);
    function priceFeedVault() external view returns (address);
    function pricePerShare() external view returns (uint256 _pricePerShare);
    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external;
    function redeem(uint256 _sharesIn, address _receiver, address _owner) external returns (uint256 _assetsOut);
    function setMintRedeemFee(uint256 _fee) external;
    function setOracleTimeTolerance(uint256 _secs) external;
    function setOracles(address _underlyingOracleAddr, address _vaultOracleAddr) external;
    function totalAssets() external view returns (uint256 _assets);
    function totalSupply() external view returns (uint256 _supply);
    function underlyingTkn() external view returns (address);
    function updateVaultTknOracle() external;
    function vaultTkn() external view returns (address);
    function vaultTknPrice() external view returns (uint256);
    function withdraw(uint256 _assetsOut, address _receiver, address _owner) external returns (uint256 _sharesIn);
}
