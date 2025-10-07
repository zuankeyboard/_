import React from 'react';
import { Card, Statistic, Row, Col } from 'antd';
import { BankOutlined, DollarOutlined } from '@ant-design/icons';
import { useAccount } from 'wagmi';
import { useTokenBank, useToken } from '../hooks/useTokenBank';

interface BalanceCardProps {
  tokenAddress: string;
}

// 余额显示组件
export const BalanceCard: React.FC<BalanceCardProps> = ({ tokenAddress }) => {
  const { address } = useAccount();
  const { userDeposit, bankTotalBalance } = useTokenBank();
  const { balance: tokenBalance, symbol } = useToken(tokenAddress);

  return (
    <Card title="资产余额" style={{ marginBottom: 24 }}>
      <Row gutter={16}>
        <Col span={8}>
          <Statistic
            title="钱包余额"
            value={tokenBalance}
            precision={4}
            valueStyle={{ color: '#3f8600' }}
            prefix={<DollarOutlined />}
            suffix={symbol}
          />
        </Col>
        <Col span={8}>
          <Statistic
            title="银行存款"
            value={userDeposit}
            precision={4}
            valueStyle={{ color: '#1890ff' }}
            prefix={<BankOutlined />}
            suffix={symbol}
          />
        </Col>
        <Col span={8}>
          <Statistic
            title="银行总存款"
            value={bankTotalBalance}
            precision={4}
            valueStyle={{ color: '#722ed1' }}
            prefix={<BankOutlined />}
            suffix={symbol}
          />
        </Col>
      </Row>
      {address && (
        <div style={{ marginTop: 16, fontSize: 12, color: '#666' }}>
          当前地址: {address.slice(0, 6)}...{address.slice(-4)}
        </div>
      )}
    </Card>
  );
};