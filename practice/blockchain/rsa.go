// package main

// import (
// 	"crypto"
// 	"crypto/rand"
// 	"crypto/rsa"
// 	"crypto/sha256"
// 	"crypto/x509"
// 	"encoding/hex"
// 	"encoding/pem"
// 	"fmt"
// 	"os"
// 	"time"
// )

// // Pow 工作量证明结构体
// type Pow struct {
// 	Nickname     string // 昵称
// 	LeadingZeros int    // 目标前导零数量
// 	Nonce        int    // 随机数
// }

// // NewPow 创建一个新的POW实例
// func NewPow(nickname string, leadingZeros int) *Pow {
// 	return &Pow{
// 		Nickname:     nickname,
// 		LeadingZeros: leadingZeros,
// 		Nonce:        0, // 初始化为0
// 	}
// }

// // generateContent 生成用于哈希计算的内容
// func (p *Pow) generateContent() string {
// 	return fmt.Sprintf("%s%d", p.Nickname, p.Nonce)
// }

// // calculateHash 计算内容的SHA256哈希值
// func (p *Pow) calculateHash(content string) string {
// 	hash := sha256.Sum256([]byte(content))
// 	return hex.EncodeToString(hash[:])
// }

// // isHashValid 检查哈希是否满足前导零要求
// func (p *Pow) isHashValid(hash string) bool {
// 	if len(hash) < p.LeadingZeros {
// 		return false
// 	}
// 	// 检查前n位是否都是0
// 	for i := 0; i < p.LeadingZeros; i++ {
// 		if hash[i] != '0' {
// 			return false
// 		}
// 	}
// 	return true
// }

// // Run 执行工作量证明，返回结果和耗时
// func (p *Pow) Run() (string, string, time.Duration) {
// 	startTime := time.Now()

// 	for {
// 		content := p.generateContent()
// 		hash := p.calculateHash(content)

// 		if p.isHashValid(hash) {
// 			duration := time.Since(startTime)
// 			return content, hash, duration
// 		}

// 		p.Nonce++
// 	}
// }

// // 生成RSA公私钥对
// func generateRSAKeyPair(bits int) (*rsa.PrivateKey, *rsa.PublicKey, error) {
// 	// 生成私钥
// 	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
// 	if err != nil {
// 		return nil, nil, err
// 	}

// 	// 从私钥中提取公钥
// 	publicKey := &privateKey.PublicKey

// 	return privateKey, publicKey, nil
// }

// // 使用私钥签名数据
// func signData(privateKey *rsa.PrivateKey, data []byte) ([]byte, error) {
// 	// 计算数据的SHA256哈希
// 	hash := sha256.Sum256(data)

// 	// 使用私钥对哈希进行签名
// 	signature, err := rsa.SignPKCS1v15(rand.Reader, privateKey, crypto.SHA256, hash[:])
// 	if err != nil {
// 		return nil, err
// 	}

// 	return signature, nil
// }

// // 使用公钥验证签名
// func verifySignature(publicKey *rsa.PublicKey, data []byte, signature []byte) error {
// 	// 计算数据的SHA256哈希
// 	hash := sha256.Sum256(data)

// 	// 使用公钥验证签名
// 	return rsa.VerifyPKCS1v15(publicKey, crypto.SHA256, hash[:], signature)
// }

// // 保存密钥到文件
// func saveKeyToFile(key []byte, filename string) error {
// 	return os.WriteFile(filename, key, 0600)
// }

// // 格式化密钥为PEM格式
// func formatPrivateKey(privateKey *rsa.PrivateKey) []byte {
// 	privateKeyBytes := x509.MarshalPKCS1PrivateKey(privateKey)
// 	privateKeyPEM := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: privateKeyBytes})
// 	return privateKeyPEM
// }

// func formatPublicKey(publicKey *rsa.PublicKey) []byte {
// 	publicKeyBytes := x509.MarshalPKCS1PublicKey(publicKey)
// 	publicKeyPEM := pem.EncodeToMemory(&pem.Block{Type: "RSA PUBLIC KEY", Bytes: publicKeyBytes})
// 	return publicKeyPEM
// }

