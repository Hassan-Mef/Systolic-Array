// this module is a top module to simulate 1D conv on vivado
`timescale 1ns / 1ps
module rxtx_top(
    input  wire clk,
    input  wire send_btn,     // echo input
    input  wire read_btn,     // send output
    input  wire conv_start,   // start convolution push button
    input  wire RxD,
    input  wire reset,
    output wire TxD,
    output wire conv_done_led,
    output wire y_valid_led
);

    parameter MAX_LEN = 32;
    parameter DATA_WIDTH = 8;

    // =====================================================
    // RX side
    // =====================================================
    wire [DATA_WIDTH-1:0] RxData;
    wire rx_done;

    reg [DATA_WIDTH-1:0] in_mem [0:MAX_LEN-1];
    reg [4:0] in_len;
    reg [4:0] rx_wr_ptr;

    // =====================================================
    // Output buffer
    // =====================================================
    reg [DATA_WIDTH-1:0] out_mem [0:MAX_LEN-1];
    reg [4:0] out_len;

    // =====================================================
    // UART RX
    // =====================================================
    receiver rx_inst (
        .clk(clk),
        .reset(1'b0),
        .RxD(RxD),
        .RxData(RxData),
        .rx_done(rx_done)
    );

    // =====================================================
    // RX store
    // =====================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            in_len    <= 0;
            rx_wr_ptr <= 0;
        end else if (rx_done && rx_wr_ptr < MAX_LEN) begin
            in_mem[rx_wr_ptr] <= RxData;
            rx_wr_ptr <= rx_wr_ptr + 1;
            in_len    <= rx_wr_ptr + 1;
        end
    end

    // =====================================================
    // Button debounce
    // =====================================================
    wire send_pulse, out_pulse, conv_start_pulse;

    button_debounce db1 (.clk(clk), .btn_in(send_btn), .btn_pulse(send_pulse));
    button_debounce db2 (.clk(clk), .btn_in(read_btn), .btn_pulse(out_pulse));
    button_debounce db3 (.clk(clk), .btn_in(conv_start), .btn_pulse(conv_start_pulse));

    // =====================================================
    // Convolution DUT
    // =====================================================
    wire [DATA_WIDTH-1:0] conv_out_data;
    wire conv_out_valid;
    wire conv_done;
    reg conv_out_read;

    conv_serial_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .BUFFER_SIZE(MAX_LEN)
    ) dut (
        .clk(clk),
        .reset(reset),
        .mem_wr_en(rx_done),
        .mem_wr_addr(rx_wr_ptr),
        .mem_wr_data(RxData),
        .start_conv(conv_start_pulse),
        .conv_done(conv_done),
        .conv_valid_led(),         // ignore PE internal LED here
        .out_data(conv_out_data),
        .out_valid(conv_out_valid),
        .out_read_en(conv_out_read)
    );

    // =====================================================
    // Drive LEDs safely (single driver)
    // =====================================================
    assign conv_done_led = conv_done;

    // Register conv_out_valid for LED
    reg conv_valid_r;
    always @(posedge clk or posedge reset) begin
        if (reset)
            conv_valid_r <= 0;
        else
            conv_valid_r <= conv_out_valid;
    end
    assign y_valid_led = conv_valid_r;

    // =====================================================
    // Capture convolution output
    // =====================================================
    always @(posedge clk or posedge reset) begin
        if (reset || conv_start_pulse) begin
            out_len <= 0;
        end else if (conv_out_valid && out_len < MAX_LEN) begin
            out_mem[out_len] <= conv_out_data;
            out_len <= out_len + 1;
        end
    end

    // Read while valid
    always @(posedge clk or posedge reset) begin
        if (reset)
            conv_out_read <= 0;
        else
            conv_out_read <= conv_out_valid;
    end

    // =====================================================
    // UART TX FSM
    // =====================================================
    reg [DATA_WIDTH-1:0] tx_data;
    reg tx_start;
    wire tx_done;

    reg [4:0] tx_index;
    reg [1:0] tx_state;

    localparam TX_IDLE = 2'd0;
    localparam TX_IN   = 2'd1;
    localparam TX_OUT  = 2'd2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_state <= TX_IDLE;
            tx_index <= 0;
            tx_start <= 0;
        end else begin
            tx_start <= 0;

            case (tx_state)

                TX_IDLE: begin
                    if (send_pulse && in_len != 0) begin
                        tx_state <= TX_IN;
                        tx_index <= 0;
                        tx_data  <= in_mem[0];
                        tx_start <= 1;
                    end else if (out_pulse && out_len != 0) begin
                        tx_state <= TX_OUT;
                        tx_index <= 0;
                        tx_data  <= out_mem[0];
                        tx_start <= 1;
                    end
                end

                TX_IN: begin
                    if (tx_done) begin
                        if (tx_index < in_len-1) begin
                            tx_index <= tx_index + 1;
                            tx_data  <= in_mem[tx_index + 1];
                            tx_start <= 1;
                        end else begin
                            tx_state <= TX_IDLE;
                        end
                    end
                end

                TX_OUT: begin
                    if (tx_done) begin
                        if (tx_index < out_len-1) begin
                            tx_index <= tx_index + 1;
                            tx_data  <= out_mem[tx_index + 1];
                            tx_start <= 1;
                        end else begin
                            tx_state <= TX_IDLE;
                        end
                    end
                end

            endcase
        end
    end

    // =====================================================
    // UART TX
    // =====================================================
    transmitter tx_inst (
        .clk(clk),
        .reset(1'b0),
        .transmit(tx_start),
        .data(tx_data),
        .TxD(TxD),
        .tx_done(tx_done)
    );

endmodule
