// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 基础ERC20合约（复用之前实现）
contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10 **uint256(_decimals));
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }
}

// 回调接口定义（接收方需实现）
interface ITokenReceiver {
    // 回调函数：接收代币时触发，返回特定选择器表示成功
    function tokensReceived(address sender, address receiver, uint256 amount) external returns (bytes4);
}

// 带回调功能的ERC20扩展合约
contract ERC20WithCallback is BaseERC20 {
    // 回调函数的选择器（用于验证接收方是否正确实现）
    bytes4 public constant TOKENS_RECEIVED_SELECTOR = bytes4(keccak256("tokensReceived(address,address,uint256)"));

    constructor() 
        BaseERC20("ERC20WithCallback", "ERC20CB", 18, 100000000) // 初始化基础ERC20参数
    {}

    // 带回调的转账函数：目标为合约时触发其tokensReceived
    function transferWithCallback(address to, uint256 value) public returns (bool) {
        // 1. 执行基础转账逻辑
        require(balances[msg.sender] >= value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);

        // 2. 若目标是合约地址，调用其tokensReceived回调
        if (address(to).code.length > 0) { // 判断是否为合约地址
            bytes4 returnSelector = ITokenReceiver(to).tokensReceived(msg.sender, to, value);
            // 验证回调返回值，确保接收方正确处理
            require(returnSelector == TOKENS_RECEIVED_SELECTOR, "ERC20: callback failed");
        }

        return true;
    }
}