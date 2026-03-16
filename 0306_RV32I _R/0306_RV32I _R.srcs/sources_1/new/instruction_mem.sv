`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:127];

    initial begin

        $readmemh("riscv_rv32i_data.mem", rom);

        // S_type instruction 
        //rom[0] = 32'h01400023;  // sb x20, 0(x0)  → mem[0] = xxxx_xx78
        //rom[1] = 32'h014000A3;  // sb x20, 1(x0)  → mem[0] = xxxx_5678
        //rom[2] = 32'h01400123;  // sb x20, 2(x0)  → mem[0] = xx34_5678
        //rom[3] = 32'h014001a3;  // sb x20, 3(x0)  → mem[0] = 1234_5678       
        //rom[4] = 32'h01401223;  // sh x20, 4(x0)  → mem[1] = xxxx_5678
        //rom[5] = 32'h01401323;  // sh x20, 6(x0)  → mem[1] = 1234_5678
        //rom[6] = 32'h01402423;  // sw x20, 8(x0)  → mem[2] = 1234_5678 

        //IL_type instruction
        //rom[0]  = 32'h01402023;  //sw x20, 0(x0)
        //rom[1]  = 32'h00000503;  //lb x10, 0(x0)
        //rom[2]  = 32'h00100503;  //lb x10, 1(x0)
        //rom[3]  = 32'h00200503;  //lb x10, 2(x0)
        //rom[4]  = 32'h00300503;  //lb x10, 3(x0)
        //rom[5]  = 32'h00004583;  //lbu x11, 0(x0)
        //rom[6]  = 32'h00104583;  //lbu x11, 1(x0)
        //rom[7]  = 32'h00204583;  //lbu x11, 2(x0)
        //rom[8]  = 32'h00304583;  //lbu x11, 3(x0)
        //rom[9]  = 32'h00001603;  //lh x12, 0(x0)
        //rom[10] = 32'h00201603;  //lh x12, 2(x0)
        //rom[11] = 32'h00005683;  //lhu x13, 0(x0)
        //rom[12] = 32'h00205683;  //lhu x13, 2(x0)
        //rom[13] = 32'h00002703;  //lw x14, 0(x0)
    end



    assign instr_data = rom[instr_addr[31:2]];

endmodule



// $readmemh("riscv_rv32i_data.mem",rom);
// rom[0] = 32'h00c000ef;  //jal x1, 12
// rom[1] = 32'h002202b3;  //add x5, x4, x2
// rom[2] = 32'h0000006f;  //jal x0, 0
// rom[3] = 32'h003282b3;  //add x5, x5, x3
// rom[4] = 32'h000080e7;  //jalr x1, 0(x1)


//S_type
// SB 4번 → mem[0]
//       rom[0] = 32'h01400023;  // sb x20, 0(x0)  → mem[0] = xxxx_xx78
//       rom[1] = 32'h014000A3;  // sb x20, 1(x0)  → mem[0] = xxxx_5678
//       rom[2] = 32'h01400123;  // sb x20, 2(x0)  → mem[0] = xx34_5678
//       rom[3] = 32'h014001a3;  // sb x20, 3(x0)  → mem[0] = 1234_5678 ✓
//
//       // SH 2번 → mem[1] (daddr=4,6 → daddr[31:2]=1)
//       rom[4] = 32'h01401223;  // sh x20, 4(x0)  → mem[1] = xxxx_5678
//       rom[5] = 32'h01401323;  // sh x20, 6(x0)  → mem[1] = 1234_5678 ✓
//
//       // SW 1번 → mem[2] (daddr=8 → daddr[31:2]=2)
//       rom[6] = 32'h01402423;  // sw x20, 8(x0)  → mem[2] = 1234_5678 ✓
