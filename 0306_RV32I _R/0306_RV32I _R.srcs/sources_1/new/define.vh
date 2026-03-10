
// 
`define SIMULATION 

//opcode
`define R_TYPE 7'b011_0011
`define S_TYPE 7'b010_0011
`define IL_TYPE 7'b000_0011
`define II_TYPE 7'b001_0011

`define SB 3'b000
`define SH 3'b001
`define SW 3'b010
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101
//R-TYPE instruction
`define ADD 4'b0_000 //0
`define SUB 4'b1_000 //8
`define SLL 4'b0_001 //1
`define SLT 4'b0_010 //2
`define SLTU 4'b0_011 //3
`define XOR 4'b0_100 //4
`define SRL 4'b0_101 //5
`define SRA 4'b1_101 //d
`define OR 4'b0_110 //6
`define AND 4'b0_111 //7
