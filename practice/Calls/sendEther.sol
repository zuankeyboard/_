/**
 * 补充完整 Caller 合约 的 sendEther 方法，用于向指定地址发送 Ether。要求：

 * 使用 call 方法发送 Ether
 * 如果发送失败，抛出“sendEther failed”异常并回滚交易。
 * 如果发送成功，则返回 true
 */

pragma solidity ^0.8.0;

contract Caller {
    function sendEther(address to, uint256 value) public returns (bool) {
        // 使用call方法发送Ether，通过{value: value}指定发送金额，空字符串表示无附加数据
        (bool success, ) = to.call{value: value}("");
        
        // 若发送失败，抛出异常并回滚
        require(success, "sendEther failed");
        
        // 发送成功返回true
        return success;
    }

    // 接收Ether的回调函数（确保合约可以接收ETH，用于测试时给合约充值）
    receive() external payable {}
}