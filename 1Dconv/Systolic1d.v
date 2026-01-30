`timescale 1ns/1ps

module systolic_conv_1D #(
    parameter NUM_PE = 16,
    parameter DATA_WIDTH = 8
)(
    input  wire clk,
    input  wire reset,

    input  wire [4:0] active_pe_count,   // log2(16)=4 use 5 bits

    input  wire [NUM_PE*DATA_WIDTH-1:0] kernel_row_flat,

    input  wire [DATA_WIDTH-1:0] x_in,
    input  wire x_valid,

    output wire [DATA_WIDTH-1:0] y_out,
    output wire y_valid
);
    reg [4:0] drain_cnt;
    reg draining;

    // ----------------------------
    // Kernel unpacking
    // ----------------------------
    wire [DATA_WIDTH-1:0] kernel_row [0:NUM_PE-1];

    genvar kk;
    generate
        for (kk = 0; kk < NUM_PE; kk = kk + 1) begin : KERNEL_UNPACK
            assign kernel_row[kk] =
                kernel_row_flat[kk*DATA_WIDTH +: DATA_WIDTH];
        end
    endgenerate

    // ----------------------------
    // Systolic buses
    // ----------------------------
    wire [DATA_WIDTH-1:0] x_bus [0:NUM_PE];
    wire [DATA_WIDTH-1:0] y_bus [0:NUM_PE];
    wire                  v_bus [0:NUM_PE];

    assign x_bus[0] = x_in;
    assign y_bus[0] = {DATA_WIDTH{1'b0}};
    assign v_bus[0] = x_valid;

    // ----------------------------
    // PE array
    // ----------------------------
    genvar k;
    generate
        for (k = 0; k < NUM_PE; k = k + 1) begin : PE_ARRAY
            systolic_pe u_pe (
                .clk       (clk),
                .reset     (reset),
                .enable    (k < active_pe_count),

                .valid_in  (v_bus[k]),
                .x_in      (x_bus[k]),
                .y_in      (y_bus[k]),
                .h         (kernel_row[k]),

                .valid_out (v_bus[k+1]),
                .x_out     (x_bus[k+1]),
                .y_out     (y_bus[k+1])
            );
        end
    endgenerate
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            draining  <= 0;
            drain_cnt <= 0;
        end else begin
            // Start draining when input valid drops
            if (x_valid) begin
                draining  <= 1;
                drain_cnt <= active_pe_count+1;
            end else if (draining && drain_cnt != 0) begin
                drain_cnt <= drain_cnt - 1;
            end else if (drain_cnt == 0) begin
                draining <= 0;
            end
        end
    end

    // ----------------------------
    // Output select
    // ----------------------------
    assign y_out   = y_bus[active_pe_count];
    assign y_valid = v_bus[active_pe_count] || draining;

//    assign y_valid = v_bus[active_pe_count];

endmodule
