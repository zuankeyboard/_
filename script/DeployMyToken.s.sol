// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Script.sol";
import "../src/MyToken.sol"; // 假设合约文件在src目录下

contract DeployMyToken is Script {
    // 部署函数
    function run() external returns (MyToken) {
        // 从环境变量获取部署者私钥（确保是Decert.met登录的钱包私钥）
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 启动广播（使用部署者私钥签名交易）
        vm.startBroadcast(deployerPrivateKey);

        // 部署合约，指定名称和符号（示例："DecertToken" 和 "DEC"）
        MyToken token = new MyToken("DecertToken", "DEC");

        // 保存部署信息
        saveContract("MyToken", address(token));

        // 结束广播
        vm.stopBroadcast();

        return token;
    }

    /**
     * @notice 将已部署合约的地址保存到本地 JSON 文件
     * @dev 文件路径格式：deployments/{合约名称}_{链ID}.json
     * @param name 合约名称，用于生成文件名
     * @param addr 已部署合约的地址
     */
    function saveContract(string memory name, address addr) public {
        // 获取当前链的链 ID 并转为字符串
        string memory chainId = vm.toString(block.chainid);

        // 初始化 JSON 键名
        string memory json1 = "key";
        // 序列化地址到 JSON 字符串
        string memory finalJson = vm.serializeAddress(json1, "address", addr);

        // 构建文件目录路径：deployments/合约名称_
        string memory dirPath = string.concat(
            string.concat("deployments/", name),
            "_"
        );

        // 将最终 JSON 写入磁盘，文件名为 链ID.json
        vm.writeJson(
            finalJson,
            string.concat(dirPath, string.concat(chainId, ".json"))
        );
    }
}
