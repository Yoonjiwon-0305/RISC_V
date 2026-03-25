`timescale 1ns / 1ps

module APB_master (

    // 상단 구간 input
    // Bus Global signal
    input               p_clk,
    input               p_reset,
    // soc internal signal with cpu
    input        [31:0] addr,
    input        [31:0] wdata,
    input               w_req,    // signal cpu : dwe
    input               r_req,    // signal cpu : dre
    // 상단 구간 output
    // apb interface signal
    output logic [31:0] p_addr,   //need register
    output logic [31:0] p_wdata,  //need register
    output logic        p_en,     //공통
    output logic        p_write,  //공통 
    output logic        p_sel_0,  //RAM
    output logic        p_sel_1,  //GPO
    output logic        p_sel_2,  //GPI
    output logic        p_sel_3,  //GPIO
    output logic        p_sel_4,  //FND
    output logic        p_sel_5,  //UART

    //하단 구간 input 
    input [31:0] p_rdata_0,  //RAM
    input [31:0] p_rdata_1,  //GPO
    input [31:0] p_rdata_2,  //GPI
    input [31:0] p_rdata_3,  //GPIO
    input [31:0] p_rdata_4,  //FND
    input [31:0] p_rdata_5,  //UART
    input        p_ready_0,  //RAM
    input        p_ready_1,  //GPO
    input        p_ready_2,  //GPI
    input        p_ready_3,  //GPIO
    input        p_ready_4,  //FND
    input        p_ready_5,  //UART

    //하단 구간 output
    output [31:0] rdata,
    output        ready

);

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e current_state, next_state;

    logic [31:0] p_addr_next, p_wdata_next;
    logic p_write_next;
    logic decode_en;

    // FSM 상태 레지스터
    always_ff @(posedge p_clk, posedge p_reset) begin
        if (p_reset) begin
            current_state <= IDLE;
            p_addr        <= 32'd0;
            p_wdata       <= 32'd0;
            p_write       <= 1'b0;
        end else begin
            current_state <= next_state;
            p_addr        <= p_addr_next;
            p_wdata       <= p_wdata_next;
            p_write       <= p_write_next;
        end
    end

    //다음 상태 
    always_comb begin
        next_state   = current_state;
        decode_en    = 1'b0;
        p_en         = 1'b0;
        p_write_next = p_write;
        p_addr_next  = p_addr;
        p_wdata_next = p_wdata;
        case (current_state)
            IDLE: begin
                decode_en    = 0;
                p_en         = 0;
                p_write_next = 1'b0;
                p_addr_next  = 32'd0;
                p_wdata_next = 32'd0;
                if (w_req | r_req) begin
                    p_addr_next  = addr;
                    p_wdata_next = wdata;
                    if (w_req) begin
                        p_write_next = 1;
                    end else begin
                        p_write_next = 0;
                    end
                    next_state = SETUP;
                end
            end
            SETUP: begin
                decode_en  = 1;
                p_en       = 0;
                next_state = ACCESS;
            end
            ACCESS: begin
                decode_en = 1;
                p_en      = 1;
                //if(p_ready_0 | p_ready_1 | p_ready_2 | p_ready_3 | p_ready_4 | p_ready_5);
                if (ready) begin
                    next_state = IDLE;
                end
            end
        endcase

    end

    address_decoder U_APB_DECODER (
        .en     (decode_en),
        .addr   (p_addr),
        .p_sel_0(p_sel_0),    //RAM
        .p_sel_1(p_sel_1),    //GPO
        .p_sel_2(p_sel_2),    //GPI
        .p_sel_3(p_sel_3),    //GPIO
        .p_sel_4(p_sel_4),    //FND
        .p_sel_5(p_sel_5)     //UART
    );

    mux_6x1 U_APB_MUX (

        .sel_addr (p_addr),
        .p_rdata_0(p_rdata_0),  //RAM
        .p_rdata_1(p_rdata_1),  //GPO
        .p_rdata_2(p_rdata_2),  //GPI
        .p_rdata_3(p_rdata_3),  //GPIO
        .p_rdata_4(p_rdata_4),  //FND
        .p_rdata_5(p_rdata_5),  //UART
        .p_ready_0(p_ready_0),  //RAM
        .p_ready_1(p_ready_1),  //GPO
        .p_ready_2(p_ready_2),  //GPI
        .p_ready_3(p_ready_3),  //GPIO
        .p_ready_4(p_ready_4),  //FND
        .p_ready_5(p_ready_5),  //UART
        .rdata    (rdata),
        .ready    (ready)

    );

endmodule

module address_decoder (
    input               en,
    input        [31:0] addr,
    output logic        p_sel_0,  //RAM
    output logic        p_sel_1,  //GPO
    output logic        p_sel_2,  //GPI
    output logic        p_sel_3,  //GPIO
    output logic        p_sel_4,  //FND
    output logic        p_sel_5   //UART
);

    // teach way
    always_comb begin
        p_sel_0 = 1'b0;  // idle : 0
        p_sel_1 = 1'b0;  // idle : 0
        p_sel_2 = 1'b0;  // idle : 0
        p_sel_3 = 1'b0;  // idle : 0
        p_sel_4 = 1'b0;  // idle : 0
        p_sel_5 = 1'b0;  // idle : 0
        if (en) begin
            case (addr[31:28])
                4'h1: begin
                    p_sel_0 = 1'b1;
                end
                4'h2: begin
                    case (addr[14:12])
                        3'h0: begin
                            p_sel_1 = 1'b1;
                        end
                        3'h1: begin
                            p_sel_2 = 1'b1;
                        end
                        3'h2: begin
                            p_sel_3 = 1'b1;
                        end
                        3'h3: begin
                            p_sel_4 = 1'b1;
                        end
                        3'h4: begin
                            p_sel_5 = 1'b1;
                        end
                    endcase
                end

            endcase
        end
    end

    // 조합 CL 
    // my way
    //assign p_sel_0 = (addr[31:12] == 20'h10000);  //RAM
    //assign p_sel_1 = (addr[31:12] == 20'h20000);  //GPO
    //assign p_sel_2 = (addr[31:12] == 20'h20001);  //GPI
    //assign p_sel_3 = (addr[31:12] == 20'h20002);  //GPIO
    //assign p_sel_4 = (addr[31:12] == 20'h20003);  //FND
    //assign p_sel_5 = (addr[31:12] == 20'h20004);  //UART

endmodule

module mux_6x1 (

    input        [31:0] sel_addr,
    input        [31:0] p_rdata_0,  //RAM
    input        [31:0] p_rdata_1,  //GPO
    input        [31:0] p_rdata_2,  //GPI
    input        [31:0] p_rdata_3,  //GPIO
    input        [31:0] p_rdata_4,  //FND
    input        [31:0] p_rdata_5,  //UART
    input               p_ready_0,  //RAM
    input               p_ready_1,  //GPO
    input               p_ready_2,  //GPI
    input               p_ready_3,  //GPIO
    input               p_ready_4,  //FND
    input               p_ready_5,  //UART
    output logic [31:0] rdata,
    output logic        ready

);
    //teach way
    always_comb begin
        rdata = 32'h0000_0000;
        ready = 1'b0;
        case (sel_addr[31:28])
            4'h1: begin
                rdata = p_rdata_0;
                ready = p_ready_0;
            end
            4'h2: begin
                case (sel_addr[14:12])
                    3'h0: begin
                        rdata = p_rdata_1;
                        ready = p_ready_1;
                    end
                    3'h1: begin
                        rdata = p_rdata_2;
                        ready = p_ready_2;
                    end
                    3'h2: begin
                        rdata = p_rdata_3;
                        ready = p_ready_3;
                    end
                    3'h3: begin
                        rdata = p_rdata_4;
                        ready = p_ready_4;
                    end
                    3'h4: begin
                        rdata = p_rdata_5;
                        ready = p_ready_5;
                    end
                endcase
            end
            default: begin
                rdata = 32'd0;
                ready = 1'b0;
            end
        endcase
    end

    // my way
    //always_comb begin
    //    rdata = 32'h0000_0000;
    //    ready = 1'b0;
    //    case (sel_addr[31:12])
    //        20'h10000: begin
    //            rdata = p_rdata_0;
    //            ready = p_ready_0;
    //        end
    //        20'h20000: begin
    //            rdata = p_rdata_1;
    //            ready = p_ready_1;
    //        end
    //        20'h20001: begin
    //            rdata = p_rdata_2;
    //            ready = p_ready_2;
    //        end
    //        20'h20002: begin
    //            rdata = p_rdata_3;
    //            ready = p_ready_3;
    //        end
    //        20'h20003: begin
    //            rdata = p_rdata_4;
    //            ready = p_ready_4;
    //        end
    //        20'h20004: begin
    //            rdata = p_rdata_5;
    //            ready = p_ready_5;
    //        end
    //    endcase
    //end
endmodule
