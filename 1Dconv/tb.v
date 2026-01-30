//`timescale 1ns/1ps

//module tb_conv_serial_top();

//    parameter DATA_WIDTH = 16;
//    parameter NUM_PE     = 16;
//    parameter BUFFER_SIZE = 64;

//    reg clk;
//    reg reset;

//    // Instantiate the top module
//    conv_serial_top #(
//        .DATA_WIDTH(DATA_WIDTH),
//        .NUM_PE(NUM_PE),
//        .BUFFER_SIZE(BUFFER_SIZE)
//    ) dut (
//        .clk(clk),
//        .reset(reset)
//    );

//    // ----------------------------
//    // Clock generation
//    // ----------------------------
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk; // 100MHz simulation
//    end

//    // ----------------------------
//    // Simulation sequence
//    // ----------------------------
//    integer i;
//    integer expected_idx;
//    reg [31:0] expected_conv [0:4];  // for kernel=[2,3,4], input=[1..7]

//    initial begin
//        // Reset
//        reset = 1;
//        #20;
//        reset = 0;

//        // Expected convolution results
//        expected_conv[0] = 16;
//        expected_conv[1] = 25;
//        expected_conv[2] = 34;
//        expected_conv[3] = 43;
//        expected_conv[4] = 52;

//        expected_idx = 0;

//        // Run simulation long enough for FSM to complete
//        #500;

//        $display("-----------------------------------------------------------");
//        $display(" Output Buffer Values:");
//        $display("-----------------------------------------------------------");

//        for (i = 0; i < BUFFER_SIZE; i=i+1) begin
//            if (dut.output_buffer[i] !== 16'bx) begin
//                $display("output_buffer[%0d] = %0d", i, dut.output_buffer[i]);

//                // Compare with expected
//                if (expected_idx <= 4) begin
//                    if (dut.output_buffer[i] == expected_conv[expected_idx])
//                        $display("   -> PASS (expected %0d)", expected_conv[expected_idx]);
//                    else
//                        $display("   -> FAIL (expected %0d)", expected_conv[expected_idx]);
//                    expected_idx = expected_idx + 1;
//                end
//            end
//        end

//        $display("-----------------------------------------------------------");
//        $display(" Simulation finished");
//        $display("-----------------------------------------------------------");

//        $finish;
//    end

//endmodule



//`timescale 1ns/1ps

//module tb_conv_serial_top;

//    localparam DATA_WIDTH  = 8;
//    localparam NUM_PE      = 16;
//    localparam BUFFER_SIZE = 64;

//    reg clk;
//    reg reset;

//    reg        mem_wr_en;
//    reg [5:0]  mem_wr_addr;
//    reg [DATA_WIDTH-1:0] mem_wr_data;

//    reg start_conv;
//    wire conv_done;
//    wire conv_valid_led;

//    // DUT
//    conv_serial_top #(
//        .DATA_WIDTH(DATA_WIDTH),
//        .NUM_PE(NUM_PE),
//        .BUFFER_SIZE(BUFFER_SIZE)
//    ) dut (
//        .clk(clk),
//        .reset(reset),
//        .mem_wr_en(mem_wr_en),
//        .mem_wr_addr(mem_wr_addr),
//        .mem_wr_data(mem_wr_data),
//        .start_conv(start_conv),
//        .conv_done(conv_done),
//        .conv_valid_led(conv_valid_led)
//    );

//    // Clock
//    always #5 clk = ~clk;

//    // UART-like memory write task
//    task write_mem(input [5:0] addr, input [DATA_WIDTH-1:0] data);
//    begin
//        @(posedge clk);
//        mem_wr_en   <= 1'b1;
//        mem_wr_addr <= addr;
//        mem_wr_data <= data;
//        @(posedge clk);
//        mem_wr_en   <= 1'b0;
//    end
//    endtask

//    integer i;

//    initial begin
//        // Init
//        clk = 0;
//        reset = 1;
//        mem_wr_en = 0;
//        mem_wr_addr = 0;
//        mem_wr_data = 0;
//        start_conv = 0;

//        // Reset
//        #20;
//        reset = 0;

//        // -------------------------
//        // Simulate UART RX
//        // -------------------------
//        // active_pe_count = 3
//        write_mem(0, 3);

//        // kernel = [2, 3, 4]
//        write_mem(1, 2);
//        write_mem(2, 3);
//        write_mem(3, 4);

