`timescale 1ns / 1ps

module convolver_tb2;

    `define n 9'h00a
    `define k 9'h005
    `define tn 0
    `define c_size 32
   
	// Inputs
	reg clk;
	reg ce;
	reg [`k*`k*16-1:0] weight1;
	reg global_rst;
	reg [15:0] activation;
 
	// Outputs
	wire [31:0] conv_op;
	wire end_conv;
	wire valid_conv;
	integer ip_file,op_file,ch;
	reg [15:0] weight [0:((`n)*(`n))-1];
	reg [15:0] activations [0:(`k*`k)-1];
	integer r1,r2,i,j,l,m,r3,r4;
	reg [23:0] endc = "EoT"; 
	parameter clkp = 2;
	// Instantiate the Unit Under Test (UUT)
		convolver #(`n,`k,`c_size) uut (
                .clk(clk), 
                .ce(ce), 
                .weight1(weight1), 
                .global_rst(global_rst), 
                .activation(activation), 
                .conv_op(conv_op), 
                .end_conv(end_conv), 
                .valid_conv(valid_conv)
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
		r3 = $fscanf(ip_file,"%h\n",activations[i]);
		end
		for(j=0;j<`n*`n;j = j+1) begin
		r4 = $fscanf(ip_file,"%h",weight[j]);
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
		weight1[l*16 +: 16] = activations[l];
		end
		$display("weights loading done");
	
		ce = 1;
		for(m = 0;m<`n*`n;m=m+1)begin
		activation = weight[m];
		#clkp;
		end
end
      always@(posedge clk) begin
		if(valid_conv&!end_conv) begin 
		$fdisplay(op_file,"%h",conv_op); 
		end
		if(end_conv) begin
		if(ce)
		begin
		$fdisplay(op_file,"%s%0d",endc,`tn);
	   $finish;
		end
		end
		end
		

      always #(clkp/2) clk = ~clk;
endmodule
