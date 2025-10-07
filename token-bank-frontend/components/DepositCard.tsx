import React, { useState } from 'react';
import { Card, Input, Button, Space, message } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { useAccount } from 'wagmi';
import { useTokenBank } from '../hooks/useTokenBank';

const { Search } = Input;

// 存款组件
export const DepositCard: React.FC = () => {
  const { address } = useAccount();
  const { deposit, isDepositPending, depositHash } = useTokenBank();
  const [depositAmount, setDepositAmount] = useState('');

  // 处理存款
  const handleDeposit = async () => {
    if (!address) {
      message.warning('请先连接钱包');
      return;
    }

    if (!depositAmount || parseFloat(depositAmount) <= 0) {
      message.error('请输入有效的存款金额');
      return;
    }

    // 立即禁用输入框，避免重复点击
    setDepositAmount('');
    await deposit(depositAmount);
  };

  return (
    <Card 
      title="存款" 
      style={{ marginBottom: 24 }}
      actions={[
        depositHash && (
          <div key="tx" style={{ fontSize: 12, color: '#666' }}>
            交易哈希: {depositHash.slice(0, 10)}...{depositHash.slice(-8)}
          </div>
        )
      ]}
    >
      <Space direction="vertical" style={{ width: '100%' }}>
        <Search
          placeholder="输入存款金额"
          value={depositAmount}
          onChange={(e) => setDepositAmount(e.target.value)}
          enterButton={
            <Button 
              type="primary" 
              icon={<PlusOutlined />}
              loading={isDepositPending}
              disabled={!address}
            >
              {isDepositPending ? '存款中...' : '存款'}
            </Button>
          }
          size="large"
          onSearch={handleDeposit}
          disabled={!address || isDepositPending}
        />
        {!address && (
          <div style={{ color: '#999', fontSize: 12 }}>
            请先连接钱包以使用存款功能
          </div>
        )}
        {depositHash && (
          <div style={{ color: isDepositPending ? '#faad14' : '#52c41a', fontSize: 12 }}>
            {isDepositPending ? '⏳ 交易确认中，请稍候...' : '✅ 交易已确认！'}
          </div>
        )}
      </Space>
    </Card>
  );
};