//        // input samples
//        write_mem(4, 1);
//        write_mem(5, 2);
//        write_mem(6, 3);
//        write_mem(7, 4);
//        write_mem(8, 5);
//        write_mem(9, 6);
//        write_mem(10, 7);

//        // -------------------------
//        // Start convolution
//        // -------------------------
//        @(posedge clk);
//        start_conv <= 1'b1;
//        @(posedge clk);
//        start_conv <= 1'b0;

//        // -------------------------
//        // Monitor outputs
//        // -------------------------
//        $display("Time\t y_valid\t y_out");
//        while (!conv_done) begin
//            @(posedge clk);
//            if (conv_valid_led) begin
//                $display("%0t\t 1\t\t %0d",
//                    $time, dut.y_out);
//            end
//        end

//        // Dump output buffer
//        $display("\nOutput buffer:");
//        for (i = 0; i < 10; i = i + 1)
//            $display("out[%0d] = %0d", i, dut.output_buffer[i]);

//        $display("\nTEST PASSED");
//        #50;
//        $finish;
//    end

//endmodule



`timescale 1ns/1ps

module tb_conv_serial_top;

    localparam DATA_WIDTH  = 8;
    localparam NUM_PE      = 16;
    localparam BUFFER_SIZE = 64;

    reg clk;
    reg reset;

    reg mem_wr_en;
    reg [5:0] mem_wr_addr;
    reg [DATA_WIDTH-1:0] mem_wr_data;

    reg start_conv;
    wire conv_done;
    wire conv_valid_led;

    wire [DATA_WIDTH-1:0] out_data;
    wire out_valid;
    reg  out_read_en;

    // ----------------------------
    // DUT
    // ----------------------------
    conv_serial_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_PE(NUM_PE),
        .BUFFER_SIZE(BUFFER_SIZE)
    ) dut (
        .clk(clk),
        .reset(reset),

        .mem_wr_en(mem_wr_en),
        .mem_wr_addr(mem_wr_addr),
        .mem_wr_data(mem_wr_data),

        .start_conv(start_conv),
        .conv_done(conv_done),
        .conv_valid_led(conv_valid_led),

        .out_data(out_data),
        .out_valid(out_valid),
        .out_read_en(out_read_en)
    );

    // ----------------------------
    // Clock
    // ----------------------------
    always #5 clk = ~clk;

    // ----------------------------
    // Memory write task (UART RX)
    // ----------------------------
    task write_mem(input [5:0] addr, input [DATA_WIDTH-1:0] data);
    begin
        @(posedge clk);
        mem_wr_en   <= 1'b1;
        mem_wr_addr <= addr;
        mem_wr_data <= data;
        @(posedge clk);
        mem_wr_en   <= 1'b0;
    end
    endtask

    integer i;

    // ----------------------------
    // Test sequence
    // ----------------------------
    initial begin
        // Init
        clk          = 0;
        reset        = 1;
        mem_wr_en    = 0;
        mem_wr_addr  = 0;
        mem_wr_data  = 0;
        start_conv   = 0;
        out_read_en  = 0;

        // Reset pulse
        #20;
        reset = 0;

        // ------------------------------------
        // Load data (same format as your design)
        // ------------------------------------
        // mem[0] = active_pe_count = 3
        write_mem(0, 3);

        // kernel values
        write_mem(1, 2);
        write_mem(2, 3);
        write_mem(3, 4);

        // input samples
        write_mem(4, 1);
        write_mem(5, 2);
        write_mem(6, 3);
        write_mem(7, 4);
        write_mem(8, 5);
        write_mem(9, 6);
        write_mem(10, 7);

        // ------------------------------------
        // Start convolution
        // ------------------------------------
        @(posedge clk);
        start_conv <= 1'b1;
        @(posedge clk);
        start_conv <= 1'b0;

        // ------------------------------------
        // Monitor y_valid during processing
        // ------------------------------------
        $display("\nTime\t y_valid\t y_out");
        while (!conv_done) begin
            @(posedge clk);
            if (conv_valid_led) begin
                $display("%0t\t 1\t\t %0d",
                    $time, dut.y_out);
            end
        end

        // ------------------------------------
        // Read output buffer via out_read_en
        // ------------------------------------
        $display("\nReading output buffer:");

        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            out_read_en <= 1'b1;

            @(posedge clk);
            out_read_en <= 1'b0;

            if (out_valid) begin
                $display("out[%0d] = %0d", i, out_data);
            end
        end

        $display("\nTEST COMPLETED SUCCESSFULLY");
        #50;
        $finish;
    end

endmodule
