import Head from "next/head";
import { Layout, Typography, Space } from 'antd';
import { ConnectButton, Connector } from '@ant-design/web3';
import { useAccount } from 'wagmi';
import { useState, useEffect } from 'react';
import { BalanceCard } from '../../components/BalanceCard';
import { DepositCard } from '../../components/DepositCard';
import { WithdrawCard } from '../../components/WithdrawCard';
import { TransactionRecords } from '../../components/TransactionRecords';
import { CONTRACT_ADDRESSES } from '../../config/abis';

const { Title } = Typography;
const { Content } = Layout;

export default function Home() {
  const { address, isConnected } = useAccount();

  // 防止hydration mismatch，只在客户端渲染连接状态
  const [mounted, setMounted] = useState(false);
  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <>
      <Head>
        <title>TokenBank V2 - 去中心化银行</title>
        <meta name="description" content="基于区块链的去中心化银行系统" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      
      <Layout style={{ minHeight: '100vh', background: '#f0f2f5' }}>
        {/* 头部 */}
        <div style={{ 
          background: '#fff', 
          padding: '16px 24px', 
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center'
        }}>
          <Title level={2} style={{ margin: 0, color: '#1890ff' }}>
            🏦 TokenBank V2
          </Title>
          {mounted && (
            <Connector>
              <ConnectButton />
            </Connector>
          )}
        </div>

        {/* 主要内容 */}
        <Content style={{ padding: '24px', maxWidth: '1200px', margin: '0 auto', width: '100%' }}>
          {!mounted || !address ? (
            <div style={{ 
              textAlign: 'center', 
              padding: '100px 0',
              background: '#fff',
              borderRadius: '8px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
            }}>
              <Title level={3} style={{ color: '#666' }}>
                欢迎使用 TokenBank V2
              </Title>
              <p style={{ color: '#999', marginBottom: 24 }}>
                请连接您的钱包以开始使用去中心化银行服务
              </p>
              {mounted && (
                <Connector>
                  <ConnectButton />
                </Connector>
              )}
            </div>
          ) : (
            <Space direction="vertical" style={{ width: '100%' }}>
              {/* 余额显示 */}
              <BalanceCard tokenAddress={CONTRACT_ADDRESSES.token} />
              
              {/* 操作区域 */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
                <DepositCard />
                <WithdrawCard />
              </div>
              
              {/* 交易记录 */}
              <TransactionRecords />
            </Space>
          )}
        </Content>

        {/* 页脚 */}
        <div style={{ 
          textAlign: 'center', 
          padding: '24px',
          background: '#fff',
          borderTop: '1px solid #e8e8e8'
        }}>
          <p style={{ color: '#999', margin: 0 }}>
            TokenBank V2 - 基于区块链的去中心化银行系统 ©2024
          </p>
        </div>
      </Layout>
    </>
  );
}
