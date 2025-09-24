// package day1
// package main

// import (
// 	"crypto/sha256"
// 	"encoding/hex"
// 	"encoding/json"
// 	"fmt"
// 	"time"
// )

// // Transaction 表示区块链中的交易信息
// type Transaction struct {
// 	Sender    string  `json:"sender"`
// 	Recipient string  `json:"recipient"`
// 	Amount    float64 `json:"amount"`
// }

// // Block 表示区块链中的一个区块
// type Block struct {
// 	Index        int           `json:"index"`
// 	Timestamp    int64         `json:"timestamp"`
// 	Transactions []Transaction `json:"transactions"`
// 	Proof        int           `json:"proof"`
// 	PreviousHash string        `json:"previous_hash"`
// }

// // Blockchain 表示区块链结构
// type Blockchain struct {
// 	chain               []*Block
// 	currentTransactions []Transaction
// }

// // NewBlockchain 创建一个新的区块链实例
// func NewBlockchain() *Blockchain {
// 	bc := &Blockchain{
// 		chain:               make([]*Block, 0),
// 		currentTransactions: make([]Transaction, 0),
// 	}

// 	// 创建创世区块（区块链的第一个区块，没有前序区块）
// 	bc.createGenesisBlock()
// 	return bc
// }

// // createGenesisBlock 创建创世区块
// func (bc *Blockchain) createGenesisBlock() {
// 	// 创世区块的previous_hash通常设为"0"
// 	bc.NewBlock(1, "0")
// }

// // NewBlock 创建一个新的区块并添加到链上
// func (bc *Blockchain) NewBlock(proof int, previousHash string) *Block {
// 	block := &Block{
// 		Index:        len(bc.chain) + 1,
// 		Timestamp:    time.Now().Unix(),
// 		Timestamp:    time.Now().UnixNano(), // 纳秒级精度，1秒=1e9纳秒
// 		Transactions: bc.currentTransactions,
// 		Proof:        proof,
// 		PreviousHash: previousHash,
// 	}

// 	// 重置当前交易列表，为下一个区块准备
// 	bc.currentTransactions = make([]Transaction, 0)
// 	bc.chain = append(bc.chain, block)

// 	return block
// }

// // NewTransaction 添加一笔新交易到下一个要挖掘的区块
// func (bc *Blockchain) NewTransaction(sender, recipient string, amount float64) {
// 	bc.currentTransactions = append(bc.currentTransactions, Transaction{
// 		Sender:    sender,
// 		Recipient: recipient,
// 		Amount:    amount,
// 	})
// }

// // LastBlock 返回区块链中最后一个区块
// func (bc *Blockchain) LastBlock() *Block {
// 	return bc.chain[len(bc.chain)-1]
// }

// // CalculateHash 计算区块的SHA-256哈希值
// func (b *Block) CalculateHash() string {
// 	// 将区块转换为JSON格式以便计算哈希
// 	blockBytes, err := json.Marshal(b)
// 	if err != nil {
// 		panic(err)
// 	}

// 	// 计算SHA-256哈希
// 	hash := sha256.Sum256(blockBytes)
// 	return hex.EncodeToString(hash[:])
// }

// // ProofOfWork 执行工作量证明：找到一个proof使得前一个区块的proof和当前proof的哈希以4个0开头
// func (bc *Blockchain) ProofOfWork(lastProof int) int {
// 	proof := 0
// 	for !bc.validProof(lastProof, proof) {
// 		proof++
// 	}
// 	return proof
// }

// // validProof 验证证明：检查哈希是否以4个0开头
// func (bc *Blockchain) validProof(lastProof, proof int) bool {
// 	// 组合前一个proof和当前proof
// 	guess := fmt.Sprintf("%d%d", lastProof, proof)
// 	hash := sha256.Sum256([]byte(guess))
// 	hashStr := hex.EncodeToString(hash[:])

// 	// 检查哈希是否以4个0开头
// 	return len(hashStr) >= 4 && hashStr[:4] == "0000"
// }

// // PrintChain 打印区块链中的所有区块
// func (bc *Blockchain) PrintChain() {
// 	for i, block := range bc.chain {
// 		blockHash := block.CalculateHash()
// 		fmt.Printf("区块 #%d:\n", i+1)
// 		fmt.Printf("  索引: %d\n", block.Index)
// 		fmt.Printf("  时间戳: %d\n", block.Timestamp)
// 		fmt.Printf("  交易: %v\n", block.Transactions)
// 		fmt.Printf("  Proof: %d\n", block.Proof)
// 		fmt.Printf("  前一区块哈希: %s\n", block.PreviousHash)
// 		fmt.Printf("  当前区块哈希: %s\n\n", blockHash)
// 	}
// }

