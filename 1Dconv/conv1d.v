`timescale 1ns/1ps

module systolic_conv_1D_top #(
    parameter NUM_PE     = 16,
    parameter DATA_WIDTH = 8
)(
    input  wire clk,
    input  wire reset,

    input  wire [4:0] active_pe_count,   // log2(16)=4 ? use 5 bits

    input  wire kernel_load,
    input  wire [DATA_WIDTH-1:0] kernel_value,

    input  wire [DATA_WIDTH-1:0] x_in,
    input  wire x_valid,

    output wire [DATA_WIDTH-1:0] y_out,
    output wire y_valid
);

    reg [NUM_PE*DATA_WIDTH-1:0] kernel_row_flat;
    reg [4:0] kernel_index;

    integer k;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            kernel_index <= 0;
            kernel_row_flat <= {NUM_PE*DATA_WIDTH{1'b0}};
        end else if (kernel_load) begin
            kernel_row_flat[kernel_index*DATA_WIDTH +: DATA_WIDTH]
                <= kernel_value;

            if (kernel_index == active_pe_count - 1)
                kernel_index <= 0;
            else
                kernel_index <= kernel_index + 1;
        end
    end

    systolic_conv_1D #(
        .NUM_PE(NUM_PE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_conv_1d (
        .clk(clk),
        .reset(reset),
        .active_pe_count(active_pe_count),
        .kernel_row_flat(kernel_row_flat),
        .x_in(x_in),
        .x_valid(x_valid),
        .y_out(y_out),
        .y_valid(y_valid)
    );

endmodule
