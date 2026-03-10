`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:31];

    initial begin
        

        rom[0]  = 32'h00e6_87b3;  // ADD
        rom[1]  = 32'h00e6_87b3;  // SUB
        rom[2]  = 32'h00e6_87b3;  // SLL
        rom[3]  = 32'h00e6_87b3;  // SLT
        rom[4]  = 32'h00e6_87b3;  // SLTU
        rom[5]  = 32'h00e6_87b3;  // XOR
        rom[6]  = 32'h00e6_87b3;  // SRL
        rom[7]  = 32'h00e6_87b3;  // SRA
        rom[8]  = 32'h00e6_87b3;  // OR
        rom[9]  = 32'h00e6_87b3;  // AND
        rom[10] = 32'h00e6_87b3;  // SB
        rom[11] = 32'h00e6_87b3;  // SH
        rom[12] = 32'h00e6_87b3;  // SW
        rom[13] = 32'h00e6_87b3;  // LB
        rom[14] = 32'h00e6_87b3;  // LH
        rom[15] = 32'h00e6_87b3;  // LW
        rom[16] = 32'h00e6_87b3;  // LBU
        rom[17] = 32'h00e6_87b3;  // LHU
        rom[18] = 32'h00e6_87b3;  // ADDI
        rom[19] = 32'h00e6_87b3;  // SLTI
        rom[20] = 32'h00e6_87b3;  // SLTUI
        rom[21] = 32'h00e6_87b3;  // XORI
        rom[22] = 32'h00e6_87b3;  // ORI
        rom[23] = 32'h00e6_87b3;  // ANDI
        rom[24] = 32'h00e6_87b3;  // SLLI
        rom[25] = 32'h00e6_87b3;  // SRLI
        rom[26] = 32'h00e6_87b3;  // SRAI

    end

    assign instr_data = rom[instr_addr[31:2]];

endmodule
// rom[0] = 32'h00e6_87b3;  // ADD : 14+13=27(x15)
        // rom[1] = 32'h0081_2123;  // SW  x2,2(x8) ,SW x2,x8,2
        // rom[2] = 32'h0021_2383;  // LW x7 ,x2,2
        // rom[3] = 32'h0043_8413;  // ADDi 18 x7 4
        // rom[1] = 32'h40cf_8eb3;  // SUB : 31-12=19(x29)
        // rom[2] = 32'h0021_9433;  // SLL : 3 << 2 (x8)
        // rom[3] = 32'h00b2_a533;  // SLT : (5 < 11)? 1 : 0 =1 (x10)
        // rom[4] = 32'h007f_3e33;  // SLTU : (30 < 7)? 1 : 0 =0 (x28)
        // rom[5] = 32'h006c_cd33;  // XOR : 25 ^ 6 = 31 (x26)
        // rom[6] = 32'h001c_5ab3;  // SRL : 24 >> 1 = 12 (x21)
        // rom[7] = 32'h404d_d8b3;  // SRA:  -16 >> 4 = -1 (x17)
        // rom[8] = 32'h009a_6933;  // OR : 20 | 9 = 15 (x18)
        // rom[9] = 32'h017b_79b3;  // AND : 22 & 23 = 16 (x19)