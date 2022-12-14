`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/13 22:55:41
// Design Name: 
// Module Name: oneSecond
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


module oneSecond(
input clk,
input button_in,
output button_out
    );
    
    reg [26:0] cnt;
    wire button_clk;
    reg out;
    reg [1:0] record = 2'b00;
    
    always@(posedge clk) begin
        record<={record[0],button_in};
        end
        
        assign button_clk = record[0]^record[1];
    
    always@(posedge clk)begin
            if(button_clk==1'b1)begin
            cnt<=0;
            end
            else if(record[0]==1'b1&&record[1]==1'b1) begin
            cnt<=cnt+1'b1;
            end
            else begin
            cnt<=0;
            end
            end
            
            always @(posedge  clk,negedge button_in)begin
                if(cnt==27'd100000000)begin
                out<=record[0];
                end
                if(~button_in)begin
                                out<=1'b0;
                                end
                end
                
    assign button_out=out;
endmodule
