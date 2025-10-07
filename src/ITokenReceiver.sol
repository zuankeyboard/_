// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Token接收者接口：合约需要实现此接口才能接收ERC20WithCallback转账
interface ITokenReceiver {
    function tokensReceived(address sender, address receiver, uint256 amount, bytes calldata data) external returns (bytes4);
}