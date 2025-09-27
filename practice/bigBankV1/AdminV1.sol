// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBankV1.sol";

contract Admin {
    // Admin合约自己的所有者
    address owner;

    // 仅Admin合约所有者可调用的修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Admin: only owner can call this function");
        _;
    }

    // 构造函数：设置部署者为Admin合约的所有者
    constructor() {
        owner = msg.sender;
    }

    // 从银行合约提取资金到Admin合约
    function adminWithdraw(IBank bank) external onlyOwner() {
        uint256 balance = bank.getContractBalance();
        require(balance > 0, "Admin: bank contract has no balance");
        bank.withdraw(balance);
    }

    // 接收以太函数：用于接收从银行合约提取的资金
    // receive() payable;
    receive() external payable {}

    // function adminWithdrawToOwner(address addr) external onlyOwner() {
    //     uint256 balance = addr.balance;
    //     require(balance > 0, "Admin: address has no balance");
    //     // payable(addr).transfer(balance);
    //     (bool success, ) = addr.call{value: balance}("");
    //     require(success, "Admin: transfer failed");
    // }

    // 提取以太函数：用于将Admin合约中的资金提取到所有者地址
    function adminWithdrawToOwner() external onlyOwner() {
        uint256 balance = address(this).balance;
        require(balance > 0, "Admin: address has no balance");
        // payable(addr).transfer(balance);
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Admin: transfer failed");
    }
}