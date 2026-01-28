
// Datapath - wraps Con2x2 convolution

module systolic_datapath #(
    parameter dataSize = 8,
    parameter IMG_WIDTH = 3
)(
    input  wire clk,
    input  wire rst,
    input  wire [dataSize-1:0] pixel_in,

    // weights
    input  wire [dataSize-1:0] w1, w2, w3, w4,

    // window valid output to FSM
    output wire window_valid_out,

    // kernal 
    input wire kernel_load_valid,

    // outputs
    output wire [2*dataSize+4:0] result_k1,
    output wire [2*dataSize+4:0] result_k2
);

    // Only use Con2x2 module
    Con2x2 #(dataSize, IMG_WIDTH) conv_core (
    .clk(clk),
    .rst(rst),
    .pixel_in(pixel_in),

    .w1(w1), .w2(w2), .w3(w3), .w4(w4),
    .kernel_load_valid(kernel_load_valid),

    .window_valid_out(window_valid_out),
    .result_k1(result_k1)
    );

endmodule


