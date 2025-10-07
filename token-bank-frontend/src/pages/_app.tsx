import "@/styles/globals.css";
import type { AppProps } from "next/app";
import { WagmiWeb3ConfigProvider, MetaMask } from '@ant-design/web3-wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ConfigProvider } from 'antd';
import { config } from '../../config/wagmi';
import { localChain } from '../../config/wagmi';

// 创建查询客户端
const queryClient = new QueryClient();

export default function App({ Component, pageProps }: AppProps) {
  return (
    <WagmiWeb3ConfigProvider 
      config={config}
      chains={[localChain]}
      eip6963={{
        autoAddInjectedWallets: true,
      }}
      wallets={[MetaMask()]}
    >
      <QueryClientProvider client={queryClient}>
        <ConfigProvider
          theme={{
            token: {
              colorPrimary: '#1890ff',
              borderRadius: 8,
            },
          }}
        >
          <Component {...pageProps} />
        </ConfigProvider>
      </QueryClientProvider>
    </WagmiWeb3ConfigProvider>
  );
}
