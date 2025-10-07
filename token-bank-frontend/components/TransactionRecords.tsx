import React, { useState, useEffect } from 'react';
import { Card, List, Tag, Empty, Button, Space } from 'antd';
import { CheckCircleOutlined, ClockCircleOutlined, DollarOutlined, ReloadOutlined } from '@ant-design/icons';
import { useWatchContractEvent, usePublicClient } from 'wagmi';
import { TOKEN_BANK_V2_ABI, CONTRACT_ADDRESSES } from '../config/abis';
import { formatEther } from 'viem';

interface DepositRecord {
  user: string;
  amount: string;
  timestamp: number;
  txHash: string;
  type: 'deposit' | 'withdraw' | 'callback';
}

// 存款记录组件
export const TransactionRecords: React.FC = () => {
  const [records, setRecords] = useState<DepositRecord[]>([]);
  const [displayCount, setDisplayCount] = useState(20); // 显示数量
  const [isLoading, setIsLoading] = useState(false);
  const publicClient = usePublicClient();

  // 读取历史事件
  const fetchHistoricalEvents = async () => {
    if (!publicClient) return;

    setIsLoading(true);
    try {
      // 获取存款事件
      const depositLogs = await publicClient.getLogs({
        address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
        event: {
          type: 'event',
          name: 'Deposited',
          inputs: [
            { type: 'address', name: 'user', indexed: true },
            { type: 'uint256', name: 'amount' },
            { type: 'uint256', name: 'timestamp' }
          ]
        },
        fromBlock: 0n,
        toBlock: 'latest'
      });

      // 获取取款事件
      const withdrawLogs = await publicClient.getLogs({
        address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
        event: {
          type: 'event',
          name: 'Withdrawn',
          inputs: [
            { type: 'address', name: 'user', indexed: true },
            { type: 'uint256', name: 'amount' },
            { type: 'uint256', name: 'timestamp' }
          ]
        },
        fromBlock: 0n,
        toBlock: 'latest'
      });

      // 获取代币接收事件
      const callbackLogs = await publicClient.getLogs({
        address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
        event: {
          type: 'event',
          name: 'TokensReceived',
          inputs: [
            { type: 'address', name: 'user', indexed: true },
            { type: 'address', name: 'receiver' },
            { type: 'uint256', name: 'amount' }
          ]
        },
        fromBlock: 0n,
        toBlock: 'latest'
      });

      // 转换格式并合并
      const historicalRecords: DepositRecord[] = [
        ...depositLogs.map(log => ({
          user: log.args.user as string,
          amount: formatEther(log.args.amount as bigint),
          timestamp: Number(log.args.timestamp) * 1000,
          txHash: log.transactionHash,
          type: 'deposit' as const
        })),
        ...withdrawLogs.map(log => ({
          user: log.args.user as string,
          amount: formatEther(log.args.amount as bigint),
          timestamp: Number(log.args.timestamp) * 1000,
          txHash: log.transactionHash,
          type: 'withdraw' as const
        })),
        ...callbackLogs.map(log => ({
          user: log.args.user as string,
          amount: formatEther(log.args.amount as bigint),
          timestamp: Date.now(), // 使用当前时间
          txHash: log.transactionHash,
          type: 'callback' as const
        }))
      ];

      // 按时间排序（最新的在前）
      historicalRecords.sort((a, b) => b.timestamp - a.timestamp);
      
      setRecords(historicalRecords); // 保存所有记录
      setDisplayCount(20); // 重置显示数量
    } catch (error) {
      console.error('获取历史事件失败:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // 组件挂载时读取历史事件
  useEffect(() => {
    fetchHistoricalEvents();
  }, [publicClient]);

  // 监听存款事件
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
    abi: TOKEN_BANK_V2_ABI,
    eventName: 'Deposited',
    onLogs: (logs) => {
      const newRecords = logs.map(log => ({
        user: log.args.user as string,
        amount: formatEther(log.args.amount as bigint),
        timestamp: Number(log.args.timestamp) * 1000, // 转换为毫秒
        txHash: log.transactionHash,
        type: 'deposit' as const,
      }));
      setRecords(prev => {
        const allRecords = [...newRecords, ...prev];
        return allRecords.sort((a, b) => b.timestamp - a.timestamp); // 不再限制数量
      });
    },
  });

  // 监听取款事件
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
    abi: TOKEN_BANK_V2_ABI,
    eventName: 'Withdrawn',
    onLogs: (logs) => {
      const newRecords = logs.map(log => ({
        user: log.args.user as string,
        amount: formatEther(log.args.amount as bigint),
        timestamp: Number(log.args.timestamp) * 1000, // 转换为毫秒
        txHash: log.transactionHash,
        type: 'withdraw' as const,
      }));
      setRecords(prev => {
        const allRecords = [...newRecords, ...prev];
        return allRecords.sort((a, b) => b.timestamp - a.timestamp); // 不再限制数量
      });
    },
  });

  // 监听代币接收事件（来自ERC20WithCallback的回调）
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
    abi: TOKEN_BANK_V2_ABI,
    eventName: 'TokensReceived',
    onLogs: (logs) => {
      const newRecords = logs.map(log => ({
        user: log.args.user as string,
        amount: formatEther(log.args.amount as bigint),
        timestamp: Date.now(), // 使用当前时间，因为TokensReceived事件没有时间戳
        txHash: log.transactionHash,
        type: 'callback' as const,
      }));
      setRecords(prev => {
        const allRecords = [...newRecords, ...prev];
        return allRecords.sort((a, b) => b.timestamp - a.timestamp); // 不再限制数量
      });
    },
  });

  const formatAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  const formatTime = (timestamp: number) => {
    return new Date(timestamp).toLocaleString('zh-CN');
  };

  // 加载更多记录
  const loadMore = () => {
    setDisplayCount(prev => prev + 20); // 每次加载20条
  };

  // 刷新记录
  const refreshRecords = () => {
    fetchHistoricalEvents();
  };

  // 获取当前显示的记录
  const displayRecords = records.slice(0, displayCount);
  const hasMore = records.length > displayCount;

  return (
    <Card 
      title="交易记录" 
      style={{ marginBottom: 24 }}
      extra={
        <Button 
          icon={<ReloadOutlined />} 
          size="small" 
          onClick={refreshRecords}
          loading={isLoading}
        >
          刷新
        </Button>
      }
    >
      {records.length === 0 ? (
        <Empty description="暂无交易记录" />
      ) : (
        <>
          <List
            dataSource={displayRecords}
            renderItem={(record) => (
              <List.Item
                actions={[
                  <Tag 
                    key={record.txHash}
                    icon={record.type === 'deposit' ? <CheckCircleOutlined /> : record.type === 'withdraw' ? <ClockCircleOutlined /> : <DollarOutlined />}
                    color={record.type === 'deposit' ? 'success' : record.type === 'withdraw' ? 'processing' : 'warning'}
                  >
                    {record.type === 'deposit' ? '存款' : record.type === 'withdraw' ? '取款' : '回调存款'}
                  </Tag>
                ]}
              >
                <List.Item.Meta
                  title={
                    <div>
                      <span style={{ marginRight: 8 }}>
                        {record.type === 'deposit' ? '+' : '-'} {record.amount}
                      </span>
                      <span style={{ fontSize: 12, color: '#999' }}>
                        {formatTime(record.timestamp)}
                      </span>
                    </div>
                  }
                  description={`地址: ${formatAddress(record.user)}`}
                />
              </List.Item>
            )}
          />
          {hasMore && (
            <div style={{ textAlign: 'center', marginTop: 16 }}>
              <Button onClick={loadMore}>
                加载更多 ({records.length - displayCount} 条)
              </Button>
            </div>
          )}
          <div style={{ textAlign: 'center', marginTop: 16, color: '#666', fontSize: 12 }}>
            共 {records.length} 条记录，当前显示 {displayRecords.length} 条
          </div>
        </>
      )}
    </Card>
  );
};