// func main() {
// 	// 创建区块链
// 	bc := NewBlockchain()
// 	fmt.Println("已创建新的区块链，包含创世区块")

// 	// 添加一些交易并挖矿
// 	bc.NewTransaction("Alice", "Bob", 5.0)
// 	bc.NewTransaction("Bob", "Charlie", 2.5)

// 	fmt.Println("正在挖掘第一个区块...")
// 	lastBlock := bc.LastBlock()
// 	lastProof := lastBlock.Proof
// 	proof := bc.ProofOfWork(lastProof)

// 	// 将新块添加到链上
// 	previousHash := lastBlock.CalculateHash()
// 	bc.NewBlock(proof, previousHash)

// 	// 添加更多交易并挖矿
// 	bc.NewTransaction("Charlie", "Alice", 1.0)
// 	bc.NewTransaction("Bob", "Dave", 0.5)

// 	fmt.Println("正在挖掘第二个区块...")
// 	lastBlock = bc.LastBlock()
// 	lastProof = lastBlock.Proof
// 	proof = bc.ProofOfWork(lastProof)

// 	previousHash = lastBlock.CalculateHash()
// 	bc.NewBlock(proof, previousHash)

// 	// 打印整个区块链
// 	fmt.Println("\n区块链完整信息:")
// 	bc.PrintChain()
// }

// package main

// import (
// 	"crypto/sha256"
// 	"encoding/hex"
// 	"encoding/json"
// 	"fmt"
// 	"time"
// )

// // Transaction 交易结构
// type Transaction struct {
// 	Sender    string  `json:"sender"`
// 	Recipient string  `json:"recipient"`
// 	Amount    float64 `json:"amount"`
// }

// // Block 区块结构（存储Unix纳秒时间戳）
// type Block struct {
// 	Index        int           `json:"index"`
// 	Timestamp    int64         `json:"timestamp"` // 存储：Unix纳秒时间戳
// 	Transactions []Transaction `json:"transactions"`
// 	Proof        int           `json:"proof"`
// 	PreviousHash string        `json:"previous_hash"`
// }

// // Blockchain 区块链结构
// type Blockchain struct {
// 	chain               []*Block
// 	currentTransactions []Transaction
// }

// // NewBlockchain 创建区块链
// func NewBlockchain() *Blockchain {
// 	bc := &Blockchain{
// 		chain:               make([]*Block, 0),
// 		currentTransactions: make([]Transaction, 0),
// 	}
// 	bc.createGenesisBlock()
// 	return bc
// }

// // createGenesisBlock 创建创世区块
// func (bc *Blockchain) createGenesisBlock() {
// 	bc.NewBlock(1, "0")
// }

// // NewBlock 创建新区块（使用纳秒级时间戳）
// func (bc *Blockchain) NewBlock(proof int, previousHash string) *Block {
// 	block := &Block{
// 		Index:        len(bc.chain) + 1,
// 		Timestamp:    time.Now().UnixNano(), // 存储：纳秒级时间戳（避免重复）
// 		Transactions: bc.currentTransactions,
// 		Proof:        proof,
// 		PreviousHash: previousHash,
// 	}
// 	bc.currentTransactions = make([]Transaction, 0)
// 	bc.chain = append(bc.chain, block)
// 	return block
// }

// // 其他方法（NewTransaction、LastBlock、CalculateHash等保持不变）
// func (bc *Blockchain) NewTransaction(sender, recipient string, amount float64) {
// 	bc.currentTransactions = append(bc.currentTransactions, Transaction{
// 		Sender:    sender,
// 		Recipient: recipient,
// 		Amount:    amount,
// 	})
// }

// func (bc *Blockchain) LastBlock() *Block {
// 	return bc.chain[len(bc.chain)-1]
// }

// func (b *Block) CalculateHash() string {
// 	blockBytes, err := json.Marshal(b)
// 	if err != nil {
// 		panic(err)
// 	}
// 	hash := sha256.Sum256(blockBytes)
// 	return hex.EncodeToString(hash[:])
// }

// func (bc *Blockchain) ProofOfWork(lastProof int) int {
// 	proof := 0
// 	for !bc.validProof(lastProof, proof) {
// 		proof++
// 	}
// 	return proof
// }

// func (bc *Blockchain) validProof(lastProof, proof int) bool {
// 	guess := fmt.Sprintf("%d%d", lastProof, proof)
// 	hash := sha256.Sum256([]byte(guess))
// 	hashStr := hex.EncodeToString(hash[:])
// 	return len(hashStr) >= 4 && hashStr[:4] == "0000"
// }

