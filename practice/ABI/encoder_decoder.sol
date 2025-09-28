/**
 * 完善ABIEncoder合约的encodeUint和encodeMultiple函数，使用abi.encode对参数进行编码并返回
 * 完善ABIDecoder合约的decodeUint和decodeMultiple函数，使用abi.decode将字节数组解码成对应类型的数据
 */

pragma solidity ^0.8.0;

contract ABIEncoder {
    // 对单个uint256进行ABI编码
    function encodeUint(uint256 value) public pure returns (bytes memory) {
        // 使用abi.encode对uint256参数编码，返回编码后的字节数组
        return abi.encode(value);
    }

    // 对uint和string多个参数进行ABI编码
    function encodeMultiple(
        uint num,
        string memory text
    ) public pure returns (bytes memory) {
        // 使用abi.encode对多个参数按顺序编码，返回组合后的字节数组
        return abi.encode(num, text);
    }
}

contract ABIDecoder {
    // 将字节数组解码为单个uint
    function decodeUint(bytes memory data) public pure returns (uint) {
        // 使用abi.decode解码，指定目标类型为uint（即uint256）
        // 注意：解码时需用元组包裹类型，即使只有一个参数
        (uint decodedValue) = abi.decode(data, (uint));
        return decodedValue;
    }

    // 将字节数组解码为uint和string
    function decodeMultiple(
        bytes memory data
    ) public pure returns (uint, string memory) {
        // 使用abi.decode解码，指定目标类型为(uint, string)，与编码时的参数类型顺序一致
        (uint decodedNum, string memory decodedText) = abi.decode(data, (uint, string));
        return (decodedNum, decodedText);
    }
}

// pragma solidity ^0.8.0;

// contract ABIEncoder {
//     // 对单个uint256进行ABI编码（不使用return）
//     function encodeUint(uint256 value) public pure returns (bytes memory encoded) {
//         // 直接给命名返回参数encoded赋值，函数结束后自动返回
//         encoded = abi.encode(value);
//     }

//     // 对多个参数进行ABI编码（不使用return）
//     function encodeMultiple(
//         uint num,
//         string memory text
//     ) public pure returns (bytes memory encoded) {
//         // 给命名返回参数encoded赋值
//         encoded = abi.encode(num, text);
//     }
// }

// contract ABIDecoder {
//     // 解码为单个uint（不使用return）
//     function decodeUint(bytes memory data) public pure returns (uint decoded) {
//         // 解码结果直接赋值给命名返回参数decoded
//         (decoded) = abi.decode(data, (uint));
//     }

//     // 解码为多个参数（不使用return）
//     function decodeMultiple(
//         bytes memory data
//     ) public pure returns (uint decodedNum, string memory decodedText) {
//         // 解码结果分别赋值给两个命名返回参数
//         (decodedNum, decodedText) = abi.decode(data, (uint, string));
//     }
// }