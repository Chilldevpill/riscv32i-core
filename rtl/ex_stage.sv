module ex_stage (
  input logic[31:0] pc_i,
  input logic[31:0] rs1_data_i,
  input logic[31:0] rs2_data_i,
  input logic[31:0] imm_i,
  input logic alu_src_i,
  input logic[3:0] alu_op_i,
  input logic branch_i,
  input logic[2:0] funct3_i,
  
  output logic[31:0] alu_result_o,
  output logic branch_taken_o
);
  
  // Operand B Selection
  logic[31:0] operand_b;
  assign operand_b = alu_src_i ? imm_i : rs2_data_i;
  
  // ALU Operations
  always_comb begin
    case (alu_op_i)
      4'b0000: alu_result_o = rs1_data_i + operand_b; // ADD / ADDI / Load / Store
      4'b0001: alu_result_o = rs1_data_i - operand_b; // SUB / Branch
      4'b0010: alu_result_o = rs1_data_i << operand_b[4:0]; // SLL / SLLI
      4'b0011: alu_result_o = ($signed(rs1_data_i) < $signed(operand_b)) ? 32'd1 : 32'd0; // SLT / SLTI
      4'b0100: alu_result_o = (rs1_data_i < operand_b) ? 32'd1 : 32'd0; // SLTU / SLTIU
      4'b0101: alu_result_o = rs1_data_i ^ operand_b; // XOR / XORI
      4'b0110: alu_result_o = rs1_data_i >> operand_b[4:0]; // SRL / SRLI
      4'b0111: alu_result_o = $signed(rs1_data_i) >>> operand_b[4:0]; // SRA / SRAI
      4'b1000: alu_result_o = rs1_data_i | operand_b; // OR / ORI
      4'b1001: alu_result_o = rs1_data_i & operand_b; // AND / ANDI
      default: alu_result_o = 32'b0;
    endcase
  end
  
  // Branch Condition Evaluation
  logic branch_cond;
  always_comb begin
    case (funct3_i)
      3'b000: branch_cond = (rs1_data_i == rs2_data_i); // BEQ
      3'b001: branch_cond = (rs1_data_i != rs2_data_i); // BNE
      3'b100: branch_cond = ($signed(rs1_data_i) < $signed(rs2_data_i)); // BLT
      3'b101: branch_cond = ($signed(rs1_data_i) >= $signed(rs2_data_i)); // BGE
      3'b110: branch_cond = (rs1_data_i < rs2_data_i); // BLTU
      3'b111: branch_cond = (rs1_data_i >= rs2_data_i); // BGEU
      default: branch_cond = 1'b0;
    endcase
  end
  
  assign branch_taken_o = branch_i && branch_cond;
  
endmodule