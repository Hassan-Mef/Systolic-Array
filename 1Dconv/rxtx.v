//`timescale 1ns / 1ps
//module rxtx_top(
//    input  wire clk,
//    input  wire send_btn,   // physical button to read input data
//    input  wire RxD,
//    output wire TxD,
//    input  wire reset,
//    input  wire read_btn, // new button to read output data
//    output wire conv_done_led,
//    output wire y_valid_led,
//    input  wire conv_start // conv start button
//);
//    parameter MAX_LEN = 32;
//    parameter DATA_WIDTH = 8;
//    parameter NUM_PE=16;
//    parameter BUFFER_SIZE=64;
//   // --------------------------
//   // Signals for conv_serial_top
//   // --------------------------
//    wire        conv_done;
//    wire        conv_valid_led;
//    reg         mem_wr_en;
//    reg [5:0]   mem_wr_addr;
//    reg [DATA_WIDTH-1:0]  mem_wr_data;
//    wire [7:0] conv_out_data;
//    wire       conv_out_valid;
//    reg        conv_out_read;

//    //     RX storage
//    // =====================================================
//    reg [7:0] in_mem [0:MAX_LEN-1];
//    reg [7:0] out_mem [0:MAX_LEN-1];
//    reg [4:0] mem_index;

//    wire [7:0] RxData;
//    wire rx_done;
//    // =====================================================
//    // TX control
//    // =====================================================
//    reg  [7:0] data_to_tx;
//    reg        start_tx;
//    wire       tx_done;
//    reg  [4:0] tx_index;
//    reg        sending;
//    // =====================================================
//    // Button debounce
//    // =====================================================
//    wire send_pulse;
//    wire out_pulse;
//    // for input echo button
//    button_debounce u_db (
//        .clk(clk),
//        .btn_in(send_btn),
//        .btn_pulse(send_pulse)
//    );
//    // for output echo button
//    button_debounce uu_db (
//            .clk(clk),
//            .btn_in(read_btn),
//            .btn_pulse(out_pulse)
//        );
//    // =====================================================
//    // UART Receiver
//    // =====================================================
//    receiver rx_inst (
//        .clk(clk),
//        .reset(1'b0),    // power-on reset handled internally
//        .RxD(RxD),
//        .RxData(RxData),
//        .rx_done(rx_done)
//    );

//    // =====================================================
//    // RX memory logic
//    // =====================================================
//    always @(posedge clk) begin
//        if (rx_done) begin
//            if (mem_index < MAX_LEN) begin
//                in_mem[mem_index] <= RxData;
//                mem_wr_en <= 1;
//                mem_wr_addr <= mem_index;
//                mem_wr_data <= RxData;
//                mem_index <= mem_index + 1;
//            end
//            else begin
//               mem_wr_en <= 0; 
//            end
//        end
//        else begin
//            mem_wr_en <= 0;
//        end
//    end
    
//    // reset logic
////    always@(posedge clk)begin
////        if(reset)begin
////            mem_index <= 0;
////            tx_index <= 0;
////        end
////    end
//    // =====================================================
//    // TX logic (ONE transmission per button press) for input data
//    // =====================================================
//    always @(posedge clk) begin
//        start_tx <= 0;

//        // Start transmission
//        if (send_pulse && !sending && mem_index != 0) begin
//            sending    <= 1;
//            tx_index   <= 0;
//            data_to_tx <= in_mem[0];
//            start_tx   <= 1;
//        end

//        // Continue transmission
//        else if (sending && tx_done) begin
//            if (tx_index < mem_index - 1) begin
//                tx_index   <= tx_index + 1;
//                data_to_tx <= in_mem[tx_index + 1];
//                start_tx   <= 1;
//            end else begin
//                sending <= 0;  // DONE after one pass
//            end
//        end
//    end
//    // =====================================================
//        // TX logic (ONE transmission per button press) for output data of convolution
//        // =====================================================
//    always @(posedge clk) begin
//            start_tx <= 0;
    
