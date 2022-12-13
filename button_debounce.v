`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/13 21:28:33
// Design Name: 
// Module Name: button_debounce
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


module button_debounce(
input clk,
input button_in,
output button_out
    );
    
    reg [20:0] cnt;
    wire button_clk;
    reg out;
    reg [1:0] record = 2'b00;
    
    always@(posedge clk) begin
    record<={record[0],button_in};
    end
    
    assign button_clk = record[0]^record[1];
    
    always@(posedge clk)begin
    if(button_clk==1)begin
    cnt<=0;
    end
    else begin
    cnt<=cnt+1'b1;
    end
    end
    
    always @(posedge  clk)begin
    if(cnt==21'h1fffff)begin
    out<=record[0];
    end
    end
    
    assign button_out=out;
    //button_out is the final output
    //button_in is related to the button on the hardware
    
endmodule
