`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:31];

    initial begin

        rom[0] = 32'h00a00093;  // PC 0x00: ADDI x1, x0, 10
        rom[1] = 32'h00c002ef;  // PC 0x04: JAL x5, 12 (Target 0x10)
        rom[2] = 32'h01400313;  // PC 0x08: ADDI x6, x0, 20 (Return Target)
        rom[3] = 32'h00000013;  // PC 0x0C: NOP
        rom[4] = 32'h01400313;  // PC 0x10: ADDI x6, x0, 20 (Jump Target)
        rom[5] = 32'h00028067;  // PC 0x14: JALR x0, x5, 0 (Return to 0x08)


        // 교수님 버전
        //rom[0] = 32'h0041_82b3;  // ADD
        //rom[1] = 32'h0081_2123;  // SUB
        //rom[2] = 32'h0021_2383;  // SLL
        //rom[3] = 32'h0083_8463;  // SLTU
        //rom[4] = 32'h0043_8413;  // SL
        //rom[5] = 32'h0041_82b3;  // XOR
        //rom[6] = 32'h0081_2123;  // SRL

        // rom[0] = 32'h002081b3;
        // rom[1] = 32'h40208233;
        // rom[2] = 32'h00208033;
        // rom[3] = 32'h001122b3;
        // rom[4] = 32'h00122333;
        // rom[5] = 32'h001233b3;
        // rom[6] = 32'h40425433;
        // rom[7] = 32'h004244b3;

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

