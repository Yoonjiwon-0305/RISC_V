`timescale 1ns / 1ps

module tb_RV32I ();

    logic clk, reset;

    RV32I_top dut (
        .clk  (clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        @(negedge clk);
        @(negedge clk);
        reset = 0;

        repeat (15) @(negedge clk);
        $stop;
    end

endmodule
