`timescale 1ns / 1ps

module sum_cpu2 (
    input        clk,
    input        reset,
    output [7:0] out

);

    logic sumsrc_sel, sum_load, asrc_sel, a_load, outsel, alt11;

    control_unit U_CONTROL_UNIT (.*);
    datapath U_DATAPATH (.*);

endmodule

module control_unit (
    input        clk,
    input        reset,
    input        alt11,
    output logic sumsrc_sel,
    output logic sum_load,
    output logic asrc_sel,
    output logic a_load,
    output logic outsel

);
    typedef enum logic [2:0] {
        S0, // 초기화
        S1, // 
        S2,
        S3,
        S4

    } state_t;
    state_t current_state, next_state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        sumsrc_sel = 0;
        sum_load = 0;
        asrc_sel = 0;
        a_load = 0;
        outsel = 0;
        case (current_state)
            S0: begin // 초기화 
                sumsrc_sel = 0;
                sum_load   = 0;
                asrc_sel   = 0;
                a_load     = 0;
                outsel     = 0;
                next_state = S1;
            end
            S1: begin
                sumsrc_sel = 0;
                sum_load   = 0;
                asrc_sel   = 0;
                a_load     = 0;
                outsel     = 0;
                if (alt11) begin
                    next_state = S2;
                end else begin
                    next_state = S4;
                end
            end
            S2: begin
                sumsrc_sel = 1;
                sum_load   = 1;
                asrc_sel   = 0;
                a_load     = 0;
                outsel     = 0;
                next_state = S3;
            end
            S3: begin
                sumsrc_sel = 0;
                sum_load   = 0;
                asrc_sel   = 1;
                a_load     = 1;
                outsel     = 0;
                next_state = S1;
            end
            S4: begin
                sumsrc_sel = 0;
                sum_load   = 0;
                asrc_sel   = 0;
                a_load     = 0;
                outsel     = 1;

            end

        endcase
    end

endmodule

module datapath (
    input        clk,
    input        reset,
    input        sumsrc_sel,
    input        sum_load,
    input        asrc_sel,
    input        a_load,
    input        outsel,
    output       alt11,
    output [7:0] out
);

    logic [7:0] w_sum_reg, w_a_reg, w_sum_alu, w_a_alu, w_sum_mux, w_a_mux;
    assign out = (outsel) ? w_sum_reg : 8'hz;

    register U_SUM_REG (
        .clk(clk),
        .reset(reset),
        .reg_in(w_sum_mux),
        .load(sum_load),
        .reg_out(w_sum_reg)
    );

    register U_A_REG (
        .clk(clk),
        .reset(reset),
        .reg_in(w_a_mux),
        .load(a_load),
        .reg_out(w_a_reg)
    );

    alu U_SUM_ALU (
        .a(w_sum_reg),
        .b(w_a_reg),
        .alu_out(w_sum_alu)
    );

    alu U_A_ALU (
        .a(w_a_reg),
        .b(8'h1),
        .alu_out(w_a_alu)
    );

    mux_2X1 U_SUM_MUX (
        .a(0),
        .b(w_sum_alu),
        .srcsel(sumsrc_sel),
        .mux_out(w_sum_mux)
    );

    mux_2X1 U_A_MUX (
        .a(0),
        .b(w_a_alu),
        .srcsel(asrc_sel),
        .mux_out(w_a_mux)
    );

    alt11_compare U_ALT11_COM (
        .in_data(w_a_reg),
        .alt11  (alt11)
    );
endmodule

module register (
    input        clk,
    input        reset,
    input  [7:0] reg_in,
    input        load,
    output [7:0] reg_out
);

    logic [7:0] r_data;

    assign reg_out = r_data;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            r_data <= 0;
        end else begin
            if (load) begin
                r_data <= reg_in;
            end
        end
    end
endmodule

module alu (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] alu_out
);
    assign alu_out = a + b;  // 조합논리 

endmodule

module mux_2X1 (
    input  [7:0] a,
    input  [7:0] b,
    input        srcsel,
    output [7:0] mux_out
);

    assign mux_out = (srcsel ? b : a);

endmodule

module alt11_compare (
    input [7:0] in_data,
    output logic alt11
);
    assign alt11 = (in_data < 11);
endmodule


/*<c언어>
byte a = 0;   
byte sum = 0; 

while (a <11) {
    sum = sum + a; 
    a = a + 1;     
}*/

