`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:31];

    initial begin
        rom[0]  = 32'h004182b3;  // ADD 
        rom[1]  = 32'h005201b3;  // SUB
        //rom[2]  = 32'h005201b3;  // SLL
        //rom[3]  = 32'h005201b3;  // SLT
        //rom[4]  = 32'h005201b3;  // SLTU
        //rom[5]  = 32'h005201b3;  // XOR
        //rom[6]  = 32'h005201b3;  // SRL
        //rom[7]  = 32'h005201b3;  // SRA
        //rom[8]  = 32'h005201b3;  // OR
        //rom[9] = 32'h005201b3;  // AND

    end

    assign instr_data = rom[instr_addr[31:2]];

endmodule
