/**
 * 补充完整 Caller 合约的 callSetValue 方法，用于设置 Callee 合约的 value 值。要求：

 * 使用 call 方法调用用 Callee 的 setValue 方法，并附带 1 Ether
 * 如果发送失败，抛出“call function failed”异常并回滚交易。
 * 如果发送成功，则返回 true
 */

pragma solidity ^0.8.0;

contract Callee {
    uint256 value;

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 value_) public payable {
        require(msg.value > 0);
        value = value_;
    }
}

contract Caller {
    function callSetValue(address callee, uint256 value) public returns (bool) {
        // 1. 编码setValue函数调用：签名为"setValue(uint256)"，参数为传入的value
        bytes memory payload = abi.encodeWithSignature("setValue(uint256)", value);
        
        // 2. 使用call调用，附带1 Ether（1 ether = 1e18 wei），并传入编码后的payload
        (bool success, ) = callee.call{value: 1 ether}(payload);
        
        // 3. 若调用失败，抛出异常并回滚
        require(success, "call function failed");
        
        // 4. 成功则返回true
        return success;
    }

    // 接收ETH的回调函数（确保Caller合约可以接收ETH，以便调用时能发送1 Ether）
    receive() external payable {}
}

// pragma solidity ^0.8.0;

// contract Callee {
//     uint256 value;

//     function getValue() public view returns (uint256) {
//         return value;
//     }

//     function setValue(uint256 value_) public payable {
//         require(msg.value > 0);
//         value = value_;
//     }
// }

// contract Caller {
//     // 方法1：使用 abi.encodeCall（推荐，编译器校验）
//     function callSetValue1(address callee, uint256 value) public returns (bool) {
//         // 用 abi.encodeCall 编码，参数为 (value)，自动校验函数签名
//         bytes memory payload = abi.encodeCall(Callee.setValue, (value));
        
//         // 用 call 发送1 Ether并调用，注意是 {value: 1 ether}
//         (bool success, ) = callee.call{value: 1 ether}(payload);
        
//         require(success, "call function failed");
//         return success;
//     }

//     // 方法2：使用 abi.encodeWithSelector（手动计算选择器）
//     function callSetValue2(address callee, uint256 value) public returns (bool) {
//         // 计算 setValue 的函数选择器
//         bytes4 selector = Callee.setValue.selector; // 等价于 bytes4(keccak256(bytes("setValue(uint256)")))
        
//         // 编码选择器+参数
//         bytes memory payload = abi.encodeWithSelector(selector, value);
        
//         // 发送1 Ether并调用
//         (bool success, ) = callee.call{value: 1 ether}(payload);
        
//         require(success, "call function failed");
//         return success;
//     }

//     // 方法3：使用 abi.encodeWithSignature（直接写签名）
//     function callSetValue3(address callee, uint256 value) public returns (bool) {
//         // 直接用函数签名编码
//         bytes memory payload = abi.encodeWithSignature("setValue(uint256)", value);
        
//         // 发送1 Ether并调用
//         (bool success, ) = callee.call{value: 1 ether}(payload);
        
//         require(success, "call function failed");
//         return success;
//     }

//     // 必须添加 receive 函数，确保合约能接收ETH（否则无法发送1 Ether）
//     receive() external payable {}
// }