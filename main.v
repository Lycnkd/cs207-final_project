`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/06 23:39:58
// Design Name: 
// Module Name: main
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


module main(
input rst_n,clk,//reset and clock
input [0:0] powerOn,powerOff,turnLeft,turnRight,//button
input [0:0] moduleChange,throttle,clutch,brake,rgShift,//switch
output reg [2:0] state,next_state, //??ÊÇ·ñÐèÒª
output reg [0:0] goStraight,goBackward,goLeft,goRight  //move signal
// to be add more
 );
parameter PowerOffState = 3'b000, PowerOnState = 3'b001, NotStaringState = 3'b010, StartingState = 3'b011, MovingState = 3'b100,
           WaitingCommandState = 3'b101, TurnState = 3'b110, StraightForwardState = 3'b111;
 
 always @(posedge clk,negedge rst_n)
    begin
    if(~rst_n)
    begin
      state<= PowerOffState;
      goStraight<=1'b0;
      goBackward<=1'b0;
      goLeft<=1'b0;
      goRight<=1'b0;
    end
    else
      state<=next_state;
    end
    
//    PowerOffState = 3'b000, PowerOnState = 3'b001, NotStaringState = 3'b010, StartingState = 3'b011, MovingState = 3'b100,
//               WaitingCommandState = 3'b101, TurnState = 3'b110, StraightForwardState = 3'b111;
always @(state,powerOn,powerOff,turnLeft,turnRight,moduleChange,throttle,clutch,brake,rgShift)
begin 
case(state)
PowerOffState: if(powerOn) next_state = PowerOnState; else next_state = PowerOffState;
PowerOnState:  if(moduleChange) next_state = NotStaringState; else next_state = WaitingCommandState;
NotStaringState: if(throttle)
                 begin
                 if(clutch==1&&brake==0) 
                  next_state = StartingState;
                 if(clutch==0)
                  next_state = PowerOffState;
                end
                else next_state = NotStaringState;
StartingState:if(brake) next_state = NotStaringState; 
              else if(throttle==1&&clutch==0) next_state = MovingState;
              else next_state = StartingState;
MovingState:  if(brake) next_state = NotStaringState;
              else if(clutch==1 || throttle==0) next_state = StartingState;
              else if(rgShift) next_state = PowerOffState;          
              else next_state = MovingState;
endcase           
end 

always@(state,turnLeft,turnRight,rgShift)
begin
case(state)
PowerOffState,PowerOnState,NotStaringState: {goStraight,goBackward,goLeft,goRight}=4'b0000;
StartingState:if(turnLeft==turnRight){goStraight,goBackward,goLeft,goRight}=4'b0000;
              else if(turnLeft) {goStraight,goBackward,goLeft,goRight}=4'b0010;
              else if(turnRight) {goStraight,goBackward,goLeft,goRight}=4'b0001; 
MovingState: if(rgShift)
             begin
             if(turnLeft==turnRight){goStraight,goBackward,goLeft,goRight}=4'b0100;
             else if(turnLeft) {goStraight,goBackward,goLeft,goRight}=4'b0110;
             else if(turnRight) {goStraight,goBackward,goLeft,goRight}=4'b0101;                                     
             end
             else
             begin
             if(turnLeft==turnRight){goStraight,goBackward,goLeft,goRight}=4'b1000;
             else if(turnLeft) {goStraight,goBackward,goLeft,goRight}=4'b1010;
             else if(turnRight) {goStraight,goBackward,goLeft,goRight}=4'b1001;
             end
endcase
end
endmodule









