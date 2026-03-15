`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:127];

    initial begin

        rom[0] = 32'h12345537;  //lui x10, 0x12345
        rom[1] = 32'h67850513;  //addi x10, x10, 0x678
        rom[2] = 32'h00001517;  //auipc x10, 1
        rom[3] = 32'h00001517;  //auipc x10, 1 


    end



    assign instr_data = rom[instr_addr[31:2]];

endmodule



// $readmemh("riscv_rv32i_data.mem",rom);
