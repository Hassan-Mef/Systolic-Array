`timescale 1ns / 1ps
module transmitter(
    input  wire clk,
    input  wire reset,
    input  wire transmit,
    input  wire [7:0] data,
    output reg  TxD,
    output reg  tx_done
);
    localparam BAUD_COUNT = 10416;
    reg [13:0] baud_cnt;
    reg [3:0]  bit_cnt;
    reg [9:0]  shift_reg;
    reg state, nextstate;
    localparam IDLE = 1'b0,
               SEND = 1'b1;
    always @(posedge clk) begin
        if (reset) begin
            state     <= IDLE;
            baud_cnt  <= 0;
            bit_cnt   <= 0;
            shift_reg <= 10'b1111111111;
            TxD       <= 1'b1;
            tx_done   <= 1'b0;
        end else begin
            state   <= nextstate;
            tx_done <= 1'b0;
            case (state)
                IDLE: begin
                    TxD      <= 1'b1;
                    baud_cnt <= 0;
                    bit_cnt  <= 0;
                    if (transmit) begin
                        shift_reg <= {1'b1, data, 1'b0}; // load frame
                    end
                end
                SEND: begin
                    if (baud_cnt == BAUD_COUNT-1) begin
                        baud_cnt  <= 0;
                        TxD       <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        bit_cnt   <= bit_cnt + 1;
                        if (bit_cnt == 9) begin
                            tx_done <= 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end
    always @(*) begin
        nextstate = state;
        case (state)
            IDLE: begin
                if (transmit)
                    nextstate = SEND;
            end

            SEND: begin
                if (bit_cnt == 10)
                    nextstate = IDLE;
            end
        endcase
    end

endmodule
