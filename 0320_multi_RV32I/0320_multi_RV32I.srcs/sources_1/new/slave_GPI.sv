`timescale 1ns / 1ps

module slave_GPI (

    input         clk,
    input         reset,
    input  [31:0] p_addr,
    input  [31:0] p_wdata,
    input         p_write,
    input         p_en,
    input         p_sel,
    input  [15:0] i_gpi,
    output [31:0] p_rdata,
    output        p_ready
);

    localparam [11:0] gpi_ctl_addr = 12'h000;
    localparam [11:0] gpi_data_addr = 12'h004;

    logic [15:0] gpi_data_reg;
    logic [15:0] gpi_ctl_reg;

    assign p_ready = (p_sel && p_en) ? 1'b1 : 1'b0;

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign gpi_data_reg[i] = (gpi_ctl_reg[i]) ? i_gpi[i] : 1'bz;
        end
    endgenerate

    assign p_rdata = (p_addr[11:0] == gpi_ctl_addr)  ? {16'h0000, gpi_ctl_reg}  :
                     (p_addr[11:0] == gpi_data_addr) ? {16'h0000, gpi_data_reg} :
                                                        32'hxxxx_xxxx;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            gpi_ctl_reg <= 16'h0000;
        end else begin
            if (p_ready & p_write) begin
                case (p_addr[11:0])
                    gpi_ctl_addr: begin
                        gpi_ctl_reg <= p_wdata[15:0];
                    end
                endcase
            end
        end
    end


endmodule
