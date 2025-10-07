// NFTMarket事件监听脚本
import { createPublicClient, http, parseAbiItem } from 'viem';
import { sepolia } from 'viem/chains';

// 导入环境变量
import dotenv from 'dotenv';
dotenv.config();

// 配置Sepolia测试网客户端
const client = createPublicClient({
  chain: sepolia,
  transport: http(`https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`),
});

// NFTMarket合约地址 - 替换为你部署的合约地址
const NFT_MARKET_ADDRESS = '0x7BBD25eEe62a083F207636375f5498A00675e6e3';

// 事件ABI定义
const NFT_LISTED_EVENT = parseAbiItem('event NFTListed(address indexed nftContract, uint256 indexed tokenId, address indexed seller, uint256 price)');
const NFT_PURCHASED_EVENT = parseAbiItem('event NFTPurchased(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, address seller, uint256 price)');

// 监听NFT上架事件
async function listenToNFTListedEvents() {
  console.log('开始监听NFT上架事件...');
  
  client.watchEvent({
    address: NFT_MARKET_ADDRESS,
    event: NFT_LISTED_EVENT,
    onLogs: (logs) => {
      for (const log of logs) {
        const { args } = log;
        console.log('\n--- NFT上架事件 ---');
        console.log(`NFT合约地址: ${args.nftContract}`);
        console.log(`Token ID: ${args.tokenId}`);
        console.log(`卖家地址: ${args.seller}`);
        console.log(`价格: ${args.price} 代币`);
        console.log('------------------');
      }
    },
  });
}

// 监听NFT购买事件
async function listenToNFTPurchasedEvents() {
  console.log('开始监听NFT购买事件...');
  
  client.watchEvent({
    address: NFT_MARKET_ADDRESS,
    event: NFT_PURCHASED_EVENT,
    onLogs: (logs) => {
      for (const log of logs) {
        const { args } = log;
        console.log('\n--- NFT购买事件 ---');
        console.log(`NFT合约地址: ${args.nftContract}`);
        console.log(`Token ID: ${args.tokenId}`);
        console.log(`买家地址: ${args.buyer}`);
        console.log(`卖家地址: ${args.seller}`);
        console.log(`价格: ${args.price} 代币`);
        console.log('------------------');
      }
    },
  });
}

// 监听历史事件
async function getHistoricalEvents() {
  console.log('获取历史上架事件...');
  
  const listedLogs = await client.getLogs({
    address: NFT_MARKET_ADDRESS,
    event: NFT_LISTED_EVENT,
    fromBlock: 'earliest',
  });
  
  console.log(`找到 ${listedLogs.length} 个历史上架事件`);
  
  for (const log of listedLogs) {
    const { args } = log;
    console.log('\n--- 历史NFT上架事件 ---');
    console.log(`NFT合约地址: ${args.nftContract}`);
    console.log(`Token ID: ${args.tokenId}`);
    console.log(`卖家地址: ${args.seller}`);
    console.log(`价格: ${args.price} 代币`);
    console.log('----------------------');
  }
  
  console.log('获取历史购买事件...');
  
  const purchasedLogs = await client.getLogs({
    address: NFT_MARKET_ADDRESS,
    event: NFT_PURCHASED_EVENT,
    fromBlock: 'earliest',
  });
  
  console.log(`找到 ${purchasedLogs.length} 个历史购买事件`);
  
  for (const log of purchasedLogs) {
    const { args } = log;
    console.log('\n--- 历史NFT购买事件 ---');
    console.log(`NFT合约地址: ${args.nftContract}`);
    console.log(`Token ID: ${args.tokenId}`);
    console.log(`买家地址: ${args.buyer}`);
    console.log(`卖家地址: ${args.seller}`);
    console.log(`价格: ${args.price} 代币`);
    console.log('----------------------');
  }
}

// 主函数
async function main() {
  try {
    // 获取历史事件
    await getHistoricalEvents();
    
    // 开始监听新事件
    await listenToNFTListedEvents();
    await listenToNFTPurchasedEvents();
    
    console.log('事件监听器已启动，等待新事件...');
  } catch (error) {
    console.error('监听事件时出错:', error);
  }
}

// 运行主函数
main();