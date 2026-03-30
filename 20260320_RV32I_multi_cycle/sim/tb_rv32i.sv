`timescale 1ns / 1ps

module tb_rv32i ();

    logic        clk, rst;
    logic [ 7:0] gpi;
    wire  [ 7:0] gpo;
    wire  [15:0] gpio;
    wire  [ 3:0] fnd_digit;
    wire  [ 7:0] fnd_data;
    logic        uart_rx;
    wire         uart_tx;

    logic [7:0] gpio_sw;
    assign gpio = {8'bz, gpio_sw};

    rv32i_mcu dut (.*);

    always #5 clk = ~clk;

    task uart_send(input [7:0] data);
        integer i;
        uart_rx = 0;
        #8680;
        for (i = 0; i < 8; i++) begin
            uart_rx = data[i];
            #8680;
        end
        uart_rx = 1;
        #8680;
    endtask

    initial begin
        clk      = 0;
        rst      = 1;
        gpi      = 8'h00;
        gpio_sw  = 8'h00;
        uart_rx  = 1;

        @(negedge clk);
        @(negedge clk);
        rst = 0;

        repeat(5000) @(negedge clk);

        // RAM
        repeat(1000) @(negedge clk);

        // GPO
        repeat(100) @(negedge clk);

        // GPI
        gpi = 8'hAA;
        repeat(100) @(negedge clk);

        gpi = 8'h55;
        repeat(100) @(negedge clk);

        // GPIO
        gpio_sw = 8'h55;
        repeat(200) @(negedge clk);

        gpio_sw = 8'hAA;
        repeat(200) @(negedge clk);

        // FND
        gpio_sw = 8'h0F;
        repeat(500) @(negedge clk);

        gpio_sw = 8'h63;
        repeat(500) @(negedge clk);

        // UART
        uart_send(8'h41);
        repeat(200) @(negedge clk);

        uart_send(8'h5A);
        repeat(200) @(negedge clk);

        repeat(100) @(negedge clk);
        $stop;
    end

    initial begin
        $monitor("[%0t] gpo=%0h gpio[15:8]=%0b fnd=%0h uart_tx=%b",
                 $time, gpo, gpio[15:8], fnd_data, uart_tx);
    end

endmodule