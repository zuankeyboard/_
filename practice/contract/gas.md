基于EIP-1559的费用机制（base fee、priority fee、max fee）：


### 1. 钱包账号需要的最低余额（GWei）  
在以太坊上，用户发起一笔交易 设置了GasLimit 为 10000, Max Fee 为 10 GWei, Max priority fee 为 1 GWei ， 为此用户应该在钱包账号里多少 GWei 的余额？

用户发起交易时，钱包需要预存的金额是“最大可能消耗的费用”，即 **GasLimit × Max Fee**（这是用户愿意支付的最高总费用，未消耗部分会退回）。  
- 计算：10000（GasLimit）× 10（Max Fee，GWei）= **100,000 GWei**  
- 结论：钱包需至少有100,000 GWei余额。  


### 2. 矿工（验证者）拿到的手续费（GWei）  
在以太坊上，用户发起一笔交易 设置了 GasLimit 为 10000, Max Fee 为 10 GWei, Max priority Fee 为 1 GWei，在打包时，Base Fee 为 5 GWei, 实际消耗的Gas为 5000， 那么矿工（验证者）拿到的手续费是多少 GWei ?

矿工的收入仅来自 **priority fee（优先费）**，计算公式为：**实际消耗Gas × priority fee**（优先级费用不能超过用户设置的Max priority fee）。  
- 已知：实际消耗Gas=5000，Max priority fee=1 GWei（此处未超过限制）  
- 计算：5000 × 1 = **5,000 GWei**  
- 结论：矿工拿到5,000 GWei。  


### 3. 用户需要支付的总手续费（GWei）  
在以太坊上，用户发起一笔交易 设置了 GasLimit 为 10000, Max Fee 为 10 GWei, Max priority Fee 为 1 GWei，在打包时，Base Fee 为 5 GWei, 实际消耗的Gas为 5000， 那么用户需要支付的的手续费是多少 GWei ?

用户实际支付的总费用= **实际消耗Gas ×（base fee + 实际priority fee）**。  
- 规则：实际priority fee = min（用户设置的Max priority fee，Max Fee - base fee）  
  此处：Max priority fee=1 GWei，Max Fee - base fee=10-5=5 GWei，取较小值1 GWei。  
- 计算：5000 ×（5 + 1）= 5000 × 6 = **30,000 GWei**  
- 结论：用户需支付30,000 GWei。  


### 4. 燃烧掉的ETH数量（GWei）  
在以太坊上，用户发起一笔交易 设置了 GasLimit 为 10000, Max Fee 为 10 GWei, Max priority Fee 为 1 GWei，在打包时，Base Fee 为 5 GWei, 实际消耗的 Gas 为 5000， 那么燃烧掉的 Eth 数量是多少 GWei ?

EIP-1559中，base fee会被“燃烧”（销毁），计算公式为：**实际消耗Gas × base fee**。  
- 计算：5000 × 5 = **25,000 GWei**  
- 结论：燃烧掉25,000 GWei。  