//            // Start transmission
//            if (out_pulse && !sending && mem_index != 0) begin
//                sending    <= 1;
//                tx_index   <= 0;
//                data_to_tx <= out_mem[0];
//                start_tx   <= 1;
//            end
    
//            // Continue transmission
//            else if (sending && tx_done) begin
//                if (tx_index < mem_index - 1) begin
//                    tx_index   <= tx_index + 1;
//                    data_to_tx <= out_mem[tx_index + 1];
//                    start_tx   <= 1;
//                end else begin
//                    sending <= 0;  // DONE after one pass
//                end
//            end
//        end
        
//     always @(posedge clk) begin
//            if (conv_done) begin
//                conv_out_read <= 1'b1;
//            end else begin
//                conv_out_read <= 1'b0;
//            end
//    end


//    reg [4:0] out_index;

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            out_index <= 0;
//        end else if (conv_out_valid) begin
//            out_mem[out_index] <= conv_out_data;
//            out_index <= out_index + 1;
//        end
//    end

//    // =====================================================
//    // UART Transmitter
//    // =====================================================
//    transmitter tx_inst (
//        .clk(clk),
//        .reset(1'b0),
//        .transmit(start_tx),
//        .data(data_to_tx),
//        .TxD(TxD),
//        .tx_done(tx_done)
//    );
    
//    // DUT
//    conv_serial_top dut (
//        .clk(clk),
//        .reset(reset),
//        .mem_wr_en(mem_wr_en),
//        .mem_wr_addr(mem_wr_addr),
//        .mem_wr_data(mem_wr_data),
//        .start_conv(conv_start),
//        .conv_done(conv_done),
//        .conv_valid_led(conv_valid_led),
    
//        .out_data(conv_out_data),
//        .out_valid(conv_out_valid),
//        .out_read_en(conv_out_read)
//    );

//endmodule



//`timescale 1ns / 1ps
//module rxtx_top(
//    input  wire clk,
//    input  wire send_btn,     // echo input
//    input  wire read_btn,     // send output
//    input  wire conv_start,   // start convolution switch
//    input  wire RxD,
//    input  wire reset,
//    output wire TxD,
//    output wire conv_done_led,
//    output wire y_valid_led
//);

//    parameter MAX_LEN = 32;
//    parameter DATA_WIDTH = 8;

//    // =====================================================
//    // RX side
//    // =====================================================
//    wire [7:0] RxData;
//    wire rx_done;

//    reg [7:0] in_mem [0:MAX_LEN-1];
//    reg [4:0] in_len;

//    // =====================================================
//    // Output buffer
//    // =====================================================
//    reg [7:0] out_mem [0:MAX_LEN-1];
//    reg [4:0] out_len;

//    // =====================================================
//    // UART RX
//    // =====================================================
//    receiver rx_inst (
//        .clk(clk),
//        .reset(1'b0),
//        .RxD(RxD),
//        .RxData(RxData),
//        .rx_done(rx_done)
//    );

//    // =====================================================
//    // RX store
//    // =====================================================
////    always @(posedge clk or posedge reset) begin
////        if (reset) begin
////            in_len <= 0;
////        end else if (rx_done && in_len < MAX_LEN) begin
////            in_mem[in_len] <= RxData;
////            in_len <= in_len + 1;
////        end
////    end
//    reg [4:0] rx_wr_ptr;
    
//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            in_len    <= 0;
//            rx_wr_ptr <= 0;
//        end else if (rx_done && rx_wr_ptr < MAX_LEN) begin
//            in_mem[rx_wr_ptr] <= RxData;
//            rx_wr_ptr <= rx_wr_ptr + 1;
//            in_len    <= rx_wr_ptr + 1;
//        end
//    end

//    // =====================================================
//    // Button debounce
//    // =====================================================
//    wire send_pulse, out_pulse,conv_start_pulse;

//    button_debounce db1 (.clk(clk), .btn_in(send_btn), .btn_pulse(send_pulse));
//    button_debounce db2 (.clk(clk), .btn_in(read_btn), .btn_pulse(out_pulse));
//    button_debounce db3 (.clk(clk), .btn_in(conv_start), .btn_pulse(conv_start_pulse));
//    // =====================================================
//    // Convolution DUT
//    // =====================================================
//    wire [7:0] conv_out_data;
//    wire       conv_out_valid;
//    wire       conv_done;
//    reg        conv_out_read;

