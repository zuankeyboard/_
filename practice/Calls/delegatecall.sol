/**
 * 补充完整 Caller 合约 的 delegateSetValue 方法，调用 Callee 的 setValue 方法用于设置 value 值。要求：

 * 使用 delegatecall
 * 如果发送失败，抛出“delegate call failed”异常并回滚交易。
 */

pragma solidity ^0.8.0;

contract Callee {
    uint256 public value;

    function setValue(uint256 _newValue) public {
        value = _newValue;
    }
}

contract Caller {
    uint256 public value; // 与Callee状态变量布局一致，确保delegatecall正常工作

    function delegateSetValue(address callee, uint256 _newValue) public {
        // 1. 编码调用Callee.setValue的payload（函数签名+参数）
        bytes memory payload = abi.encodeWithSignature("setValue(uint256)", _newValue);
        
        // 2. 使用delegatecall调用：在Caller的上下文执行Callee的setValue逻辑
        (bool success, ) = callee.delegatecall(payload);
        
        // 3. 调用失败时抛出异常并回滚
        require(success, "delegate call failed");
    }
}

// pragma solidity ^0.8.0;

// contract Callee {
//     uint256 public value;

//     function setValue(uint256 _newValue) public {
//         value = _newValue;
//     }
// }

// contract Caller {
//     uint256 public value; // 与Callee状态变量布局一致

//     function delegateSetValue(address callee, uint256 _newValue) public {
//         // 1. 获取setValue的函数选择器（通过函数引用的selector属性）
//         bytes4 selector = Callee.setValue.selector; // 等价于 bytes4(keccak256(bytes("setValue(uint256)")))
        
//         // 2. 用选择器+参数编码payload
//         bytes memory payload = abi.encodeWithSelector(selector, _newValue);
        
//         // 3. 执行delegatecall并检查结果
//         (bool success, ) = callee.delegatecall(payload);
//         require(success, "delegate call failed");
//     }
// }

// pragma solidity ^0.8.0;

// contract Callee {
//     uint256 public value;

//     function setValue(uint256 _newValue) public {
//         value = _newValue;
//     }
// }

// contract Caller {
//     uint256 public value; // 与Callee状态变量布局一致

//     function delegateSetValue(address callee, uint256 _newValue) public {
//         // 1. 用abi.encodeCall编码（传入函数引用和参数，编译器自动校验）
//         bytes memory payload = abi.encodeCall(Callee.setValue, (_newValue));
        
//         // 2. 执行delegatecall并检查结果
//         (bool success, ) = callee.delegatecall(payload);
//         require(success, "delegate call failed");
//     }
// }

// pragma solidity ^0.8.0;

// contract Callee {
//     uint256 public value;

//     function setValue(uint256 _newValue) public {
//         value = _newValue;
//     }
// }

// contract Caller {
//     uint256 public value; // 与Callee状态变量布局一致

//     function delegateSetValue(address callee, uint256 _newValue) public {
//         // 1. 手动计算setValue的函数选择器（前4字节哈希）
//         // 函数签名"setValue(uint256)"的keccak256前4字节为 0x55241077
//         bytes4 selector = 0x55241077;
        
//         // 2. 手动编码参数（uint256需为32字节）
//         bytes32 param = bytes32(_newValue);
        
//         // 3. 拼接选择器和参数为payload
//         bytes memory payload = abi.encodePacked(selector, param);
        
//         // 4. 执行delegatecall并检查结果
//         (bool success, ) = callee.delegatecall(payload);
//         require(success, "delegate call failed");
//     }
// }