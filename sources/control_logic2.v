`timescale 1ns / 1ps

//1. normal case : just store the max value in the register.  
//2. end of one neighbourhood: store the max value to the shift register.
//3. end of row: store the max value in the shift register and then load the max register from the shift register.
//4. end of neighbourhood in the last row: make output valid and store the max value in the max register.
//5. end of last neighbourhood of last row: make op valid and store the max value in the max register and then reset the entire module.

//SIGNALS TO BE HANDLED IN EACH CASE
//CASE               1		 2		 3 	 	 4		 5 
//1. load _sr       low	    high	high	high	low			
//2. sel			low		low	   	high	high	low
//3. rst_m			low		high	low		low		low
//4. op_en			low		low		low		high	high
//5. global_rst		low		low		low		low		high

module control_logic2(
    input clk,
    input master_rst,
    input ce,
    output reg [1:0] sel,
    output reg rst_m,
    output reg op_en,
    output reg load_sr,
    output reg global_rst,
    output reg end_op
    );

    parameter m = 9'h01a;
    parameter p = 9'h002;
    integer row_count =0;
    integer col_count =0;
    integer count =0;
    integer nbgh_row_count;

    always@(posedge clk) begin 
        if(master_rst) begin
        sel <=0;
        load_sr <=0;
        rst_m <=0;
        op_en <=0;
        global_rst <=0;
        end_op <=0;
        end
        else begin
        if(((col_count+1)%p !=0)&&(row_count == p-1)&&(col_count == p*count+ (p-2))&&ce) begin     //op_en
        op_en <=1;
        end 
        else begin
        op_en <=0;
        end
            if(ce) begin
                if(nbgh_row_count == m/p) begin     //end_op
                end_op <=1;
                end
                else begin
                end_op <=0;
                end

                if(((col_count+1) % p != 0)&&(col_count == m-2)&&(row_count == p-1)) begin     //global_rst and pause_ip
                global_rst <= 1;                           //  (reset everything)
                end
                else begin
                global_rst <= 0;
                end  
                
                

                //end

                if((((col_count+1) % p == 0)&&(count != m/p-1)&&(row_count != p-1))||((col_count == m-1)&&(row_count == p-1))) begin     //rst_m
                rst_m <= 1;              
                end  
                else begin
                rst_m <= 0;
                end   
                
                
                if(((col_count+1) % p != 0)&&(col_count == m-2)&&(row_count == p-1)) begin
                sel <= 2'b10;
                end
                else begin
                if((((col_count) % p == 0)&&(count == m/p-1)&&(row_count != p-1))|| (((col_count) % p == 0)&&(count != m/p-1)&&(row_count == p-1))) begin     //sel
                sel<=2'b01;
                end 
                else begin
                sel <= 2'b00;
                end
                end

                if((((col_count+1) % p == 0)&&((count == m/p-1)))||((col_count+1) % p == 0)&&((count != m/p-1))) begin     //load_sr
                load_sr <= 1;                                 //&&(row_count!=p-1)
                end 
                else begin
                load_sr <= 0;
                end
            end
        end 
    end 
    always@(posedge clk) begin            //counters
        if(master_rst) begin
        row_count <=0;
        col_count <=32'hffffffff;
        count <=32'hffffffff;
        nbgh_row_count <=0;
        end
        else begin
            if(ce) begin
                if(global_rst) begin
                   row_count <=0;
                   col_count <=32'h0;//ffffffff;
                   count <=32'h0;//ffffffff;
                   nbgh_row_count <= nbgh_row_count + 1'b1; 
                end
                else begin
                    if(((col_count+1) % p == 0)&&(count == m/p-1)&&(row_count != p-1)) begin   //col_count and row_count
                        col_count <= 0;
                        row_count <= row_count + 1'b1;
                        count <=0;
                    end
                    else begin
                        col_count<=col_count+1'b1;
                        if(((col_count+1) % p == 0)&&(count != m/p-1)) begin
                            count <= count+ 1'b1;
                        end 
                    end
                end
            end
        end  
    end 
    endmodule
