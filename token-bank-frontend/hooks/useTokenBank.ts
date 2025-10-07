import { useReadContract, useWriteContract, useWaitForTransactionReceipt, useAccount } from 'wagmi';
import { TOKEN_BANK_V2_ABI, ERC20_ABI, CONTRACT_ADDRESSES } from '../config/abis';
import { parseEther, formatEther } from 'viem';
import { message } from 'antd';
import { useEffect } from 'react';

// TokenBankV2合约交互Hook
export function useTokenBank() {
  const { address } = useAccount();
  
  // 读取用户存款余额
  const { data: userDeposit, refetch: refetchUserDeposit } = useReadContract({
    address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
    abi: TOKEN_BANK_V2_ABI,
    functionName: 'getUserDeposit',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  // 读取银行总余额
  const { data: bankTotalBalance } = useReadContract({
    address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
    abi: TOKEN_BANK_V2_ABI,
    functionName: 'getBankTotalBalance',
  });

  // 获取代币地址
  const { data: tokenAddress } = useReadContract({
    address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
    abi: TOKEN_BANK_V2_ABI,
    functionName: 'token',
  });

  // 存款功能
  const { writeContract: deposit, data: depositHash } = useWriteContract();
  
  // 取款功能
  const { writeContract: withdraw, data: withdrawHash } = useWriteContract();

  // 等待存款交易确认
  const { isLoading: isDepositPending, isSuccess: isDepositSuccess } = useWaitForTransactionReceipt({
    hash: depositHash,
  });

  // 等待取款交易确认
  const { isLoading: isWithdrawPending, isSuccess: isWithdrawSuccess } = useWaitForTransactionReceipt({
    hash: withdrawHash,
  });

  // 监听存款交易确认
  useEffect(() => {
    if (isDepositSuccess) {
      refetchUserDeposit();
      message.success('存款交易已确认！');
    }
  }, [isDepositSuccess, refetchUserDeposit]);

  // 监听取款交易确认
  useEffect(() => {
    if (isWithdrawSuccess) {
      refetchUserDeposit();
      message.success('取款交易已确认！');
    }
  }, [isWithdrawSuccess, refetchUserDeposit]);

  // 执行存款
  const handleDeposit = async (amount: string) => {
    try {
      if (!amount || parseFloat(amount) <= 0) {
        message.error('请输入有效的存款金额');
        return;
      }

      // 立即给用户反馈，避免等待交易构建
      message.loading('正在准备交易，请稍候...', 2);
      
      // 添加小延迟，让用户看到准备状态
      await new Promise(resolve => setTimeout(resolve, 300));

      await deposit({
        address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
        abi: TOKEN_BANK_V2_ABI,
        functionName: 'deposit',
        args: [parseEther(amount)],
      });
      
      message.success('交易请求已发送到钱包');
    } catch (error) {
      console.error('存款失败:', error);
      message.error('存款失败，请重试');
    }
  };

  // 执行取款
  const handleWithdraw = async (amount: string) => {
    try {
      if (!amount || parseFloat(amount) <= 0) {
        message.error('请输入有效的取款金额');
        return;
      }

      // 立即给用户反馈，避免等待交易构建
      message.loading('正在准备交易，请稍候...', 2);
      
      // 添加小延迟，让用户看到准备状态
      await new Promise(resolve => setTimeout(resolve, 300));

      await withdraw({
        address: CONTRACT_ADDRESSES.tokenBank as `0x${string}`,
        abi: TOKEN_BANK_V2_ABI,
        functionName: 'withdraw',
        args: [parseEther(amount)],
      });
      
      message.success('交易请求已发送到钱包');
    } catch (error) {
      console.error('取款失败:', error);
      message.error('取款失败，请重试');
    }
  };

  return {
    // 数据
    userDeposit: userDeposit ? formatEther(userDeposit as bigint) : '0',
    bankTotalBalance: bankTotalBalance ? formatEther(bankTotalBalance as bigint) : '0',
    tokenAddress: tokenAddress as string,
    
    // 方法
    deposit: handleDeposit,
    withdraw: handleWithdraw,
    refetchUserDeposit,
    
    // 状态
    isDepositPending,
    isWithdrawPending,
    depositHash,
    withdrawHash,
  };
}

// ERC20代币交互Hook
export function useToken(tokenAddress: string) {
  const { address } = useAccount();
  
  // 读取代币余额
  const { data: balance } = useReadContract({
    address: tokenAddress as `0x${string}`,
    abi: ERC20_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address && !!tokenAddress,
    },
  });

  // 读取代币符号
  const { data: symbol } = useReadContract({
    address: tokenAddress as `0x${string}`,
    abi: ERC20_ABI,
    functionName: 'symbol',
  });

  // 读取代币名称
  const { data: name } = useReadContract({
    address: tokenAddress as `0x${string}`,
    abi: ERC20_ABI,
    functionName: 'name',
  });

  // 读取代币精度
  const { data: decimals } = useReadContract({
    address: tokenAddress as `0x${string}`,
    abi: ERC20_ABI,
    functionName: 'decimals',
  });

  // 授权功能
  const { writeContract: approve } = useWriteContract();

  // 执行授权
  const handleApprove = async (spender: string, amount: string) => {
    try {
      await approve({
        address: tokenAddress as `0x${string}`,
        abi: ERC20_ABI,
        functionName: 'approve',
        args: [spender as `0x${string}`, parseEther(amount)],
      });
      
      message.success('授权交易已提交');
    } catch (error) {
      console.error('授权失败:', error);
      message.error('授权失败，请重试');
    }
  };

  return {
    // 数据
    balance: balance ? formatEther(balance as bigint) : '0',
    symbol: symbol as string,
    name: name as string,
    decimals: decimals ? Number(decimals) : 18,
    
    // 方法
    approve: handleApprove,
  };
}