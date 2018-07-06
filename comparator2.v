`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2018 16:42:52
// Design Name: 
// Module Name: comparator2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module comparator2(
    input [31:0] ip1,
    input [31:0] ip2,
    output [31:0] comp_op);
    
    assign comp_op = (ip1>ip2)?ip1:ip2;
endmodule
//master_rst?32'h0:(rst?(32'h0):