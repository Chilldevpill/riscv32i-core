# Architecture: Fetch Stage (`if_stage.sv`)

## Overview
The fetch stage is responsible for generating the Program Counter (PC), issuing instruction memory requests, and computing sequential or target next-address paths.

## Key Signals
- `clk`, `rst_n`: Standard clock and active-low asynchronous reset.
- `branch_taken_i`: Control signal from the EX stage indicating a jump or taken branch.
- `branch_target_i`: Computed target address for branches/jumps.
- `stall_i`: Pipeline stall control signal from the Hazard Unit to freeze the PC.
- `pc_o`: Current Program Counter value.
- `pc_plus4_o`: Sequential next PC (`pc_reg + 4`), forwarded to the decode stage.

## Design Decisions
- Reset vector is hardcoded to `32'h00000000`.
- Priority is given to branch/jump resolution over sequential execution when `branch_taken_i` is asserted.


---

## Architecture: Decode Stage (`id_stage.sv`)

## Overview
The decode stage takes the raw 32-bit instruction from the fetch stage, breaks down the opcode and fields (funct3, funct7, rs1, rs2, rd), and interfaces with the Register File to fetch operand data and generate control signals.

## Key Signals
- `instr_i`: 32-bit instruction fetched from memory/fetch stage.
- `rs1_data_o`, `rs2_data_o`: Operand data read from the register file.
- `imm_o`: Sign-extended immediate value generated based on instruction type (I, S, B, U, J).
- `alu_op_o`, `reg_write_o`, `mem_write_o`: Control signals decoded for downstream stages.

## Design Decisions
- Includes an internal Register File handling registers `x0` through `x31` (with `x0` hardwired to zero).
- Supports immediate generation for R, I, S, B, U, and J formats.

---

## Architecture: Execute Stage (`ex_stage.sv`)

## Overview
The execute stage contains the Arithmetic Logic Unit (ALU) and branch comparison logic. It performs arithmetic, logical, and shift operations, calculates memory addresses for loads/stores, and evaluates branch conditions.

## Key Signals
- `alu_op_i`: 4-bit ALU operation control signal.
- `alu_src_i`: Selects second operand (0 for `rs2_data`, 1 for `imm`).
- `operand_a_i`, `operand_b_i`: Input operands.
- `alu_result_o`: Final computed result from the ALU.
- `branch_taken_o`: Evaluates whether a conditional branch should be taken.

## Design Decisions
- Supports standard RV32I arithmetic (`ADD`, `SUB`), logical (`AND`, `OR`, `XOR`), shifts (`SLL`, `SRL`, `SRA`), and comparisons (`SLT`, `SLTU`).
- Handles branch target calculations for conditional jumps.

---

## Architecture: Memory Stage (`mem_stage.sv`)

## Overview
The memory stage interfaces with the data memory subsystem. It handles memory read and write requests for load and store instructions while passing ALU results and control signals down to the writeback stage.

## Key Signals
- `mem_read_i`, `mem_write_i`: Control flags determining data memory operation type.
- `alu_result_i`: Effective memory address calculated in the execute stage.
- `write_data_i`: Data value to be stored (for store instructions).
- `mem_rdata_i`: Raw data read from the memory interface.
- `mem_rdata_o`, `alu_result_o`: Data passed forward to the writeback stage.

## Design Decisions
- Acts as an interface layer between the core's execute outputs and the external data memory/cache subsystem.
- Prepares data pathways for load/store routing.