`timescale 1ns / 1ps
`include "define.vh"

module data_mem (
    input               clk,
    input               dwe,
    input        [ 2:0] i_funct3,
    input        [31:0] daddr,
    input        [31:0] dwdata,
    output logic [31:0] drdata
);
    //word address
    logic [31:0] data_mem[0:1023];

    always_ff @(posedge clk) begin
        if (dwe) begin
            case (i_funct3)
                `SB: begin
                    case (daddr[1:0])
                        2'b00:
                        data_mem[daddr[11:2]] <= {
                            data_mem[daddr[11:2]][31:8], dwdata[7:0]
                        };
                        2'b01:
                        data_mem[daddr[11:2]] <= {
                            data_mem[daddr[11:2]][31:16],
                            dwdata[15:8],
                            data_mem[daddr[11:2]][7:0]
                        };
                        2'b10:
                        data_mem[daddr[11:2]] <= {
                            data_mem[daddr[11:2]][31:24],
                            dwdata[23:16],
                            data_mem[daddr[11:2]][15:0]
                        };
                        2'b11:
                        data_mem[daddr[11:2]] <= {
                            dwdata[31:24], data_mem[daddr[11:2]][23:0]
                        };
                    endcase
                end
                `SH: begin
                    case (daddr[1])
                        1'b0:
                        data_mem[daddr[11:2]] <= {
                            data_mem[daddr[11:2]][31:16], dwdata[15:0]
                        };
                        1'b1:
                        data_mem[daddr[11:2]] <= {
                            dwdata[31:16], data_mem[daddr[11:2]][15:0]
                        };
                    endcase
                end
                `SW: begin
                    data_mem[daddr[11:2]] <= dwdata;
                end
            endcase
        end
    end

    always_comb begin
        case (i_funct3)
            `LB: begin
                case (daddr[1:0])
                    2'b00:
                    drdata = {
                        {24{data_mem[daddr[11:2]][7]}},
                        data_mem[daddr[11:2]][7:0]
                    };
                    2'b01:
                    drdata = {
                        {24{data_mem[daddr[11:2]][15]}},
                        data_mem[daddr[11:2]][15:8]
                    };
                    2'b10:
                    drdata = {
                        {24{data_mem[daddr[11:2]][23]}},
                        data_mem[daddr[11:2]][23:16]
                    };
                    2'b11:
                    drdata = {
                        {24{data_mem[daddr[11:2]][31]}},
                        data_mem[daddr[11:2]][31:24]
                    };
                endcase
            end
            `LBU: begin
                case (daddr[1:0])
                    2'b00: drdata = {24'd0, data_mem[daddr[11:2]][7:0]};
                    2'b01: drdata = {24'd0, data_mem[daddr[11:2]][15:8]};
                    2'b10: drdata = {24'd0, data_mem[daddr[11:2]][23:16]};
                    2'b11: drdata = {24'd0, data_mem[daddr[11:2]][31:24]};
                endcase
            end
            `LH: begin
                case (daddr[1])
                    1'b0:
                    drdata = {
                        {16{data_mem[daddr[11:2]][15]}},
                        data_mem[daddr[11:2]][15:0]
                    };
                    1'b1:
                    drdata = {
                        {16{data_mem[daddr[11:2]][31]}},
                        data_mem[daddr[11:2]][31:16]
                    };
                endcase
            end
            `LHU: begin
                case (daddr[1])
                    1'b0: drdata = {16'd0, data_mem[daddr[11:2]][15:0]};
                    1'b1: drdata = {16'd0, data_mem[daddr[11:2]][31:16]};
                endcase
            end
            `LW: drdata = data_mem[daddr[11:2]];
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
