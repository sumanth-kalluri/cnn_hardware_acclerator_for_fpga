`timescale 1ns / 1ps

module pooler(
    input clk,
    input ce,
    input master_rst,
    input [31:0] data_in,
    output [31:0] data_out,
    output valid_op,
    output end_op
    );
    wire rst_m,op_en,pause_ip,load_sr,global_rst;
    wire [1:0] sel;
    wire [31:0] comp_op;
    wire [31:0] Q;
    wire [31:0] reg_op;
    wire [31:0] mux_out;
    wire temp_rst;
    parameter m = 9'h00c;
    parameter p = 9'h003;
    assign temp_rst = master_rst;
    control_logic2 #(m,p) log(
	    clk,
	    master_rst,
	    ce,
	    sel,
	    rst_m,
	    valid_op,
	    load_sr,
	    global_rst,
	    end_op);
    
    comparator2 cmp(
	    data_in,
	    mux_out,
	    comp_op);
  wire temp2;
    
    max_reg m1(
    	clk,
	    comp_op,
	    rst_m,
	    temp2,
	    master_rst,
	    reg_op);
    
    reg [31:0] temp;
    c_shift_ram_0 SR (
      .A((m/p)-4),        // input wire [8 : 0] A
      .D(comp_op),        // input wire [31 : 0] D
      .CLK(clk),    // input wire CLK
      .CE(load_sr),      // input wire CE
      .SCLR(global_rst&&temp_rst),  // input wire SCLR
      .Q(Q)        // output wire [31 : 0] Q
    );

   input_mux mux(Q,reg_op,sel,mux_out);
   assign data_out = reg_op;
endmodule
