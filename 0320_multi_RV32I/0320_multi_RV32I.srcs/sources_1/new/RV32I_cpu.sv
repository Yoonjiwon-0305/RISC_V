`timescale 1ns / 1ps
`include "define.vh"

module RV32I_cpu (

    input         clk,
    input         reset,
    input  [31:0] instr_data,
    input  [31:0] drdata,
    output [31:0] instr_addr,
    output        dwe,
    output [ 2:0] o_funct3,
    output [31:0] daddr,
    output [31:0] dwdata
);
    logic [2:0] rfwdsrc_sel;
    logic rf_we, alusrc;
    logic [4:0] w_alu_control;
    logic branch;
    logic jal, jalr;
    logic pc_en;


    control_unit U_CONTROL_UNIT (
        .clk        (clk),
        .reset      (reset),
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .pc_en      (pc_en),
        .rf_we      (rf_we),
        .jal        (jal),
        .jalr       (jalr),
        .alusrc     (alusrc),
        .alu_control(w_alu_control),
        .branch     (branch),
        .rfwdsrc_sel(rfwdsrc_sel),
        .o_funct3   (o_funct3),
        .dwe        (dwe)
    );

    RV32I_datapath U_DATAPATH (
        .clk        (clk),
        .reset      (reset),
        .pc_en      (pc_en),
        .rf_we      (rf_we),
        .jal        (jal),
        .jalr       (jalr),
        .alusrc     (alusrc),
        .rfwdsrc_sel(rfwdsrc_sel),
        .alu_control(w_alu_control),
        .branch     (branch),
        .drdata     (drdata),
        .instr_data (instr_data),
        .instr_addr (instr_addr),
        .daddr      (daddr),
        .dwdata     (dwdata)
    );

endmodule


