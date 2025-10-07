// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ERC20WithCallback.sol";
import "../src/TokenBankV2.sol";

contract DeployTokenBankV2 is Script {
    function run() external {
        // 使用 Anvil 默认的第一个账户私钥
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        // 1. 部署 ERC20WithCallback 代币合约
        ERC20WithCallback token = new ERC20WithCallback();
        console.log("ERC20WithCallback deployed at:", address(token));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Total supply:", token.totalSupply());

        // 2. 部署 TokenBankV2 合约
        TokenBankV2 tokenBank = new TokenBankV2(address(token));
        console.log("TokenBankV2 deployed at:", address(tokenBank));
        console.log("TokenBank token address:", address(tokenBank.token()));

        // 3. 给部署者一些代币用于测试
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer address:", deployer);
        console.log("Deployer token balance:", token.balanceOf(deployer));

        // 4. 批准 TokenBank 合约可以转移代币（用于测试 deposit 功能）
        uint256 approveAmount = 1000000 * 10 ** 18; // 100万代币
        token.approve(address(tokenBank), approveAmount);
        console.log("Approved TokenBank to spend:", approveAmount);

        vm.stopBroadcast();

        // 输出部署信息
        console.log("\n=== Deployment Summary ===");
        console.log("ERC20WithCallback:", address(token));
        console.log("TokenBankV2:", address(tokenBank));
        console.log("Network: Anvil Local (Chain ID: 31337)");
        console.log("Deployer:", deployer);
    }
}
