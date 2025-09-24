// package main

// import (
// 	"crypto/sha256"
// 	"encoding/hex"
// 	"fmt"
// 	"time"
// )

// // 我的昵称
// const nickname = "Lumos"

// // 执行工作量证明，寻找具有指定数量前导零的哈希
// func findHashWithLeadingZeros(leadingZeros int) (string, string, int, time.Duration) {
// 	nonce := 0
// 	prefix := fmt.Sprintf("%0"+fmt.Sprint(leadingZeros)+"s", "") // 创建由指定数量0组成的前缀

// 	startTime := time.Now()

// 	for {
// 		// 组合输入内容：昵称 + nonce
// 		content := fmt.Sprintf("%s%d", nickname, nonce)

// 		// 计算SHA256哈希
// 		hash := sha256.Sum256([]byte(content))
// 		hashStr := hex.EncodeToString(hash[:])

// 		// 检查哈希是否以指定数量的0开头
// 		if len(hashStr) >= leadingZeros && hashStr[:leadingZeros] == prefix {
// 			duration := time.Since(startTime)
// 			return content, hashStr, nonce, duration
// 		}

// 		nonce++
// 	}
// }

// func main() {
// 	// 寻找4个0开头的哈希
// 	fmt.Println("开始寻找以4个0开头的哈希值...")
// 	content4, hash4, nonce4, duration4 := findHashWithLeadingZeros(4)
// 	fmt.Printf("找到4个0开头的哈希值！\n")
// 	fmt.Printf("花费时间: %v\n", duration4)
// 	fmt.Printf("哈希内容: %s\n", content4)
// 	fmt.Printf("哈希值: %s\n", hash4)
// 	fmt.Printf("使用的nonce: %d\n\n", nonce4)

// 	// 寻找5个0开头的哈希
// 	fmt.Println("开始寻找以5个0开头的哈希值...")
// 	content5, hash5, nonce5, duration5 := findHashWithLeadingZeros(5)
// 	fmt.Printf("找到5个0开头的哈希值！\n")
// 	fmt.Printf("花费时间: %v\n", duration5)
// 	fmt.Printf("哈希内容: %s\n", content5)
// 	fmt.Printf("哈希值: %s\n", hash5)
// 	fmt.Printf("使用的nonce: %d\n", nonce5)
// }

package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"
)

// Pow 工作量证明结构体，封装相关属性和方法
type Pow struct {
	Nickname     string // 昵称
	LeadingZeros int    // 目标前导零数量
	Nonce        int    // 随机数
}

// NewPow 创建一个新的POW实例
func NewPow(nickname string, leadingZeros int) *Pow {
	return &Pow{
		Nickname:     nickname,
		LeadingZeros: leadingZeros,
		Nonce:        0, // 初始化为0
	}
}

// generateContent 生成用于哈希计算的内容
func (p *Pow) generateContent() string {
	return fmt.Sprintf("%s%d", p.Nickname, p.Nonce)
}

// calculateHash 计算内容的SHA256哈希值
func (p *Pow) calculateHash(content string) string {
	hash := sha256.Sum256([]byte(content))
	return hex.EncodeToString(hash[:])
}

// isHashValid 检查哈希是否满足前导零要求
func (p *Pow) isHashValid(hash string) bool {
	if len(hash) < p.LeadingZeros {
		return false
	}
	// 检查前n位是否都是0
	for i := 0; i < p.LeadingZeros; i++ {
		if hash[i] != '0' {
			return false
		}
	}
	return true
}

// Run 执行工作量证明，返回结果和耗时
func (p *Pow) Run() (string, string, time.Duration) {
	startTime := time.Now()

	for {
		content := p.generateContent()
		hash := p.calculateHash(content)

		if p.isHashValid(hash) {
			duration := time.Since(startTime)
			return content, hash, duration
		}

		p.Nonce++
	}
}

func main() {
	// 配置参数
	nickname := "Lumos"

	// 寻找4个0开头的哈希
	pow4 := NewPow(nickname, 4)
	fmt.Println("开始寻找以4个0开头的哈希值...")
	content4, hash4, duration4 := pow4.Run()
	fmt.Printf("找到4个0开头的哈希值！\n")
	fmt.Printf("花费时间: %v\n", duration4)
	fmt.Printf("哈希内容: %s\n", content4)
	fmt.Printf("哈希值: %s\n", hash4)
	fmt.Printf("使用的nonce: %d\n\n", pow4.Nonce)

	// 寻找5个0开头的哈希
	pow5 := NewPow(nickname, 5)
	fmt.Println("开始寻找以5个0开头的哈希值...")
	content5, hash5, duration5 := pow5.Run()
	fmt.Printf("找到5个0开头的哈希值！\n")
	fmt.Printf("花费时间: %v\n", duration5)
	fmt.Printf("哈希内容: %s\n", content5)
	fmt.Printf("哈希值: %s\n", hash5)
	fmt.Printf("使用的nonce: %d\n", pow5.Nonce)
}
