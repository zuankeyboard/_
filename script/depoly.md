# 方案 1: 使用完整的验证参数
```
source .env && forge script script/DeployMyToken.s.sol:DeployMyToken \
  --rpc-url https://sepolia.infura.io/v3/$INFURA_API_KEY \
  --broadcast \
  --verify \
  --verifier etherscan \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --chain 11155111
```

# 方案 2: 分步操作（推荐）
## 1. 先部署（不验证）
```
source .env && forge script script/DeployMyToken.s.sol:DeployMyToken \
  --rpc-url https://sepolia.infura.io/v3/$INFURA_API_KEY \
  --broadcast \
  --chain 11155111
```

## 2. 后续手动验证
```
source .env && forge verify-contract <CONTRACT_ADDRESS> \
  src/MyToken.sol:MyToken \
  --verifier etherscan \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --chain 11155111
```
# 手动验证
```
source .env && forge verify-contract 0x14A58AAd9f20662299a4BBF24F7D41508065D0E1 src/MyToken.sol:MyToken --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --chain 11155111 

source .env && forge verify-contract 0x14A58AAd9f20662299a4BBF24F7D41508065D0E1 src/MyToken.sol:MyToken --verifier sourcify --chain 11155111 

source .env && forge verify-contract 0x14A58AAd9f20662299a4BBF24F7D41508065D0E1 src/MyToken.sol:MyToken --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --chain 11155111 --constructor-args $(cast abi-encode "constructor(string,string)" "DecertToken" "DEC") 
```