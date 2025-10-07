import React, { useState } from 'react';
import { Card, Input, Button, Space, message } from 'antd';
import { MinusOutlined } from '@ant-design/icons';
import { useAccount } from 'wagmi';
import { useTokenBank } from '../hooks/useTokenBank';

const { Search } = Input;

// 取款组件
export const WithdrawCard: React.FC = () => {
  const { address } = useAccount();
  const { withdraw, userDeposit, isWithdrawPending, withdrawHash } = useTokenBank();
  const [withdrawAmount, setWithdrawAmount] = useState('');

  // 处理取款
  const handleWithdraw = async () => {
    if (!address) {
      message.warning('请先连接钱包');
      return;
    }

    if (!withdrawAmount || parseFloat(withdrawAmount) <= 0) {
      message.error('请输入有效的取款金额');
      return;
    }

    if (parseFloat(withdrawAmount) > parseFloat(userDeposit)) {
      message.error('取款金额不能超过存款余额');
      return;
    }

    // 立即禁用输入框，避免重复点击
    setWithdrawAmount('');
    await withdraw(withdrawAmount);
  };

  return (
    <Card 
      title="取款" 
      style={{ marginBottom: 24 }}
      actions={[
        withdrawHash && (
          <div key="tx" style={{ fontSize: 12, color: '#666' }}>
            交易哈希: {withdrawHash.slice(0, 10)}...{withdrawHash.slice(-8)}
          </div>
        )
      ]}
    >
      <Space direction="vertical" style={{ width: '100%' }}>
        <div style={{ marginBottom: 16, color: '#666' }}>
          可用存款余额: {parseFloat(userDeposit).toFixed(4)}
        </div>
        <Search
          placeholder="输入取款金额"
          value={withdrawAmount}
          onChange={(e) => setWithdrawAmount(e.target.value)}
          enterButton={
            <Button 
              type="primary" 
              icon={<MinusOutlined />}
              loading={isWithdrawPending}
              disabled={!address || parseFloat(userDeposit) === 0}
            >
              {isWithdrawPending ? '取款中...' : '取款'}
            </Button>
          }
          size="large"
          onSearch={handleWithdraw}
          disabled={!address || isWithdrawPending || parseFloat(userDeposit) === 0}
        />
        {!address && (
          <div style={{ color: '#999', fontSize: 12 }}>
            请先连接钱包以使用取款功能
          </div>
        )}
        {parseFloat(userDeposit) === 0 && address && (
          <div style={{ color: '#999', fontSize: 12 }}>
            您当前没有存款余额
          </div>
        )}
        {withdrawHash && (
          <div style={{ color: isWithdrawPending ? '#faad14' : '#52c41a', fontSize: 12 }}>
            {isWithdrawPending ? '⏳ 交易确认中，请稍候...' : '✅ 交易已确认！'}
          </div>
        )}
      </Space>
    </Card>
  );
};