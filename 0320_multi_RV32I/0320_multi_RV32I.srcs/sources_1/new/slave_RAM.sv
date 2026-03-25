`timescale 1ns / 1ps

module slave_RAM (

    // BUS Global signal
    input               clk,
    input               reset,
    // APB Interface Signal (Master → Slave)
    input        [31:0] p_addr,
    input        [31:0] p_wdata,
    input               p_en,
    input               p_write,
    input               p_sel,
    input        [ 2:0] p_funct3,
    // APB Interface Signal (Slave → Master)
    output logic [31:0] p_rdata,
    output logic        p_ready
);


    logic        d_dwe;
    logic [31:0] d_addr;
    logic [31:0] d_wdata;
    logic [31:0] d_rdata;

    // combinational
    always_comb begin
        d_dwe   = 1'b0;
        d_addr  = 32'b0;
        d_wdata = 32'b0;
        p_rdata = 32'd0;
        p_ready = 1'b0;
        if (p_sel & p_en) begin
            p_ready = 1'b1;
            if (p_write) begin
                d_dwe   = 1'b1;
                d_addr  = p_addr;
                d_wdata = p_wdata;
            end else begin
                d_addr  = p_addr;
                p_rdata = d_rdata;
            end
        end
    end

    // data_mem 인스턴스
    data_mem U_DATA_MEM (
        .clk     (clk),
        .dwe     (d_dwe),
        .i_funct3(p_funct3),
        .daddr   (d_addr),
        .dwdata  (d_wdata),
        .drdata  (d_rdata)
    );
    //typedef enum logic {
    //    IDLE,
    //    ACCESS
    //} slave_state_e;
    //
    //slave_state_e current_state, next_state;
    //always_ff @(posedge clk, posedge reset) begin
    //    if (reset) begin
    //        current_state <= IDLE;
    //    end else begin
    //        current_state <= next_state;
    //    end
    //end
    //
    //always_comb begin
    //    next_state = current_state;
    //    case (current_state)
    //        IDLE: begin
    //            if (p_en && p_sel) begin
    //                next_state = ACCESS;
    //            end
    //        end
    //        ACCESS: begin
    //            next_state = IDLE;
    //        end
    //    endcase
    //end
    //
    //always_comb begin
    //    d_dwe   = 1'b0;
    //    d_addr  = 32'b0;
    //    d_wdata = 32'b0;
    //    p_rdata = 32'd0;
    //    p_ready = 1'b0;
    //    case (current_state)
    //        IDLE: begin
    //        end
    //        ACCESS: begin
    //            if (p_write) begin  // write
    //                d_dwe   = 1'b1;
    //                d_addr  = p_addr;
    //                d_wdata = p_wdata;
    //                p_rdata = 32'd0;
    //                p_ready = 1'b1;
    //            end else begin  // read
    //                d_dwe   = 1'b0;
    //                d_addr  = p_addr;
    //                d_wdata = 32'b0;
    //                p_rdata = d_rdata;
    //                p_ready = 1'b1;
    //            end
    //        end
    //    endcase
    //end
endmodule
