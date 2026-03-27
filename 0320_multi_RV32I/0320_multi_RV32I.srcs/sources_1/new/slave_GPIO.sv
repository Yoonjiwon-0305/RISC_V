`timescale 1ns / 1ps

module slave_GPIO (

    input               clk,
    input               reset,
    input        [31:0] p_addr,
    input        [31:0] p_wdata,
    input               p_write,
    input               p_en,
    input               p_sel,
    inout        [15:0] gpio,
    output logic [31:0] p_rdata,
    output logic        p_ready

);

    localparam [11:0] gpio_ctl_addr = 12'h000;
    localparam [11:0] gpio_o_data_addr = 12'h004;
    localparam [11:0] gpio_i_data_addr = 12'h008;

    logic [15:0] gpio_o_data_reg;
    logic [15:0] gpio_ctl_reg;
    logic [15:0] gpio_i_data_reg;
    logic [15:0] gpio_i_data;

    assign p_ready = (p_sel && p_en) ? 1'b1 : 1'b0;

    assign p_rdata = (p_sel) ? (
                   (p_addr[11:0] == gpio_ctl_addr)    ? {16'h0000, gpio_ctl_reg}    :
                   (p_addr[11:0] == gpio_o_data_addr)  ? {16'h0000, gpio_o_data_reg} :
                   (p_addr[11:0] == gpio_i_data_addr)  ? {16'h0000, gpio_i_data_reg} :
                   32'hzzzz_zzzz
                 ) : 32'hzzzz_zzzz;  // ✅ 선택 안됐으면 0


    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            gpio_ctl_reg    <= 16'h0000;
            gpio_i_data_reg <= 16'h0000;
            gpio_o_data_reg <= 16'h0000;
        end else begin
            gpio_i_data_reg <= gpio_i_data;
            if (p_ready & p_write) begin
                case (p_addr[11:0])
                    gpio_ctl_addr: begin
                        gpio_ctl_reg <= p_wdata[15:0];
                    end
                    gpio_o_data_addr: begin
                        gpio_o_data_reg <= p_wdata[15:0];
                    end
                endcase
            end
        end
    end


    gpio U_GPIO (
        .ctl   (gpio_ctl_reg),
        .o_data(gpio_o_data_reg),
        .i_data(gpio_i_data),
        .gpio  (gpio)

    );

endmodule


module gpio (
    input        [15:0] ctl,
    input        [15:0] o_data,
    output logic [15:0] i_data,
    inout  logic [15:0] gpio

);

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign gpio[i]   = ctl[i] ? o_data[i] : 1'bz;
            assign i_data[i] = gpio[i];
            //assign i_data[i] = ~ctl[i] ? gpio[i] : 1'bz;
        end
    endgenerate
endmodule
