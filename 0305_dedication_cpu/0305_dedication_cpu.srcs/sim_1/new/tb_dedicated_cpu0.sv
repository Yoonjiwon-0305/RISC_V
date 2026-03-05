`timescale 1ns / 1ps



module tb_dedicated_cpu0 ();
    logic clk;
    logic reset;
    logic [7:0] out;

    dedicated_cpu0 dut (

        .clk  (clk),
        .reset(reset),
        .out  (out)

    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #20;
        reset = 0;
        #40;
        $stop;
    end



endmodule
