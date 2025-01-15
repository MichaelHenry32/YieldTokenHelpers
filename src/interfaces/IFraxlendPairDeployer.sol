// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IFraxlendPairDeployer {
    struct ConstructorParams {
        address circuitBreaker;
        address comptroller;
        address timelock;
        address fraxlendWhitelist;
        address fraxlendPairRegistry;
    }

    error CircuitBreakerOnly();
    error Create2Failed();
    error WhitelistedDeployersOnly();

    event LogDeploy(
        address indexed address_,
        address indexed asset,
        address indexed collateral,
        string name,
        bytes configData,
        bytes immutables,
        bytes customConfigData
    );
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetCircuitBreaker(address oldAddress, address newAddress);
    event SetComptroller(address oldAddress, address newAddress);
    event SetRegistry(address oldAddress, address newAddress);
    event SetTimelock(address oldAddress, address newAddress);
    event SetWhitelist(address oldAddress, address newAddress);

    function circuitBreakerAddress() external view returns (address);
    function comptrollerAddress() external view returns (address);
    function contractAddress1() external view returns (address);
    function contractAddress2() external view returns (address);
    function defaultSwappers(uint256) external view returns (address);
    function deploy(bytes memory _configData) external returns (address _pairAddress);
    function deployedPairsArray(uint256) external view returns (address);
    function deployedPairsLength() external view returns (uint256);
    function fraxlendPairRegistryAddress() external view returns (address);
    function fraxlendWhitelistAddress() external view returns (address);
    function getAllPairAddresses() external view returns (address[] memory _deployedPairs);
    function getNextNameSymbol(address _asset, address _collateral)
        external
        view
        returns (string memory _name, string memory _symbol);
    function globalPause(address[] memory _addresses) external returns (address[] memory _updatedAddresses);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function setCircuitBreaker(address _newAddress) external;
    function setComptroller(address _newAddress) external;
    function setCreationCode(bytes memory _creationCode) external;
    function setDefaultSwappers(address[] memory _swappers) external;
    function setRegistry(address _newAddress) external;
    function setTimelock(address _newAddress) external;
    function setWhitelist(address _newAddress) external;
    function timelockAddress() external view returns (address);
    function transferOwnership(address newOwner) external;
    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch);
}
