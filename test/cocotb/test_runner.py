import os
from pathlib import Path
from cocotb.runner import get_runner

def test_serv_gpu_runner():
    # Get the simulator from the environment (default: verilator)
    sim = os.getenv("SIM", "verilator")

    # Get the project path
    proj_path = Path(__file__).resolve().parent.parent.parent  # Root directory
    rtl_path = proj_path / "rtl"  # RTL directory

    # List of Verilog sources
    verilog_sources = [
        rtl_path / "serv" / "rtl" / "serv_aligner.v",
        rtl_path / "serv" / "rtl" / "serv_alu.v",
        rtl_path / "serv" / "rtl" / "serv_bufreg.v",
        rtl_path / "serv" / "rtl" / "serv_bufreg2.v",
        rtl_path / "serv" / "rtl" / "serv_compdec.v",
        rtl_path / "serv" / "rtl" / "serv_csr.v",
        rtl_path / "serv" / "rtl" / "serv_ctrl.v",
        rtl_path / "serv" / "rtl" / "serv_debug.v",
        rtl_path / "serv" / "rtl" / "serv_decode.v",
        rtl_path / "serv" / "rtl" / "serv_immdec.v",
        rtl_path / "serv" / "rtl" / "serv_mem_if.v",
        rtl_path / "serv" / "rtl" / "serv_rf_if.v",
        rtl_path / "serv" / "rtl" / "serv_rf_ram_if.v",
        rtl_path / "serv" / "rtl" / "serv_rf_ram.v",
        rtl_path / "serv" / "rtl" / "serv_rf_top.v",
        rtl_path / "serv" / "rtl" / "serv_state.v",
        rtl_path / "serv" / "rtl" / "serv_top.v",
        rtl_path / "barrier_sync.sv",
        rtl_path / "instruction_memory.sv",
        rtl_path / "round_robin_arbiter.sv",
        rtl_path / "serv_gpu.sv",
        rtl_path / "shared_memory.sv",
    ]

    # Get the cocotb runner
    runner = get_runner(sim)

    # Build arguments
    build_args = ["--timescale", "1ps/1ps"]

    # Conditionally add -Wall
    if sim != "verilator":
        build_args.append("-Wall")

    # Build the design
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="serv_gpu",  # Ensure this matches the top-level module name
        build_args=build_args,
    )

    # Run the testbench
    runner.test(
        hdl_toplevel="serv_gpu",  # Ensure this matches the top-level module name
        test_module="test_serv_gpu",
    )

if __name__ == "__main__":
    test_serv_gpu_runner()