// func main() {
// 	// 配置参数
// 	nickname := "Lumos"
// 	leadingZeros := 4  // 4个0开头的POW
// 	rsaKeySize := 2048 // RSA密钥长度

// 	// 1. 生成RSA公私钥对
// 	fmt.Println("正在生成RSA公私钥对...")
// 	privateKey, publicKey, err := generateRSAKeyPair(rsaKeySize)
// 	if err != nil {
// 		fmt.Printf("生成密钥对失败: %v\n", err)
// 		return
// 	}
// 	fmt.Println("RSA公私钥对生成成功")

// 	// 可选：保存密钥到文件
// 	privateKeyPEM := formatPrivateKey(privateKey)
// 	publicKeyPEM := formatPublicKey(publicKey)

// 	if err := saveKeyToFile(privateKeyPEM, "private_key.pem"); err != nil {
// 		fmt.Printf("保存私钥失败: %v\n", err)
// 	} else {
// 		fmt.Println("私钥已保存到 private_key.pem")
// 	}

// 	if err := saveKeyToFile(publicKeyPEM, "public_key.pem"); err != nil {
// 		fmt.Printf("保存公钥失败: %v\n", err)
// 	} else {
// 		fmt.Println("公钥已保存到 public_key.pem")
// 	}

// 	// 2. 执行POW找到4个0开头的哈希值
// 	fmt.Printf("\n开始寻找以%d个0开头的哈希值...\n", leadingZeros)
// 	pow := NewPow(nickname, leadingZeros)
// 	content, hash, duration := pow.Run()
// 	fmt.Printf("找到符合条件的哈希值！\n")
// 	fmt.Printf("花费时间: %v\n", duration)
// 	fmt.Printf("内容: %s\n", content)
// 	fmt.Printf("哈希值: %s\n", hash)
// 	fmt.Printf("使用的nonce: %d\n", pow.Nonce)

// 	// 3. 使用私钥对内容进行签名
// 	fmt.Println("\n使用私钥进行签名...")
// 	signature, err := signData(privateKey, []byte(content))
// 	if err != nil {
// 		fmt.Printf("签名失败: %v\n", err)
// 		return
// 	}
// 	fmt.Printf("签名结果 (十六进制): %s\n", hex.EncodeToString(signature))

// 	// 4. 使用公钥验证签名
// 	fmt.Println("\n使用公钥验证签名...")
// 	err = verifySignature(publicKey, []byte(content), signature)
// 	if err != nil {
// 		fmt.Printf("签名验证失败: %v\n", err)
// 		return
// 	}
// 	fmt.Println("签名验证成功！内容未被篡改，且确实由对应私钥签名")
// }

package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"time"
)

// POW相关封装
type POW struct {
	Nickname     string
	LeadingZeros int
	Nonce        int
}

func NewPOW(nickname string, leadingZeros int) *POW {
	return &POW{
		Nickname:     nickname,
		LeadingZeros: leadingZeros,
		Nonce:        0,
	}
}

func (p *POW) GenerateContent() string {
	return fmt.Sprintf("%s%d", p.Nickname, p.Nonce)
}

func (p *POW) CalculateHash() string {
	content := p.GenerateContent()
	hash := sha256.Sum256([]byte(content))
	return hex.EncodeToString(hash[:])
}

func (p *POW) IsValid() bool {
	hash := p.CalculateHash()
	if len(hash) < p.LeadingZeros {
		return false
	}
	for i := 0; i < p.LeadingZeros; i++ {
		if hash[i] != '0' {
			return false
		}
	}
	return true
}

func (p *POW) Mine() (string, string, time.Duration) {
	start := time.Now()
	for !p.IsValid() {
		p.Nonce++
	}
	return p.GenerateContent(), p.CalculateHash(), time.Since(start)
}

// RSA相关封装
type RSAKeyPair struct {
	privateKey *rsa.PrivateKey
	publicKey  *rsa.PublicKey
}

// NewRSAKeyPair 生成密钥对
func NewRSAKeyPair(bits int) (*RSAKeyPair, error) {
	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
	if err != nil {
		return nil, err
	}
	return &RSAKeyPair{
		privateKey: privateKey,
		publicKey:  &privateKey.PublicKey,
	}, nil
}

