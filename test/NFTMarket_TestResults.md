No files changed, compilation skipped

Ran 20 tests for test/NFTMarket.t.sol:NFTMarketTest
[PASS] invariant_marketNeverHoldsTokens() (runs: 256, calls: 128000, reverts: 98161)

╭-------------------+----------------------+-------+---------+----------╮
| Contract          | Selector             | Calls | Reverts | Discards |
+=======================================================================+
| NFTMarket         | buyNFT               | 9765  | 9765    | 0        |
|-------------------+----------------------+-------+---------+----------|
| NFTMarket         | list                 | 9914  | 9914    | 0        |
|-------------------+----------------------+-------+---------+----------|
| NFTMarket         | tokensReceived       | 9761  | 9761    | 0        |
|-------------------+----------------------+-------+---------+----------|
| ERC20WithCallback | approve              | 9801  | 0       | 0        |
|-------------------+----------------------+-------+---------+----------|
| ERC20WithCallback | transfer             | 9815  | 9700    | 0        |
|-------------------+----------------------+-------+---------+----------|
| ERC20WithCallback | transferFrom         | 9792  | 9689    | 0        |
|-------------------+----------------------+-------+---------+----------|
| ERC20WithCallback | transferWithCallback | 9863  | 9734    | 0        |
|-------------------+----------------------+-------+---------+----------|
| TestNFT           | approve              | 9906  | 9906    | 0        |
|-------------------+----------------------+-------+---------+----------|
| TestNFT           | mint                 | 9878  | 10      | 0        |
|-------------------+----------------------+-------+---------+----------|
| TestNFT           | safeTransferFrom     | 19730 | 19730   | 0        |
|-------------------+----------------------+-------+---------+----------|
| TestNFT           | setApprovalForAll    | 9829  | 6       | 0        |
|-------------------+----------------------+-------+---------+----------|
| TestNFT           | transferFrom         | 9946  | 9946    | 0        |
╰-------------------+----------------------+-------+---------+----------╯

[PASS] testBuyNFTFailAlreadySold() (gas: 194163)
[PASS] testBuyNFTFailInsufficientAllowance() (gas: 163366)
[PASS] testBuyNFTFailInsufficientTokens() (gas: 162852)
[PASS] testBuyNFTFailNotListed() (gas: 47761)
[PASS] testBuyNFTFailSelfPurchase() (gas: 155977)
[PASS] testBuyNFTSuccess() (gas: 182152)
[PASS] testBuyNFTWithCallback() (gas: 183101)
[PASS] testFuzzListAndBuyNFT(uint256,address) (runs: 256, μ: 203456, ~: 203527)
[PASS] testInvariantMarketNeverHoldsTokens() (gas: 628365)
[PASS] testInvariantMarketNeverHoldsTokensWithCallback() (gas: 171984)
[PASS] testListMultipleNFTs() (gas: 345374)
[PASS] testListNFTFailAlreadyListed() (gas: 131071)
[PASS] testListNFTFailInvalidContract() (gas: 12979)
[PASS] testListNFTFailNotApproved() (gas: 29394)
[PASS] testListNFTFailNotOwner() (gas: 21279)
[PASS] testListNFTFailZeroPrice() (gas: 45873)
[PASS] testListNFTSuccess() (gas: 128936)
[PASS] testListNFTWithMaxPrice() (gas: 125249)
[PASS] testListNFTWithMinPrice() (gas: 125268)
Suite result: ok. 20 passed; 0 failed; 0 skipped; finished in 2.90s (2.95s CPU time)

Ran 1 test suite in 2.90s (2.90s CPU time): 20 tests passed, 0 failed, 0 skipped (20 total tests)
