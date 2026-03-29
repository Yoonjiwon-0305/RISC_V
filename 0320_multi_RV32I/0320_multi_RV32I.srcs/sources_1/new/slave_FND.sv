`timescale 1ns / 1ps

module slave_FND (
    input               clk,
    input               reset,
    input        [31:0] p_addr,
    input        [31:0] p_wdata,
    input               p_write,
    input               p_en,
    input               p_sel,
    output       [31:0] p_rdata,
    output       [ 7:0] fnd_data,
    output       [ 3:0] fnd_digit,
    output logic        p_ready
);

    localparam [11:0] fnd_data_addr = 12'h000;

    logic [15:0] fnd_data_reg;

    assign p_ready = (p_sel && p_en) ? 1'b1 : 1'b0;

    assign p_rdata = (p_addr[11:0] == fnd_data_addr) ? {16'h0, fnd_data_reg}
                                                      : 32'hxxxx_xxxx;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            fnd_data_reg <= 16'h0000;
        end else begin
            if (p_ready && p_write) begin
                case (p_addr[11:0])
                    fnd_data_addr: fnd_data_reg <= p_wdata[15:0];
                endcase
            end
        end
    end

    fnd_controller U_FND (
        .clk    (clk),
        .reset  (reset),
        .fnd_in (fnd_data_reg),
        .fnd_seg(fnd_data),
        .fnd_com(fnd_digit)
    );

endmodule

module fnd_controller (
    input         clk,
    input         reset,
    input  [15:0] fnd_in,
    output [ 7:0] fnd_seg,
    output [ 3:0] fnd_com
);
    wire [3:0] w_digit_0, w_digit_1, w_digit_2, w_digit_3;
    wire [1:0] w_sel;
    wire [3:0] w_digit_mux;
    wire       w_1khz;

    fnd_digit_splitter U_SPLITTER (
        .fnd_in (fnd_in),
        .digit_0(w_digit_0),
        .digit_1(w_digit_1),
        .digit_2(w_digit_2),
        .digit_3(w_digit_3)
    );

    fnd_clk_div U_CLK_DIV (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_1khz)
    );

    fnd_counter U_COUNTER (
        .clk  (clk),    
        .reset(reset),
        .en   (w_1khz),  
        .sel  (w_sel)
    );

    fnd_mux U_MUX (
        .sel    (w_sel),
        .digit_0(w_digit_0),
        .digit_1(w_digit_1),
        .digit_2(w_digit_2),
        .digit_3(w_digit_3),
        .mux_out(w_digit_mux)
    );

    fnd_com_decoder U_COM_DEC (
        .sel    (w_sel),
        .fnd_com(fnd_com)
    );

    fnd_bcd U_BCD (
        .bcd    (w_digit_mux),
        .fnd_seg(fnd_seg)
    );

endmodule

module fnd_digit_splitter (
    input  [15:0] fnd_in,
    output [ 3:0] digit_0,  // 일의 자리
    output [ 3:0] digit_1,  // 십의 자리
    output [ 3:0] digit_2,  // 백의 자리
    output [ 3:0] digit_3   // 천의 자리
);
    assign digit_0 = fnd_in % 10;
    assign digit_1 = (fnd_in / 10) % 10;
    assign digit_2 = (fnd_in / 100) % 10;
    assign digit_3 = (fnd_in / 1000) % 10;
endmodule

module fnd_clk_div (
    input      clk,
    input      reset,
    output reg o_clk
);
    reg [$clog2(100_000):0] counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            o_clk   <= 0;
        end else begin
            if (counter == 99_999) begin
                counter <= 0;
                o_clk   <= 1'b1;
            end else begin
                counter <= counter + 1;
                o_clk   <= 1'b0;
            end
        end
    end
endmodule

module fnd_counter (
    input        clk,    
    input        reset,
    input        en,    
    output [1:0] sel
);
    reg [1:0] cnt;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) cnt <= 2'b00;
        else if (en) cnt <= cnt + 1;  
    end
    assign sel = cnt;
endmodule

module fnd_mux (
    input      [1:0] sel,
    input      [3:0] digit_0,
    input      [3:0] digit_1,
    input      [3:0] digit_2,
    input      [3:0] digit_3,
    output reg [3:0] mux_out
);
    always_comb begin
        case (sel)
            2'b00: mux_out = digit_0;
            2'b01: mux_out = digit_1;
            2'b10: mux_out = digit_2;
            2'b11: mux_out = digit_3;
        endcase
    end
endmodule

module fnd_com_decoder (
    input      [1:0] sel,
    output reg [3:0] fnd_com
);
    always_comb begin
        case (sel)
            2'b00: fnd_com = 4'b1110;
            2'b01: fnd_com = 4'b1101;
            2'b10: fnd_com = 4'b1011;
            2'b11: fnd_com = 4'b0111;
        endcase
    end
endmodule

module fnd_bcd (
    input      [3:0] bcd,
    output reg [7:0] fnd_seg
);
    always_comb begin
        case (bcd)
            4'd0: fnd_seg = 8'hC0;
            4'd1: fnd_seg = 8'hF9;
            4'd2: fnd_seg = 8'hA4;
            4'd3: fnd_seg = 8'hB0;
            4'd4: fnd_seg = 8'h99;
            4'd5: fnd_seg = 8'h92;
            4'd6: fnd_seg = 8'h82;
            4'd7: fnd_seg = 8'hF8;
            4'd8: fnd_seg = 8'h80;
            4'd9: fnd_seg = 8'h90;
            default: fnd_seg = 8'hFF;
        endcase
    end
endmodule
