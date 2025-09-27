//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBankV1.sol";

contract Bank is IBank {
    // 管理员地址 - 修改为可变更的，以便BigBank可以转移管理员
    address public owner;

    // 记录每个地址的存款金额
    mapping(address => uint256) public balances;

    // 存款记录结构：地址和金额
    // struct Depositor {
    //     address addr;
    //     uint256 amount;
    // }

    // 存储存款前三名用户
    Depositor[3] public topDepositors;

    // 事件定义
    event Deposited(address indexed depositor, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed owner, uint256 amount, uint256 timestamp);
    event TopDepositorsUpdated(Depositor[3] newTopDepositors);

    // 仅管理员可调用的修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Bank: only owner can call this function");
        _;
    }

    // 构造函数：设置部署者为管理员
    constructor() {
        owner = msg.sender;
    }

    // 接收以太函数：允许直接向合约地址存款
    receive() external payable {
        deposit();
    }

    // 存款函数
    function deposit() public payable virtual {
        require(msg.value > 0, "Bank: deposit amount must be greater than 0");
        
        // 更新存款余额
        balances[msg.sender] += msg.value;
        
        // 更新前三名存款记录
        updateTopDepositors(msg.sender, balances[msg.sender]);
        
        // 触发存款事件
        emit Deposited(msg.sender, msg.value, block.timestamp);
    }

    // 管理员提款函数
    function withdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Bank: withdrawal amount must be greater than 0");
        require(address(this).balance >= amount, "Bank: insufficient contract balance");
        
        // 转账给管理员
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Bank: withdrawal failed");
        
        // 触发提款事件
        emit Withdrawn(owner, amount, block.timestamp);
    }

    // 更新存款前三名记录
    function updateTopDepositors(address depositor, uint256 amount) internal {
        // 创建临时数组存储当前前三名+新存款人
        Depositor[4] memory temp;
        for (uint256 i = 0; i < 3; i ++ ){
            temp[i] = topDepositors[i];
        }
        // temp[3] = Depositor{depositor, amount};
        // temp[3] = Depositor{addr: depositor, amount: amount};
        temp[3] = Depositor({addr: depositor, amount: amount});

        // 排序：从高到低
        for (uint256 i = 0; i < 4; i ++ ) {
            for (uint256 j = i + 1; j < 4; j ++ ) {
                if (temp[i].amount < temp[j].amount) {
                    (temp[i], temp[j]) = (temp[j], temp[i]);
                }
            }
        }

        // 去重并更新前三名（如果有重复地址）
        Depositor[3] memory newTop;
        uint256 count = 0;
        for (uint256 i = 0; i < 4 && count < 3; i++) {
            bool isDuplicate = false;
            for (uint256 j = 0; j < count; j++) {
                if (temp[i].addr == newTop[j].addr) {
                    isDuplicate = true;
                    break;
                }
            }
            if (!isDuplicate) {
                newTop[count] = temp[i];
                count++;
            }
        }
        
        // 更新前三名
        // topDepositors = newTop;
        // UnimplementedFeatureError: Copying of type struct IBank.Depositor memory[3] memory to storage not yet supported.
        
        for (uint256 i = 0; i < 3; i ++ ) {
            topDepositors[i] = newTop[i];
        }
        
        // 触发前三名更新事件
        emit TopDepositorsUpdated(newTop);
    }
    
    // 获取当前合约余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // 获取完整的前三名存款记录
    function getTopDepositors() external view returns (Depositor[3] memory) {
        return topDepositors;
    }

    // 状态变量getter
    function getOwner() external view returns (address) {
        return owner;  // 银行账户？
    }
    
    function getBalances(address addr) external view onlyOwner returns (uint256) {
        return balances[addr];
    }

    function getTopDepositors(uint256 i) external view returns (address, uint256) {
        return (topDepositors[i].addr, topDepositors[i].amount);
    }
}
