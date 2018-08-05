`timescale 1ns / 1ps

module acclerator(clk,ce,weight1,global_rst,activation,data_out,valid_op,end_op);
    parameter n = 9'h00a;
    parameter k = 9'h003;
    parameter p = 9'h002;
    parameter s = 1;
    input clk,global_rst,ce;
    input [15:0] activation;
    input wire [(k*k)*16-1:0] weight1;
    output [31:0] data_out;
    output valid_op;
    output end_op;
    wire [31:0] conv_op;
    wire valid_conv,end_conv;
    wire valid_ip;
    wire relu_op;
    assign valid_ip = valid_conv&&(!end_conv);
        
    convolver #(n,k,s) conv(
            .clk(clk), 
            .ce(ce), 
            .weight1(weight1), 
            .global_rst(global_rst), 
            .activation(activation), 
            .conv_op(conv_op), 
            .end_conv(end_conv), 
            .valid_conv(valid_conv)
        );
    relu act(conv_op,relu_op);
    
    
    pooler #((n-k+1),p) pool(clk,valid_ip,global_rst,relu_op,data_out,valid_op,end_op);
    
endmodule
