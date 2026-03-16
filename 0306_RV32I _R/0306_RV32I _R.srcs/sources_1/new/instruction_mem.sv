`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:127];

    initial begin

        // SB 4번 → mem[0]
        rom[0] = 32'h01400023;  // sb x20, 0(x0)  → mem[0] = xxxx_xx78
        rom[1] = 32'h014000A3;  // sb x20, 1(x0)  → mem[0] = xxxx_5678
        rom[2] = 32'h01400123;  // sb x20, 2(x0)  → mem[0] = xx34_5678
        rom[3] = 32'h014001a3;  // sb x20, 3(x0)  → mem[0] = 1234_5678 ✓

        // SH 2번 → mem[1] (daddr=4,6 → daddr[31:2]=1)
        rom[4] = 32'h01401223;  // sh x20, 4(x0)  → mem[1] = xxxx_5678
        rom[5] = 32'h01401323;  // sh x20, 6(x0)  → mem[1] = 1234_5678 ✓

        // SW 1번 → mem[2] (daddr=8 → daddr[31:2]=2)
        rom[6] = 32'h01402423;  // sw x20, 8(x0)  → mem[2] = 1234_5678 ✓
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
