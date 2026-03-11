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
    logic [2:0] rfwdsrc_sel;
    logic rf_we, alusrc;
    logic [31:0] rd1, rd2, w_pc_alu_result;
    logic [4:0] w_alu_control;
    logic branch;
    logic branch_sel;

    control_unit U_CONTROL_UNIT (
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .rf_we      (rf_we),
        .jal        (jal),
        .jalr       (jalr),
        .alusrc     (alusrc),
        .alu_control(w_alu_control),
        .branch     (branch),
        .rfwdsrc_sel(rfwdsrc_sel),
        .o_funct3   (o_funct3),
        .dwe        (dwe)
    );

    RV32I_datapath U_DATAPATH (
        .clk        (clk),
        .reset      (reset),
        .rf_we      (rf_we),
        .jal        (jal),
        .jalr       (jalr),
        .alusrc     (alusrc),
        .rfwdsrc_sel(rfwdsrc_sel),
        .alu_control(w_alu_control),
        .branch     (branch),
        .drdata     (drdata),
        .instr_data (instr_data),
        .instr_addr (instr_addr),
        .daddr      (daddr),
        .dwdata     (dwdata)
    );

endmodule


module control_unit (
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       rf_we,
    output logic       jal,
    output logic       jalr,
    output logic       alusrc,
    output logic [4:0] alu_control,
    output logic       branch,
    output logic [2:0] rfwdsrc_sel,
    output logic [2:0] o_funct3,
    output logic       dwe

);
    always_comb begin
        rf_we       = 1'b0;
        jal         = 1'b0;
        jalr        = 1'b0;
        alusrc      = 1'b0;
        alu_control = 5'b0_0_000;
        branch      = 1'b0;
        rfwdsrc_sel = 1'b0;
        o_funct3    = 3'b000;
        dwe         = 1'b0;
        case (opcode)
            `R_TYPE: begin
                rf_we       = 1'b1;
                jal         = 1'b0;
                jalr        = 1'b0;
                alusrc      = 1'b0;
                alu_control = {1'b0, funct7[5], funct3};
                branch      = 1'b0;
                rfwdsrc_sel = 3'b000;
                o_funct3    = 3'b000;
                dwe         = 1'b0;
            end
            `S_TYPE: begin
                rf_we       = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alusrc      = 1'b1;
                alu_control = 5'b0_0_000;
                branch      = 3'b000;
                rfwdsrc_sel = 3'b000;
                o_funct3    = funct3;
                dwe         = 1'b1;
            end
            `IL_TYPE: begin
                rf_we       = 1'b1;
                jal         = 1'b0;
                jalr        = 1'b0;
                alusrc      = 1'b1;
                alu_control = 5'b0_0_000;
                branch      = 1'b0;
                rfwdsrc_sel = 3'b001;
                o_funct3    = funct3;
                dwe         = 1'b0;
            end
            `II_TYPE: begin
                rf_we  = 1'b1;
                jal    = 1'b0;
                jalr   = 1'b0;
                alusrc = 1'b1;
                if (funct3 == 3'b101) begin
                    alu_control = {1'b0, funct7[5], funct3};
                end else begin
                    alu_control = {1'b0, funct3};
                end
                branch      = 1'b0;
                rfwdsrc_sel = 1'b0;
                o_funct3    = funct3;
                dwe         = 0;
            end
            `B_TYPE: begin
                rf_we       = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alusrc      = 1'b0;
                alu_control = {2'b10, funct3};
                branch      = 1'b1;
                rfwdsrc_sel = 3'b000;
                o_funct3    = funct3;
                dwe         = 1'b0;
            end
            `LUI_TYPE: begin
                rf_we       = 1'b1;
                jal         = 1'b0;
                jalr        = 1'b0;
                alusrc      = 1'b1;
                alu_control = 5'b11000;
                branch      = 1'b0;
                rfwdsrc_sel = 3'b010;
                o_funct3    = 3'b000;
                dwe         = 1'b0;
            end
            `AULPC_TYPE: begin
                rf_we       = 1'b1;
                jal         = 1'b0;
                jalr        = 1'b0;
                alusrc      = 1'b1;
                alu_control = `ADD;
                branch      = 1'b0;
                rfwdsrc_sel = 1'b0;
                o_funct3    = 3'b011;
                dwe         = 1'b0;
            end
            `JAL_TYPE: begin
                rf_we       = 1'b1;
                jal         = 1'b1;
                jalr        = 1'b0;
                alusrc      = 1'b1;
                alu_control = `ADD;
                branch      = 1'b1;
                rfwdsrc_sel = 1'b0;
                o_funct3    = 3'b100;
                dwe         = 1'b0;
            end
            `JALR_TYPE: begin
                rf_we       = 1'b1;
                jal         = 1'b1;
                jalr        = 1'b1;
                alusrc      = 1'b1;
                alu_control = `ADD;
                branch      = 1'b1;
                rfwdsrc_sel = 1'b0;
                o_funct3    = 3'b100;
                dwe         = 1'b0;
            end
        endcase
    end
endmodule
