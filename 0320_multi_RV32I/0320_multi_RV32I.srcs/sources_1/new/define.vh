
// 
//`define SIMULATION 

//opcode
`define R_TYPE 7'b011_0011
`define S_TYPE 7'b010_0011
`define IL_TYPE 7'b000_0011
`define II_TYPE 7'b001_0011
`define B_TYPE 7'b110_0011
`define LUI_TYPE 7'b011_0111
`define AUIPC_TYPE 7'b001_0111
`define JAL_TYPE 7'b110_1111
`define JALR_TYPE 7'b110_0111

//R-TYPE instruction
`define ADD 5'b0_0_000 
`define SUB 5'b0_1_000 
`define SLL 5'b0_0_001 
`define SLT 5'b0_0_010 
`define SLTU 5'b0_0_011 
`define XOR 5'b0_0_100 
`define SRL 5'b0_0_101 
`define SRA 5'b0_1_101 
`define OR 5'b0_0_110 
`define AND 5'b0_0_111 

//B-TYPE instruction
`define BEQ 5'b1_0_000
`define BNE 5'b1_0_001
`define BLT 5'b1_0_100
`define BGE 5'b1_0_101
`define BLTU 5'b1_0_110
`define BGEU 5'b1_0_111

//S-TYPE instruction
`define SB 3'b000
`define SH 3'b001
`define SW 3'b010
//IL-TYPE instruction
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

// LUI
`define LUI 5'b1_1_000
//AUIPC
`define AUIPC 5'b1_1_001
