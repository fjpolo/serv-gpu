# test_serv_gpu.py (simple)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.result import TestSuccess, TestFailure

@cocotb.test()
async def test_serv_gpu(dut):
    # Start the clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the DUT
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    # Test 1: Verify instruction memory initialization
    await test_instruction_memory(dut)

    # Test 2: Verify memory access and arbitration
    await test_memory_access(dut)

    # Test 3: Verify barrier synchronization
    await test_barrier_sync(dut)

    # Test 4: Verify vector addition functionality
    await test_vector_addition(dut)

    # If all tests pass, raise TestSuccess
    raise TestSuccess("All tests passed!")

async def test_instruction_memory(dut):
    """Verify instruction memory initialization."""
    # Check the first few instructions
    expected_instructions = [
        0x00500093,  # li x1, 5
        0x00800113,  # li x2, 8
        0x01000193,  # li x3, 16
        0x00008233,  # add x4, x1, x0
        0x002102b3,  # add x5, x1, x2
    ]
    for i, expected in enumerate(expected_instructions):
        dut.instr_addr.value = i
        await RisingEdge(dut.clk)
        actual = dut.instr_data.value
        if actual != expected:
            raise TestFailure(f"Instruction mismatch at address {i}: expected {hex(expected)}, got {hex(actual)}")

async def test_memory_access(dut):
    """Test memory access."""
    # Initialize data memory with test data
    for i in range(16):
        dut.data_mem.mem[i].value = i + 1  # data[0:15] = 1..16

    # Wait for the core to request memory access
    await RisingEdge(dut.clk)
    for _ in range(100):  # Timeout after 100 cycles
        if dut.data_req.value != 0:
            break
        await RisingEdge(dut.clk)
    else:
        raise TestFailure("Memory access request not detected!")

    # Verify arbitration
    await RisingEdge(dut.clk)
    if dut.data_grant.value != 1:
        raise TestFailure("Arbiter failed to grant access to the core")

async def test_barrier_sync(dut):
    """Test barrier synchronization."""
    # Wait for the core to signal completion
    await RisingEdge(dut.clk)
    for _ in range(100):  # Timeout after 100 cycles
        if dut.core_done.value == 1:
            break
        await RisingEdge(dut.clk)
    else:
        raise TestFailure("Barrier synchronization failed!")

    # Verify all_done signal
    if dut.all_done.value != 1:
        raise TestFailure("Barrier synchronization signal not asserted!")

async def test_vector_addition(dut):
    """Test vector addition functionality."""
    # Wait for the core to complete computation
    await RisingEdge(dut.clk)
    for _ in range(100):  # Timeout after 100 cycles
        if dut.all_done.value == 1:
            break
        await RisingEdge(dut.clk)
    else:
        raise TestFailure("Vector addition did not complete!")

    # Verify result in memory
    expected_result = 1 + 9  # data[0] + data[8]
    actual_result = dut.data_mem.mem[16].value
    if actual_result != expected_result:
        raise TestFailure(f"Result mismatch: expected {expected_result}, got {actual_result}")