`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/14 23:07:01
// Design Name: 
// Module Name: flashing
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


module flashing(
input clk,
input[2:0] state,
input[0:0] direction,
output[0:0] light
    );
    reg[0:0] on;
    reg[0:0] out;
    reg [25:0] cnt;
    reg [1:0] record = 2'b00;
    wire [0:0] flashing;
    
    always@(posedge clk) begin
            record<={record[0],direction};
            end
            
            assign flashing = record[0]^record[1];
    
    always@(state) begin
    case(state)
    000:on=1'b1;
    001:on=1'b1;
    010:on=1'b1;
    011:on=1'b0;
    100:on=1'b0;
    endcase
    end
    
    always@(posedge clk) begin
    if(on==1'b1)begin
    out<=1'b1;
    end
    if(on==1'b0&&direction==1'b0) begin
    out<=1'b0;
    end
    if(on==1'b0&&flashing==1'b1)begin
    cnt<=0;
    out<=1'b1;
    end
    end
    
    always @(posedge  clk)begin
                    if(cnt==26'd50000000)begin
                    out<=~out;
                    end
                    end
    
    assign light=out;
endmodule
