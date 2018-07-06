`timescale 1ns / 1ps

module acclerator_tb2();

`define n 9'h00a
`define k 9'h003
`define p 9'h002 
`define tn 0
//`define c_size 32

reg clk,global_rst,ce;
reg [15:0] activation;
reg [(`k*`k)*16-1:0] weight1;
wire [31:0] data_out;
wire valid_op;
wire end_op;
parameter clkp = 40;
integer ip_file,op_file,ch;
reg [15:0] activations [0:((`n)*(`n))-1];
reg [15:0] weight [0:(`k*`k)-1];
integer r1,r2,i,j,l,m,r3,r4;
reg [23:0] endc = "EoT"; 

acclerator #(`n,`k,`p) dut(
clk,
ce,
weight1,
global_rst,
activation,
data_out,
valid_op,
end_op
 );

initial begin
		// Initialize Inputs
		clk = 0;
		ce = 0;
		weight1 = 0; 
		global_rst = 0; 
		activation = 0;

		// Wait 100 ns for global reset to finish
		#100;
	   ip_file = $fopen("ip_data.txt","r");
	   op_file = $fopen("tb_op.txt","a");	
		for(i=0;i<`k*`k;i=i+1) begin
		r3 = $fscanf(ip_file,"%h\n",weight[i]);
		end
		for(j=0;j<`n*`n;j = j+1) begin
		r4 = $fscanf(ip_file,"%h",activations[j]);
		end
		$display("data loading done");
	
		clk = 0;
		ce = 0; 
		weight1 = 0;
		activation = 0;
		global_rst = 1;
		#(20*clkp);
		
		global_rst = 0;
		for(l =0;l<`k*`k;l=l+1) begin
		weight1[l*16 +: 16] = weight[l];
		end
		$display("weights loading done");
	
		ce = 1;
		for(m = 0;m<`n*`n;m=m+1)begin
		activation = activations[m];
		#clkp;
		end
end 

always@(posedge clk) begin
		if(valid_op&!end_op) begin 
		$fdisplay(op_file,"%h",data_out); 
		end
		if(end_op) begin
		if(ce)
		begin
		$fdisplay(op_file,"%s%0d",endc,`tn);
	   $finish;
		end
		end
end
		

always #(clkp/2) clk = ~clk;

endmodule
