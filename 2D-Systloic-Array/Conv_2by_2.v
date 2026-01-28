
module Con2x2 #(
    parameter dataSize = 8,
    parameter IMG_WIDTH = 4
)(
    input  wire clk,
    input  wire rst,
    input  wire [dataSize-1:0] pixel_in,
    input  wire [dataSize-1:0] w1, w2, w3, w4,
    output wire window_valid_out,
    output wire [2*dataSize+4:0] result_k1
);

    // ================= LINE BUFFERS =================
    reg [dataSize-1:0] row0 [0:IMG_WIDTH-1]; // current row
    reg [dataSize-1:0] row1 [0:IMG_WIDTH-1]; // previous row
    integer i;

    // Counters to track filling
    reg [$clog2(IMG_WIDTH+1)-1:0] row0_fill_cnt;
    reg [$clog2(IMG_WIDTH+1)-1:0] row1_fill_cnt;

    // Window enable: latched after both rows are fully filled
    reg window_valid;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row0_fill_cnt <= 0;
            row1_fill_cnt <= 0;
            window_valid  <= 0;
            for (i = 0; i < IMG_WIDTH; i=i+1) begin
                row0[i] <= 0;
                row1[i] <= 0;
            end
        end else begin
            // ---------------- ROW 0 FILLING ----------------
            // Shift row0 forward (0→1→2→...)
            for (i = 0; i < IMG_WIDTH-1; i=i+1)
                row0[i] <= row0[i+1];
            row0[IMG_WIDTH-1] <= pixel_in;

            // Count how many pixels have filled row0
            if (row0_fill_cnt < IMG_WIDTH)
                row0_fill_cnt <= row0_fill_cnt + 1;

            // ---------------- ROW 1 FILLING ----------------
            // Only start filling row1 after row0 is fully filled
            if (row0_fill_cnt == IMG_WIDTH) begin
                for (i = 0; i < IMG_WIDTH-1; i=i+1)
                    row1[i] <= row1[i+1];
                row1[IMG_WIDTH-1] <= row0[0]; // oldest pixel from row0

                // Count how many pixels have filled row1
                if (row1_fill_cnt < IMG_WIDTH-1)
                    row1_fill_cnt <= row1_fill_cnt + 1;
            end

            // ---------------- WINDOW VALID ----------------
            // Generate window_valid only after both rows are full
            if (!window_valid && row0_fill_cnt == IMG_WIDTH && row1_fill_cnt == IMG_WIDTH-1) begin
                window_valid <= 1;
            end
        end
    end

    assign window_valid_out = window_valid;

    // ================= KERNEL INPUT ALIGNMENT =================
    reg [dataSize-1:0] k1_in_top, k1_in_bottom;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            k1_in_top    <= 0;
            k1_in_bottom <= 0;
        end else if (window_valid) begin
            // Always use oldest data in row1 & row0 for top-left / bottom-left
            k1_in_top    <= row1[0];
            k1_in_bottom <= row0[0];
        end
    end

    // ================= KERNEL INSTANCE =================
    kernal_2by2 #(dataSize) kernel1 (
        .clk(clk),
        .rst(rst),
        .en(window_valid),       // kernel starts only when both rows are full
        .in_row1(k1_in_top),
        .in_row2(k1_in_bottom),
        .w1(w1), .w2(w2), .w3(w3), .w4(w4),
        .result(result_k1)
    );

endmodule