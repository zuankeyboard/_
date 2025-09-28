/**
 * 补充完整getFunctionSelector1函数，返回getValue函数的签名
 * 补充完整getFunctionSelector2函数，返回setValue函数的签名
 */

pragma solidity ^0.8.0;

contract FunctionSelector {
    uint256 private storedValue;

    function getValue() public view returns (uint) {
        return storedValue;
    }

    function setValue(uint value) public {
        storedValue = value;
    }

    // 返回getValue函数的签名（函数选择器）
    function getFunctionSelector1() public pure returns (bytes4) {
        // 函数签名字符串："getValue()"（无参数）
        // 计算keccak256哈希的前4字节
        return bytes4(keccak256(bytes("getValue()")));
    }

    // 返回setValue函数的签名（函数选择器）
    function getFunctionSelector2() public pure returns (bytes4) {
        // 函数签名字符串："setValue(uint256)"（注意uint实际是uint256的别名，需用完整类型）
        // 计算keccak256哈希的前4字节
        return bytes4(keccak256(bytes("setValue(uint256)")));
    }
}