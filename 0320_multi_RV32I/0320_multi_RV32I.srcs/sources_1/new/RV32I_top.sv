`timescale 1ns / 1ps

module RV32I_MCU (
    input clk,
    input reset
);
    // CPU ↔ ROM
    logic [31:0] instr_addr;
    logic [31:0] instr_data;

    // CPU ↔ APB_Master
    logic [31:0] bus_addr;
    logic [31:0] bus_wdata;
    logic [31:0] bus_rdata;
    logic        bus_w_req;
    logic        bus_r_req;
    logic        bus_ready;
    logic [ 2:0] o_funct3;

    //ROM
    instruction_mem U_INST_MEM (
        .instr_addr(instr_addr),
        .instr_data(instr_data)
    );


    RV32I_cpu U_RV32I_CPU (
        .clk       (clk),
        .reset     (reset),
        .instr_data(instr_data),
        .bus_rdata (bus_rdata),
        .bus_ready (bus_ready),
        .instr_addr(instr_addr),
        .bus_w_req (bus_w_req),
        .bus_r_req (bus_r_req),
        .bus_addr  (bus_addr),
        .bus_wdata (bus_wdata),
        .o_funct3  (o_funct3)
    );

    // APB_master
    APB_master U_APB_MASTER (

        .p_clk    (clk),
        .p_reset  (reset),
        .addr     (bus_addr),
        .wdata    (bus_wdata),
        .w_req    (bus_w_req),  // signal cpu : dwe
        .r_req    (bus_r_req),  // signal cpu : dre
        .p_addr   (),           //need register
        .p_wdata  (),           //need register
        .p_en     (),           //공통
        .p_write  (),           //공통 
        .p_sel_0  (),           //RAM
        .p_sel_1  (),           //GPO
        .p_sel_2  (),           //GPI
        .p_sel_3  (),           //GPIO
        .p_sel_4  (),           //FND
        .p_sel_5  (),           //UART
        .p_rdata_0(),           //RAM
        .p_rdata_1(),           //GPO
        .p_rdata_2(),           //GPI
        .p_rdata_3(),           //GPIO
        .p_rdata_4(),           //FND
        .p_rdata_5(),           //UART
        .p_ready_0(),           //RAM
        .p_ready_1(),           //GPO
        .p_ready_2(),           //GPI
        .p_ready_3(),           //GPIO
        .p_ready_4(),           //FND
        .p_ready_5(),           //UART
        .rdata    (bus_rdata),
        .ready    (bus_ready)

    );

    // APB_slave
    data_mem U_DATA_MEM (
        .clk(),
        .dwe(),
        .i_funct3(),
        .daddr(),
        .dwdata(),
        .drdata()
    );

endmodule