//    conv_serial_top dut (
//        .clk(clk),
//        .reset(reset),
////        .mem_wr_en(rx_done),
////        .mem_wr_addr(in_len),
////        .mem_wr_data(RxData),
//        .mem_wr_en(rx_done),
//        .mem_wr_addr(rx_wr_ptr),
//        .mem_wr_data(RxData),

//        .start_conv(conv_start_pulse),
//        .conv_done(conv_done),
//        .conv_valid_led(y_valid_led),
//        .out_data(conv_out_data),
//        .out_valid(conv_out_valid),
//        .out_read_en(conv_out_read)
//    );

//    assign conv_done_led = conv_done;
//    assign y_valid_led = conv_out_valid;
//    // =====================================================
//    // Capture convolution output
//    // =====================================================
//    always @(posedge clk or posedge reset) begin
//        if (reset || conv_start_pulse) begin
//            out_len <= 0;
//        end else if (conv_out_valid && out_len < MAX_LEN) begin
//            out_mem[out_len] <= conv_out_data;
//            out_len <= out_len + 1;
//        end
//    end

//    // Read while valid
////    always @(posedge clk or posedge reset) begin
////        if (reset)
////            conv_out_read <= 0;
////        else
////            conv_out_read <= conv_done;
////    end
//    always @(posedge clk or posedge reset) begin
//        if (reset)
//            conv_out_read <= 1'b0;
//        else if (conv_done)
//            conv_out_read <= 1'b1;   // start reading after DONE
//        else
//            conv_out_read <= 1'b0;
//    end

////    always @(posedge clk or posedge reset) begin
////        if (reset)
////            conv_out_read <= 0;
////        else
////            conv_out_read <= conv_out_valid;
////    end


//    // =====================================================
//    // UART TX FSM  (FIXED & SAFE)
//    // =====================================================
//    reg [7:0] tx_data;
//    reg tx_start;
//    wire tx_done;

//    reg [4:0] tx_index;
//    reg [1:0] tx_state;

//    localparam TX_IDLE = 2'd0;
//    localparam TX_IN   = 2'd1;
//    localparam TX_OUT  = 2'd2;

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            tx_state <= TX_IDLE;
//            tx_index <= 0;
//            tx_start <= 0;
//        end else begin
//            tx_start <= 0;

//            case (tx_state)

//                TX_IDLE: begin
//                    if (send_pulse && in_len != 0) begin
//                        tx_state <= TX_IN;
//                        tx_index <= 0;
//                        tx_data  <= in_mem[0];
//                        tx_start <= 1;
//                    end else if (out_pulse && out_len != 0) begin
//                        tx_state <= TX_OUT;
//                        tx_index <= 0;
//                        tx_data  <= out_mem[0];
//                        tx_start <= 1;
//                    end
//                end

//                TX_IN: begin
//                    if (tx_done) begin
//                        if (tx_index < in_len-1) begin
//                            tx_index <= tx_index + 1;
//                            tx_data  <= in_mem[tx_index + 1];
//                            tx_start <= 1;
//                        end else begin
//                            tx_state <= TX_IDLE;
//                        end
//                    end
//                end

//                TX_OUT: begin
//                    if (tx_done) begin
//                        if (tx_index < out_len-1) begin
//                            tx_index <= tx_index + 1;
//                            tx_data  <= out_mem[tx_index + 1];
//                            tx_start <= 1;
//                        end else begin
//                            tx_state <= TX_IDLE;
//                        end
//                    end
//                end

//            endcase
//        end
//    end

//    // =====================================================
//    // UART TX
//    // =====================================================
//    transmitter tx_inst (
//        .clk(clk),
//        .reset(1'b0),
//        .transmit(tx_start),
//        .data(tx_data),
//        .TxD(TxD),
//        .tx_done(tx_done)
//    );

//endmodule


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
