module mac_manual(
    input clk,sclr,ce,
    input [15:0] a,
    input [15:0] b,
    input [31:0] c,
    output reg [31:0] p
    );
 always@(posedge clk,posedge sclr)
 begin
 
 if(sclr)
 begin
 p<=0;
 end
 else if(ce)
 begin
 p <= (a*b+c);
 end
 end
endmodule