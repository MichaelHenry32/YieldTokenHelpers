// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ISfrxUsdFrxUsdOracle {
    struct RewardsCycleData {
        uint40 cycleEnd;
        uint40 lastSync;
        uint216 rewardCycleAmount;
    }

    error CastError();
    error OnlyPendingTimelock();
    error OnlyPriceSource();
    error OnlyTimelock();
    error SamePriceSource();
    error StalePush();

    event MaxDistributionPerSecondPerAssetUpdated(uint256 newMax);
    event SetPriceSource(address oldPriceSource, address newPriceSource);
    event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);
    event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);
    event VaultDataUpdated(
        uint256 totalSupply, uint256 totalStoredAssets, uint256 lastRewardsDistribution, RewardsCycleData data
    );

    function acceptTransferTimelock() external;
    function calculateRewardsToDistribute(RewardsCycleData memory _rewardsCycleData, uint256 _deltaTime)
        external
        view
        returns (uint256 _rewardToDistribute);
    function decimals() external pure returns (uint8 _decimals);
    function description() external pure returns (string memory _description);
    function getPrices() external view returns (bool isBadData, uint256 _priceLow, uint256 _priceHigh);
    function lastL1Block() external view returns (uint96);
    function lastRewardsDistribution() external view returns (uint256);
    function latestRoundData()
        external
        view
        returns (uint80 _roundId, int256 _answer, uint256 _startedAt, uint256 _updatedAt, uint80 _answeredInRound);
    function maxDistributionPerSecondPerAsset() external view returns (uint256);
    function name() external pure returns (string memory _name);
    function pendingTimelockAddress() external view returns (address);
    function previewDistributeRewards() external view returns (uint256 _rewardToDistribute);
    function pricePerShare() external view returns (uint256);
    function priceSource() external view returns (address);
    function renounceTimelock() external;
    function rewardsCycleData() external view returns (uint40 cycleEnd, uint40 lastSync, uint216 rewardCycleAmount);
    function setPriceSource(address _newPriceSource) external;
    function stateRootOracle() external view returns (address);
    function storedTotalAssets() external view returns (uint256);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function timelockAddress() external view returns (address);
    function totalAssets() external view returns (uint256 _totalAssets);
    function totalSupply() external view returns (uint256);
    function transferTimelock(address _newTimelock) external;
    function updateMaxDistributionPerSecond(uint96 _l1BlockNumber, uint256 _maxPerSecond) external;
    function updatedAt() external view returns (uint256);
    function updatesFRAXData(
        uint96 _l1BlockNumber,
        uint256 _totalSupply,
        uint256 _totalAssets,
        uint256 _lastRewardsDistribution,
        RewardsCycleData memory _data
    ) external;
}
