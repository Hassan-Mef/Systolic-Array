module button_debounce (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_pulse
);
 reg [19:0] cnt = 0;
    reg btn_sync = 0;
    reg btn_prev = 0;
    always @(posedge clk) begin
        // Synchronize
        btn_sync <= btn_in;
        // Debounce counter
        if (btn_sync == btn_prev) begin
            if (cnt < 20'd1_000_000)
                cnt <= cnt + 1;
        end else begin
            cnt <= 0;
        end
        // Stable press detected ? generate pulse
        btn_pulse <= (cnt == 20'd999_999) && btn_sync;
        btn_prev <= btn_sync;
    end
endmodule
