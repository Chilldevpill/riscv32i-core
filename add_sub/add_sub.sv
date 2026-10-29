`timescale 1ns / 1ps

module add_sub #(
    parameter int WIDTH = 4
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             M,
    output logic [WIDTH-1:0] result
);

    always_comb begin
        if (M) begin
            result = a - b;
        end else begin
            result = a + b;
        end
    end

endmodule
