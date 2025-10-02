// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../practice/bigBankV1/BankV1.sol";
// import "../practice/bigBankV1/IBankV1.sol";

contract BankV1Test is Test {
    Bank public bank;
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;

    // 事件定义，用于测试事件触发
    event Deposited(address indexed depositor, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed owner, uint256 amount, uint256 timestamp);
    event TopDepositorsUpdated(IBank.Depositor[3] newTopDepositors);

    // 添加 receive 函数以接收以太币
    receive() external payable {}

    function setUp() public {
        // 设置测试账户
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
        user5 = makeAddr("user5");

        // 部署 Bank 合约
        bank = new Bank();

        // 给测试账户分配 ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
        vm.deal(user5, 10 ether);
    }

    // 测试合约初始状态
    function testInitialState() public {
        assertEq(bank.getOwner(), owner);
        assertEq(bank.getContractBalance(), 0);

        // 检查初始前三名为空
        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();
        for (uint256 i = 0; i < 3; i++) {
            assertEq(topDepositors[i].addr, address(0));
            assertEq(topDepositors[i].amount, 0);
        }
    }

    // 测试存款功能和余额更新
    function testDepositAndBalanceUpdate() public {
        uint256 depositAmount = 1 ether;

        // 记录存款前的状态
        uint256 initialContractBalance = bank.getContractBalance();
        uint256 initialUserBalance = user1.balance;

        // 用户1存款
        vm.prank(user1);
        vm.expectEmit(true, false, false, false);
        emit Deposited(user1, depositAmount, 0);
        bank.deposit{value: depositAmount}();

        // 断言检查存款后状态
        assertEq(bank.getContractBalance(), initialContractBalance + depositAmount);
        assertEq(user1.balance, initialUserBalance - depositAmount);

        // 检查用户在合约中的存款记录（需要owner权限）
        assertEq(bank.getBalances(user1), depositAmount);
    }

    // 测试通过 receive 函数存款
    function testDepositViaReceive() public {
        uint256 depositAmount = 0.5 ether;

        vm.prank(user1);
        vm.expectEmit(true, false, false, false);
        emit Deposited(user1, depositAmount, 0);
        (bool success,) = address(bank).call{value: depositAmount}("");
        assertTrue(success);

        assertEq(bank.getContractBalance(), depositAmount);
        assertEq(bank.getBalances(user1), depositAmount);
    }

    // 测试前3名用户 - 1个用户
    function testTopDepositors_OneUser() public {
        uint256 depositAmount = 2 ether;

        vm.prank(user1);
        bank.deposit{value: depositAmount}();

        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();

        // 第一名应该是 user1
        assertEq(topDepositors[0].addr, user1);
        assertEq(topDepositors[0].amount, depositAmount);

        // 其他位置应该为空
        assertEq(topDepositors[1].addr, address(0));
        assertEq(topDepositors[1].amount, 0);
        assertEq(topDepositors[2].addr, address(0));
        assertEq(topDepositors[2].amount, 0);
    }

    // 测试前3名用户 - 2个用户
    function testTopDepositors_TwoUsers() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user2);
        bank.deposit{value: 2 ether}();

        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();

        // 第一名应该是 user2 (2 ether)
        assertEq(topDepositors[0].addr, user2);
        assertEq(topDepositors[0].amount, 2 ether);

        // 第二名应该是 user1 (1 ether)
        assertEq(topDepositors[1].addr, user1);
        assertEq(topDepositors[1].amount, 1 ether);

        // 第三名应该为空
        assertEq(topDepositors[2].addr, address(0));
        assertEq(topDepositors[2].amount, 0);
    }

    // 测试前3名用户 - 3个用户
    function testTopDepositors_ThreeUsers() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user2);
        bank.deposit{value: 3 ether}();

        vm.prank(user3);
        bank.deposit{value: 2 ether}();

        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();

        // 验证排序：user2(3) > user3(2) > user1(1)
        assertEq(topDepositors[0].addr, user2);
        assertEq(topDepositors[0].amount, 3 ether);

        assertEq(topDepositors[1].addr, user3);
        assertEq(topDepositors[1].amount, 2 ether);

        assertEq(topDepositors[2].addr, user1);
        assertEq(topDepositors[2].amount, 1 ether);
    }

    // 测试前3名用户 - 4个用户（第4个用户应该被排除）
    function testTopDepositors_FourUsers() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user2);
        bank.deposit{value: 4 ether}();

        vm.prank(user3);
        bank.deposit{value: 2 ether}();

        vm.prank(user4);
        bank.deposit{value: 3 ether}();

        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();

        // 验证排序：user2(4) > user4(3) > user3(2)，user1(1)被排除
        assertEq(topDepositors[0].addr, user2);
        assertEq(topDepositors[0].amount, 4 ether);

        assertEq(topDepositors[1].addr, user4);
        assertEq(topDepositors[1].amount, 3 ether);

        assertEq(topDepositors[2].addr, user3);
        assertEq(topDepositors[2].amount, 2 ether);
    }

    // 测试同一用户多次存款
    function testTopDepositors_SameUserMultipleDeposits() public {
        // user1 多次存款
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user1);
        bank.deposit{value: 2 ether}();

        // user2 存款
        vm.prank(user2);
        bank.deposit{value: 2.5 ether}();

        // user3 存款
        vm.prank(user3);
        bank.deposit{value: 1.5 ether}();

        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();

        // user1 总存款应该是 3 ether，应该排第一
        assertEq(topDepositors[0].addr, user1);
        assertEq(topDepositors[0].amount, 3 ether);

        // user2 应该排第二
        assertEq(topDepositors[1].addr, user2);
        assertEq(topDepositors[1].amount, 2.5 ether);

        // user3 应该排第三
        assertEq(topDepositors[2].addr, user3);
        assertEq(topDepositors[2].amount, 1.5 ether);

        // 验证 user1 的总余额
        assertEq(bank.getBalances(user1), 3 ether);
    }

    // 测试复杂的多次存款场景
    function testTopDepositors_ComplexMultipleDeposits() public {
        // 初始存款
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user2);
        bank.deposit{value: 2 ether}();

        vm.prank(user3);
        bank.deposit{value: 1.5 ether}();

        // user1 再次存款，超过其他人
        vm.prank(user1);
        bank.deposit{value: 3 ether}();

        IBank.Depositor[3] memory topDepositors = bank.getTopDepositors();

        // user1 现在应该是第一名 (4 ether)
        assertEq(topDepositors[0].addr, user1);
        assertEq(topDepositors[0].amount, 4 ether);

        assertEq(topDepositors[1].addr, user2);
        assertEq(topDepositors[1].amount, 2 ether);

        assertEq(topDepositors[2].addr, user3);
        assertEq(topDepositors[2].amount, 1.5 ether);
    }

    // 测试管理员提款功能
    function testOwnerWithdraw() public {
        // 先存入一些资金
        vm.prank(user1);
        bank.deposit{value: 5 ether}();

        uint256 withdrawAmount = 2 ether;
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialContractBalance = bank.getContractBalance();

        // 管理员提款
        vm.expectEmit(true, false, false, false);
        emit Withdrawn(owner, withdrawAmount, 0);
        bank.withdraw(withdrawAmount);

        // 验证提款后状态
        assertEq(owner.balance, initialOwnerBalance + withdrawAmount);
        assertEq(bank.getContractBalance(), initialContractBalance - withdrawAmount);
    }

    // 测试非管理员无法提款
    function testNonOwnerCannotWithdraw() public {
        // 先存入一些资金
        vm.prank(user1);
        bank.deposit{value: 5 ether}();

        // 非管理员尝试提款应该失败
        vm.prank(user1);
        vm.expectRevert("Bank: only owner can call this function");
        bank.withdraw(1 ether);

        vm.prank(user2);
        vm.expectRevert("Bank: only owner can call this function");
        bank.withdraw(1 ether);
    }

    // 测试提款金额超过合约余额
    function testWithdrawExceedsBalance() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        // 尝试提取超过合约余额的金额
        vm.expectRevert("Bank: insufficient contract balance");
        bank.withdraw(2 ether);
    }

    // 测试零金额存款
    function testZeroDeposit() public {
        vm.prank(user1);
        vm.expectRevert("Bank: deposit amount must be greater than 0");
        bank.deposit{value: 0}();
    }

    // 测试零金额提款
    function testZeroWithdraw() public {
        vm.expectRevert("Bank: withdrawal amount must be greater than 0");
        bank.withdraw(0);
    }

    // 测试非管理员无法查看用户余额
    function testNonOwnerCannotViewBalances() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user2);
        vm.expectRevert("Bank: only owner can call this function");
        bank.getBalances(user1);
    }

    // 测试事件触发
    function testTopDepositorsUpdatedEvent() public {
        vm.prank(user1);
        vm.expectEmit(false, false, false, true);
        emit TopDepositorsUpdated(
            [
                IBank.Depositor({addr: user1, amount: 1 ether}),
                IBank.Depositor({addr: address(0), amount: 0}),
                IBank.Depositor({addr: address(0), amount: 0})
            ]
        );
        bank.deposit{value: 1 ether}();
    }

    // 测试大额存款
    function testLargeDeposit() public {
        uint256 largeAmount = 100 ether;
        vm.deal(user1, largeAmount);

        vm.prank(user1);
        bank.deposit{value: largeAmount}();

        assertEq(bank.getContractBalance(), largeAmount);
        assertEq(bank.getBalances(user1), largeAmount);
    }

    // 测试边界情况：完全提取所有资金
    function testWithdrawAllFunds() public {
        uint256 totalDeposit = 10 ether;

        vm.prank(user1);
        bank.deposit{value: totalDeposit}();

        // 提取所有资金
        bank.withdraw(totalDeposit);

        assertEq(bank.getContractBalance(), 0);
    }
}
