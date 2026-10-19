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