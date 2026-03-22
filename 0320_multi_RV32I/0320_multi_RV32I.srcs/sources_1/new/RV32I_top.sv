`timescale 1ns / 1ps

module RV32I_top (
    input         clk,
    input         reset,
    output [31:0] instr_addr
);

    //logic [31:0] instr_addr;
    logic [31:0] instr_data;
    logic [31:0] daddr;
    logic [31:0] dwdata, drdata;
    logic dwe;
    logic [2:0] o_funct3;



    instruction_mem U_INSTRUCTION_MEM (.*);
    RV32I_cpu U_RV32I_CPU (
        .*,
        .o_funct3(o_funct3)
    );
    data_mem I_DATA_MEM (
        .*,
        .i_funct3(o_funct3)
    );

endmodule
