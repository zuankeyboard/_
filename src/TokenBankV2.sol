// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 复用之前的TokenBank基础合约
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

import "./ITokenReceiver.sol";

contract TokenBank {
    IERC20 public immutable token;
    mapping(address => uint256) public userDeposits;

    event Deposited(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 timestamp);

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "TokenBank: invalid token address");
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "TokenBank: amount must be > 0");
        require(token.transferFrom(msg.sender, address(this), amount), "TokenBank: transferFrom failed");
        userDeposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount, block.timestamp);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "TokenBank: amount must be > 0");
        require(userDeposits[msg.sender] >= amount, "TokenBank: insufficient deposit");
        require(token.transfer(msg.sender, amount), "TokenBank: transfer failed");
        userDeposits[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    function getBankTotalBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getUserDeposit(address user) external view returns (uint256) {
        return userDeposits[user];
    }
}

// 继承TokenBank并实现回调接收功能
contract TokenBankV2 is TokenBank, ITokenReceiver {
    // 添加重入锁
    bool private _callbackLocked;

    // 添加回调事件
    event TokensReceived(address indexed sender, uint256 amount, bytes data);

    constructor(address _tokenAddress) TokenBank(_tokenAddress) {
        // 确保传入的是带回调功能的ERC20合约（可选校验）
        require(_tokenAddress != address(0), "TokenBankV2: invalid token address");
    }

    // ITokenReceiver 接口实现：处理来自 ERC20WithCallback 的回调
    function tokensReceived(address sender, address receiver, uint256 amount, bytes calldata data)
        external
        returns (bytes4)
    {
        // 重入保护
        require(!_callbackLocked, "TokenBankV2: reentrant call");
        _callbackLocked = true;

        // 安全校验1：确保调用者是我们信任的Token合约
        require(msg.sender == address(token), "TokenBankV2: only token contract can call");
        // 安全校验2：确保接收者是当前银行合约（防止回调到其他地址）
        require(receiver == address(this), "TokenBankV2: invalid receiver");
        // 安全校验3：确保金额有效
        require(amount > 0, "TokenBankV2: amount must be > 0");

        // 记录存款（相当于自动执行deposit逻辑）
        userDeposits[sender] += amount;
        emit Deposited(sender, amount, block.timestamp);
        emit TokensReceived(sender, amount, data);

        // 释放重入锁
        _callbackLocked = false;

        // 返回回调选择器表示处理成功
        return bytes4(keccak256("tokensReceived(address,address,uint256,bytes)"));
    }
}
