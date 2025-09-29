// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 复用之前的TokenBank基础合约
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// 回调接口定义（接收方需实现）
// interface ITokenReceiver {
//     // 回调函数：接收代币时触发，返回特定选择器表示成功
//     function tokensReceived(address sender, address receiver, uint256 amount) external returns (bytes4);
// }

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
}

// 继承TokenBank并实现回调接收功能
// contract TokenBankV2 is TokenBank, ITokenReceiver {
contract TokenBankV2 is TokenBank {
    constructor(address _tokenAddress) TokenBank(_tokenAddress) {
        // 确保传入的是带回调功能的ERC20合约（可选校验）
        require(_tokenAddress != address(0), "TokenBankV2: invalid token address");
    }

    // 实现回调函数：接收ERC20WithCallback转账时自动记录存款
    function tokensReceived(
        address sender,
        address receiver,
        uint256 amount
    ) external returns (bytes4) {
        // 安全校验1：确保调用者是当前银行管理的代币合约
        require(msg.sender == address(token), "TokenBankV2: invalid token");
        // 安全校验2：确保接收者是当前银行合约（防止回调到其他地址）
        require(receiver == address(this), "TokenBankV2: invalid receiver");
        // 安全校验3：确保金额有效
        require(amount > 0, "TokenBankV2: amount must be > 0");

        // 记录存款（相当于自动执行deposit逻辑）
        userDeposits[sender] += amount;
        emit Deposited(sender, amount, block.timestamp);

        // 返回回调选择器表示处理成功
        // return TOKENS_RECEIVED_SELECTOR;
        return bytes4(keccak256("tokensReceived(address,address,uint256)"));
    }
}