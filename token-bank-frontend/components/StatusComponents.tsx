import React from 'react';
import { Spin, Result, Button } from 'antd';
import { LoadingOutlined, WarningOutlined } from '@ant-design/icons';

// 加载状态组件
export const LoadingSpinner: React.FC<{ tip?: string }> = ({ tip = '加载中...' }) => (
  <div style={{ 
    display: 'flex', 
    justifyContent: 'center', 
    alignItems: 'center', 
    height: '200px' 
  }}>
    <Spin 
      indicator={<LoadingOutlined style={{ fontSize: 48 }} spin />} 
      tip={tip}
    />
  </div>
);

// 错误状态组件
export const ErrorResult: React.FC<{ 
  error: string; 
  onRetry?: () => void;
  title?: string;
}> = ({ error, onRetry, title = '出错了' }) => (
  <Result
    status="error"
    title={title}
    subTitle={error}
    icon={<WarningOutlined />}
    extra={
      onRetry && (
        <Button type="primary" onClick={onRetry}>
          重试
        </Button>
      )
    }
  />
);

// 空状态组件
export const EmptyResult: React.FC<{ 
  description?: string;
  title?: string;
}> = ({ description, title }) => (
  <Result
    status="info"
    title={title || '暂无数据'}
    subTitle={description || '当前没有可显示的数据'}
  />
);