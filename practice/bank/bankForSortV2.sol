// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/security/Pausable.sol"; // 引入OpenZeppelin的暂停合约（工业级常用）
import "@openzeppelin/contracts/utils/Pausable.sol"; // 引入OpenZeppelin的暂停合约（工业级常用）
import "@openzeppelin/contracts/access/Ownable.sol";   // 引入Ownable，简化权限控制

/**
 * @title Bank
 * @dev 支持存款、管理员提款、动态前N名查询的工业级合约
 * @author 开发者
 */
contract Bank is Pausable, Ownable {
    // ========================= 可配置参数（避免硬编码，增强灵活性） =========================
    uint256 public immutable MAX_TOP_N; // 排行榜最大支持的查询数量（避免N过大导致gas爆炸）
    uint256 public constant MIN_DEPOSIT = 1 wei; // 最小存款金额（防止无效存款）

    // ========================= 核心存储 =========================
    // 记录每个地址的存款余额
    mapping(address => uint256) public balances;
    // 记录所有存款用户（用于后续扩展，如遍历所有用户）
    address[] public allDepositors;
    // 快速判断地址是否为存款用户（避免重复加入allDepositors）
    mapping(address => bool) public isDepositor;

    // 存款者结构体（包含地址和余额）
    struct Depositor {
        address addr;
        uint256 balance;
    }
    // 排序后的排行榜（始终按余额降序排列，仅保留前MAX_TOP_N个）
    Depositor[] public sortedTopDepositors;
    // 快速判断地址是否在排行榜中（避免重复处理，节省gas）
    mapping(address => bool) public isInTopDepositors;

    // ========================= 事件定义（便于审计和前端追踪） =========================
    event Deposited(address indexed depositor, uint256 amount, uint256 newBalance, uint256 timestamp);
    event Withdrawn(address indexed owner, uint256 amount, uint256 contractBalanceAfter, uint256 timestamp);
    event TopDepositorsUpdated(uint256 newTopCount, uint256 timestamp);
    event Paused(address indexed operator, uint256 timestamp);
    event Unpaused(address indexed operator, uint256 timestamp);

    // ========================= 修饰器（权限和状态控制） =========================
    // 仅存款用户可调用（后续扩展功能用，如用户提款）
    modifier onlyDepositor() {
        require(isDepositor[msg.sender], "Bank: only depositor can call");
        _;
    }

    // 校验存款金额（复用逻辑，减少代码冗余）
    modifier validDepositAmount() {
        require(msg.value >= MIN_DEPOSIT, "Bank: deposit amount too small");
        _;
    }

    // ========================= 构造函数（初始化参数） =========================
    /**
     * @param maxTopN 排行榜最大支持的查询数量（建议设为100以内，避免gas过高）
     */
    constructor(uint256 maxTopN) Ownable(msg.sender) {
        require(maxTopN >= 1 && maxTopN <= 100, "Bank: maxTopN must be 1-100"); // 限制范围，平衡灵活性和gas
        MAX_TOP_N = maxTopN;
    }

    // ========================= 核心功能：存款 =========================
    // 接收ETH直接存款（无需调用方法，符合用户习惯）
    receive() external payable whenNotPaused validDepositAmount {
        _deposit();
    }

    // 显式存款方法（兼容不支持receive的场景）
    function deposit() external payable whenNotPaused validDepositAmount {
        _deposit();
    }

    // 内部存款逻辑（代码复用，减少重复）
    function _deposit() internal {
        address depositor = msg.sender;
        uint256 depositAmount = msg.value;

        // 1. 更新存款余额
        uint256 oldBalance = balances[depositor];
        uint256 newBalance = oldBalance + depositAmount;
        balances[depositor] = newBalance;

        // 2. 若用户是首次存款，加入allDepositors
        if (!isDepositor[depositor]) {
            allDepositors.push(depositor);
            isDepositor[depositor] = true;
        }

        // 3. 更新排行榜（gas优化核心：仅在有资格时操作）
        _updateTopDepositors(depositor, newBalance);

        // 4. 触发事件
        emit Deposited(depositor, depositAmount, newBalance, block.timestamp);
    }

    // ========================= 核心功能：管理员提款 =========================
    /**
     * @param amount 提款金额
     * @dev 仅管理员可调用，且合约余额充足
     */
    function withdraw(uint256 amount) external onlyOwner whenNotPaused {
        require(amount > 0, "Bank: withdrawal amount must be >0");
        require(address(this).balance >= amount, "Bank: insufficient contract balance");

        // 转账（工业级推荐用call，配合返回值检查，避免重入风险）
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Bank: withdrawal failed");

        // 触发事件
        emit Withdrawn(owner(), amount, address(this).balance, block.timestamp);
    }

    // ========================= 核心功能：动态查询前N名 =========================
    /**
     * @param n 要查询的前N名数量
     * @return 前N名存款者数组（按余额降序）
     * @dev N必须在1~MAX_TOP_N之间，避免无效查询
     */
    function getTopN(uint256 n) external view returns (Depositor[] memory) {
        require(n >= 1 && n <= MAX_TOP_N, "Bank: n must be 1~MAX_TOP_N");
        
        // 实际返回数量为“n和当前排行榜长度的较小值”
        uint256 returnCount = n < sortedTopDepositors.length ? n : sortedTopDepositors.length;
        Depositor[] memory result = new Depositor[](returnCount);
        
        // 复制前returnCount个元素（避免返回空值）
        for (uint256 i = 0; i < returnCount; i++) {
            result[i] = sortedTopDepositors[i];
        }
        return result;
    }

    // ========================= 内部功能：排行榜更新（gas优化核心） =========================
    /**
     * @param depositor 存款者地址
     * @param newBalance 存款者新余额
     * @dev 仅在新余额有资格进入排行榜时更新，避免全量排序
     */
    function _updateTopDepositors(address depositor, uint256 newBalance) internal {
        uint256 currentTopLength = sortedTopDepositors.length;

        // 情况1：用户已在排行榜中 → 仅更新余额并调整位置（避免重复加入）
        if (isInTopDepositors[depositor]) {
            _updateExistingTopDepositor(depositor, newBalance);
            return;
        }

        // 情况2：用户不在排行榜中 → 检查是否有资格进入
        // 子情况2.1：排行榜未满（长度<MAX_TOP_N）→ 直接加入并排序
        if (currentTopLength < MAX_TOP_N) {
            sortedTopDepositors.push(Depositor({addr: depositor, balance: newBalance}));
            isInTopDepositors[depositor] = true;
            _sortTopDepositors(); // 插入排序（仅对少量元素排序，gas低）
        } 
        // 子情况2.2：排行榜已满 → 比较新余额与最后一名，若更大则替换并排序
        else {
            Depositor memory lastTop = sortedTopDepositors[currentTopLength - 1];
            if (newBalance > lastTop.balance) {
                // 移除最后一名的标记
                isInTopDepositors[lastTop.addr] = false;
                // 替换为新用户
                sortedTopDepositors[currentTopLength - 1] = Depositor({addr: depositor, balance: newBalance});
                isInTopDepositors[depositor] = true;
                _sortTopDepositors(); // 插入排序（仅调整位置，gas低）
            }
        }

        // 触发排行榜更新事件
        emit TopDepositorsUpdated(sortedTopDepositors.length, block.timestamp);
    }

    /**
     * @dev 更新已在排行榜中的用户余额并调整位置（gas优化：仅移动目标用户）
     */
    function _updateExistingTopDepositor(address depositor, uint256 newBalance) internal {
        // 找到用户在排行榜中的索引
        uint256 index = 0;
        for (; index < sortedTopDepositors.length; index++) {
            if (sortedTopDepositors[index].addr == depositor) {
                sortedTopDepositors[index].balance = newBalance;
                break;
            }
        }

        // 调整位置（插入排序：仅移动目标用户，比全量排序省gas）
        _sortTopDepositors();
    }

    /**
     * @dev 插入排序（对少量元素排序，gas消耗远低于冒泡/快速排序）
     * @dev 始终按余额降序排列
     */
    function _sortTopDepositors() internal {
        uint256 length = sortedTopDepositors.length;
        // 插入排序：从第二个元素开始，向前比较并插入正确位置
        for (uint256 i = 1; i < length; i++) {
            Depositor memory current = sortedTopDepositors[i];
            uint256 j = i - 1;
            // 向前找比current小的元素，后移
            while (j >= 0 && sortedTopDepositors[j].balance < current.balance) {
                sortedTopDepositors[j + 1] = sortedTopDepositors[j];
                if (j == 0) break; // 避免uint下溢
                j--;
            }
            // 插入current到正确位置
            sortedTopDepositors[j + 1] = current;
        }
    }

    // ========================= 辅助功能：紧急控制 =========================
    /**
     * @dev 紧急暂停合约（如发现漏洞时）
     */
    function pause() external onlyOwner {
        _pause();
        emit Paused(msg.sender, block.timestamp);
    }

    /**
     * @dev 恢复合约
     */
    function unpause() external onlyOwner {
        _unpause();
        emit Unpaused(msg.sender, block.timestamp);
    }

    // ========================= 辅助功能：查询信息 =========================
    /**
     * @dev 获取合约当前总余额
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev 获取存款用户总数
     */
    function getDepositorCount() external view returns (uint256) {
        return allDepositors.length;
    }
}