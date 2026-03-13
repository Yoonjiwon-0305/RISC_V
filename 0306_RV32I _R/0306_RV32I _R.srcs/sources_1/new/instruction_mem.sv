`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:127];

    initial begin

        $readmemh("riscv_rv32i_data.mem", rom);
        //rom[0] = 32'h00208ab3;  //add x21, x1, x2
        //rom[1] = 32'h40328b33;  //sub x22, x5, x3
        //rom[2] = 32'h00219bb3;  //sll x23, x3, x2
        //rom[3] = 32'h0057ac33;  //slt x24, x15, x5
        //rom[4] = 32'h0057bcb3;  //sltu x25, x15, x5
        //rom[5] = 32'h0053cd33;  //xor x26 x7 x5
        //rom[6] = 32'h00385db3;  //srl x27, x16, x3
        //rom[7] = 32'h40385e33;  //sra x28, x16, x3
        //rom[8] = 32'h0064eeb3;  //or x29, x9, x6
        //rom[9] = 32'h00a67f33;  //and x30, x12, x10
    end



    assign instr_data = rom[instr_addr[31:2]];

endmodule



// $readmemh("riscv_rv32i_data.mem",rom);
