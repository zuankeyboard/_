// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        // 设置Token基本信息
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** decimals; // 总供给1亿，考虑18位小数

        balances[msg.sender] = totalSupply;  // 部署者获得全部初始代币
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // 返回指定地址的代币余额
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 检查转账金额是否超过余额
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        
        // 更新余额
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // 检查余额是否充足
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        // 检查授权额度是否充足
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        
        // 更新授权额度和余额
        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // 设置授权额度
        allowances[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // 返回授权额度
        return allowances[_owner][_spender];     
    }
}