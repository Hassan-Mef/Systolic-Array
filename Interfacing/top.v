`timescale 1ns / 1ps

module uart_systolic_top (
    input  wire clk,
    input  wire reset,
    input  wire RxD,
    output wire TxD
);

    // ========================================
    // UART RX
    // ========================================
    wire [7:0] rx_data;
    wire       rx_done;

    receiver rx_inst (
        .clk(clk),
        .reset(reset),
        .RxD(RxD),
        .RxData(rx_data),
        .rx_done(rx_done)
    );
    
    reg [7:0] temp;
    
    always @(posedge clk) 
        temp<= rx_data;
    

    // ========================================
    // SYSTOLIC ARRAY
    // ========================================
    wire [20:0] systolic_out;
    wire        systolic_valid;

    Systolic_top_module dut (
        .clk(clk),
        .rst(reset),
        .data_in(temp),
        .data_in_valid(rx_done),
        .data_out(systolic_out),
        .data_out_valid(systolic_valid)
    );

    // ========================================
    // UART TX
    // ========================================
    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_done;

    transmitter tx_inst (
        .clk(clk),
        .reset(reset),
        .transmit(tx_start),
        .data(tx_data),
        .TxD(TxD),
        .tx_done(tx_done)
    );

    // ========================================
    // Send systolic output when valid
    // Only lower 8 bits for simplicity
    // ========================================
    reg systolic_valid_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_start <= 0;
            tx_data  <= 0;
            systolic_valid_d <= 0;
        end else begin
            systolic_valid_d <= systolic_valid;
            tx_start <= 0;

            if (systolic_valid && !systolic_valid_d) begin
                tx_data  <= systolic_out[7:0]; // send lower 8 bits
                tx_start <= 1'b1;
            end
        end
    end

endmodule