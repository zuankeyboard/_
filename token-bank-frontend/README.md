# TokenBank V2 前端配置指南

## 项目概述
这是一个基于 Next.js + TypeScript + Viem + Ant Design Web3 的 TokenBank V2 前端应用，提供去中心化银行服务。

## 技术栈
- **前端框架**: Next.js 14 (Pages Router)
- **编程语言**: TypeScript
- **Web3库**: Viem + Wagmi
- **UI组件库**: Ant Design + Ant Design Web3
- **样式**: CSS Modules (已移除Tailwind CSS)

## 功能特性
✅ 钱包连接集成
✅ Token余额显示
✅ 存款功能
✅ 取款功能
✅ 交易记录显示
✅ 响应式UI设计

## 配置步骤

### 1. 配置合约地址
编辑 `config/abis.ts` 文件，替换为实际部署的合约地址：

```typescript
export const CONTRACT_ADDRESSES = {
  tokenBank: 'YOUR_TOKENBANK_V2_CONTRACT_ADDRESS', // TokenBankV2合约地址
  token: 'YOUR_ERC20_TOKEN_CONTRACT_ADDRESS', // ERC20代币地址
} as const;
```

### 2. 配置网络
编辑 `config/wagmi.ts` 文件，配置要连接的网络：

```typescript
export const config = createConfig({
  chains: [mainnet, sepolia], // 可以添加其他网络
  // ...
});
```

### 3. 配置WalletConnect (可选)
如果需要使用WalletConnect，设置环境变量：

```bash
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
```

## 项目结构

```
token-bank-frontend/
├── components/          # React组件
│   ├── BalanceCard.tsx  # 余额显示组件
│   ├── DepositCard.tsx  # 存款组件
│   ├── WithdrawCard.tsx # 取款组件
│   ├── TransactionRecords.tsx # 交易记录组件
│   └── StatusComponents.tsx   # 状态组件
├── config/              # 配置文件
│   ├── abis.ts         # 合约ABI和地址
│   └── wagmi.ts        # Web3配置
├── hooks/               # 自定义Hook
│   └── useTokenBank.ts # 合约交互Hook
├── src/
│   ├── pages/          # Next.js页面
│   │   ├── _app.tsx    # 应用入口
│   │   └── index.tsx   # 首页
│   └── styles/         # 样式文件
└── public/             # 静态资源
```

## 使用说明

### 开发环境运行
```bash
npm run dev
```

### 生产环境构建
```bash
npm run build
npm start
```

### 功能使用
1. **连接钱包**: 点击右上角的"连接钱包"按钮
2. **查看余额**: 连接后会自动显示钱包余额、银行存款和银行总存款
3. **存款**: 在存款卡片中输入金额，点击"存款"按钮
4. **取款**: 在取款卡片中输入金额，点击"取款"按钮
5. **查看记录**: 交易记录会自动显示最新的存款和取款操作

## 注意事项

1. **合约地址**: 使用前必须配置正确的合约地址
2. **网络选择**: 确保钱包连接到正确的网络
3. **代币授权**: 首次存款需要先授权代币转账
4. **Gas费用**: 所有交易都需要支付Gas费用

## 支持的浏览器
- Chrome (推荐配合MetaMask)
- Firefox
- Safari
- Edge

## 联系支持
如有问题，请检查浏览器控制台错误信息，或联系开发团队。
