`timescale 1ns / 1ps

module data_mem (
    input               clk,
    input               dwe,
    input        [ 2:0] i_funct3,
    input        [31:0] daddr,
    input        [31:0] dwdata,
    output logic [31:0] drdata
);
    //word address
    logic [31:0] data_mem[0:31];
    always_ff @(posedge clk) begin
        if (dwe) begin
            case (i_funct3)
                `SB: begin
                    data_mem[daddr[31:2]] <= {
                        data_mem[daddr[31:2]][31:8], dwdata[7:0]
                    };
                end
                `SH: begin
                    data_mem[daddr[31:2]] <= {
                        data_mem[daddr[31:2]][31:16], dwdata[15:0]
                    };
                end
                `SW: begin
                    data_mem[daddr[31:2]] <= dwdata;
                end
                default: ;
            endcase
        end
    end

    always_comb begin
        case (i_funct3)
            `LB:
            drdata = {
                {24{data_mem[daddr[31:2]][7]}}, data_mem[daddr[31:2]][7:0]
            };
            `LH:
            drdata = {
                {16{data_mem[daddr[31:2]][15]}}, data_mem[daddr[31:2]][15:0]
            };
            `LW: drdata = data_mem[daddr[31:2]];
            `LBU: drdata = {24'd0, data_mem[daddr[31:2]][7:0]};
            `LHU: drdata = {16'd0, data_mem[daddr[31:2]][15:0]};
            default: drdata = 32'd0;
        endcase
    end



endmodule

// byte address
//  logic [7:0] data_mem[0:31];
//  always_ff @(posedge clk) begin
//      if (dwe) begin
//          data_mem[dwaddr+0] <= dwdata[7:0];
//          data_mem[dwaddr+1] <= dwdata[15:8];
//          data_mem[dwaddr+2] <= dwdata[23:16];
//          data_mem[dwaddr+3] <= dwdata[31:24];
//      end
//  end
//  assign drdata = {
//      data_mem[dwaddr],
//      data_mem[dwaddr+1],
//      data_mem[dwaddr+2],
//      data_mem[dwaddr+3]
//  };
