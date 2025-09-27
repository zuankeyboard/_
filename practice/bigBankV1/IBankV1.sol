// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// IBank 接口定义
interface IBank {
    // 结构体定义
    struct Depositor {
        address addr;
        uint256 amount;
    }
    
    // 状态变量getter
    function getOwner() external view returns (address);
    function getBalances(address) external view returns (uint256);
    function getTopDepositors(uint256) external view returns (address, uint256);
    
    // 核心功能
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function getContractBalance() external view returns (uint256);
    function getTopDepositors() external view returns (Depositor[3] memory);
}
