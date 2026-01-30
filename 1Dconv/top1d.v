`timescale 1ns/1ps

module conv_serial_top #(
    parameter DATA_WIDTH  = 8,
    parameter NUM_PE      = 16,
    parameter BUFFER_SIZE = 64
)(
    input wire clk,
    input wire reset,
    input  wire        mem_wr_en,
    input  wire [5:0]  mem_wr_addr,
    input  wire [DATA_WIDTH-1:0] mem_wr_data,
    
    input  wire        start_conv,
    output wire        conv_done,
    output wire        conv_valid_led,
    
    output reg [DATA_WIDTH-1:0] out_data,
    output reg                  out_valid,
    input  wire                 out_read_en


);

    // ----------------------------
    // Local parameters
    // ----------------------------
    // log2(NUM_PE) = 4 for NUM_PE=16
    localparam PE_W = 4;

    // FSM state encoding
    localparam IDLE         = 3'd0;
    localparam READ_PE      = 3'd1;
    localparam LOAD_KERNEL  = 3'd2;
    localparam STREAM_INPUT = 3'd3;
    localparam STORE_OUTPUT = 3'd4;
    localparam DONE         = 3'd5;
    localparam DRAIN = 3'd6;

    // ----------------------------
    // Internal buffers
    // ----------------------------
    reg [DATA_WIDTH-1:0] mem_buffer    [0:BUFFER_SIZE-1];
    reg [DATA_WIDTH-1:0] output_buffer [0:BUFFER_SIZE-1];

    // ----------------------------
    // FSM & control signals
    // ----------------------------
    reg [2:0] state;
    reg [PE_W:0] active_pe_count;
    reg [DATA_WIDTH-1:0] kernel_value;
    reg kernel_load;
    reg [DATA_WIDTH-1:0] x_in;
    reg x_valid;

    wire [DATA_WIDTH-1:0] y_out;
    wire y_valid;

    integer read_ptr;
    integer write_ptr;
    integer i;

    // ----------------------------
    // Instantiate convolution core
    // ----------------------------
    systolic_conv_1D_top #(
        .NUM_PE(NUM_PE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_conv_top (
        .clk(clk),
        .reset(reset),
        .active_pe_count(active_pe_count),
        .kernel_load(kernel_load),
        .kernel_value(kernel_value),
        .x_in(x_in),
        .x_valid(x_valid),
        .y_out(y_out),
        .y_valid(y_valid)
    );

    // ----------------------------
    // Sample counter
    // ----------------------------
    reg [PE_W:0] sample_count;
    reg store_enable;

//    always @(posedge clk or posedge reset) begin
//        if (reset)
//            sample_count <= 0;
//        else if (x_valid)
//            sample_count <= sample_count + 1;
//    end
    always @(posedge clk or posedge reset) begin
        if (reset || state == IDLE)
            sample_count <= 0;
        else if (x_valid)
            sample_count <= sample_count + 1;
    end

    always @(*) begin
        store_enable = (sample_count >= active_pe_count);
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
        end else if (y_valid) begin
            output_buffer[write_ptr] <= y_out;
            write_ptr <= write_ptr + 1;
        end
    end
    // for writing data
    always @(posedge clk) begin
        if (mem_wr_en) begin
            mem_buffer[mem_wr_addr] <= mem_wr_data;
        end
    end
    // for reading data
    reg [5:0] out_rd_ptr;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_rd_ptr <= 0;
            out_valid  <= 0;
        end else if (out_read_en) begin
            out_data  <= output_buffer[out_rd_ptr];
            out_valid <= 1'b1;
            out_rd_ptr <= out_rd_ptr + 1;
        end else begin
            out_valid <= 1'b0;
        end
    end

    // ----------------------------
    // FSM
    // ----------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            read_ptr <= 0;
            write_ptr <= 0;
            kernel_load <= 0;
            x_in <= 0;
            x_valid <= 0;
            kernel_value <= 0;
            active_pe_count <= 0;
        end else begin
            case (state)

//                IDLE: begin
//                    read_ptr <= 0;
//                    write_ptr <= 0;
//                    kernel_load <= 0;
//                    x_valid <= 0;
//                    state <= READ_PE;
//                end
                IDLE: begin
                    if (start_conv) begin
                        read_ptr <= 0;
                        write_ptr <= 0;
                        state <= READ_PE;
                    end
                end


                READ_PE: begin
                    active_pe_count <= mem_buffer[0];
                    read_ptr <= 1;
                    state <= LOAD_KERNEL;
                end

                LOAD_KERNEL: begin
                    if (read_ptr <= active_pe_count) begin
                        kernel_value <= mem_buffer[read_ptr];
                        kernel_load <= 1'b1;
                        read_ptr <= read_ptr + 1;
                    end else begin
                        kernel_load <= 1'b0;
                        state <= STREAM_INPUT;
                    end
                end

                STREAM_INPUT: begin
                    if (read_ptr < BUFFER_SIZE &&
                        mem_buffer[read_ptr] !== {DATA_WIDTH{1'bx}}) begin
                        x_in <= mem_buffer[read_ptr];
                        x_valid <= 1'b1;
                        read_ptr <= read_ptr + 1;
                    end else begin
                        x_valid <= 1'b0;
//                        write_ptr <= 0;
//                        state <= STORE_OUTPUT;
                        state <= DRAIN;
                    end
                end

//                STORE_OUTPUT: begin
//                    if (y_valid && store_enable) begin
//                        output_buffer[write_ptr] <= y_out;
//                        write_ptr <= write_ptr + 1;
//                    end

//                    if (write_ptr >= BUFFER_SIZE ||
//                        mem_buffer[write_ptr] === {DATA_WIDTH{1'bx}}) begin
//                        state <= DONE;
//                    end
//                end
                DRAIN: begin
                    if (!y_valid)
                        state <= DONE;
                end

                DONE: begin
                    x_valid <= 1'b0;
                    kernel_load <= 1'b0;
                end

                default: state <= IDLE;

            endcase
        end
    end
assign conv_done = (state == DONE);
assign conv_valid_led = y_valid;

    // ----------------------------
    // Test initialization
    // ----------------------------
//    initial begin
//        mem_buffer[0]  = 3;
//        mem_buffer[1]  = 2;
//        mem_buffer[2]  = 3;
//        mem_buffer[3]  = 4;
//        mem_buffer[4]  = 1;
//        mem_buffer[5]  = 2;
//        mem_buffer[6]  = 3;
//        mem_buffer[7]  = 4;
//        mem_buffer[8]  = 5;
//        mem_buffer[9]  = 6;
//        mem_buffer[10] = 7;

//        for (i = 11; i < BUFFER_SIZE; i = i + 1)
//            mem_buffer[i] = {DATA_WIDTH{1'bx}};

//        #1000;
//        $display("Simulation finished, output_buffer:");
//        for (i = 0; i < 20; i = i + 1)
//            $display("output_buffer[%0d] = %0d", i, output_buffer[i]);

//        $finish;
//    end

endmodule
