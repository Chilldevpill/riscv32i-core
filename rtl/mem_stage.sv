module mem_stage (
  input logic mem_read_i,
  input logic mem_write_i,
  input logic[31:0] alu_result_i,
  input logic[31:0] write_data_i,
  input logic[31:0] mem_rdata_i,
  
  output logic[31:0] mem_rdata_o,
  output logic[31:0] alu_result_o
);
  
  // Pass-through signals to the Writeback stage
  assign alu_result_o = alu_result_i;
  assign mem_rdata_o = mem_rdata_i;
  
endmodule