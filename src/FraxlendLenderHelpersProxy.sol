// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IFraxlendPair} from "./interfaces/IFraxlendPair.sol";

pragma solidity ^0.8.0;

contract FraxlendLenderHelpersProxy is Initializable {
    address public fraxlendPairAddress;
    IFraxlendPair public FraxlendPair;

    constructor() {}

    function initialize(address _fraxlendPairAddress) public initializer {
        require(
            _fraxlendPairAddress != address(0),
            "FraxlendPairAddress must be set"
        );
        fraxlendPairAddress = _fraxlendPairAddress;
        FraxlendPair = IFraxlendPair(fraxlendPairAddress);
    }

    function getFraxlendPairAddress() external view returns (address) {
        return fraxlendPairAddress;
    }
}
