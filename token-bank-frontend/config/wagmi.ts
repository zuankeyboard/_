import { http } from 'wagmi';
import { mainnet } from 'wagmi/chains';
import { createConfig } from 'wagmi';
import { defineChain } from 'viem';

// 本地Anvil链配置
export const localChain = defineChain({
  id: 31337,
  name: 'Local Anvil',
  network: 'localhost',
  nativeCurrency: {
    decimals: 18,
    name: 'Local ETH',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { http: ['http://localhost:8545'] },
    public: { http: ['http://localhost:8545'] },
  },
  blockExplorers: {
    default: { name: 'Local Explorer', url: 'http://localhost:8545' },
  },
  testnet: true,
});

// 获取WalletConnect项目ID
const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'default_project_id';

// Ant Design Web3 配置
export const config = createConfig({
  chains: [localChain],
  transports: {
    [localChain.id]: http('http://localhost:8545'),
  },
});

// 声明模块类型
declare module 'wagmi' {
  interface Register {
    config: typeof config;
  }
}