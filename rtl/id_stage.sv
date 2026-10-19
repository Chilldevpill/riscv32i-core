module id_stage (
  input logic clk,
  input logic rst_n,
  
  // Instruction input from Fetch Stage
  input logic[31:0] instr_i,
  
  // Register File Write Back interface (from WB stage)
  input logic reg_write_wb_i,
  input logic[4:0] rd_addr_wb_i,
  input logic[31:0] rd_data_wb_i,
  
  // Outputs to Execute Stage
  output logic[31:0] rs1_data_o,
  output logic[31:0] rs2_data_o,
  output logic[31:0] imm_o,
  output logic[4:0] rs1_addr_o,
  output logic[4:0] rs2_addr_o,
  output logic[4:0] rd_addr_o,
  
  // Control Signals
  output logic[3:0] alu_op_o,
  output logic alu_src_o, // 0: rs2_data, 1: immediate
  output logic reg_write_o,
  output logic mem_write_o,
  output logic mem_read_o,
  output logic mem_to_reg_o,
  output logic branch_o,
  output logic jump_o
);
  
  // Extract Register Addresses & Opcodes
  assign rs1_addr_o = instr_i[19:15];
  assign rs2_addr_o = instr_i[24:20];
  assign rd_addr_o = instr_i[11:7];
  
  logic[6:0] opcode;
  logic[2:0] funct3;
  logic[6:0] funct7;
  
  assign opcode = instr_i[6:0];
  assign funct3 = instr_i[14:12];
  assign funct7 = instr_i[31:25];
  
  // -------------------------------------------------------------------------
  // 1. Register File (32 x 32-bit registers, x0 hardwired to 0)
  // -------------------------------------------------------------------------
  logic[31:0] reg_file[31:1]; // x1 to x31 stored
  
  // Asynchronous Read with x0 Check
  assign rs1_data_o = (rs1_addr_o == 5'd0) ? 32'b0 : reg_file[rs1_addr_o];
  assign rs2_data_o = (rs2_addr_o == 5'd0) ? 32'b0 : reg_file[rs2_addr_o];
  
  // Synchronous Write
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 1; i < 32; i++) begin
        reg_file[i] <= 32'b0;
      end
    end
    else if (reg_write_wb_i && (rd_addr_wb_i != 5'd0)) begin
      reg_file[rd_addr_wb_i] <= rd_data_wb_i;
    end
  end
  
  // -------------------------------------------------------------------------
  // 2. Immediate Generator (I, S, B, U, J Formats)
  // -------------------------------------------------------------------------
  always_comb begin
    case (opcode)
      7'b0010011, // I-type ALU
      7'b0000011, // Load
      7'b1100111: // JALR
        imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
      
      7'b0100011: // S-type (Store)
        imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
      
      7'b1100011: // B-type (Branch)
        imm_o = {
          {20{instr_i[31]}},
          instr_i[7],
          instr_i[30:25],
          instr_i[11:8],
          1'b0
        };
      
      7'b0110111, // U-type (LUI)
      7'b0010111: // U-type (AUIPC)
        imm_o = {instr_i[31:12], 12'b0};
      
      7'b1101111: // J-type (JAL)
        imm_o = {
          {12{instr_i[31]}},
          instr_i[19:12],
          instr_i[20],
          instr_i[30:21],
          1'b0
        };
      
      default: imm_o = 32'b0;
    endcase
  end
  
  // -------------------------------------------------------------------------
  // 3. Control Unit Decoder
  // -------------------------------------------------------------------------
  always_comb begin
    // Defaults
    alu_op_o = 4'b0000;
    alu_src_o = 1'b0;
    reg_write_o = 1'b0;
    mem_write_o = 1'b0;
    mem_read_o = 1'b0;
    mem_to_reg_o = 1'b0;
    branch_o = 1'b0;
    jump_o = 1'b0;
    
    case (opcode)
      7'b0110011: begin // R-type
        reg_write_o = 1'b1;
        case (funct3)
          3'b000: alu_op_o = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
          3'b001: alu_op_o = 4'b0010; // SLL
          3'b010: alu_op_o = 4'b0011; // SLT
          3'b011: alu_op_o = 4'b0100; // SLTU
          3'b100: alu_op_o = 4'b0101; // XOR
          3'b101: alu_op_o = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA : SRL
          3'b110: alu_op_o = 4'b1000; // OR
          3'b111: alu_op_o = 4'b1001; // AND
          default: alu_op_o = 4'b0000;
        endcase
      end
      
      7'b0010011: begin // I-type ALU
        reg_write_o = 1'b1;
        alu_src_o = 1'b1;
        case (funct3)
          3'b000: alu_op_o = 4'b0000; // ADDI
          3'b010: alu_op_o = 4'b0011; // SLTI
          3'b011: alu_op_o = 4'b0100; // SLTIU
          3'b100: alu_op_o = 4'b0101; // XORI
          3'b110: alu_op_o = 4'b1000; // ORI
          3'b111: alu_op_o = 4'b1001; // ANDI
          3'b001: alu_op_o = 4'b0010; // SLLI
          3'b101: alu_op_o = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI : SRLI
          default: alu_op_o = 4'b0000;
        endcase
      end
      
      7'b0000011: begin // Load
        reg_write_o = 1'b1;
        alu_src_o = 1'b1;
        mem_read_o = 1'b1;
        mem_to_reg_o = 1'b1;
        alu_op_o = 4'b0000; // ADD base + offset
      end
      
      7'b0100011: begin // Store
        alu_src_o = 1'b1;
        mem_write_o = 1'b1;
        alu_op_o = 4'b0000; // ADD base + offset
      end
      
      7'b1100011: begin // Branch
        branch_o = 1'b1;
        alu_op_o = 4'b0001; // SUB for comparison
      end
      
      7'b1101111: begin // JAL
        reg_write_o = 1'b1;
        jump_o = 1'b1;
      end
      
      default:;
    endcase
  end
  
endmodule