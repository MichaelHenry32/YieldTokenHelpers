// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FraxlendLenderHelpers.sol";

pragma solidity ^0.8.0;

contract FraxlendLenderHelpersProxyFactory is Ownable {
    using Clones for address;
    address private implementation;

    struct PairHelper {
        address helper;
        address pair;
    }

    PairHelper[] public pairHelpers;

    constructor(address _owner, address _implementation) Ownable(_owner) {
        implementation = _implementation;
    }

    function getFraxlendYieldTokenProxyAddress(
        bytes32 salt
    ) external view returns (address) {
        require(owner() != address(0), "master must be set");
        return Clones.predictDeterministicAddress(implementation, salt);
    }

    function createFraxlendLenderHelpersProxy(
        address _fraxlendPairAddress,
        bytes32 salt
    ) external payable onlyOwner returns (address _clone) {
        _clone = Clones.cloneDeterministic(implementation, salt);
        FraxlendLenderHelpers(_clone).initialize(_fraxlendPairAddress);
        pairHelpers.push(
            PairHelper({helper: _clone, pair: _fraxlendPairAddress})
        );
    }

    function getAllHelperAddresses()
        external
        view
        returns (PairHelper[] memory _deployedPairs)
    {
        _deployedPairs = pairHelpers;
    }
}
