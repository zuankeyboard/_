
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // 使用0.8.x版本，包含安全特性

contract Counter {

    uint256 public counter;

    event CounterUpdated(uint256 indexed oldValue, uint256 indexed newValue, int256 delta);

    // constructor() {
    //     counter = 0;
    // }

    // 带参数的构造函数：部署时指定初始值
    constructor(uint256 initialValue) {
        counter = initialValue; // 用参数初始化状态变量
        emit CounterUpdated(0, initialValue, int256(initialValue)); // 记录初始化事件
    }

    // 获取计数器当前值
    function get() external view returns (uint256) {
        return counter;
    }

    // // 给计数器增加x值
    // function add(uint256 x) external {
    //     counter += x;
    // }

    /**
     * 工业级add方法：支持正数（加）和负数（减），带安全检查和事件记录
     * @param delta 变化量（正数为加，负数为减）
     */

     function add(int256 delta) external {
        uint256 oldValue = counter;

        if (delta > 0) {
            // 处理加法：检查溢出（Solidity 0.8+会自动 revert 溢出，但显式注释更清晰）
            counter += uint256(delta);
        } else {
            // 处理减法：先转为正数的绝对值，再检查是否下溢
            uint256 absDelta = uint256(-delta);
            require(oldValue >= absDelta, "Counter: underflow"); // 防止减法导致负数（uint不允许）
            counter -= absDelta;
        }

        // 记录状态变化事件
        emit CounterUpdated(oldValue, counter, delta);
     }
}