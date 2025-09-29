// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入ERC20标准接口（与BaseERC20兼容）
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenBank {
    // 要处理的ERC20代币合约地址
    IERC20 public immutable token;
    
    // 记录每个地址存入的代币数量
    mapping(address => uint256) public userDeposits;
    
    // 事件：记录存款和取款行为
    event Deposited(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 timestamp);
    
    // 构造函数：初始化要管理的代币合约地址
    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "TokenBank: invalid token address");
        token = IERC20(_tokenAddress);
    }
    
    /**
     * @dev 存入代币到银行
     * @param amount 要存入的代币数量（最小单位）
     * 注意：存入前需先调用代币的approve方法，授权TokenBank合约转移该数量的代币
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "TokenBank: deposit amount must be greater than 0");
        
        // 1. 从用户地址转移代币到银行合约
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "TokenBank: transferFrom failed (check allowance)");
        
        // 2. 更新用户存款记录
        userDeposits[msg.sender] += amount;
        
        // 3. 触发存款事件
        emit Deposited(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @dev 从银行取出代币
     * @param amount 要取出的代币数量（最小单位）
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "TokenBank: withdrawal amount must be greater than 0");
        // 检查用户存款是否充足
        require(userDeposits[msg.sender] >= amount, "TokenBank: insufficient deposit");
        
        // 1. 从银行合约转移代币到用户地址
        bool success = token.transfer(msg.sender, amount);
        require(success, "TokenBank: transfer failed");
        
        // 2. 更新用户存款记录
        userDeposits[msg.sender] -= amount;
        
        // 3. 触发取款事件
        emit Withdrawn(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @dev 查询银行合约中当前持有的代币总数量
     */
    function getBankTotalBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}