// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IMasterChefUmami {
    function getPIdFromLP(address lp) external view returns (uint256);
    function collectAllPoolRewards() external;
    function userInfo(uint256 _pid, address _account)
        external
        view
        returns (uint256 stakedAmount, uint256 rewardDebt);
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}
