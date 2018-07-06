`timescale 1ns / 1ps

module convolver(clk,ce,weight1,global_rst,activation,conv_op,end_conv,valid_conv);

`define UNPACK_ARRAY(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC)  genvar unpk_idx;  for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) begin; assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx) +: PK_WIDTH]; end     

parameter n = 9'h00a;
parameter k = 9'h003;
input clk,ce,global_rst;
input [15:0] activation;
input wire [(k*k)*16-1:0] weight1;
wire [15:0] weight [0:k*k-1];
output [31:0] conv_op;
output valid_conv,end_conv;
wire [31:0] tmp [k*k+1:0];
integer j;

`UNPACK_ARRAY(16,k*k,weight,weight1)
assign tmp[0] = 32'h0000000;
generate
genvar i;
for(i = 0;i<k*k;i=i+1)
begin: MAC
if((i+1)%k ==0)    //end of the row
begin
if(i==k*k-1) //end of convolver
begin
mac_manual mac(                     //implements a*b+c
  .clk(clk), // input clk
  .ce(ce), // input ce
  .sclr(global_rst), // input sclr
  .a(activation), // activation input [15 : 0] a
  .b(weight[i]), // weight input [15 : 0] b
  .c(tmp[i]), // previous mac sum input [32 : 0] c
  .p(conv_op) // output [32 : 0] p
  );
end
else
begin
wire [31:0] tmp2;
//make a mac unit
mac_manual mac(                     //implements a*b+c
  .clk(clk), // input clk
  .ce(ce), // input ce
  .sclr(global_rst), // input sclr
  .a(activation), // activation input [15 : 0] a
  .b(weight[i]), // weight input [15 : 0] b
  .c(tmp[i]), // previous mac sum input [33 : 0] c
  .p(tmp2) // output [33 : 0] p
  );

//make a shift register unit
c_shift_ram_0 SR (
  .A(n-k-9'h004), // input [8 : 0] a
  .D(tmp2), // input [32 : 0] d
  .CLK(clk), // input clk
  .CE(ce), // input ce
  .SCLR(global_rst), // input sclr
  .Q(tmp[i+1]) // output [32 : 0] q
  );
end
end
else
begin
mac_manual mac2(                     //implements a*b+c
  .clk(clk), // input clk
  .ce(ce), // input ce
  .sclr(global_rst), // input sclr
  .a(activation), // activation input [15 : 0] a
  .b(weight[i]), // weight input [15 : 0] b
  .c(tmp[i]), // previous mac sum input [31 : 0] c
  .p(tmp[i+1]) // output [31 : 0] p
  );
end 
end 
endgenerate


reg [31:0] count,count2,count3;
reg en1,en2;
always@(posedge clk) begin


if(global_rst)
begin
count <=0;
count2<=0;
count3<=0;
en1<=0;
en2<=1;
end

else if(ce)
begin

if(count == (k-1)*n+k-1)
begin
en1 <= 1'b1;
count <= count+1'b1;
end
else
begin 
//en1<= 1'b0;
count<= count+1'b1;
end

end
if(en1 && en2) begin

if(count2 == n-k)
begin 
count2<=0;
en2 <=0 ;
end

else begin
count2 <= count2+1'b1;
end

end

if(~en2) begin
if(count3 == k-2) begin
count3<=0;
en2 <= 1'b1;
end
else
count3 <= count3 + 1'b1;
end
end

assign end_conv = (count>= n*n+2)?1'b1:1'b0;
assign valid_conv = (en1&&en2);
  

endmodule
