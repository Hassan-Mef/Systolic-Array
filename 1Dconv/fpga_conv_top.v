//module fpga_conv_top(
//    input  wire clk,
//    input  wire reset,
//    input  wire send_btn,   // trigger TX for output
//    input wire read_btn, // new button to read stored data
//    input  wire RxD,        // UART RX
//    output wire TxD,        // UART TX
//    output wire conv_done_led,
//    output wire y_valid_led,
//    input  wire conv_start // conv start button
//);

//    localparam DATA_WIDTH  = 16;
//    localparam NUM_PE      = 16;
//    localparam BUFFER_SIZE = 64;

//    // --------------------------
//    // Signals for conv_serial_top
//    // --------------------------
//    wire        conv_done;
//    wire        conv_valid;
//    reg         start_conv;
//    reg         mem_wr_en;
//    reg [5:0]   mem_wr_addr;
//    reg [15:0]  mem_wr_data;

//    // --------------------------
//    // UART RX signals
//    // --------------------------
//    wire [7:0] RxData;
//    wire rx_done;
//    reg [5:0] data_index;

//    // --------------------------
//    // UART TX signals
//    // --------------------------
//    reg  [7:0] data_to_tx;
//    reg        start_tx;
//    wire       tx_done;
//    reg        sending;
//    reg  [5:0] tx_index;

//    // Memory to store data received over UART
//    reg [7:0] mem_buffer [0:BUFFER_SIZE-1];
//    reg reading;        // state: are we currently reading mem_buffer?
//    reg [5:0] read_index; // which element we are sending

//    // --------------------------
//    // Instantiate UART Receiver
//    // --------------------------
//    receiver rx_inst (
//        .clk(clk),
//        .reset(reset),
//        .RxD(RxD),
//        .RxData(RxData),
//        .rx_done(rx_done)
//    );
 
//    // --------------------------
//    // Instantiate Convolution Top
//    // --------------------------
//    conv_serial_top #(
//        .DATA_WIDTH(DATA_WIDTH),
//        .NUM_PE(NUM_PE),
//        .BUFFER_SIZE(BUFFER_SIZE)
//    ) conv_inst (
//        .clk(clk),
//        .reset(reset),
//        .mem_wr_en(mem_wr_en),
//        .mem_wr_addr(mem_wr_addr),
//        .mem_wr_data(mem_wr_data),
//        .start_conv(start_conv),
//        .conv_done(conv_done),
//        .conv_valid_led(conv_valid)
//    );

//    // --------------------------
//    // Handle UART RX to write memory
//    // --------------------------
//    always @(posedge clk) begin
//        if (reset) begin
//            data_index <= 0;
//            mem_wr_en  <= 0;
//            start_conv <= 0;
//        end else if (rx_done) begin
//            mem_wr_en   <= 1'b1;
//            mem_wr_addr <= data_index;
//            mem_wr_data <= {8'd0, RxData}; // UART 8-bit -> 16-bit
//            mem_buffer[mem_wr_addr]  <= mem_wr_data; // for storing input data localy
//            data_index  <= data_index + 1;
//        end else begin
//            mem_wr_en <= 0;
//        end
//    end
    
    
    
////    always @(posedge clk) begin
////        if (reset) begin
////            reading    <= 0;
////            read_index <= 0;
////            start_tx   <= 0;
////            sending    <= 0;
////        end else begin
////            start_tx <= 0; // default
////            if (read_btn && !reading && !sending) begin
////                // start reading memory
////                reading    <= 1;
////                read_index <= 0;
////                data_to_tx <= mem_buffer[0]; // send lower 8-bit
////                start_tx   <= 1;
////                sending    <= 1;
////            end else if (reading && tx_done) begin
////                if (read_index < data_index-1) begin
////                    // continue sending next memory data
////                    read_index <= read_index + 1;
////                    data_to_tx <= mem_buffer[read_index+1];
////                    start_tx   <= 1;
////                end else begin
////                    // finished sending
////                    reading <= 0;
////                    sending <= 0;
////                end
////            end
////        end
////    end

//    // Start convolution when last data received (simple example)
//    always @(posedge clk) begin
//        if (conv_start)
//            start_conv <= 1'b1;
//        else
//            start_conv <= 1'b0;
//    end

//    // --------------------------
//    // Optional: TX output from conv
//    // --------------------------
//    // Could be triggered by send_btn (like your rxtx_top)
//    always @(posedge clk) begin
//        start_tx <= 0;
//        if (conv_valid && !sending) begin
//            sending <= 1;
//            tx_index <= 0;
//            data_to_tx <= conv_inst.output_buffer[0][7:0]; // send lower byte first
//            start_tx <= 1;
//        end else if (sending && tx_done) begin
//            if (tx_index < NUM_PE-1) begin
//                tx_index <= tx_index + 1;
//                data_to_tx <= conv_inst.output_buffer[tx_index+1][7:0];
//                start_tx <= 1;
//            end else begin
//                sending <= 0;
//            end
//        end
//    end

//    // --------------------------
//    // Instantiate UART Transmitter
//    // --------------------------
//    transmitter tx_inst (
//        .clk(clk),
//        .reset(reset),
//        .transmit(start_tx),
//        .data(data_to_tx),
//        .TxD(TxD),
//        .tx_done(tx_done)
//    );

//    // LEDs for status
//    assign conv_done_led = conv_done;
//    assign y_valid_led   = conv_valid;

//endmodule
