// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "./IERC20.sol";

interface IGMETH is IERC20 {
    function deposit(uint256 assets, uint256 minOutAfterFees, address receiver)
        external
        payable
        returns (uint256 shares);

    function depositWithCallback(uint256 assets, uint256 minOutAfterFees, address receiver, address callback)
        external
        payable
        returns (uint256 shares);
}
