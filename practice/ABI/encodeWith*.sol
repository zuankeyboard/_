/**
 * 补充完整getDataByABI，对getData函数签名及参数进行编码，调用成功后解码并返回数据
 * 补充完整setDataByABI1，使用abi.encodeWithSignature()编码调用setData函数，确保调用能够成功
 * 补充完整setDataByABI2，使用abi.encodeWithSelector()编码调用setData函数，确保调用能够成功
 * 补充完整setDataByABI3，使用abi.encodeCall()编码调用setData函数，确保调用能够成功
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataStorage {
    string private data;

    function setData(string memory newData) public {
        data = newData;
    }

    function getData() public view returns (string memory) {
        return data;
    }
}

contract DataConsumer {
    address private dataStorageAddress;

    constructor(address _dataStorageAddress) {
        dataStorageAddress = _dataStorageAddress;
    }

    // 编码调用getData()，解码返回结果
    function getDataByABI() public returns (string memory) {
        // 1. 编码getData()函数调用（无参数）
        bytes memory payload = abi.encodeWithSignature("getData()");
        
        // 2. 调用DataStorage合约
        (bool success, bytes memory data) = dataStorageAddress.call(payload);
        require(success, "call function failed");
        
        // 3. 解码返回的字节数组为string
        return abi.decode(data, (string));
    }

    // 使用abi.encodeWithSignature编码调用setData
    function setDataByABI1(string calldata newData) public returns (bool) {
        // 编码函数签名和参数："setData(string)" + newData
        bytes memory payload = abi.encodeWithSignature("setData(string)", newData);
        
        // 调用合约
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }

    // 使用abi.encodeWithSelector编码调用setData
    function setDataByABI2(string calldata newData) public returns (bool) {
        // 1. 计算setData的函数选择器（前4字节哈希）
        bytes4 selector = bytes4(keccak256(bytes("setData(string)")));
        
        // 2. 用选择器+参数编码
        bytes memory payload = abi.encodeWithSelector(selector, newData);
        
        // 3. 调用合约
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }

    // 使用abi.encodeCall编码调用setData（最安全的方式，编译器会检查函数匹配）
    function setDataByABI3(string calldata newData) public returns (bool) {
        // 直接传入函数引用和参数，编译器会自动校验函数签名和参数类型
        bytes memory payload = abi.encodeCall(DataStorage.setData, (newData));
        
        // 调用合约
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }
}