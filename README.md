## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
---
好的，在 Foundry（Forge）项目中安装 OpenZeppelin 合约库非常简单，主要有两种推荐方法。

### 方法一：使用 `forge install`（推荐，最常用）

这是最标准、最集成化的方法。Foundry 直接使用 Git 子模块来管理依赖。

1.  **初始化项目（如果你的项目还不是 Foundry 项目）**
    如果你的目录还没有初始化，首先需要创建一个新项目。
    ```bash
    forge init my-project
    cd my-project
    ```
    如果已经是项目了，跳过这一步。

2.  **安装 OpenZeppelin 合约库**
    在项目根目录下执行以下命令：
    ```bash
    forge install OpenZeppelin/openzeppelin-contracts
    ```
    这个命令会从 GitHub 上将 OpenZeppelin 合约库拉取到项目的 `lib` 文件夹中。

3.  **在 `remappings.txt` 中生成重映射（可选但推荐）**
    Foundry 可以自动生成一个重映射文件，让你在导入合约时使用更短的路径。
    ```bash
    forge remappings > remappings.txt
    ```
    执行后，你的 `remappings.txt` 文件内容会类似这样：
    ```
    @openzeppelin/=lib/openzeppelin-contracts/
    ```
    这意味着，你可以在代码中用 `@openzeppelin/` 开头来导入库合约，例如：
    ```solidity
    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    ```
    如果没有这个文件，你可能需要使用相对路径，如 `import "../lib/openzeppelin-contracts/contracts/..."`，这样非常不方便。

**完整示例流程：**
```bash
# 1. 创建并进入新项目
forge init my-oz-project
cd my-oz-project

# 2. 安装 OpenZeppelin
forge install OpenZeppelin/openzeppelin-contracts

# 3. 生成重映射文件
forge remappings > remappings.txt

# 4. 现在你可以编译项目了，Forge 会自动识别依赖
forge build
```

### 方法二：作为 npm 包安装（适合混合项目）

如果你的项目不仅使用 Foundry，还同时使用了 Hardhat 或 Truffle 等基于 Node.js 的框架，那么也可以使用 npm 安装。

1.  **使用 npm 安装**
    ```bash
    npm install @openzeppelin/contracts
    ```
    这会将 OpenZeppelin 合约安装到 `node_modules` 目录中。

2.  **配置重映射**
    为了让 Foundry 能够找到 `node_modules` 中的依赖，你需要在 `remappings.txt` 文件中手动添加一行：
    ```
    @openzeppelin/=node_modules/@openzeppelin/contracts/
    ```
    之后，导入方式与方法一相同：
    ```solidity
    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    ```

### 使用示例：创建一个简单的 ERC20 代币

安装成功后，你就可以继承 OpenZeppelin 的合约了。例如，在 `src/MyToken.sol` 中：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 thanks to remappings.txt
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}
```

然后进行编译和测试：
```bash
forge build
forge test
```

### 更新依赖

当需要更新到新版本时，可以使用：

```bash
# 进入项目根目录
cd my-project

# 更新 OpenZeppelin 合约
forge update lib/openzeppelin-contracts

# 或者更新所有依赖
forge update
```

### 总结

| 特性 | 方法一 (`forge install`) | 方法二 (npm) |
| :--- | :--- | :--- |
| **推荐度** | **★★★★★**（纯 Foundry 项目） | **★★★☆☆**（混合项目） |
| **管理方式** | Git 子模块 | npm 包 |
| **集成度** | 与 Foundry 工具链无缝集成 | 需要手动配置重映射 |
| **适用场景** | 纯 Foundry 项目 | Foundry + Hardhat/Truffle 混合项目 |

对于绝大多数 Foundry 项目，**强烈推荐使用 `forge install` 方法**，这是最符合 Foundry 设计哲学的方式。