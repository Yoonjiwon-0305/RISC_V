`timescale 1ns / 1ps

module dedicated_cpu1_repeat (

    input        clk,
    input        reset,
    output [7:0] out

);

    logic asrcsel, aload, outsel, alt10;

    control_unit U_CONTROL_UNIT (.*);

    datapath U_DATAPATH (.*);

endmodule

module control_unit (

    input        clk,
    input        reset,
    input        alt10,
    output logic asrcsel,
    output logic aload,
    output logic outsel

);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4
    } state_t;
    state_t current_state, next_state;

    // 초기화
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;

        end else begin
            current_state <= next_state;

        end
    end

    // 상태변환
    always_comb begin
        next_state = current_state;
        asrcsel    = 0;
        aload      = 0;
        outsel     = 0;
        case (current_state)
            S0: begin
                asrcsel    = 0;
                aload      = 0;
                outsel     = 0;
                next_state = S1;
            end
            S1: begin
                asrcsel = 0;
                aload   = 0;
                outsel  = 0;
                if (alt10) begin
                    next_state = S2;
                end else begin
                    next_state = S4;
                end
            end
            S2: begin
                asrcsel    = 0;
                aload      = 0;
                outsel     = 1;
                next_state = S3;
            end
            S3: begin
                asrcsel    = 1;
                aload      = 1;
                outsel     = 0;
                next_state = S1;
            end
            S4: begin
                asrcsel = 0;
                aload   = 0;
                outsel  = 1;
            end
        endcase
    end
endmodule

module datapath (

    input        clk,
    input        reset,
    input        asrcsel,
    input        aload,
    input        outsel,
    output [7:0] out,
    output       alt10
);

    logic [7:0] w_aluout;
    logic [7:0] w_muxout;
    logic [7:0] w_regout;
    assign out = (outsel) ? w_regout : 8'hz;

    mux_2X1 U_MUX (
        .a      (8'h00),
        .b      (w_aluout),
        .asrcsel(asrcsel),
        .mux_out(w_muxout)
    );

    areg U_AREG (
        .clk    (clk),
        .reset  (reset),
        .reg_in (w_muxout),
        .aload  (aload),
        .reg_out(w_regout)
    );

    alu U_ALU (
        .a      (w_regout),
        .b      (8'h1),
        .alu_out(w_aluout)
    );

    alt10_compare U_COMPARE (
        .in_data(w_regout),
        .alt10  (alt10)
    );


endmodule

module areg (
    input        clk,
    input        reset,
    input  [7:0] reg_in,
    input        aload,
    output [7:0] reg_out
);

    logic [7:0] areg;

    assign reg_out = areg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            areg <= 0;
        end else begin
            if (aload) begin
                areg <= reg_in;
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

module alt10_compare (
    input [7:0] in_data,
    output logic alt10
);
    assign alt10 = (in_data < 10);
endmodule

module mux_2X1 (
    input  [7:0] a,
    input  [7:0] b,
    input        asrcsel,
    output [7:0] mux_out
);

    assign mux_out = (asrcsel ? b : a);

endmodule






