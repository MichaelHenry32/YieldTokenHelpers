// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FraxlendLenderHelpersProxy.sol";

pragma solidity ^0.8.0;

contract FraxlendLenderHelpersFactory is Ownable {
    using Clones for address;

    address private implementation;

    constructor(address _owner, address _implementation) Ownable(_owner) {
        implementation = _implementation;
    }

    function getFraxlendYieldTokenProxyAddress(bytes32 salt) external view returns (address) {
        require(owner() != address(0), "master must be set");
        return Clones.predictDeterministicAddress(implementation, salt);
    }

    function createFraxlendLenderHelpersProxy(address _fraxlendPairAddress, bytes32 salt)
        external
        payable
        onlyOwner
        returns (address _clone)
    {
        _clone = Clones.cloneDeterministic(implementation, salt);
        FraxlendLenderHelpersProxy(_clone).initialize(_fraxlendPairAddress);
    }
}
