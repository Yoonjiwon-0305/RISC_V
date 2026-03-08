`timescale 1ns / 1ps

module tb_universal_cpu0 ();

    logic       clk;
    logic       reset;
    logic [7:0] out;

    universal_cpu0 dut (

        .clk  (clk),
        .reset(reset),
        .out  (out)

    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;
        #400;
        $stop;
    end
endmodule
