// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface ICallbackReceiver {
    /// @dev open close request
    struct OCRequest {
        address sender;
        address account;
        address vault;
        address callback;
        bool isDeposit;
        uint256 amount;
        uint256 minOut;
        uint256 requestBlock;
    }

    function afterDepositExecution(uint256 key, bool sucess, OCRequest memory request) external;
}
