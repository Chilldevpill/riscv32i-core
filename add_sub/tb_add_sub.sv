`timescale 1ns / 1ps

module tb_add_sub;
  localparam int WIDTH = 4;
  
  logic [WIDTH-1 : 0] a;
  logic [WIDTH-1 : 0] b;
  logic               M;
  logic [WIDTH-1 : 0] result;
  
  add_sub #(.WIDTH(WIDTH)) uut (
    .a(a),
    .b(b),
    .M(M),
    .result(result)
  );
  
  initial begin
    // Generate waveform file for GTKWave
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_add_sub);
    
    // Initializing
    M = 1'b0;
    a = 4'd0;
    b = 4'd0;
    #1;
    
    // Addition
    M = 1'b0;
    a = 4'd5;
    b = 4'd6;
    #10;
    
    a = 4'd2;
    b = 4'd4;
    #10;
    
    // Subtraction
    M = 1'b1;
    a = 4'd6;
    b = 4'd4;
    #10;
    
    a = 4'd5;
    b = 4'd3;
    #10;
    
    $finish;
  end
endmodule
