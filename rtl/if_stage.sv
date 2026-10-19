module if_stage (

    input logic clk,
    input logic rst_n,

    // Branch / Jump interface (from EX stage)
    input logic        branch_taken_i,
    input logic [31:0] branch_target_i,

    // Pipeline control (from Hazard Unit)
    input logic stall_i,

    // Outputs
    output logic [31:0] pc_o,
    output logic [31:0] pc_plus4_o

);

  logic [31:0] pc_reg;
  logic [31:0] pc_next;

  // Next PC Mux: Choose between branch target or sequential PC + 4
  assign pc_next = branch_taken_i ? branch_target_i : (pc_reg + 32'd4);

  // Program Counter Register with reset and stall support
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_reg <= 32'h00000000;  // Reset PC to start at address 0
    end else if (!stall_i) begin
      pc_reg <= pc_next;
    end
  end

  // Drive outputs
  assign pc_o       = pc_reg;
  assign pc_plus4_o = pc_reg + 32'd4;
endmodule
