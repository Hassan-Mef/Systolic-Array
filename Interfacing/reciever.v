`timescale 1ns / 1ps
module receiver(
    input  wire clk,
    input  wire reset,
    input  wire RxD,
    output wire [7:0] RxData,
    output reg  rx_done        
);
    // =========================
    // PARAMETERS
    // =========================
    localparam CLK_FREQ   = 100_000_000;
    localparam BAUD_RATE  = 9600;
    localparam OVERSAMPLE = 4;
    localparam DIV_COUNT  = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
    localparam MID_SAMPLE = OVERSAMPLE / 2;

    localparam IDLE = 1'b0,
               RX   = 1'b1;

    // =========================
    // REGISTERS
    // =========================
    reg [13:0] clk_cnt;
    reg [1:0]  sample_cnt;
    reg [3:0]  bit_cnt;
    reg [9:0]  shift_reg;
    reg        state, nextstate;

    assign RxData = shift_reg[8:1];  // DATA ONLY (ignore start & stop)

    // =========================
    // SEQUENTIAL LOGIC
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            state      <= IDLE;
            clk_cnt    <= 0;
            sample_cnt <= 0;
            bit_cnt    <= 0;
            shift_reg  <= 0;
            rx_done    <= 0;
        end else begin
            rx_done <= 0; // default

            state <= nextstate;

            if (clk_cnt == DIV_COUNT-1) begin
                clk_cnt <= 0;

                if (state == RX) begin
                    // Sample at middle of bit
                    if (sample_cnt == MID_SAMPLE-1)
                        shift_reg <= {RxD, shift_reg[9:1]};

                    // Oversample counter
                    if (sample_cnt == OVERSAMPLE-1) begin
                        sample_cnt <= 0;
                        bit_cnt <= bit_cnt + 1;

                        // Done after stop bit
                        if (bit_cnt == 9)
                            rx_done <= 1;   // FULL BYTE RECEIVED
                    end else begin
                        sample_cnt <= sample_cnt + 1;
                    end
                end
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
            if (state == IDLE) begin
                sample_cnt <= 0;
                bit_cnt <= 0;
            end
        end
    end

    // =========================
    // FSM
    // =========================
    always @(*) begin
        nextstate = state;

        case (state)
            IDLE: begin
                if (!RxD)            // start bit detected
                    nextstate = RX;
            end
            RX: begin
                if (bit_cnt == 10)   // start + 8 data + stop
                    nextstate = IDLE;
            end
        endcase
    end

endmodule