module control_unit (
    input              clk,
    input              reset,
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       pc_en,
    output logic       rf_we,
    output logic       jal,
    output logic       jalr,
    output logic       alusrc,
    output logic [4:0] alu_control,
    output logic       branch,
    output logic [2:0] rfwdsrc_sel,
    output logic [2:0] o_funct3,
    output logic       dwe

);

    typedef enum logic [3:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM,
        WB
    } state_e;

    state_e current_state, next_state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state = FETCH;
        end else begin
            current_state = next_state;
        end
    end


    always_comb begin
        next_state = current_state;
        case (current_state)
            FETCH: begin
                next_state = DECODE;
            end
            DECODE: begin
                next_state = EXECUTE;
            end
            EXECUTE: begin
                case (opcode)
                    `R_TYPE, `II_TYPE, `LUI_TYPE, `AUIPC_TYPE, `JALR_TYPE,`JAL_TYPE:
                    next_state = WB;  // rd에 쓰는 애들
                    `IL_TYPE:
                    next_state = MEM;  // load → 메모리 읽어야 함
                    `S_TYPE:
                    next_state = MEM;  // store → 메모리 써야 함
                    `B_TYPE: next_state = FETCH;  // 레지스터 write 없음
                    default: next_state = FETCH;
                endcase
            end
            MEM: begin
                case (opcode)
                    `IL_TYPE: next_state = WB;  // load → WB 필요
                    `S_TYPE:  next_state = FETCH;  // store → WB 없음
                    default:  next_state = FETCH;
                endcase
            end
            WB: begin
                next_state = FETCH;
            end

        endcase
    end

    //output 
    always_comb begin
        pc_en       = 1'b0;
        rf_we       = 1'b0;
        jal         = 1'b0;
        jalr        = 1'b0;
        alusrc      = 1'b0;
        alu_control = 5'b0_0_000;
        branch      = 1'b0;
        rfwdsrc_sel = 1'b0;
        o_funct3    = 3'b000;
        dwe         = 1'b0;
        case (current_state)
            FETCH: begin
                pc_en = 1'b1;
            end
            DECODE: begin
                pc_en = 1'b0;
            end
            EXECUTE: begin
                case (opcode)
                    `R_TYPE: begin
                        alusrc      = 1'b0;
                        alu_control = {1'b0, funct7[5], funct3};
                    end
                    `II_TYPE: begin
                        alusrc = 1'b1;
                        if (funct3 == 3'b101) begin
                            alu_control = {
                                1'b0, funct7[5], funct3
                            };  // SRA,SRL
                        end else begin
                            alu_control = {1'b0, funct3};
                        end
                    end
                    `B_TYPE: begin
                        branch      = 1'b1;
                        alusrc      = 1'b0;
                        alu_control = {2'b10, funct3};
                    end
                    `S_TYPE: begin
                        alusrc      = 1'b1;
                        alu_control = 5'b0_0_000;
                    end
                    `IL_TYPE: begin
                        alusrc      = 1'b1;
                        alu_control = 5'b0_0_000;
                    end
                    `LUI_TYPE: begin
                        alusrc      = 1'b1;
                        alu_control = 5'b1_1_000;
                    end
                    `AUIPC_TYPE: begin
                        alusrc      = 1'b1;
                        alu_control = 5'b1_1_001;
                    end
                    `JAL_TYPE: begin
                        jal         = 1'b1;
                        jalr        = 1'b0;
                        alusrc      = 1'b1;
                        alu_control = `ADD;
                    end
                    `JALR_TYPE: begin
                        jal         = 1'b1;
                        jalr        = 1'b1;
                        alusrc      = 1'b1;
                        alu_control = `ADD;
                        branch      = 1'b1;
                    end
                endcase
            end
            MEM: begin
                case (opcode)
                    `S_TYPE: begin
                        dwe = 1'b1;
                        o_funct3 = funct3;
                    end
                    `IL_TYPE: begin
                        dwe = 1'b0;
                        o_funct3 = funct3;
                    end
                endcase
            end
            WB: begin
                rf_we = 1'b1;
                case (opcode)
                    `R_TYPE:    rfwdsrc_sel = 3'b000; // ALU 결과
                    `II_TYPE:   rfwdsrc_sel = 3'b000; // ALU 결과
                    `IL_TYPE:   rfwdsrc_sel = 3'b001; // 메모리 읽은 값
                    `LUI_TYPE:  rfwdsrc_sel = 3'b010; // LUI 결과
                    `AUIPC_TYPE:rfwdsrc_sel = 3'b011; // AUIPC 결과
                    `JAL_TYPE: begin
                        rfwdsrc_sel = 3'b100;  // PC+4
                        jal = 1'b1;
                    end

                    `JALR_TYPE: begin
                        rfwdsrc_sel = 3'b100;
                        jal    = 1'b1;  // ← 추가!
                        jalr = 1'b1;  // ← 추가!
                    end  // PC+4    `
                endcase
            end
        endcase
    end

    //     
    //    always_comb begin
    //
    //        rf_we       = 1'b0;
    //        jal         = 1'b0;
    //        jalr        = 1'b0;
    //        alusrc      = 1'b0;
    //        alu_control = 5'b0_0_000;
    //        branch      = 1'b0;
    //        rfwdsrc_sel = 1'b0;
    //        o_funct3    = 3'b000;
    //        dwe         = 1'b0;
    //        case (opcode)
    //            `R_TYPE: begin
    //                rf_we       = 1'b1;
    //                jal         = 1'b0;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b0;
    //                alu_control = {1'b0, funct7[5], funct3};
    //                branch      = 1'b0;
    //                rfwdsrc_sel = 3'b000;
    //                o_funct3    = 3'b000;
    //                dwe         = 1'b0;
    //            end
    //            `S_TYPE: begin
    //                rf_we       = 1'b0;
    //                jal         = 1'b0;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b1;
    //                alu_control = 5'b0_0_000;
    //                branch      = 3'b000;
    //                rfwdsrc_sel = 3'b000;
    //                o_funct3    = funct3;
    //                dwe         = 1'b1;
    //            end
    //            `IL_TYPE: begin
    //                rf_we       = 1'b1;
    //                jal         = 1'b0;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b1;
    //                alu_control = 5'b0_0_000;
    //                branch      = 1'b0;
    //                rfwdsrc_sel = 3'b001;
    //                o_funct3    = funct3;
    //                dwe         = 1'b0;
    //            end
    //            `II_TYPE: begin
    //                rf_we  = 1'b1;
    //                jal    = 1'b0;
    //                jalr   = 1'b0;
    //                alusrc = 1'b1;
    //                if (funct3 == 3'b101) begin
    //                    alu_control = {1'b0, funct7[5], funct3};
    //                end else begin
    //                    alu_control = {1'b0, funct3};
    //                end
    //                branch      = 1'b0;
    //                rfwdsrc_sel = 1'b0;
    //                o_funct3    = funct3;
    //                dwe         = 0;
    //            end
    //            `B_TYPE: begin
    //                rf_we       = 1'b0;
    //                jal         = 1'b0;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b0;
    //                alu_control = {2'b10, funct3};
    //                branch      = 1'b1;
    //                rfwdsrc_sel = 3'b000;
    //                o_funct3    = funct3;
    //                dwe         = 1'b0;
    //            end
    //            `LUI_TYPE: begin
    //                rf_we       = 1'b1;
    //                jal         = 1'b0;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b1;
    //                alu_control = 5'b11000;
    //                branch      = 1'b0;
    //                rfwdsrc_sel = 3'b010;
    //                o_funct3    = 3'b000;
    //                dwe         = 1'b0;
    //            end
    //            `AUIPC_TYPE: begin
    //                rf_we       = 1'b1;
    //                jal         = 1'b0;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b1;
    //                alu_control = `ADD;
    //                branch      = 1'b0;
    //                rfwdsrc_sel = 3'b011;
    //                o_funct3    = 3'b011;
    //                dwe         = 1'b0;
    //            end
    //            `JAL_TYPE: begin
    //                rf_we       = 1'b1;
    //                jal         = 1'b1;
    //                jalr        = 1'b0;
    //                alusrc      = 1'b1;
    //                alu_control = `ADD;
    //                branch      = 1'b1;
    //                rfwdsrc_sel = 3'b100;
    //                o_funct3    = 3'b100;
    //                dwe         = 1'b0;
    //            end
    //            `JALR_TYPE: begin
    //                rf_we       = 1'b1;
    //                jal         = 1'b1;
    //                jalr        = 1'b1;
    //                alusrc      = 1'b1;
    //                alu_control = `ADD;
    //                branch      = 1'b1;
    //                rfwdsrc_sel = 3'b100;
    //                o_funct3    = 3'b100;
    //                dwe         = 1'b0;
    //            end
    //        endcase
    //    end
endmodule
