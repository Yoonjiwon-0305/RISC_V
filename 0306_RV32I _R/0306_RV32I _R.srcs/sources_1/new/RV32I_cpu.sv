`timescale 1ns / 1ps

module RV32I_cpu (

    input clk,
    input reset,
    input [31:0] instr_addr,
    input [31:0] instr_data

);

    logic w_rf_we;
    logic [31:0] rd1, rd2, w_alu_result, w_pc_alu_result;
    logic [3:0] w_alu_control;

    control_unit U_CONTROL_UNIT (
        .clk        (clk),
        .reset      (reset),
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .rf_we      (w_rf_we),
        .alu_control(w_alu_control)
    );

    register_file U_REG_FILE (
        .clk  (clk),
        .reset(reset),
        .RA1  (instr_data[19:15]),
        .RA2  (instr_data[24:20]),
        .WA   (instr_data[11:7]),
        .wdata(w_alu_result),
        .rf_we(w_rf_we),
        .RD1  (rd1),
        .RD2  (rd2)
    );

    alu U_ALU (
        .rd1(rd1),
        .rd2(rd2),
        .alu_control(w_alu_control),
        .alu_result(w_alu_result)
    );

    alu U_PC_ALU (
        .rd1(32'd4),
        .rd2(instr_addr),
        .alu_control(4'd0),
        .alu_result(w_pc_alu_result)
    );

    pc U_PC (
        .clk(clk),
        .reset(reset),
        .next_pc(w_pc_alu_result),
        .pc(instr_addr)
    );
endmodule

module register_file (
    input         clk,
    input         reset,
    input  [ 4:0] RA1,
    input  [ 4:0] RA2,
    input  [ 4:0] WA,
    input  [31:0] wdata,
    input         rf_we,
    output [31:0] RD1,
    output [31:0] RD2
);
    logic [31:0] rf_reg[0:31];

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i = i + 1) begin
                rf_reg[i] <= 32'd0;
            end
        end else if (rf_we && (WA != 5'd0)) begin
            rf_reg[WA] <= wdata;
        end
    end

    assign RD1 = (RA1 == 5'd0) ? 32'd0 : rf_reg[RA1];
    assign RD2 = (RA2 == 5'd0) ? 32'd0 : rf_reg[RA2];
endmodule

module control_unit (
    input              clk,
    input              reset,
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       rf_we,
    output logic [3:0] alu_control
);
    always_comb begin
        rf_we       = 1'b0;
        alu_control = 4'b000;

        case (opcode)
            7'b0110011: begin  // 명령어 R 타입
                rf_we = 1'b1;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000) begin
                            alu_control = 4'd0;  //rd1 + rd2
                        end else if (funct7 == 7'b0100000) begin
                            alu_control = 4'd1;  //rd1 - rd2
                        end
                    end
                    3'b001: begin
                        alu_control = 4'd2;  //rd1 << rd2[4:0]
                    end
                    3'b010: begin
                        alu_control = 4'd3; //($signed(rd1) < $signed(rd2)) ? 32'd1 : 32'd0
                    end
                    3'b011: begin
                        alu_control = 4'd4;  //(rd1 < rd2) ? 32'd1 : 32'd0
                    end
                    3'b100: begin
                        alu_control = 4'd5;  //rd1 ^ rd2
                    end
                    3'b101: begin
                        if (funct7 == 7'b0000000) begin
                            alu_control = 4'd6;  // rd1 >> rd2[4:0]
                        end else if (funct7 == 7'b0100000) begin
                            alu_control = 4'd7;  //$signed(rd1) >>> rd2[4:0]
                        end
                    end
                    3'b110: begin
                        alu_control = 4'd8;  //rd1 | rd2
                    end
                    3'b111: begin
                        alu_control = 4'd9;  //rd1 & rd2
                    end
                    default: alu_control = 4'd0;
                endcase
            end
        endcase
    end
endmodule

module alu (
    input [31:0] rd1,
    input [31:0] rd2,
    input [3:0] alu_control,
    output logic [31:0] alu_result
);

    always_comb begin
        case (alu_control)
            4'd0: begin
                alu_result = rd1 + rd2;
            end
            4'd1: begin
                alu_result = rd1 - rd2;
            end
            4'd2: begin
                alu_result = rd1 << rd2[4:0];
            end
            4'd3: begin
                alu_result = ($signed(rd1) < $signed(rd2)) ? 32'd1 : 32'd0;
            end
            4'd4: begin
                alu_result = (rd1 < rd2) ? 32'd1 : 32'd0;
            end
            4'd5: begin
                alu_result = rd1 ^ rd2;
            end
            4'd6: begin
                alu_result = rd1 >> rd2[4:0];
            end
            4'd7: begin
                alu_result = $signed(rd1) >>> rd2[4:0];
            end
            4'd8: begin
                alu_result = rd1 | rd2;
            end
            4'd9: begin
                alu_result = rd1 & rd2;
            end
            default: alu_result = 32'd0;
        endcase

    end

endmodule

module pc (
    input               clk,
    input               reset,
    input        [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            pc <= 0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule
