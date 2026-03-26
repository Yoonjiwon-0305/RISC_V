`timescale 1ns / 1ps

module RV32I_MCU (
    input         clk,
    input         reset,
    input  [15:0] sw,
    output [15:0] led
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

    logic p_sel_0, p_sel_1, p_sel_2;
    logic p_sel_3, p_sel_4, p_sel_5;

    logic p_ready_0, p_ready_1, p_ready_2;
    logic p_ready_3, p_ready_4, p_ready_5;

    logic [31:0] p_rdata_0, p_rdata_1, p_rdata_2;
    logic [31:0] p_rdata_3, p_rdata_4, p_rdata_5;

    logic [31:0] p_addr, p_wdata;
    logic p_en, p_write;

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
        .rdata    (bus_rdata),
        .ready    (bus_ready),
        //form apb 
        .p_addr   (p_addr),     //need register
        .p_wdata  (p_wdata),    //need register
        .p_en     (p_en),       //공통
        .p_write  (p_write),    //공통 
        //from slave
        .p_sel_0  (p_sel_0),    //RAM
        .p_sel_1  (p_sel_1),    //GPO
        .p_sel_2  (p_sel_2),    //GPI
        .p_sel_3  (p_sel_3),    //GPIO
        .p_sel_4  (p_sel_4),    //FND
        .p_sel_5  (p_sel_5),    //UART
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
        .p_ready_5(p_ready_5)   //UART


    );

    slave_RAM U_SLAVE_RAM (

        .clk     (clk),
        .reset   (reset),
        .p_addr  (p_addr),
        .p_wdata (p_wdata),
        .p_en    (p_en),
        .p_write (p_write),
        .p_sel   (p_sel_0),
        .p_funct3(o_funct3),
        .p_rdata (p_rdata_0),
        .p_ready (p_ready_0)
    );

    slave_GPO U_SLAVE_GPO (

        .clk    (clk),
        .reset  (reset),
        .p_addr (p_addr),
        .p_wdata(p_wdata),
        .p_write(p_write),
        .p_en   (p_en),
        .p_sel  (p_sel_1),
        .p_rdata(p_rdata_1),
        .o_gpo  (led),
        .p_ready(p_ready_1)
    );

    slave_GPI U_SLAVE_GPI (

        .clk    (clk),
        .reset  (reset),
        .p_addr (p_addr),
        .p_wdata(p_wdata),
        .p_write(p_write),
        .p_en   (p_en),
        .p_sel  (p_sel_2),
        .i_gpi  (sw),
        .p_rdata(p_rdata_2),
        .p_ready(p_ready_2)
    );


endmodule
