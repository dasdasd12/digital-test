`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/17 10:56:54
// Design Name: 
// Module Name: bcd_to_8421
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


module bcd_to_8421(
    input   wire            sys_clk     ,   //系统时钟，频率100MHz 
    input   wire            sys_rst_n   ,   //复位信号，低电平有效 
    input   wire    [13:0]  data_8421   ,   //输入需要转换的数据 
 
    output  reg     [3:0]   unit        ,   //个位BCD码 
    output  reg     [3:0]   ten         ,   //十位BCD码 
    output  reg     [3:0]   hun         ,   //百位BCD码 
    output  reg     [3:0]   tho             //千位BCD码    

    );
    //reg   define 
reg     [3:0]   cnt_shift   ;   //移位判断计数器 
reg     [29:0]  data_shift  ;   //移位判断数据寄存器 
reg             shift_flag  ;   //移位判断标志信号 
 
//cnt_shift:从0到15循环计数 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        cnt_shift   <=  4'd0;  
    else    if(shift_flag == 1'b1) 
        cnt_shift <= (cnt_shift == 4'd15) ? 4'd0 : cnt_shift + 1'b1; 
    else 
        cnt_shift   <=  cnt_shift; 
        
//data_shift：计数器为0时赋初值，计数器为1~14时进行移位判断操作 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        data_shift  <=  30'b0; 
    else    if(cnt_shift == 4'd0) 
        data_shift  <=  {16'b0,data_8421}; 
    else    if((cnt_shift <= 14) && (shift_flag == 1'b0)) 
        begin 
            data_shift[17:14]   <=  (data_shift[17:14] > 4) ?  
            (data_shift[17:14] + 2'd3) : (data_shift[17:14]); 
            data_shift[21:18]   <=  (data_shift[21:18] > 4) ?  
            (data_shift[21:18] + 2'd3) : (data_shift[21:18]);
            data_shift[25:22]   <=  (data_shift[25:22] > 4) ?  
            (data_shift[25:22] + 2'd3) : (data_shift[25:22]); 
            data_shift[29:26]   <=  (data_shift[29:26] > 4) ?  
            (data_shift[29:26] + 2'd3) : (data_shift[29:26]);  
        end 
    else    if((cnt_shift <= 14) && (shift_flag == 1'b1)) 
        data_shift  <=  data_shift << 1; 
    else 
        data_shift  <=  data_shift; 
 
//shift_flag：移位判断标志信号，用于控制移位判断的先后顺序 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        shift_flag  <=  1'b0; 
    else 
        shift_flag  <=  ~shift_flag; 
 
//当计数器等于20时，移位判断操作完成，对各个位数的BCD码进行赋值 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        begin 
            unit    <=  4'b0; 
            ten     <=  4'b0; 
            hun     <=  4'b0; 
            tho     <=  4'b0;  
        end 
    else    if(cnt_shift == 4'd15) 
        begin 
            unit    <=  data_shift[17:14]; 
            ten     <=  data_shift[21:18]; 
            hun     <=  data_shift[25:22]; 
            tho     <=  data_shift[29:26]; 
        end 

endmodule