func (k *RSAKeyPair) Sign(data []byte) ([]byte, error) {
	hash := sha256.Sum256(data)
	return rsa.SignPKCS1v15(rand.Reader, k.privateKey, crypto.SHA256, hash[:])
}

func (k *RSAKeyPair) Verify(data []byte, signature []byte) error {
	hash := sha256.Sum256(data)
	return rsa.VerifyPKCS1v15(k.publicKey, crypto.SHA256, hash[:], signature)
}

// SavePrivateKey 保存私钥到代码文件所在目录
func (k *RSAKeyPair) SavePrivateKey(filename string) error {
	// 1. 动态获取当前代码文件所在的目录
	_, currentFile, _, ok := runtime.Caller(0)
	if !ok {
		return fmt.Errorf("无法获取当前文件路径")
	} else {
		fmt.Printf("当前文件路径: %s\n", currentFile)
	}
	currentDir := filepath.Dir(currentFile) // 提取目录部分

	// 2. 拼接完整路径（目录 + 文件名）
	fullPath := filepath.Join(currentDir, filename)

	// 3. 写入文件
	privateBytes := x509.MarshalPKCS1PrivateKey(k.privateKey)
	pemData := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: privateBytes})
	return os.WriteFile(fullPath, pemData, 0600)
}

// SavePublicKey 保存公钥到代码文件所在目录（逻辑同上）
func (k *RSAKeyPair) SavePublicKey(filename string) error {
	_, currentFile, _, ok := runtime.Caller(0)
	if !ok {
		return fmt.Errorf("无法获取当前文件路径")
	} else {
		fmt.Printf("当前文件路径: %s\n", currentFile)
	}
	currentDir := filepath.Dir(currentFile)
	fullPath := filepath.Join(currentDir, filename)

	publicBytes := x509.MarshalPKCS1PublicKey(k.publicKey)
	pemData := pem.EncodeToMemory(&pem.Block{Type: "RSA PUBLIC KEY", Bytes: publicBytes})
	return os.WriteFile(fullPath, pemData, 0644)
}

// 主函数协调各模块
func main() {
	// 1. 初始化组件
	pow := NewPOW("Lumos", 4)
	rsaKeys, err := NewRSAKeyPair(2048)
	if err != nil {
		fmt.Printf("RSA密钥生成失败: %v\n", err)
		return
	}

	// test 在保存文件前添加：
	wd, err := os.Getwd()
	if err != nil {
		fmt.Printf("获取当前工作目录失败: %v\n", err)
	} else {
		fmt.Printf("程序当前工作目录: %s\n", wd)
	}

	// 2. 保存密钥对
	if err := rsaKeys.SavePrivateKey("private_key.pem"); err != nil {
		fmt.Printf("私钥保存失败: %v\n", err)
	} else {
		fmt.Println("私钥已保存至 private_key.pem")
	}

	if err := rsaKeys.SavePublicKey("public_key.pem"); err != nil {
		fmt.Printf("公钥保存失败: %v\n", err)
	} else {
		fmt.Println("公钥已保存至 public_key.pem")
	}

	// 3. 执行POW挖矿
	fmt.Println("\n开始POW计算（4个0前缀）...")
	content, hash, duration := pow.Mine()
	fmt.Printf("POW完成！耗时: %v\n", duration)
	fmt.Printf("内容: %s\n", content)
	fmt.Printf("哈希: %s\n", hash)
	fmt.Printf("Nonce值: %d\n", pow.Nonce)

	// 4. 签名与验证
	signature, err := rsaKeys.Sign([]byte(content))
	if err != nil {
		fmt.Printf("签名失败: %v\n", err)
		return
	}
	fmt.Printf("\n签名结果: %s\n", hex.EncodeToString(signature))

	err = rsaKeys.Verify([]byte(content), signature)
	if err != nil {
		fmt.Println("签名验证失败")
	} else {
		fmt.Println("签名验证成功：内容完整且来源可信")
	}
}
