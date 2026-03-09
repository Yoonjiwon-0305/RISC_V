`timescale 1ns / 1ps

module data_mem (
    input         clk,
    input         dwe,
    input  [31:0] dwaddr,
    input  [31:0] dwdata,
    output [31:0] drdata
);

    logic [7:0] data_mem[0:31];

    always_ff @(posedge clk) begin
        if (dwe) begin
            data_mem[dwaddr+0] <= dwdata[7:0];
            data_mem[dwaddr+1] <= dwdata[15:8];
            data_mem[dwaddr+2] <= dwdata[23:16];
            data_mem[dwaddr+3] <= dwdata[31:24];
        end
    end

    assign drdata = {
        data_mem[dwaddr],
        data_mem[dwaddr+1],
        data_mem[dwaddr+2],
        data_mem[dwaddr+3]
    };

endmodule
