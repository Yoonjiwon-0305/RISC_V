`timescale 1ns / 1ps

module slave_UART (
    input               clk,
    input               reset,
    input        [31:0] p_addr,
    input        [31:0] p_wdata,
    input               p_write,
    input               p_en,
    input               p_sel,
    output logic [31:0] p_rdata,
    output logic        p_ready,
    output              uart_tx,
    input               uart_rx
);

    localparam [11:0] UART_CTL_ADDR = 12'h000;
    localparam [11:0] UART_BAUD_ADDR = 12'h004;
    localparam [11:0] UART_STATUS_ADDR = 12'h008;
    localparam [11:0] UART_TX_ADDR = 12'h00C;
    localparam [11:0] UART_RX_ADDR = 12'h010;

    logic [31:0] ctl_reg;
    logic [31:0] baud_reg;
    logic [31:0] status_reg;
    logic [31:0] tx_data_reg;
    logic [31:0] rx_data_reg;

    logic        tx_start;
    logic        tx_busy;
    logic        rx_done;
    logic [ 7:0] rx_data;
    logic [31:0] baud_div;

    assign p_ready = (p_sel && p_en) ? 1'b1 : 1'b0;

    logic ctl_prev;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) ctl_prev <= 1'b0;
        else ctl_prev <= ctl_reg[0];
    end
    assign tx_start = ctl_reg[0] & ~ctl_prev;

    always_comb begin
        status_reg    = 32'h0;
        status_reg[0] = tx_busy;
        status_reg[1] = rx_done;
    end

    always_comb begin
        case (baud_reg[1:0])
            2'b00:   baud_div = 32'd10417;  // 100MHz / 9600
            2'b01:   baud_div = 32'd5208;  // 100MHz / 19200
            2'b10:   baud_div = 32'd868;  // 100MHz / 115200
            default: baud_div = 32'd10417;
        endcase
    end


    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ctl_reg     <= 32'h0;
            baud_reg    <= 32'h0;
            tx_data_reg <= 32'h0;
        end else begin
            if (p_ready && p_write) begin
                case (p_addr[11:0])
                    UART_CTL_ADDR:  ctl_reg <= p_wdata;
                    UART_BAUD_ADDR: baud_reg <= p_wdata;
                    UART_TX_ADDR:   tx_data_reg <= p_wdata;
                endcase
            end else begin
                if (ctl_reg[0]) ctl_reg[0] <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) rx_data_reg <= 32'h0;
        else if (rx_done) rx_data_reg <= {24'h0, rx_data};
    end

    // APB Read
    always_comb begin
        p_rdata = 32'h0;
        case (p_addr[11:0])
            UART_CTL_ADDR:    p_rdata = ctl_reg;
            UART_BAUD_ADDR:   p_rdata = baud_reg;
            UART_STATUS_ADDR: p_rdata = status_reg;
            UART_TX_ADDR:     p_rdata = tx_data_reg;
            UART_RX_ADDR:     p_rdata = rx_data_reg;
            default:          p_rdata = 32'h0;
        endcase
    end

    uart_tx U_TX (
        .clk     (clk),
        .reset   (reset),
        .tx_start(tx_start),
        .tx_data (tx_data_reg[7:0]),
        .baud_div(baud_div),
        .tx_busy (tx_busy),
        .uart_tx (uart_tx)
    );

    uart_rx U_RX (
        .clk     (clk),
        .reset   (reset),
        .uart_rx (uart_rx),
        .baud_div(baud_div),
        .rx_done (rx_done),
        .rx_data (rx_data)
    );

endmodule

module uart_tx (
    input               clk,
    input               reset,
    input               tx_start,
    input        [ 7:0] tx_data,
    input        [31:0] baud_div,
    output logic        tx_busy,
    output logic        uart_tx
);
    typedef enum logic [1:0] {
        TX_IDLE,
        TX_START,
        TX_DATA,
        TX_STOP
    } tx_state_e;

    tx_state_e        state;

    logic      [31:0] baud_cnt;
    logic      [ 2:0] bit_idx;
    logic      [ 7:0] tx_shift;
    logic             baud_tick;

    assign baud_tick = (baud_cnt == baud_div - 1);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= TX_IDLE;
            uart_tx  <= 1'b1;
            tx_busy  <= 1'b0;
            baud_cnt <= 32'd0;
            bit_idx  <= 3'd0;
            tx_shift <= 8'd0;
        end else begin
            case (state)
                TX_IDLE: begin
                    uart_tx  <= 1'b1;
                    baud_cnt <= 32'd0;
                    if (tx_start) begin
                        tx_shift <= tx_data;
                        tx_busy  <= 1'b1;   // ← tx_busy는 tx_start일 때만
                        state    <= TX_START;
                    end else begin
                        tx_busy <= 1'b0;  // ← else로 분리!
                    end
                end
                TX_START: begin
                    uart_tx <= 1'b0;  // start bit
                    if (baud_tick) begin
                        baud_cnt <= 32'd0;
                        bit_idx  <= 3'd0;
                        state    <= TX_DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                TX_DATA: begin
                    uart_tx <= tx_shift[bit_idx];
                    if (baud_tick) begin
                        baud_cnt <= 32'd0;
                        if (bit_idx == 3'd7) begin
                            state <= TX_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                TX_STOP: begin
                    uart_tx <= 1'b1;  // stop bit
                    if (baud_tick) begin
                        baud_cnt <= 32'd0;
                        tx_busy  <= 1'b0;   // ← STOP에서 클리어
                        state    <= TX_IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule


//================================================
// UART RX
//================================================
module uart_rx (
    input               clk,
    input               reset,
    input               uart_rx,
    input        [31:0] baud_div,
    output logic        rx_done,
    output logic [ 7:0] rx_data
);
    typedef enum logic [1:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP
    } rx_state_e;

    rx_state_e state;

    logic [31:0] baud_cnt;
    logic [2:0] bit_idx;
    logic [7:0] rx_shift;

    logic [31:0] half_baud;
    assign half_baud = baud_div >> 1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= RX_IDLE;
            rx_done  <= 1'b0;
            rx_data  <= 8'd0;
            baud_cnt <= 32'd0;
            bit_idx  <= 3'd0;
            rx_shift <= 8'd0;
        end else begin
            rx_done <= 1'b0;

            case (state)
                RX_IDLE: begin
                    baud_cnt <= 32'd0;
                    if (!uart_rx) begin
                        state <= RX_START;
                    end
                end
                RX_START: begin
                    if (baud_cnt == half_baud) begin
                        baud_cnt <= 32'd0;
                        bit_idx  <= 3'd0;
                        state    <= RX_DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                RX_DATA: begin
                    if (baud_cnt == baud_div - 1) begin
                        rx_shift[bit_idx] <= uart_rx;
                        baud_cnt          <= 32'd0;
                        if (bit_idx == 3'd7) begin
                            state <= RX_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                RX_STOP: begin
                    if (baud_cnt == baud_div - 1) begin
                        rx_done  <= 1'b1;
                        rx_data  <= rx_shift;
                        baud_cnt <= 32'd0;
                        state    <= RX_IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule
