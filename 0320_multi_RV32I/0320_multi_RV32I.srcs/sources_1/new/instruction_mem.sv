`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:127];

    initial begin

         $readmemh("APB_GPI.mem", rom);

        //R_type instruction
        //rom[0] = 32'h00208ab3;  //add x21 x1,x2
        //rom[1] = 32'h40328b33;  //sub x22, x5, x3
        //rom[2] = 32'h00219bb3;  //sll x23, x3, x2
        //rom[3] = 32'h0057ac33;  //slt x24, x15, x5
        //rom[4] = 32'h0057bcb3;  //sltu x25, x15, x5
        //rom[5] = 32'h0053cd33;  //xor x26, x7, x5
        //rom[6] = 32'h00385db3;  //srl x27, x16, x3
        //rom[7] = 32'h40385e33;  //sra x28, x16, x3
        //rom[8] = 32'h0064eeb3;  //or x29, x9, x6
        //rom[9] = 32'h00a67f33;  //and x30, x12, x10

        // B_type instruction
        //rom[0]  = 32'h00208463;  //beq x1, x2, +8    → rom[2] (실패→rom[1])
        //rom[1] = 32'h00150513;  //addi x10, x10, 1  (+1)
        //rom[2]  = 32'h00108463;  //beq x1, x1, +8    → rom[4] (성공→건너뜀)
        //rom[3] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[4]  = 32'h00109463;  //bne x1, x1, +8    → rom[6] (실패→rom[5])
        //rom[5] = 32'h00150513;  //addi x10, x10, 1  (+1)
        //rom[6]  = 32'h00209463;  // bne x1, x2, +8  → rom[8] (성공→건너뜀)
        //rom[7] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[8]  = 32'h00F1C463;  //blt x3, x15, +8   → rom[10] (실패→rom[9])
        //rom[9] = 32'h00150513;  //addi x10, x10, 1  (+1)
        //rom[10] = 32'h00378463;  //blt x15, x3, +8   → rom[12] (성공→건너뜀)
        //rom[11] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[12] = 32'h00F1D463;  //bge x3, x15, +8   → rom[14] (실패→rom[13])
        //rom[13] = 32'h00150513;  //addi x10, x10, 1  (+1)
        //rom[14] = 32'h0037D463;  //bge x15, x3, +8   → rom[16] (성공→건너뜀)
        //rom[15] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[16] = 32'h0031D463;  //bge x3, x3, +8    → rom[18] (성공→건너뜀)
        //rom[17] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[18] = 32'h00F1E463;  //bltu x3, x15, +8  → rom[20] (실패→rom[19])
        //rom[19] = 32'h00150513;  //addi x10, x10, 1  (+1)
        //rom[20] = 32'h00F1F463;  //bgeu x3, x15, +8  → rom[22] (성공→건너뜀)
        //rom[21] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[22] = 32'h0037F463;  //bgeu x15, x3, +8  → rom[24] (성공→건너뜀)
        //rom[23] = 32'h00150513;  //addi x10, x10, 1  (건너뜀)
        //rom[24] = 32'h00A50513;  //addi x10, x10, 10 (최종 +10)

        // S_type instruction 
        //rom[0] = 32'h01400023;  // sb x20, 0(x0)  → mem[0] = xxxx_xx78
        //rom[1] = 32'h014000A3;  // sb x20, 1(x0)  → mem[0] = xxxx_5678
        //rom[2] = 32'h01400123;  // sb x20, 2(x0)  → mem[0] = xx34_5678
        //rom[3] = 32'h014001a3;  // sb x20, 3(x0)  → mem[0] = 1234_5678       
        //rom[4] = 32'h01401223;  // sh x20, 4(x0)  → mem[1] = xxxx_5678
        //rom[5] = 32'h01401323;  // sh x20, 6(x0)  → mem[1] = 1234_5678
        //rom[6] = 32'h01402423;  // sw x20, 8(x0)  → mem[2] = 1234_5678 

        //II_TYPE instruction
        //rom[0] = 32'h00508513;  //addi x10, x1, 5
        //rom[1] = 32'h0057a513;  //slti x10, x15, 5
        //rom[2] = 32'h0057b513;  //sltiu x10, x15, 5
        //rom[3] = 32'h0053c513;  //xori x10, x7, 5
        //rom[4] = 32'h0053e513;  //ori x10, x7, 5
        //rom[5] = 32'h0053f513;  //andi x10, x7, 5
        //rom[6] = 32'h00209513;  //slli x10, x1, 2
        //rom[7] = 32'h0027d513;  //srli x10, x15, 2
        //rom[8] = 32'h4027d513;  //srai x10, x15, 2

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

        //U_type instruction
        //rom[0] = 32'h12345537;  //lui x10, 0x12345
        //rom[1] = 32'h67850513;  //addi x10, x10, 0x678
        //rom[2] = 32'h00001517;  //auipc x10, 1
        //rom[3] = 32'h00001517;  //auipc x10, 1

        //J_type instruction
        //rom[0] = 32'h00c000ef;  //jal x1, 12
        //rom[1] = 32'h002202b3;  //add x5, x4, x2
        //rom[2] = 32'h0000006f;  //jal x0, 0
        //rom[3] = 32'h003282b3;  //add x5, x5, x3
        //rom[4] = 32'h000080e7;  //jalr x1, 0(x1)
    end



    assign instr_data = rom[instr_addr[31:2]];

endmodule



// $readmemh("riscv_rv32i_data.mem",rom);

/* slave_apb_GPO
<c code>
//void delay (int delay);

void main(void) {
    *(unsigned int*) 0x10000000 =0x00000041;
    *(unsigned int*) 0x20000000 =0x0000ffff; //gpo_ctl_reg
    *(unsigned int*) 0x20000004 =0x0000AAAA; //gpo_data_reg
    *(unsigned int*) 0x20000004 =0x00005555; //gpo_data_reg
    *(unsigned int*) 0x20000000 =0x00000000; //gpo_ctl_reg
    return ;
}

//void delay(int delay) {
//    delay = delay * 10000000;
//    while(delay){
//        delay --;
//    }
//    return;
//}

<online assembly>
li sp,268435456
addi sp,sp, 1024
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16
        li      a5,268435456
        li      a4,65
        sw      a4,0(a5)
        li      a5,536870912
        li      a4,65536
        addi    a4,a4,-1
        sw      a4,0(a5)
        li      a5,536870912
        addi    a5,a5,4
        li      a4,45056
        addi    a4,a4,-1366
        sw      a4,0(a5)
        li      a5,536870912
        addi    a5,a5,4
        li      a4,20480
        addi    a4,a4,1365
        sw      a4,0(a5)
        li      a5,536870912
        sw      zero,0(a5)
        nop
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
        jr      ra
< hex code >
10000137
40010113
ff010113
00112623
00812423
01010413
100007b7
04100713
00e7a023
200007b7
00010737
fff70713
00e7a023
200007b7
00478793
0000b737
aaa70713
00e7a023
200007b7
00478793
00005737
55570713
00e7a023
200007b7
0007a023
00000013
00c12083
00812403
01010113
00008067
*/

/*/GPI
//void delay (int delay);

void main(void) {
    int i = 0;
    //RAM write test
    *(unsigned int*) 0x10000000 =0x00000041;
    //RAM read test
    i = *(unsigned int *) 0x10000000;
    // GPO write test
    *(unsigned int*) 0x20000000 =0x0000ffff; //gpo_ctl_reg
    *(unsigned int*) 0x20000004 =0x0000AAAA; //gpo_data_reg
    *(unsigned int*) 0x20000004 =0x00005555; //gpo_data_reg
    *(unsigned int*) 0x20000000 =0x00000000; //gpo_ctl_reg
    // GPI read test
    *(unsigned int*) 0x20001000 =0x0000ffff; //gpo_ctl_reg
    i = *(unsigned int *) 0x20001004;
    return ;
}

//void delay(int delay) {
//    delay = delay * 10000000;
//    while(delay){
//        delay --;
//    }
//    return;
//}

<c code>
li sp,268435456
addi sp,sp, 1024
main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      zero,-20(s0)
        li      a5,268435456
        li      a4,65
        sw      a4,0(a5)
        li      a5,268435456
        lw      a5,0(a5)
        sw      a5,-20(s0)
        li      a5,536870912
        li      a4,65536
        addi    a4,a4,-1
        sw      a4,0(a5)
        li      a5,536870912
        addi    a5,a5,4
        li      a4,45056
        addi    a4,a4,-1366
        sw      a4,0(a5)
        li      a5,536870912
        addi    a5,a5,4
        li      a4,20480
        addi    a4,a4,1365
        sw      a4,0(a5)
        li      a5,536870912
        sw      zero,0(a5)
        li      a5,536875008
        li      a4,65536
        addi    a4,a4,-1
        sw      a4,0(a5)
        li      a5,536875008
        addi    a5,a5,4
        lw      a5,0(a5)
        sw      a5,-20(s0)
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra

<hex code>
10000137
40010113
fe010113
00112e23
00812c23
02010413
fe042623
100007b7
04100713
00e7a023
100007b7
0007a783
fef42623
200007b7
00010737
fff70713
00e7a023
200007b7
00478793
0000b737
aaa70713
00e7a023
200007b7
00478793
00005737
55570713
00e7a023
200007b7
0007a023
200017b7
00010737
fff70713
00e7a023
200017b7
00478793
0007a783
fef42623
00000013
01c12083
01812403
02010113
00008067

*/