// // PrintChain 打印区块信息（将时间戳转换为标准时间）
// func (bc *Blockchain) PrintChain() {
// 	for i, block := range bc.chain {
// 		blockHash := block.CalculateHash()
// 		// 转换：将Unix纳秒时间戳转为标准时间（本地时间或UTC）
// 		blockTime := time.Unix(0, block.Timestamp).Format("2006-01-02 15:04:05.000")

// 		fmt.Printf("区块 #%d:\n", i+1)
// 		fmt.Printf("  索引: %d\n", block.Index)
// 		fmt.Printf("  时间戳（标准时间）: %s\n", blockTime)       // 显示：标准时间
// 		fmt.Printf("  时间戳（原始纳秒）: %d\n", block.Timestamp) // 可选：显示原始时间戳
// 		fmt.Printf("  交易: %v\n", block.Transactions)
// 		fmt.Printf("  Proof: %d\n", block.Proof)
// 		fmt.Printf("  前一区块哈希: %s\n", block.PreviousHash)
// 		fmt.Printf("  当前区块哈希: %s\n\n", blockHash)
// 	}
// }

// func main() {
// 	bc := NewBlockchain()
// 	fmt.Println("已创建新的区块链，包含创世区块")

// 	bc.NewTransaction("Alice", "Bob", 5.0)
// 	bc.NewTransaction("Bob", "Charlie", 2.5)

// 	fmt.Println("正在挖掘第一个区块...")
// 	lastBlock := bc.LastBlock()
// 	proof := bc.ProofOfWork(lastBlock.Proof)
// 	bc.NewBlock(proof, lastBlock.CalculateHash())

// 	bc.NewTransaction("Charlie", "Alice", 1.0)
// 	bc.NewTransaction("Bob", "Dave", 0.5)

// 	fmt.Println("正在挖掘第二个区块...")
// 	lastBlock = bc.LastBlock()
// 	proof = bc.ProofOfWork(lastBlock.Proof)
// 	bc.NewBlock(proof, lastBlock.CalculateHash())

// 	fmt.Println("\n区块链完整信息:")
// 	bc.PrintChain()
// }

package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"
)

// ------------------------------
// 交易模块封装
// ------------------------------

// Transaction 表示一笔交易，字段设为私有，通过方法访问
type Transaction struct {
	sender    string
	recipient string
	amount    float64
}

// NewTransaction 创建新交易
func NewTransaction(sender, recipient string, amount float64) *Transaction {
	return &Transaction{
		sender:    sender,
		recipient: recipient,
		amount:    amount,
	}
}

// 提供必要的getter方法，隐藏内部实现
func (t *Transaction) Sender() string    { return t.sender }
func (t *Transaction) Recipient() string { return t.recipient }
func (t *Transaction) Amount() float64   { return t.amount }

// ToMap 用于序列化，避免直接暴露字段
func (t *Transaction) ToMap() map[string]interface{} {
	return map[string]interface{}{
		"sender":    t.sender,
		"recipient": t.recipient,
		"amount":    t.amount,
	}
}

// ------------------------------
// 区块模块封装
// ------------------------------

// Block 表示一个区块，字段私有，通过方法交互
type Block struct {
	index        int
	timestamp    int64 // 纳秒级时间戳
	transactions []*Transaction
	proof        int
	previousHash string
	hash         string // 缓存当前区块哈希，避免重复计算
}

// NewBlock 创建新区块
func NewBlock(index int, proof int, previousHash string, transactions []*Transaction) *Block {
	block := &Block{
		index:        index,
		timestamp:    time.Now().UnixNano(),
		transactions: transactions,
		proof:        proof,
		previousHash: previousHash,
	}
	block.hash = block.calculateHash() // 计算并缓存哈希
	return block
}

// 计算区块哈希（私有方法，仅内部调用）
func (b *Block) calculateHash() string {
	// 序列化区块数据（仅包含必要字段）
	data := map[string]interface{}{
		"index":         b.index,
		"timestamp":     b.timestamp,
		"transactions":  b.transactions,
		"proof":         b.proof,
		"previous_hash": b.previousHash,
	}
	bytes, err := json.Marshal(data)
	if err != nil {
		panic(err)
	}
	hash := sha256.Sum256(bytes)
	return hex.EncodeToString(hash[:])
}

// 公共方法：获取区块哈希（使用缓存）
func (b *Block) Hash() string {
	return b.hash
}

// 其他必要的getter方法
func (b *Block) Index() int                   { return b.index }
func (b *Block) Timestamp() int64             { return b.timestamp }
func (b *Block) Transactions() []*Transaction { return b.transactions }
func (b *Block) Proof() int                   { return b.proof }
func (b *Block) PreviousHash() string         { return b.previousHash }

// FormatTime 将时间戳转换为标准格式
func (b *Block) FormatTime() string {
	return time.Unix(0, b.timestamp).Format("2006-01-02 15:04:05.000")
}

