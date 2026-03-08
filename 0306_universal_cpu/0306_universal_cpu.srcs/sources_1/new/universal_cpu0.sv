`timescale 1ns / 1ps
/* <c 언어>
    R3 = 1;       
    R1 = 0;       
    R2 = 0;       

    while (R1 < 11) {
        R2 = R2 + R1;  // sum
        R1 = R1 + R3;  // i
    }
    out = R2;
*/
module universal_cpu0 (

    input        clk,
    input        reset,
    output [7:0] out

);
    logic rfsrc_sel, we, eq10;
    logic [1:0] raddr0, raddr1, waddr;

    control_unit U_CONTROL_UNIT (.*);
    datapath U_DATAPATH (.*);
endmodule

module control_unit (
    input              clk,
    input              reset,
    input              eq10,
    output logic       rfsrc_sel,
    output logic [1:0] raddr0,
    output logic [1:0] raddr1,
    output logic [1:0] waddr,
    output logic       we

);
    typedef enum logic [3:0] {
        S0,  // R3 = 1
        S1,  // R1 = 0
        S2,  // R2 = 0
        S3,  // while (R1 < 11) 
        S4,  // R2 = R2 + R1
        S5,  // R1 = R1 + 1
        S6   // out = R2

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
        rfsrc_sel  = 0;
        raddr0     = 0;
        raddr1     = 0;
        waddr      = 0;
        we         = 0;
        case (current_state)
            S0: begin
                rfsrc_sel  = 0;
                raddr0     = 0;
                raddr1     = 0;
                waddr      = 3;
                we         = 1;
                next_state = S1;
            end

            S1: begin
                rfsrc_sel  = 1;
                raddr0     = 0;
                raddr1     = 0;
                waddr      = 1;
                we         = 1;
                next_state = S2;
            end

            S2: begin
                rfsrc_sel  = 1;
                raddr0     = 0;
                raddr1     = 0;
                waddr      = 2;
                we         = 1;
                next_state = S3;
            end

            S3: begin
                rfsrc_sel = 0;
                raddr0    = 1;
                raddr1    = 0;
                waddr     = 0;
                we        = 0;
                if (eq10) begin
                    next_state = S6;
                end else begin
                    next_state = S4;
                end
            end

            S4: begin
                rfsrc_sel  = 1;
                raddr0     = 1;
                raddr1     = 2;
                waddr      = 2;
                we         = 1;
                next_state = S5;
            end

            S5: begin
                rfsrc_sel  = 1;
                raddr0     = 1;
                raddr1     = 3;
                waddr      = 1;
                we         = 1;
                next_state = S3;
            end
            S6: begin
                rfsrc_sel = 0;
                raddr0    = 0;
                raddr1    = 2'd2;
                waddr     = 0;
                we        = 0;
            end
        endcase
    end

endmodule

module datapath (
    input        clk,
    input        reset,
    input        rfsrc_sel,
    input  [1:0] raddr0,
    input  [1:0] raddr1,
    input  [1:0] waddr,
    input        we,
    output       eq10,
    output [7:0] out

);

    logic [7:0] w_mux_out, w_RD0, w_RD1, w_alu_out;
    assign out = w_RD1;
    mux_2X1 U_RF_MUX (
        .a(1),
        .b(w_alu_out),
        .rfsrc_sel(rfsrc_sel),
        .mux_out(w_mux_out)
    );

    register_file U_REGISTER_FILE (
        .clk(clk),
        .reset(reset),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .waddr(waddr),
        .we(we),
        .wdata(w_mux_out),
        .RD0(w_RD0),
        .RD1(w_RD1)
    );

    eq10_compare U_EQ10 (
        .in_data(w_RD0),
        .eq10(eq10)
    );

    alu U_ALU (
        .a(w_RD0),
        .b(w_RD1),
        .alu_out(w_alu_out)
    );

endmodule

module register_file (
    input              clk,
    input              reset,
    input        [1:0] raddr0,
    input        [1:0] raddr1,
    input        [1:0] waddr,
    input              we,
    input        [7:0] wdata,
    output logic [7:0] RD0,
    output logic [7:0] RD1
);
    logic [7:0] register[0:3];

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            register[0] <= 8'd0;
            register[1] <= 8'd0;
            register[2] <= 8'd0;
            register[3] <= 8'd0;
        end else begin
            if (we) begin
                register[waddr] <= wdata;
            end
        end
    end

    assign RD0 = register[raddr0];  //i
    assign RD1 = register[raddr1];  //sum

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
    input        rfsrc_sel,
    output [7:0] mux_out
);

    assign mux_out = (rfsrc_sel ? b : a);

endmodule

module eq10_compare (
    input [7:0] in_data,
    output logic eq10
);
    assign eq10 = (in_data == 11);
endmodule
