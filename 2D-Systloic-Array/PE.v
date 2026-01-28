module PE #(parameter dataSize = 8)(
    input  wire clk,
    input  wire rst,
    input  wire en,                 // new enable
    input  wire [dataSize-1:0] x_in,
    input  wire [dataSize-1:0] weight,
    input  wire [2*dataSize+1:0] p_sum_in,
    output reg  [dataSize-1:0] x_out,
    output reg  [2*dataSize+1:0] p_sum_out
);

    reg [dataSize-1:0] x_reg;
    reg [2*dataSize-1:0] mult_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_reg     <= 0;
            mult_reg  <= 0;
            x_out     <= 0;
            p_sum_out <= 0;
        end else if (en) begin

            x_reg <= x_in;
            mult_reg <= x_reg * weight;
            p_sum_out <= p_sum_in + mult_reg;
            x_out <= x_reg;
        end
    end
endmodule
