`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:31];

    initial begin

        //BEQ
        rom[0]  = 32'h01ee5463;  //bge x28, x30, 8
        rom[1]  = 32'h01ce5463;  //bge x28, x28, 8
        rom[2]  = 32'h00c57493;  //andi x9, x10, 12
        rom[3]  = 32'h00409293;  //slli x5, x1, 4
        rom[4]  = 32'hfff00093;  //addi x1, x0, -1
        rom[5]  = 32'h00409313;  //slli x6, x1, 4
        rom[6]  = 32'h01be5863;  //bge x28, x27, 16
        rom[7]  = 32'h00c57493;  //andi x9, x10, 12
        rom[8]  = 32'h00b57493;  //andi x9, x10, 11
        rom[9]  = 32'h00407193;  //andi x3, x0, 4
        rom[10] = 32'h0040df93;  //srli x31, x1, 4
        rom[11] = 32'h00345413;  //srli x8, x8, 3
        rom[12] = 32'h40335313;  //srai x6, x6, 3
        rom[13] = 32'h40295393;  //srai x7, x18, 2
    end

    assign instr_data = rom[instr_addr[31:2]];

endmodule

