`timescale 1ns / 1ps
`include "define.vh"

module RV32I_cpu (

    input         clk,
    input         reset,
    input  [31:0] instr_data,
    input  [31:0] drdata,
    output [31:0] instr_addr,
    output        dwe,
    output [ 2:0] o_funct3,
    output [31:0] daddr,
    output [31:0] dwdata
);

    logic rf_we, alusrc, rfwdsrc_sel;
    logic [31:0] rd1, rd2, w_pc_alu_result;
    logic [3:0] w_alu_control;

    control_unit U_CONTROL_UNIT (
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .rf_we      (rf_we),
        .alusrc     (alusrc),
        .alu_control(w_alu_control),
        .rfwdsrc_sel(rfwdsrc_sel),
        .o_funct3   (o_funct3),
        .dwe        (dwe)

    );

    RV32I_datapath U_DATAPATH (
        .clk(clk),
        .reset(reset),
        .rf_we(rf_we),
        .alusrc(alusrc),
        .rfwdsrc_sel(rfwdsrc_sel),
        .alu_control(w_alu_control),
        .drdata(drdata),
        .instr_data(instr_data),
        .instr_addr(instr_addr),
        .daddr(daddr),
        .dwdata(dwdata)
    );

endmodule


module control_unit (
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       rf_we,
    output logic       alusrc,
    output logic [3:0] alu_control,
    output logic [2:0] o_funct3,
    output logic       dwe,
    output logic       rfwdsrc_sel

);
    always_comb begin
        rf_we       = 1'b0;
        alusrc      = 1'b0;
        alu_control = 4'b0000;
        rfwdsrc_sel = 1'b0;
        o_funct3    = 3'b000;
        dwe         = 1'b0;
        case (opcode)
            `R_TYPE: begin
                rf_we = 1'b1;
                alusrc = 1'b0;
                alu_control = {funct7[5], funct3};
                rfwdsrc_sel = 1'b0;
                o_funct3    = 3'b000;
                dwe = 1'b0;
            end
            `S_TYPE: begin
                rf_we       = 1'b0;
                alusrc      = 1'b1;
                alu_control = 4'b0000;
                rfwdsrc_sel = 1'b0;
                o_funct3    = funct3;
                dwe         = 1'b1;
            end
            `IL_TYPE: begin
                rf_we       = 1'b1;
                alusrc      = 1'b1;
                alu_control = 4'b0000;
                rfwdsrc_sel = 1'b1;
                o_funct3    = funct3;
                dwe         = 1'b0;
            end
            `II_TYPE: begin
                rf_we  = 1'b1;
                alusrc = 1'b1;
                if (funct3 == 3'b101) begin
                    alu_control = {funct7[5], funct3};
                end else begin
                    alu_control = {1'b0, funct3};
                end
                rfwdsrc_sel = 1'b0;
                o_funct3    = funct3;
                dwe         = 0;
            end
        endcase
    end
endmodule
