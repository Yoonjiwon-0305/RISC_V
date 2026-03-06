`timescale 1ns / 1ps

/*<c언어>
byte a = 0;   
byte sum = 0; 

while (a =< 10) {
    sum = sum + a; 
    a = a + 1;    
    out =sum; 
}*/

module sum_cpu_teach (
    input        clk,
    input        reset,
    output [7:0] out

);

    logic sumsrc_sel, sum_load, isrc_sel, i_load, alusrc_sel, out_load, ilq10;

    control_unit U_CONTROL_UNIT (.*);
    datapath U_DATAPATH (.*);

endmodule

module control_unit (
    input        clk,
    input        reset,
    input        ilq10,
    output logic isrc_sel,
    output logic sumsrc_sel,
    output logic i_load,
    output logic sum_load,
    output logic alusrc_sel,
    output logic out_load

);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5
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
        isrc_sel   = 0;
        sumsrc_sel = 0;
        i_load     = 0;
        sum_load   = 0;
        alusrc_sel = 0;
        out_load   = 0;
        case (current_state)
            S0: begin
                isrc_sel   = 0;
                sumsrc_sel = 0;
                i_load     = 1;
                sum_load   = 1;
                alusrc_sel = 0;
                out_load   = 0;
                next_state = S1;
            end
            S1: begin
                isrc_sel   = 0;
                sumsrc_sel = 0;
                i_load     = 0;
                sum_load   = 0;
                alusrc_sel = 0;
                out_load   = 0;
                if (ilq10 == 1) begin
                    next_state = S2;
                end else begin
                    next_state = S5;
                end
            end
            S2: begin
                isrc_sel   = 0;
                sumsrc_sel = 1;
                i_load     = 0;
                sum_load   = 1;
                alusrc_sel = 0;
                out_load   = 0;
                next_state = S3;
            end
            S3: begin
                isrc_sel   = 1;
                sumsrc_sel = 0;
                i_load     = 1;
                sum_load   = 0;
                alusrc_sel = 1;
                out_load   = 0;
                next_state = S4;
            end
            S4: begin
                isrc_sel   = 0;
                sumsrc_sel = 0;
                i_load     = 0;
                sum_load   = 0;
                alusrc_sel = 0;
                out_load   = 1;
                next_state = S1;
            end
            S5: begin
                isrc_sel   = 0;
                sumsrc_sel = 0;
                i_load     = 0;
                sum_load   = 0;
                alusrc_sel = 0;
                out_load   = 0;

            end
        endcase

    end
endmodule

module datapath (
    input        clk,
    input        reset,
    input        sumsrc_sel,
    input        sum_load,
    input        isrc_sel,
    input        i_load,
    input        out_load,
    input        alusrc_sel,
    output       ilq10,
    output [7:0] out
);

    wire [7:0] w_ireg_src_data, w_sumreg_src_data, ireg_out, sumreg_out, alu_out,w_alu_src_data,w_alu_out;

    register U_OUT_REG (
        .clk    (clk),
        .reset  (reset),
        .reg_in (sumreg_out),
        .load   (out_load),
        .reg_out(out)
    );

    mux_2X1 U_IREG_SRC_MUX (
        .a      (0),
        .b      (w_alu_out),
        .srcsel (isrc_sel),
        .mux_out(w_ireg_src_data)
    );

    register U_I_REG (
        .clk    (clk),
        .reset  (reset),
        .reg_in (w_ireg_src_data),
        .load   (i_load),
        .reg_out(ireg_out)
    );

    ilq10_compare U_LQT10_COM (
        .in_data(ireg_out),
        .ilq10  (ilq10)
    );

    mux_2X1 U_SUMREG_SRC_MUX (
        .a      (0),
        .b      (w_alu_out),
        .srcsel (sumsrc_sel),
        .mux_out(w_sumreg_src_data)
    );

    register U_SUM_REG (
        .clk    (clk),
        .reset  (reset),
        .reg_in (w_sumreg_src_data),
        .load   (sum_load),
        .reg_out(sumreg_out)
    );

    mux_2X1 U_ALU_SRC_MUX (
        .a      (sumreg_out),
        .b      (1),
        .srcsel (alusrc_sel),
        .mux_out(w_alu_src_data)
    );

    alu U_ALU (
        .a      (ireg_out),
        .b      (w_alu_src_data),
        .alu_out(w_alu_out)
    );

endmodule

module register (
    input              clk,
    input              reset,
    input        [7:0] reg_in,
    input              load,
    output logic [7:0] reg_out
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
    input  [7:0] a,       //  sel 0
    input  [7:0] b,       //  sel 1
    input        srcsel,
    output [7:0] mux_out
);

    assign mux_out = (srcsel) ? b : a;

endmodule

module ilq10_compare (
    input  [7:0] in_data,
    output       ilq10
);
    assign ilq10 = (in_data <= 10);
endmodule



