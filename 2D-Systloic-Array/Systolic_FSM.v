
// Systolic FSM - controls valid output timing
// GPT made it work ( wooooooow) 


module systolic_FSM #(
    parameter IMG_WIDTH   = 3,
    parameter IMG_HEIGHT  = 6,
    parameter KERNEL_SIZE = 2,
    parameter PIPE_LAT    = 4
)(
    input  wire clk,
    input  wire rst,

    input  wire window_valid,   // from datapath (correct timing)

    output reg  data_out_valid,
    output reg  image_done
);

    localparam VALID_PER_ROW =
        IMG_WIDTH - KERNEL_SIZE + 1;

    localparam TOTAL_OUTPUTS =
        (IMG_WIDTH  - KERNEL_SIZE + 1) *
        (IMG_HEIGHT - KERNEL_SIZE + 1);

    reg [PIPE_LAT-1:0] valid_pipe;
    reg [$clog2(VALID_PER_ROW):0] row_cnt;
    reg [15:0] valid_out_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_pipe     <= 0;
            row_cnt        <= 0;
            valid_out_cnt  <= 0;
            data_out_valid <= 0;
            image_done     <= 0;
        end else begin
            // pipeline datapath window-valid
            valid_pipe[0] <= window_valid;
            valid_pipe[PIPE_LAT-1:1] <= valid_pipe[PIPE_LAT-2:0];

            data_out_valid <= 0;
            image_done     <= 0;

            if (valid_pipe[PIPE_LAT-1]) begin
                if (row_cnt < VALID_PER_ROW) begin
                    // VALID cycle
                    data_out_valid <= 1;
                    row_cnt <= row_cnt + 1;

                    valid_out_cnt <= valid_out_cnt + 1;

                    // image_done aligned with LAST valid
                    if (valid_out_cnt + 1 == TOTAL_OUTPUTS)
                        image_done <= 1;
                end else begin
                    // INVALID gap between rows
                    data_out_valid <= 0;
                    row_cnt <= 0;
                end
            end
        end
    end
endmodule


