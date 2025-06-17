import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Combine
from cocotb.result import TestSuccess, TestFailure
from cocotb.binary import BinaryValue
import random
import numpy as np

# 定义FIFO深度和位宽
DATA_WIDTH = 32
ADDR_WIDTH = 10
FIFO_DEPTH = 1 << ADDR_WIDTH

@cocotb.test()
async def async_fifo_test(dut):
    """测试异步FIFO的完整功能"""
    # 启动时钟
    cocotb.start_soon(Clock(dut.wr_clk, 10, units="ns").start())  # 100MHz写时钟
    cocotb.start_soon(Clock(dut.rd_clk, 14, units="ns").start())  # 71.4MHz读时钟
    
    # 复位DUT
    await reset_dut(dut)
    
    # 运行各项测试
    await test_fill_faster(dut)     # 写入快于读取
    await test_read_faster(dut)     # 读取快于写入
    await test_concurrent_io(dut)   # 同时读写
    await test_fill_to_full(dut)    # 填充至满
    await test_read_from_empty(dut) # 从空读取
    await test_random_io(dut)       # 随机读写测试
    
    # 所有测试通过
    raise TestSuccess("异步FIFO测试全部通过!")

async def reset_dut(dut):
    """复位DUT"""
    dut.wr_rst_n.value = 0
    dut.rd_rst_n.value = 0
    dut.wr_en.value = 0
    dut.rd_en.value = 0
    
    await ClockCycles(dut.wr_clk, 5)
    dut.wr_rst_n.value = 1
    dut.rd_rst_n.value = 1
    
    await ClockCycles(dut.wr_clk, 5)
    await ClockCycles(dut.rd_clk, 5)

async def write_data(dut, data_list):
    """向FIFO写入数据列表"""
    write_results = []
    for data in data_list:
        await RisingEdge(dut.wr_clk)
        dut.din.value = data
        dut.wr_en.value = 1 if not dut.full.value else 0
        write_results.append((data, dut.wr_en.value))
    
    dut.wr_en.value = 0
    return write_results

async def read_data(dut, count):
    """从FIFO读取指定数量的数据"""
    read_data = []
    for _ in range(count):
        await RisingEdge(dut.rd_clk)
        dut.rd_en.value = 1 if not dut.empty.value else 0
        if dut.rd_en.value:
            read_data.append(int(dut.dout.value))
    
    dut.rd_en.value = 0
    return read_data

async def test_fill_faster(dut):
    """测试写入速度快于读取速度"""
    print("开始测试: 写入快于读取")
    
    # 准备测试数据
    write_data = [i for i in range(200)]
    
    # 执行写入和部分读取
    await write_data(dut, write_data)
    read_data = await read_data(dut, 100)
    
    # 验证数据一致性
    assert read_data == write_data[:100], "数据读取不一致"
    
    # 验证状态标志
    assert not dut.empty.value, "FIFO应为非空"
    assert not dut.full.value, "FIFO应为非满"
    assert not dut.almost_empty.value, "FIFO不应几乎为空"
    assert dut.almost_full.value, "FIFO应几乎为满"
    
    print("测试通过: 写入快于读取")

async def test_read_faster(dut):
    """测试读取速度快于写入速度"""
    print("开始测试: 读取快于写入")
    
    # 准备测试数据
    write_data = [i for i in range(100)]
    
    # 执行写入和过量读取
    await write_data(dut, write_data)
    read_data = await read_data(dut, 200)
    
    # 验证数据一致性
    assert read_data == write_data, "数据读取不一致"
    
    # 验证状态标志
    assert dut.empty.value, "FIFO应为空"
    assert not dut.full.value, "FIFO应为非满"
    assert dut.almost_empty.value, "FIFO应几乎为空"
    assert not dut.almost_full.value, "FIFO不应几乎为满"
    
    print("测试通过: 读取快于写入")

async def test_concurrent_io(dut):
    """测试同时进行读写操作"""
    print("开始测试: 同时读写")
    
    # 准备测试数据
    data_count = 300
    write_data = [random.randint(0, 2**DATA_WIDTH-1) for _ in range(data_count)]
    
    # 并发执行读写
    write_coroutine = write_data(dut, write_data)
    read_coroutine = read_data(dut, data_count)
    
    written, read = await Combine(write_coroutine, read_coroutine)
    
    # 验证数据一致性
    assert read == write_data, "并发读写数据不一致"
    
    # 验证状态标志
    assert dut.empty.value, "FIFO应为空"
    assert not dut.full.value, "FIFO应为非满"
    assert dut.almost_empty.value, "FIFO应几乎为空"
    assert not dut.almost_full.value, "FIFO不应几乎为满"
    
    print("测试通过: 同时读写")

async def test_fill_to_full(dut):
    """测试填充FIFO至满状态"""
    print("开始测试: 填充至满")
    
    # 准备测试数据
    write_data = [i for i in range(FIFO_DEPTH)]
    
    # 执行写入
    written = await write_data(dut, write_data)
    
    # 验证所有数据都被写入
    assert len([w for w, en in written if en]) == FIFO_DEPTH, "未完全填充FIFO"
    
    # 验证状态标志
    assert dut.full.value, "FIFO应为满"
    assert dut.almost_full.value, "FIFO应几乎为满"
    assert not dut.empty.value, "FIFO应为非空"
    assert not dut.almost_empty.value, "FIFO不应几乎为空"
    
    # 尝试写入更多数据应被拒绝
    await RisingEdge(dut.wr_clk)
    dut.din.value = FIFO_DEPTH
    dut.wr_en.value = 1
    await RisingEdge(dut.wr_clk)
    assert not dut.wr_en.value, "满状态下不应允许写入"
    
    print("测试通过: 填充至满")

async def test_read_from_empty(dut):
    """测试从空FIFO读取"""
    print("开始测试: 从空读取")
    
    # 执行读取
    read_data = await read_data(dut, 20)
    
    # 验证未读取到数据
    assert len(read_data) == 0, "空状态下不应读取到数据"
    
    # 验证状态标志
    assert dut.empty.value, "FIFO应为空"
    assert dut.almost_empty.value, "FIFO应几乎为空"
    assert not dut.full.value, "FIFO应为非满"
    assert not dut.almost_full.value, "FIFO不应几乎为满"
    
    print("测试通过: 从空读取")

async def test_random_io(dut):
    """测试随机读写操作"""
    print("开始测试: 随机读写")
    
    data_count = 500
    expected_data = []
    read_data = []
    
    # 执行500次随机读写
    for _ in range(data_count):
        # 随机选择操作
        if random.random() < 0.5 and not dut.full.value:
            # 写入操作
            data = random.randint(0, 2**DATA_WIDTH-1)
            await RisingEdge(dut.wr_clk)
            dut.din.value = data
            dut.wr_en.value = 1
            expected_data.append(data)
        else:
            # 读取操作
            await RisingEdge(dut.rd_clk)
            dut.rd_en.value = 1
            if not dut.empty.value:
                read_data.append(int(dut.dout.value))
                expected_data.pop(0)
        
        # 取消使能
        dut.wr_en.value = 0
        dut.rd_en.value = 0
    
    # 验证数据一致性
    assert read_data == [d for d in expected_data if d is not None], "随机读写数据不一致"
    
    print("测试通过: 随机读写")
