// SPDX-License-Identifier: MIT

import {IFraxlendPair} from "./interfaces/IFraxlendPair.sol";

pragma solidity ^0.8.0;

contract FraxlendLenderHelpersProxy {
    address public fraxlendPairAddress;
    IFraxlendPair public FraxlendPair;

    function getFraxlendPairAddress() external view returns (address) {
        return fraxlendPairAddress;
    }
}
