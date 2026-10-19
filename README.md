# 5-Stage Pipelined RV32I Core

A clean, modular 5-stage pipelined RISC-V (RV32I) soft core written in SystemVerilog, designed for FPGA/ASIC synthesis and verified using Python (Cocotb) and Icarus Verilog.

## Project Directory Structure

```text
riscv32i-core/
├── rtl/
│   ├── core_top.sv
│   ├── if_stage.sv
│   ├── id_stage.sv
│   ├── ex_stage.sv
│   ├── mem_stage.sv
│   ├── wb_stage.sv
│   ├── hazard_unit.sv
│   └── forwarding_unit.sv
├── tb/
│   ├── tb_top.sv                     # SystemVerilog testbench or Cocotb wrapper
│   ├── test_core.py                  # Python test runner (Cocotb)
│   └── tests/                        # Assembly (.s) or hex memory files
├── synth/
│   ├── synth.ys                      # Yosys synthesis script
│   └── reports/                      # Generated area and cell reports
├── portfolio_assets/                 # Dedicated folder for your 5 Portfolio Items
│   ├── diagrams/
│   │   └── pipeline_architecture.png # [Item 1] Architecture Diagram
│   ├── waveforms/
│   │   ├── forwarding_hazard.png     # [Item 3] Hero Waveform 1: Data Forwarding
│   │   └── load_use_stall.png        # [Item 3] Hero Waveform 2: Load-Use Stall
│   ├── verification/
│   │   └── test_pass_log.txt         # [Item 4] Verification Test Pass Proof
│   └── synthesis/
│       └── yosys_metrics_report.md   # [Item 5] Yosys Gate Count & Area Metrics
├── docs/                             # Architecture specs & ISA matrix
│   ├── architecture.md
│   └── instruction_subset.md         # [Item 2] Instruction Subset Matrix
└── README.md