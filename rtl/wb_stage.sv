module wb_stage (
  input logic mem_to_reg_i,
  input logic[31:0] alu_result_i,
  input logic[31:0] mem_rdata_i,
  
  output logic[31:0] reg_file_data_o
);
  
  // Multiplexer to select between ALU result and Memory Read data for Writeback
  assign reg_file_data_o = mem_to_reg_i ? mem_rdata_i : alu_result_i;
endmodule