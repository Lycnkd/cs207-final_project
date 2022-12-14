`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/30 14:41:33
// Design Name: 
// Module Name: turning
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


module turning(
input clk,
input[2:0] state,
output[0:0] turnIsOver
    );

reg[0:0] beginToCount;
reg[0:0] turn;
reg [25:0] cnt;
reg [1:0] record = 2'b00;
wire[0:0] en;
//wire out

always@(posedge clk) begin
            record<={record[0],beginToCount};
            end
            
            assign en = record[0]^record[1];

always@(state) begin
case(state)
3'b110:beginToCount=1'b1;
//turnIsOver=1'b0;
default:beginToCount=1'b0;
//turnIsOver=1'b0;
endcase
end

//always@(state) begin
//case(state)
////3'b110:beginToCount=1'b1;
//3'b110:turn=1'b0;
////default:beginToCount=1'b0;
//default:turn=1'b0;
//endcase
//end

always@(posedge clk) begin
if(en==1'b1)begin
cnt<=0;
end
if(en==1'b0&&beginToCount)begin
cnt<=cnt+1;
end
if(cnt==26'd50000000)begin
                        turn=1'b1;
                        //cnt<=0;
                        end
if(state==3'b000||state==3'b001||state==3'b010||state==3'b011||state==3'b100||state==3'b101||state==3'b111)begin
turn=1'b0;
end
end

assign turnIsOver=turn;
endmodule