// ------------------------------
// 区块链核心逻辑封装
// ------------------------------

// Blockchain 区块链管理器，封装链操作
type Blockchain struct {
	chain               []*Block
	currentTransactions []*Transaction
	difficulty          int // POW难度（前导零数量）
}

// NewBlockchain 创建新区块链
func NewBlockchain(difficulty int) *Blockchain {
	bc := &Blockchain{
		chain:               make([]*Block, 0),
		currentTransactions: make([]*Transaction, 0),
		difficulty:          difficulty,
	}
	bc.createGenesisBlock() // 初始化创世区块
	return bc
}

// 创建创世区块（私有方法）
func (bc *Blockchain) createGenesisBlock() {
	// 创世区块没有前置哈希，交易为空
	genesis := NewBlock(0, 1, "0", []*Transaction{})
	bc.chain = append(bc.chain, genesis)
}

// AddTransaction 添加交易到待打包列表
func (bc *Blockchain) AddTransaction(tx *Transaction) {
	bc.currentTransactions = append(bc.currentTransactions, tx)
}

// LastBlock 获取最后一个区块
func (bc *Blockchain) LastBlock() *Block {
	return bc.chain[len(bc.chain)-1]
}

// MineBlock 执行POW并创建新区块（核心方法）
func (bc *Blockchain) MineBlock() *Block {
	lastBlock := bc.LastBlock()
	proof := bc.proofOfWork(lastBlock.Proof())

	// 创建新区块，打包当前交易
	newBlock := NewBlock(
		lastBlock.Index()+1,
		proof,
		lastBlock.Hash(),
		bc.currentTransactions,
	)

	// 重置当前交易列表，更新链
	bc.currentTransactions = make([]*Transaction, 0)
	bc.chain = append(bc.chain, newBlock)

	return newBlock
}

// POW逻辑（私有方法）
func (bc *Blockchain) proofOfWork(lastProof int) int {
	proof := 0
	for !bc.isValidProof(lastProof, proof) {
		proof++
	}
	return proof
}

// 验证POW（私有方法）
func (bc *Blockchain) isValidProof(lastProof, proof int) bool {
	guess := fmt.Sprintf("%d%d", lastProof, proof)
	hash := sha256.Sum256([]byte(guess))
	hashStr := hex.EncodeToString(hash[:])
	return len(hashStr) >= bc.difficulty && hashStr[:bc.difficulty] == bc.targetPrefix()
}

// 生成目标前缀（如"0000"）
func (bc *Blockchain) targetPrefix() string {
	return fmt.Sprintf("%0"+fmt.Sprint(bc.difficulty)+"s", "")
}

// Print 打印区块链信息（对外暴露的展示方法）
func (bc *Blockchain) Print() {
	for i, block := range bc.chain {
		fmt.Printf("区块 #%d:\n", i+1)
		fmt.Printf("  索引: %d\n", block.Index())
		// fmt.Printf("  时间戳: %s\n", block.FormatTime())
		fmt.Printf("  时间戳（标准时间）: %s\n", block.FormatTime()) // 显示：标准时间
		fmt.Printf("  时间戳（原始纳秒）: %d\n", block.Timestamp())  // 可选：显示原始时间戳
		fmt.Printf("  交易数: %d\n", len(block.Transactions()))
		for _, tx := range block.Transactions() {
			fmt.Printf("    交易: %s -> %s, 金额: %.2f\n",
				tx.Sender(), tx.Recipient(), tx.Amount())
		}
		fmt.Printf("  Proof: %d\n", block.Proof())
		fmt.Printf("  前一区块哈希: %s\n", block.PreviousHash())
		fmt.Printf("  当前区块哈希: %s\n\n", block.Hash())
	}
}

// ------------------------------
// 主函数：演示使用
// ------------------------------

func main() {
	// 初始化区块链（难度为4个0）
	bc := NewBlockchain(4)
	fmt.Println("已创建区块链（包含创世区块）")

	// 添加交易
	bc.AddTransaction(NewTransaction("Alice", "Bob", 5.0))
	bc.AddTransaction(NewTransaction("Bob", "Charlie", 2.5))

	// 挖矿
	fmt.Println("正在挖掘第一个区块...")
	bc.MineBlock()

	// 添加更多交易
	bc.AddTransaction(NewTransaction("Charlie", "Alice", 1.0))
	bc.AddTransaction(NewTransaction("Bob", "Dave", 0.5))

	// 再次挖矿
	fmt.Println("正在挖掘第二个区块...")
	bc.MineBlock()

	// 打印区块链
	fmt.Println("\n区块链完整信息:")
	bc.Print()
}
