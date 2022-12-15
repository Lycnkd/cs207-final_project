`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/26 22:10:40
// Design Name: 
// Module Name: dev_top
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


module SimulatedDevice(
    input sys_clk, //bind to P17 pin (100MHz system clock)
//    input rst,
    input [0:0] powerOn_n,powerOff_n,turnLeft_n,turnRight_n,//button
    input [0:0] moduleChange,throttle_n,clutch,brake,rgShift,//switch
    input rx, //bind to N5 pin
    output tx, //bind to T4 pin
 
//    input turn_left_signal,
//    input turn_right_signal,
//    input move_forward_signal,
//    input move_backward_signal,
    
    input place_barrier_signal,
    input destroy_barrier_signal,
    
    output [0:0] ledLeft,
    output [0:0] ledRight,
    
    output front_detector,
    output back_detector,
    output left_detector,
    output right_detector,
    
    output reg onState,NsState,SState,MState //状态是否激活
  );
  
      wire[0:0] powerOn,powerOff,turnLeft,turnRight; //防抖后的按钮
      
      //按一秒后开机 
      oneSecond os(.clk(sys_clk),.button_in(powerOn_n),.button_out(powerOn));
      
      //防抖
      button_debounce b2(.clk(sys_clk),.button_in(powerOff_n),.button_out(powerOff));
      button_debounce b3(.clk(sys_clk),.button_in(turnLeft_n),.button_out(turnLeft));
      button_debounce b4(.clk(sys_clk),.button_in(turnRight_n),.button_out(turnRight));
    
     reg[0:0] throttle;//油门信号
     reg [0:0] goStraight,goBackward,goLeft,goRight;  //move signal
     
    wire [7:0] rec;
    assign front_detector = rec[0];
    assign left_detector = rec[1];
    assign right_detector = rec[2];
    assign back_detector = rec[3];
    
    reg[0:0] reverseJudge;   //倒车信号是否被激活
    reg [2:0] state,next_state; //状态机的现态和次态
    
    //状态机的状态
    parameter PowerOffState = 3'b000, PowerOnState = 3'b001, NotStaringState = 3'b010, StartingState = 3'b011, MovingState = 3'b100;
//               WaitingCommandState = 3'b101, TurnState = 3'b110, StraightForwardState = 3'b111;
             
             //防抱死对油门信号的处理
             always @(posedge sys_clk)
             begin
             if(brake)
             begin
             throttle = 1'b0;
             end
             else
             throttle = throttle_n;
             end
             
             //倒车信号的处理
             always @(posedge sys_clk)
             begin
             case(state)
             StartingState: if(clutch==1&&rgShift==1)   {reverseJudge,onState} = 2'b11;
                            else if(clutch==0&&rgShift==1) {reverseJudge,onState} = {reverseJudge,onState};
                            else  {reverseJudge,onState} = 2'b00;  
             MovingState:   if(clutch==1 || throttle==0){reverseJudge,onState} = 2'b00;
                            else {reverseJudge,onState} = {reverseJudge,onState};                       
             default:       {reverseJudge,onState} = 2'b00;
             endcase             
             end
               
               //自动机
               always @(posedge sys_clk)
                  begin
                  if(powerOff)
                  begin
                    state<= PowerOffState;
                  end
                  else
                    state<=next_state;
                  end
              
              //自动机状态的跳转
              always @(state,powerOn,powerOff,turnLeft,turnRight,moduleChange,throttle,clutch,brake,rgShift,reverseJudge)
              begin 
              case(state)
              PowerOffState: if(powerOn) next_state = PowerOnState; else next_state = PowerOffState;
              PowerOnState:  next_state = NotStaringState;
//              if(moduleChange) next_state = NotStaringState; else next_state = NotStaringState;
//              WaitingCommandState;
              NotStaringState: if(throttle)
                               begin
                               if(clutch==1&&brake==0) 
                                next_state = StartingState;                             
                               else if(clutch==0&&brake==0)
                                next_state = PowerOffState;
                               else if(clutch==0&&brake==1) 
                                next_state = PowerOffState;
                               else if(clutch==1&&brake==1)
                               next_state =  NotStaringState;                        
                               end
                              else next_state = NotStaringState;
              StartingState:                                                                    
                            if(brake) next_state = NotStaringState; 
                            else if(throttle==1&&clutch==0)
                            next_state = MovingState;                     
                            else next_state = StartingState;                                                       
//                            if (clutch==1&&rgShift==1)                           
//                            {reverseJudge,onState} = 2'b11;                                                 
//                            else if(throttle==1&&clutch==0)
//                            next_state = MovingState;    
                       
              MovingState:  if(brake) next_state = NotStaringState;
                            else if(clutch==1 || throttle==0) 
                            next_state = StartingState;                   
                            else if(rgShift==1)
                            begin
                            if(reverseJudge==1'b0)
                            next_state = PowerOffState;
                            else next_state = MovingState;
                            end     
                            else next_state = MovingState;                                                        
//                            if(rgShift==1&&reverseJudge==1'b0) next_state = PowerOffState;
//                            else if(rgShift==1&&reverseJudge==1'b1&&throttle==1) next_state = MovingState;
              default: next_state = PowerOnState;
              endcase           
              end 
              
              //自动机的输出                              
              always@(state,turnLeft,turnRight,rgShift,reverseJudge)
              begin
              case(state)
              PowerOffState:{goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000111;
              PowerOnState:{goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000000;
              NotStaringState: {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000100;
              StartingState:if(turnLeft==turnRight){goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000010;
                            else if(turnLeft==1&&turnRight==0) {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0010010;
                            else if(turnRight==1&&turnLeft==0) {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0001010;
                            else {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000111; 
              MovingState: if(reverseJudge==1'b1)
                           begin
                           if(turnLeft==turnRight){goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0100001;
                           else if(turnLeft==1&&turnRight==0) {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0101001;
                           else if(turnLeft==0&&turnRight==1) {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0110001;
                           else {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000000;  //                                                         
                           end
                        
                           else
                           begin
                           if(turnLeft==turnRight){goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b1000001;
                           else if(turnLeft==1&&turnRight==0) {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b1010001;
                           else if(turnLeft==0&&turnRight==1) {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b1001001;
                           else {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000000;
                           end
              default: {goStraight,goBackward,goLeft,goRight,NsState,SState,MState}=7'b0000000;
              endcase
              end               
    
    //转向灯的闪烁
    flashing left(.clk(sys_clk),.state(state),.direction(goLeft),.light(ledLeft));
    flashing right(.clk(sys_clk),.state(state),.direction(goRight),.light(ledRight));
    
    //uart模块的输入         
    wire [7:0] in = {2'b10, 1'b0, 1'b0, goRight,goLeft,goBackward,goStraight};
    uart_top md(.clk(sys_clk), .rst(0), .data_in(in), .data_rec(rec), .rxd(rx), .txd(tx));
    
    //    uart_top md(.clk(sys_clk), .rst(rst), .data_in(in), .data_rec(rec), .rxd(rx), .txd(tx));                           
endmodule
