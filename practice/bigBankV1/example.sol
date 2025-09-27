// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// IBank 接口定义
interface IBank {
    function withdraw() external;
    function getBalance(address account) external view returns (uint256);
}

// Bank 合约实现
contract Bank is IBank {
    address public admin;
    mapping(address => uint256) public balances;
    address[3] public topDepositors; // 存储存款前三名用户
    
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed admin, uint256 amount);
    
    // 仅管理员可调用的修饰符
    modifier onlyAdmin() {
        require(msg.sender == admin, "Bank: caller is not the admin");
        _;
    }
    
    constructor() {
        admin = msg.sender; // 部署者成为初始管理员
    }
    
    // 接收以太币的fallback函数，允许直接向合约地址转账
    receive() external payable virtual {
        deposit();
    }
    
    // 存款函数
    function deposit() public payable virtual {
        require(msg.value > 0, "Bank: deposit amount must be greater than 0");
        
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
        
        emit Deposit(msg.sender, msg.value);
    }
    
    // 取款函数，仅管理员可调用
    function withdraw() external override onlyAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "Bank: no funds to withdraw");
        
        // 转账给管理员
        (bool success, ) = admin.call{value: balance}("");
        require(success, "Bank: withdrawal failed");
        
        emit Withdrawal(admin, balance);
    }
    
    // 获取账户余额
    function getBalance(address account) external view override returns (uint256) {
        return balances[account];
    }
    
    // 更新存款前三名用户
    function updateTopDepositors(address user) internal {
        uint256 userBalance = balances[user];
        
        // 检查用户是否已在前三名中
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositors[i] == user) {
                sortTopDepositors(); // 重新排序
                return;
            }
        }
        
        // 检查是否能进入前三名
        for (uint256 i = 0; i < 3; i++) {
            if (userBalance > balances[topDepositors[i]]) {
                // 后移其他用户
                for (uint256 j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = user;
                return;
            }
        }
    }
    
    // 对前三名用户按存款金额排序
    function sortTopDepositors() internal {
        // 简单冒泡排序
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (balances[topDepositors[i]] < balances[topDepositors[j]]) {
                    address temp = topDepositors[i];
                    topDepositors[i] = topDepositors[j];
                    topDepositors[j] = temp;
                }
            }
        }
    }
}

// BigBank 合约，继承自 Bank
contract BigBank is Bank {
    // 最低存款限制修饰符
    modifier minimumDeposit() {
        require(msg.value > 0.001 ether, "BigBank: deposit must exceed 0.001 ether");
        _;
    }
    
    // 重写存款函数，添加最低存款限制
    function deposit() public payable override minimumDeposit {
        super.deposit();
    }
    
    // 重写receive函数，确保直接转账也受最低存款限制
    receive() external payable override {
        require(msg.value > 0.001 ether, "BigBank: deposit must exceed 0.001 ether");
        super.deposit();
    }
    
    // 转移管理员权限
    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "BigBank: new admin cannot be zero address");
        admin = newAdmin;
    }
}

// Admin 合约
contract Admin {
    address public owner;
    
    event AdminWithdraw(address indexed bank, uint256 amount);
    
    // 仅所有者可调用的修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Admin: caller is not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; // 部署者成为初始所有者
    }
    
    // 从银行合约取款到Admin合约
    function adminWithdraw(IBank bank) external onlyOwner {
        uint256 balanceBefore = address(this).balance;
        
        // 调用银行合约的withdraw方法
        bank.withdraw();
        
        uint256 amountReceived = address(this).balance - balanceBefore;
        emit AdminWithdraw(address(bank), amountReceived);
    }
}
