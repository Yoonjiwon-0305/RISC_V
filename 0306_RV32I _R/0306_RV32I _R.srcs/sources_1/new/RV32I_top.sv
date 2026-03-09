`timescale 1ns / 1ps

module RV32I_top (
    input clk,
    input reset
);

    logic [31:0] instr_addr;
    logic [31:0] instr_data;
    logic [31:0] dwaddr;
    logic [31:0] dwdata, drdata;
    logic dwe;



    instruction_mem U_INSTRUCTION_MEM (.*);
    RV32I_cpu U_RV32I_CPU (.*);
    data_mem I_DATA_MEM (.*);

endmodule
