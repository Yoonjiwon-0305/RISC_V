`timescale 1ns / 1ps
`include "define.vh"

module RV32I_datapath (
    input         clk,
    input         reset,
    input         rf_we,
    input         alusrc,
    input         rfwdsrc_sel,
    input  [ 3:0] alu_control,
    input  [31:0] instr_data,
    input  [31:0] drdata,
    output [31:0] instr_addr,
    output [31:0] daddr,
    output [31:0] dwdata
);
    logic [31:0]
        w_alu_result, w_rd1, w_rd2, w_imm_data, w_alurs2_data, w_wb_result;
    assign daddr  = w_alu_result;
    assign dwdata = w_rd2;

    program_counter U_PC (
        .clk(clk),
        .reset(reset),
        .pc(instr_addr)
    );


    register_file U_REGISTER_FILE (
        .clk(clk),
        .reset(reset),
        .RA1(instr_data[19:15]),
        .RA2(instr_data[24:20]),
        .WA(instr_data[11:7]),
        .wdata(w_wb_result),
        .rf_we(rf_we),
        .rd1(w_rd1),
        .rd2(w_rd2)
    );

    imm_extender U_IMM_EX (
        .instr_data(instr_data[31:0]),
        .imm_out(w_imm_data)

    );

    mux_2x1 U_MUX_ALUSRC_RS2 (
        .in0    (w_rd2),         //sel0
        .in1    (w_imm_data),    //sel1
        .mux_sel(alusrc),
        .out_mux(w_alurs2_data)
    );

    alu U_RF_ALU (
        .rd1(w_rd1),
        .rd2(w_alurs2_data),
        .alu_control(alu_control),
        .alu_result(w_alu_result)
    );
    mux_2x1 U_WB_REGFILE (
        .in0    (w_alu_result),  //sel0
        .in1    (drdata),        //sel1
        .mux_sel(rfwdsrc_sel),
        .out_mux(w_wb_result)
    );


endmodule

module mux_2x1 (
    input        [31:0] in0,      //sel0
    input        [31:0] in1,      //sel1
    input               mux_sel,
    output logic [31:0] out_mux
);

    assign out_mux = (mux_sel) ? in1 : in0;

endmodule

module imm_extender (
    input        [31:0] instr_data,
    output logic [31:0] imm_out

);

    always_comb begin
        imm_out = 32'd0;
        case (instr_data[6:0])
            `S_TYPE: begin
                imm_out = {
                    {20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]
                };
            end
            `IL_TYPE, `II_TYPE: begin
                imm_out = {{20{instr_data[31]}}, instr_data[31:20]};
            end
        endcase
    end
endmodule


module register_file (
    input         clk,
    input         reset,
    input  [ 4:0] RA1,
    input  [ 4:0] RA2,
    input  [ 4:0] WA,
    input  [31:0] wdata,
    input         rf_we,
    output [31:0] rd1,
    output [31:0] rd2
);
    logic [31:0] rf_reg[0:31];

`ifdef SIMULATION
    initial begin
        for (int i = 1; i < 32; i++) begin
            rf_reg[i] = i;
        end
        rf_reg[27] = -16;
    end
`endif

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            //x0 must have zero
            rf_reg[0] <= 32'd0;
        end else begin
            if (rf_we && (WA != 5'd0)) begin
                rf_reg[WA] <= wdata;
            end
        end
    end

    assign rd1 = (RA1 != 0) ? rf_reg[RA1] : 0;
    assign rd2 = (RA2 != 0) ? rf_reg[RA2] : 0;
endmodule

module alu (
    input        [31:0] rd1,
    input        [31:0] rd2,
    input        [ 3:0] alu_control,
    output logic [31:0] alu_result
);

    always_comb begin
        alu_result = 0;
        case (alu_control)
            `ADD: alu_result = rd1 + rd2;  //ADD

            `SUB: alu_result = rd1 - rd2;  //SUB

            `SLL: alu_result = rd1 << rd2[4:0];  //SLL

            `SLT: alu_result = ($signed(rd1) < $signed(rd2)) ? 1 : 0;  //SLT

            `SLTU: alu_result = (rd1 < rd2) ? 1 : 0;  //`SLTU

            `XOR: alu_result = rd1 ^ rd2;  //`XOR

            `SRL: alu_result = rd1 >> rd2[4:0];  //`SRL

            `SRA: alu_result = $signed(rd1) >>> rd2[4:0];  //`SRA

            `OR: alu_result = rd1 | rd2;  //`OR

            `AND: alu_result = rd1 & rd2;  //`AND

        endcase

    end

endmodule

module program_counter (
    input               clk,
    input               reset,
    output logic [31:0] pc
);

    logic [31:0] w_pc_alu_result;
    logic [31:0] w_next_pc;
    assign w_next_pc = (reset) ? 32'd0 : w_pc_alu_result;

    register U_PC_REGISTER (
        .clk(clk),
        .reset(reset),
        .data_in(w_next_pc),
        .data_out(pc)
    );

    pc_alu U_PC_ALU (
        .a(32'd4),
        .b(pc),
        .pc_alu_out(w_pc_alu_result)
    );

endmodule

module register (
    input         clk,
    input         reset,
    input  [31:0] data_in,
    output [31:0] data_out
);
    logic [31:0] register;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            register <= 0;
        end else begin
            register <= data_in;
        end
    end
    assign data_out = register;
endmodule

module pc_alu (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] pc_alu_out
);
    assign pc_alu_out = a + b;

endmodule
