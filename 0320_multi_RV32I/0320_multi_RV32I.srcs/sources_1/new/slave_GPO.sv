`timescale 1ns / 1ps

module slave_GPO (

    input               clk,
    input               reset,
    input        [31:0] p_addr,
    input        [31:0] p_wdata,
    input               p_write,
    input               p_en,
    input               p_sel,
    output       [31:0] p_rdata,
    output       [15:0] o_gpo,
    output logic        p_ready
);

    localparam [11:0] gpo_ctl_addr = 12'h000;
    localparam [11:0] gpo_data_addr = 12'h004;

    logic [15:0] gpo_data_reg;
    logic [15:0] gpo_ctl_reg;

    assign p_ready = (p_sel && p_en) ? 1'b1 : 1'b0;

    assign p_rdata = (p_addr[11:0] == gpo_ctl_addr)   ? {16'h0000,gpo_ctl_reg} :
                     (p_addr[11:0] == gpo_data_addr)  ? {16'h0000,gpo_data_reg} : 32'hxxxx_xxxx;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            gpo_ctl_reg  <= 16'h0000;
            gpo_data_reg <= 16'h0000;
        end else begin
            if (p_ready & p_write) begin
                case (p_addr[11:0])
                    gpo_ctl_addr: begin
                        gpo_ctl_reg <= p_wdata[15:0];
                    end
                    gpo_data_addr: begin
                        gpo_data_reg <= p_wdata[15:0];
                    end
                endcase
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign o_gpo[i] = (gpo_ctl_reg[i]) ? gpo_data_reg[i] : 1'bz;
        end
    endgenerate


endmodule
