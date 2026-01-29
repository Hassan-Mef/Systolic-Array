`timescale 1ns / 1ps
module rxtx_top(
    input  wire clk,
    input  wire send_btn,   // physical button
    input  wire RxD,
    output wire TxD
);
    parameter MAX_LEN = 20;
    // RX storage
    // =====================================================
    reg [7:0] char_mem [0:MAX_LEN-1];
    reg [4:0] mem_index;

    wire [7:0] RxData;
    wire rx_done;
    // =====================================================
    // TX control
    // =====================================================
    reg  [7:0] data_to_tx;
    reg        start_tx;
    wire       tx_done;
    reg  [4:0] tx_index;
    reg        sending;
    // =====================================================
    // Button debounce
    // =====================================================
    wire send_pulse;

    button_debounce u_db (
        .clk(clk),
        .btn_in(send_btn),
        .btn_pulse(send_pulse)
    );
    // =====================================================
    // UART Receiver
    // =====================================================
    receiver rx_inst (
        .clk(clk),
        .reset(1'b0),    // power-on reset handled internally
        .RxD(RxD),
        .RxData(RxData),
        .rx_done(rx_done)
    );

    // =====================================================
    // RX memory logic
    // =====================================================
    always @(posedge clk) begin
        if (rx_done) begin
            if (mem_index < MAX_LEN) begin
                char_mem[mem_index] <= RxData;
                mem_index <= mem_index + 1;
            end
        end
    end

    // =====================================================
    // TX logic (ONE transmission per button press)
    // =====================================================
    always @(posedge clk) begin
        start_tx <= 0;

        // Start transmission
        if (send_pulse && !sending && mem_index != 0) begin
            sending    <= 1;
            tx_index   <= 0;
            data_to_tx <= char_mem[0];
            start_tx   <= 1;
        end

        // Continue transmission
        else if (sending && tx_done) begin
            if (tx_index < mem_index - 1) begin
                tx_index   <= tx_index + 1;
                data_to_tx <= char_mem[tx_index + 1];
                start_tx   <= 1;
            end else begin
                sending <= 0;  // DONE after one pass
            end
        end
    end

    // =====================================================
    // UART Transmitter
    // =====================================================
    transmitter tx_inst (
        .clk(clk),
        .reset(1'b0),
        .transmit(start_tx),
        .data(data_to_tx),
        .TxD(TxD),
        .tx_done(tx_done)
    );

endmodule