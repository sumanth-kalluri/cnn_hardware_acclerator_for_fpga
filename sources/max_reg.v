`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2018 15:13:43
// Design Name: 
// Module Name: max_reg
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


module max_reg(
    input clk,
    input [31:0] din,
    input rst_m,
    input global_rst,
    input master_rst,
    output reg [31:0] reg_op
    );
    always@(posedge clk) begin
    	if(master_rst)
    		reg_op<=0;
    	else begin
		    	if(rst_m) begin
			    	reg_op <=0;
			    end
			    else begin
			    	reg_op<=din;
				end
		end
	end
endmodule

