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