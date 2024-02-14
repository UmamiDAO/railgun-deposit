// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "./interfaces/IERC20.sol";
import {IGMETH} from "./interfaces/IGMETH.sol";
import {IMasterChefUmami} from "./interfaces/IMasterChefUmami.sol";
import {ICallbackReceiver} from "./interfaces/ICallbackReceiver.sol";

contract UmamiHandler is ICallbackReceiver {
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address constant RAILGUN_TREASURY = 0x3B374464a714525498e445ba050B91571937bFc8;
    address constant GMWETH = 0x4bCA8D73561aaEee2D3a584b9F4665310de1dD69;
    address constant MASTER_CHEF_UMAMI = 0x52F6159dCAE4CE617A3d50aEb7fAB617526d9D8F;
    address constant REQUEST_HANDLER = 0x685C20eaeD3eb20f9FD6B76a9D3069b53d5DA0bC;
    uint256 constant EMISSIONS_END = 1711756740; // Date and time (GMT): Friday, 29 March 2024 23:59:00

    function depositUmami() public payable {
        uint256 wethBalance = IERC20(WETH).balanceOf(address(this));
        require(wethBalance > 0);
        require(block.timestamp < EMISSIONS_END);
        IERC20(WETH).approve(GMWETH, wethBalance);
        IGMETH(GMWETH).depositWithCallback{value: msg.value}(wethBalance, 0, address(this), address(this));
    }

    function afterDepositExecution(uint256 key, bool success, OCRequest memory request) external {
        require(msg.sender == REQUEST_HANDLER);
        require(request.sender == address(this));
        require(success);
        uint256 gmWethBalance = IERC20(GMWETH).balanceOf(address(this));
        IERC20(GMWETH).approve(MASTER_CHEF_UMAMI, gmWethBalance);
        IMasterChefUmami(MASTER_CHEF_UMAMI).deposit(
            IMasterChefUmami(MASTER_CHEF_UMAMI).getPIdFromLP(GMWETH), gmWethBalance
        );
    }

    function returnToTreasury() public {
        require(block.timestamp > EMISSIONS_END);
        uint256 pid = IMasterChefUmami(MASTER_CHEF_UMAMI).getPIdFromLP(GMWETH);
        (uint256 stakedAmount,) = IMasterChefUmami(MASTER_CHEF_UMAMI).userInfo(pid, address(this));
        IMasterChefUmami(MASTER_CHEF_UMAMI).withdraw(pid, stakedAmount);
        IERC20(GMWETH).transfer(RAILGUN_TREASURY, IERC20(GMWETH).balanceOf(address(this)));
    }

    function collectArb() public {
        IMasterChefUmami(MASTER_CHEF_UMAMI).collectAllPoolRewards();
        IERC20(ARB).transfer(RAILGUN_TREASURY, IERC20(ARB).balanceOf(address(this)));
    }
}
