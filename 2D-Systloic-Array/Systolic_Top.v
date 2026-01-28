
// Top module - integrates FSM + Datapath

module Systolic_top_module #(
    parameter IMG_WIDTH  = 3,
    parameter IMG_HEIGHT = 3,
    parameter DATA_SIZE  = 8,
    parameter KERNEL_SIZE = 2,
    parameter PIPE_LAT   = 4
)(
    input  wire clk,
    input  wire rst,
    input  wire [DATA_SIZE-1:0] data_in,
    input  wire data_in_valid,

    output wire [2*DATA_SIZE+4:0] data_out,
    output wire data_out_valid,
    output img_done
);

    // temp output of second kernel (not used here)
    wire [2*DATA_SIZE+4:0] data_out_2;
    wire window_valid;

    // ---------------- FSM ----------------
    systolic_FSM #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .KERNEL_SIZE(KERNEL_SIZE),
        .PIPE_LAT(PIPE_LAT)
    ) fsm_inst (
        .clk(clk),
        .rst(rst),
        .window_valid(window_valid),
        .data_out_valid(data_out_valid),
        .image_done(img_done)
    );


    // ---------------- Datapath ----------------
    systolic_datapath #(DATA_SIZE, IMG_WIDTH) datapath_inst (
        .clk(clk),
        .rst(rst),
        .pixel_in(data_in),
        .w1(8'd3), .w2(8'd1), .w3(8'd7), .w4(8'd5),
        .window_valid_out(window_valid),
        .result_k1(data_out)
    );

endmodule
