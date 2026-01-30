module systolic_pe #(
    parameter DATA_WIDTH = 8
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     enable,

    input  wire                     valid_in,

    input  wire [DATA_WIDTH-1:0]    x_in,
    input  wire [DATA_WIDTH-1:0]    y_in,
    input  wire [DATA_WIDTH-1:0]    h,

    output reg                      valid_out,
    output reg  [DATA_WIDTH-1:0]    x_out,
    output reg  [DATA_WIDTH-1:0]    y_out
);

    reg [DATA_WIDTH-1:0] x_reg,mul;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_reg    <= 0;
            x_out    <= 0;
            y_out    <= 0;
            valid_out <= 0;
        end else if (enable) begin
            x_reg     <= x_in;
            x_out     <= x_reg;
            // mul       <= x_in * h;
            mul       <= x_reg * h;
            y_out     <= y_in + mul;
            // y_out     <= y_in + (x_in * h);
            // y_out     <= y_in + (x_reg * h);
            valid_out <= valid_in;
        end else begin
            valid_out <= valid_in;
        end
    end

endmodule
