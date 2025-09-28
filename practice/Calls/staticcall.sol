/**
 * 补充完整 Caller 合约的 callGetData 方法，使用 staticcall 调用 Callee 合约中 getData 函数，并返回值。
 * 当调用失败时，抛出“staticcall function failed”异常。
 */

pragma solidity ^0.8.0;

contract Callee {
    function getData() public pure returns (uint256) {
        return 42;
    }
}

contract Caller {
    function callGetData(address callee) public view returns (uint256 data) {
        // 1. 生成getData函数的调用payload（函数选择器，无参数）
        bytes4 selector = bytes4(keccak256(bytes("getData()")));
        bytes memory payload = abi.encodeWithSelector(selector);
        
        // 2. 使用staticcall调用Callee合约的getData函数（适合view/pure函数，不修改状态）
        (bool success, bytes memory returnData) = callee.staticcall(payload);
        
        // 3. 检查调用是否成功，失败则抛出异常
        require(success, "staticcall function failed");
        
        // 4. 解码返回的字节数据为uint256
        data = abi.decode(returnData, (uint256));
        
        return data;
    }
}

// pragma solidity ^0.8.0;

// contract Callee {
//     function getData() public pure returns (uint256) {
//         return 42;
//     }
// }

// contract Caller {
//     // 使用 abi.encodeWithSignature 实现
//     function callGetDataWithSignature(address callee) public view returns (uint256 data) {
//         // 生成payload：直接传入函数签名字符串（无参数）
//         bytes memory payload = abi.encodeWithSignature("getData()");
        
//         // 静态调用
//         (bool success, bytes memory returnData) = callee.staticcall(payload);
//         require(success, "staticcall function failed");
        
//         // 解码返回值
//         data = abi.decode(returnData, (uint256));
//         return data;
//     }
// }

// pragma solidity ^0.8.0;

// contract Callee {
//     function getData() public pure returns (uint256) {
//         return 42;
//     }
// }

// contract Caller {
//     // 使用 abi.encodeCall 实现（最推荐）
//     function callGetDataWithEncodeCall(address callee) public view returns (uint256 data) {
//         // 生成payload：传入函数引用和参数（无参数时用空元组）
//         bytes memory payload = abi.encodeCall(Callee.getData, ());
        
//         // 静态调用
//         (bool success, bytes memory returnData) = callee.staticcall(payload);
//         require(success, "staticcall function failed");
        
//         // 解码返回值
//         data = abi.decode(returnData, (uint256));
//         return data;
//     }
// }