`timescale 1ns / 1ps

module tb_sum_cpu_teach ();
    logic       clk;
    logic       reset;
    logic [7:0] out;

    sum_cpu_teach dut (
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
        #500;
        $stop;
    end

endmodule
