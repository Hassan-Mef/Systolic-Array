
module kernal_2by2 #(parameter dataSize = 8)(
    input clk,
    input rst,
    input en,                     // new enable
    input [dataSize-1:0] in_row1, 
    input [dataSize-1:0] in_row2,
    input [dataSize-1:0] w1, w2,
    input [dataSize-1:0] w3, w4,
    output [2* dataSize+4:0] result
);

    wire [dataSize-1:0] pe1_out , pe2_out;
    wire [2*dataSize+1:0] pe1_out_p , pe2_out_p;

    PE pe1 (.clk(clk), 
            .rst(rst), 
            .en(en), 
            .x_in(in_row1), 
            .weight(w1), 
            .p_sum_in({(2*dataSize+2){1'b0}}), 
            .x_out(pe1_out), .p_sum_out(pe1_out_p));

    PE pe2 (.clk(clk), 
            .rst(rst), 
            .en(en), 
            .x_in(pe1_out),   
            .weight(w2), 
            .p_sum_in(pe1_out_p),               
            .x_out(pe2_out), 
            .p_sum_out(pe2_out_p));

    wire [dataSize-1:0] pe3_out , pe4_out;
    wire [2*dataSize+1:0] pe3_out_p , pe4_out_p;

    PE pe3 (.clk(clk), 
    .rst(rst), 
    .en(en), 
    .x_in(in_row2), 
    .weight(w3), 
    .p_sum_in({(2*dataSize+2){1'b0}}),
    .x_out(pe3_out), 
    .p_sum_out(pe3_out_p));


    PE pe4 (.clk(clk), 
    .rst(rst), 
    .en(en), 
    .x_in(pe3_out), 
    .weight(w4),
    .p_sum_in(pe3_out_p),            
    .x_out(pe4_out), 
    .p_sum_out(pe4_out_p));

    assign result = pe2_out_p + pe4_out_p;

endmodule
