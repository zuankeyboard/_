// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BankV1.sol";

contract BigBank is Bank {
    // 存款金额必须大于0.001 ether的修饰器
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "BigBank: deposit must be greater than 0.001 ether");
        _;
    }

    // 重写存款函数，添加最低存款限制
    function deposit() public payable override minDeposit {
        super.deposit();
    }

    // 转移管理员功能
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "BigBank: new owner cannot be zero address");
        owner = newOwner;
    }
}