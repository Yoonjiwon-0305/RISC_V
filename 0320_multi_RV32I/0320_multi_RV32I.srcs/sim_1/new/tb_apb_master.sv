`timescale 1ns / 1ps

module tb_apb_master ();

    logic        clk, reset;
    logic [31:0] addr, wdata;
    logic        w_req, r_req;

    logic [31:0] p_addr, p_wdata;
    logic        p_en, p_write;
    logic        p_sel_0, p_sel_1, p_sel_2;
    logic        p_sel_3, p_sel_4, p_sel_5;
    logic        p_ready_0, p_ready_1, p_ready_2;
    logic        p_ready_3, p_ready_4, p_ready_5;
    logic [31:0] p_rdata_0, p_rdata_1, p_rdata_2;
    logic [31:0] p_rdata_3, p_rdata_4, p_rdata_5;
    logic [31:0] rdata;
    logic        ready;

    APB_master dut (
        .p_clk    (clk),
        .p_reset  (reset),
        .addr     (addr),
        .wdata    (wdata),
        .w_req    (w_req),
        .r_req    (r_req),
        .p_addr   (p_addr),
        .p_wdata  (p_wdata),
        .p_en     (p_en),
        .p_write  (p_write),
        .p_sel_0  (p_sel_0),
        .p_sel_1  (p_sel_1),
        .p_sel_2  (p_sel_2),
        .p_sel_3  (p_sel_3),
        .p_sel_4  (p_sel_4),
        .p_sel_5  (p_sel_5),
        .p_rdata_0(p_rdata_0),
        .p_rdata_1(p_rdata_1),
        .p_rdata_2(p_rdata_2),
        .p_rdata_3(p_rdata_3),
        .p_rdata_4(p_rdata_4),
        .p_rdata_5(p_rdata_5),
        .p_ready_0(p_ready_0),
        .p_ready_1(p_ready_1),
        .p_ready_2(p_ready_2),
        .p_ready_3(p_ready_3),
        .p_ready_4(p_ready_4),
        .p_ready_5(p_ready_5),
        .rdata    (rdata),
        .ready    (ready)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // 초기화
        reset     = 0;
        addr      = 32'h0; wdata = 32'h0;
        w_req     = 0;     r_req = 0;
        p_ready_0 = 0; p_ready_1 = 0; p_ready_2 = 0;
        p_ready_3 = 0; p_ready_4 = 0; p_ready_5 = 0;
        p_rdata_0 = 0; p_rdata_1 = 0; p_rdata_2 = 0;
        p_rdata_3 = 0; p_rdata_4 = 0; p_rdata_5 = 0;

        repeat(2) @(negedge clk);
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 1. RAM Write
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h1000_0000; wdata = 32'h0000_00FF;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_0 & p_en);
        p_ready_0 = 1;
        @(posedge clk); #1;
        p_ready_0 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 2. RAM Read
        // =============================================
        @(posedge clk); #1;
        r_req = 1; addr = 32'h1000_0000;
        @(posedge clk); #1;
        r_req = 0;
        wait(p_sel_0 & p_en);
        p_ready_0 = 1; p_rdata_0 = 32'hAABBCCDD;
        @(posedge clk); #1;
        p_ready_0 = 0; p_rdata_0 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 3. GPO Write CTL (0x000) — 먼저
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h2000_0000; wdata = 32'h0000_FFFF;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_1 & p_en);
        p_ready_1 = 1;
        @(posedge clk); #1;
        p_ready_1 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 4. GPO Write DATA (0x004) — 나중
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h2000_0004; wdata = 32'h0000_00AA;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_1 & p_en);
        p_ready_1 = 1;
        @(posedge clk); #1;
        p_ready_1 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 5. GPI Write CTL (0x000) — 먼저
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h2000_1000; wdata = 32'h0000_FFFF;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_2 & p_en);
        p_ready_2 = 1;
        @(posedge clk); #1;
        p_ready_2 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 6. GPI Read DATA (0x004) — 나중
        // =============================================
        @(posedge clk); #1;
        r_req = 1; addr = 32'h2000_1004;
        @(posedge clk); #1;
        r_req = 0;
        wait(p_sel_2 & p_en);
        p_ready_2 = 1; p_rdata_2 = 32'h0000_00FF;
        @(posedge clk); #1;
        p_ready_2 = 0; p_rdata_2 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 7. GPIO Write DATA
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h2000_2000; wdata = 32'h0000_00A0;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_3 & p_en);
        p_ready_3 = 1;
        @(posedge clk); #1;
        p_ready_3 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 8. GPIO Read DATA
        // =============================================
        @(posedge clk); #1;
        r_req = 1; addr = 32'h2000_2000;
        @(posedge clk); #1;
        r_req = 0;
        wait(p_sel_3 & p_en);
        p_ready_3 = 1; p_rdata_3 = 32'h0000_00A0;
        @(posedge clk); #1;
        p_ready_3 = 0; p_rdata_3 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 9. FND Write DATA
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h2000_3000; wdata = 32'h0000_1234;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_4 & p_en);
        p_ready_4 = 1;
        @(posedge clk); #1;
        p_ready_4 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 10. UART Write TX
        // =============================================
        @(posedge clk); #1;
        w_req = 1; addr = 32'h2000_4000; wdata = 32'h0000_0041;
        @(posedge clk); #1;
        w_req = 0;
        wait(p_sel_5 & p_en);
        p_ready_5 = 1;
        @(posedge clk); #1;
        p_ready_5 = 0;
        repeat(2) @(posedge clk);

        // =============================================
        // 11. UART Read RX
        // =============================================
        @(posedge clk); #1;
        r_req = 1; addr = 32'h2000_4000;
        @(posedge clk); #1;
        r_req = 0;
        wait(p_sel_5 & p_en);
        p_ready_5 = 1; p_rdata_5 = 32'h0000_0041;
        @(posedge clk); #1;
        p_ready_5 = 0; p_rdata_5 = 0;

        repeat(2) @(posedge clk);
        $stop;
    end

endmodule
//`timescale 1ns / 1ps
//
//module tb_apb_master ();
//
//    logic clk, reset;
//    logic [31:0] addr, wdata;
//    logic w_req, r_req;
//
//    // DUT 출력 관찰용
//    logic [31:0] p_addr, p_wdata;
//    logic p_en, p_write;
//    logic p_sel_0, p_sel_1, p_sel_2;
//    logic p_sel_3, p_sel_4, p_sel_5;
//    logic p_ready_0, p_ready_1, p_ready_2;
//    logic p_ready_3, p_ready_4, p_ready_5;
//    logic [31:0] rdata;
//    logic        ready;
//
//    // 슬레이브 응답 신호 (tb에서 직접 만들어줌)
//    logic [31:0] p_rdata_0, p_rdata_1, p_rdata_2;
//    logic [31:0] p_rdata_3, p_rdata_4, p_rdata_5;
//
//    APB_master dut (
//
//        .p_clk    (clk),        // 내가 입력해주는 값
//        .p_reset  (reset),      // 내가 입력해주는 값
//        .addr     (addr),       // 내가 입력해주는 값
//        .wdata    (wdata),      // 내가 입력해주는 값
//        .w_req    (w_req),      // 내가 입력해주는 값
//        .r_req    (r_req),      // 내가 입력해주는 값
//        .p_addr   (p_addr),     // 결과 출력
//        .p_wdata  (p_wdata),    // 결과 출력
//        .p_en     (p_en),       // 결과 출력
//        .p_write  (p_write),    // 결과 출력
//        .p_sel_0  (p_sel_0),    // 결과 출력
//        .p_sel_1  (p_sel_1),    // 결과 출력
//        .p_sel_2  (p_sel_2),    // 결과 출력
//        .p_sel_3  (p_sel_3),    // 결과 출력
//        .p_sel_4  (p_sel_4),    // 결과 출력
//        .p_sel_5  (p_sel_5),    // 결과 출력
//        .p_rdata_0(p_rdata_0),  //RAM
//        .p_rdata_1(p_rdata_1),  //GPO
//        .p_rdata_2(p_rdata_2),  //GPI
//        .p_rdata_3(p_rdata_3),  //GPIO
//        .p_rdata_4(p_rdata_4),  //FND
//        .p_rdata_5(p_rdata_5),  //UART
//        .p_ready_0(p_ready_0),  // 결과 출력 
//        .p_ready_1(p_ready_1),  // 결과 출력
//        .p_ready_2(p_ready_2),  // 결과 출력
//        .p_ready_3(p_ready_3),  // 결과 출력
//        .p_ready_4(p_ready_4),  // 결과 출력
//        .p_ready_5(p_ready_5),  // 결과 출력
//        .rdata    (rdata),      // 내가 입력해주는 값
//        .ready    (ready)       // 내가 입력해주는 값
//
//    );
//
//    initial clk = 0;
//
//    always #5 clk = ~clk;
//
//    //ssign p_ready_0 = p_sel_0 & p_en;
//
//    task apb_write(input [31:0] w_addr, input [31:0] w_data);
//        @(posedge clk);
//        #1;
//        addr  = w_addr;
//        wdata = w_data;
//        w_req = 1;
//        r_req = 0;
//        @(posedge clk);
//        w_req = 0;
//        wait (ready == 1'b1);
//        @(posedge clk);
//    endtask
//
//    task apb_read(input [31:0] r_addr);
//        @(posedge clk);
//        addr  = r_addr;
//        w_req = 0;
//        r_req = 1;
//        @(posedge clk);
//        r_req = 0;
//        wait (ready == 1'b1);
//        @(posedge clk);
//    endtask
//
//    initial begin
//        reset = 0;
//        addr  = 32'h0;
//        wdata = 32'h0;
//        w_req = 1'b0;
//        r_req = 1'b0;
//
//        repeat (2) @(negedge clk);
//        reset = 1;
//
//        //apb_write(32'h1000_0000, 32'h0000_0041);
//
//        // write ex
//        @(posedge clk);
//        #1;
//        w_req = 1;
//        addr  = 32'h1000_0000;
//        wdata = 32'h0000_0041;
//        @(p_sel_0 && p_en);
//        p_ready_0 = 1;
//        @(posedge clk);
//        #1;
//        p_ready_0 = 0;
//        w_req = 0;
//
//
//
//        repeat (2) @(posedge clk);  // write 완료 후 잠깐 대기
//        // read ex
//        // apb_read(32'h2000_4000);
//
//        @(posedge clk);
//        #1;
//        r_req = 1;
//        addr  = 32'h2000_4000;
//        @(p_sel_5 && p_en);
//        @(posedge clk);
//        @(posedge clk);
//        #1;
//        p_ready_5 = 1;
//        p_rdata_5 = 32'h0000_0041;
//        @(posedge clk);
//        #1;
//        p_ready_5 = 0;
//        r_req = 0;
//
//        @(posedge clk);
//        @(posedge clk);
//
//        $stop;
//    end
//
//endmodule
//
