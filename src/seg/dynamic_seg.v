`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/17 10:50:15
// Design Name: 
// Module Name: dynamic_seg
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


module dynamic_seg(
input wire sys_clk , //时钟频率 1kHz 
 input wire sys_rst_n , //复位信号，低有效 
 input wire [13:0] data , //数码管要显示的值
 input wire [3:0] point , //小数点显示,高电平有效
 input wire seg_en , //数码管使能信号，高电平有效
 input wire [15:0] data_ID , //学号
 output reg [3:0] sel , //数码管位选信号
 output reg [7:0] seg //数码管段选信号
    );
    //parameter define 
parameter   CNT_MAX = 17'd99_999;  //数码管刷新时间计数最大值，1ms刷新一次 
 
//reg   define  
reg     [16:0]  cnt_1ms     ;   //1ms计数器 
reg             flag_1ms    ;   //1ms标志信号 
reg     [1:0]   cnt_sel     ;   //数码管位选计数器 
reg     [3:0]   sel_reg     ;   //位选信号 
reg     [3:0]   data_disp   ;   //当前数码管显示的数据 
reg             dot_disp    ;   //当前数码管显示的小数点 
reg     [15:0]  data_reg    ;   //待显示数据寄存器
reg     [3:0]   ONE         ;   //右一数码管 
reg     [3:0]   TWO         ;   //右二数码管 
reg     [3:0]   THREE       ;   //右三数码管 
reg     [3:0]   FOUR        ;   //右四数码管
   
wire    [3:0]   unit        ;
wire    [3:0]   ten         ;
wire    [3:0]   hun         ;
wire    [3:0]   tho         ;

always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0)
        data_reg <= 16'b0;
    else
        data_reg <= {tho,hun,ten,unit};

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            ONE     <=    data_ID[3:0];
            TWO     <=    data_ID[7:4];
            THREE   <=    data_ID[11:8];
            FOUR    <=    data_ID[15:12];
        end
    else
        begin
            ONE    <=   ONE     ;
            TWO    <=   TWO     ;
            THREE  <=   THREE   ;
            FOUR   <=   FOUR    ;
        end 
 
//cnt_1ms:1ms循环计数 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        cnt_1ms <=  17'd0; 
    else    if(cnt_1ms == CNT_MAX) 
        cnt_1ms <=  17'd0; 
    else 
        cnt_1ms <=  cnt_1ms + 1'b1; 
 
//flag_1ms:1ms标志信号 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        flag_1ms    <=  1'b0; 
    else    if(cnt_1ms == CNT_MAX - 1'b1) 
        flag_1ms    <=  1'b1; 
    else 
        flag_1ms    <=  1'b0; 
 
//cnt_sel:从0到3循环数，用于选择当前显示的数码管 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        cnt_sel <=  2'd0; 
    else    if((cnt_sel == 2'd3) && (flag_1ms == 1'b1)) 
        cnt_sel <=  2'd0; 
    else    if(flag_1ms == 1'b1) 
        cnt_sel <=  cnt_sel + 1'b1; 
    else 
        cnt_sel <=  cnt_sel; 
 
//数码管位选信号寄存器 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        sel_reg <=  4'b0000; 
    else    if((cnt_sel == 2'd0) && (flag_1ms == 1'b1)) 
        sel_reg <=  4'b0001; 
    else    if(flag_1ms == 1'b1) 
        sel_reg <=  sel_reg << 1; 
    else 
        sel_reg <=  sel_reg; 
 
//控制数码管的位选信号，使四个数码管轮流显示 
always@(posedge sys_clk or  negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        data_disp    <=  4'b0; 
    else    if((seg_en == 1'b1) && (flag_1ms == 1'b1)) 
        case(cnt_sel) 
        2'd0:   data_disp    <=  data_reg[3:0]    ; //给第1个数码管赋值 
        2'd1:   data_disp    <=  data_reg[7:4]    ; //给第2个数码管赋值 
        2'd2:   data_disp    <=  data_reg[11:8]   ; //给第3个数码管赋值 
        2'd3:   data_disp    <=  data_reg[15:12]  ; //给第4个数码管赋值
        default:data_disp    <=  4'b0; 
        endcase 
    else    if((seg_en == 1'b0) && (flag_1ms == 1'b1))
        case(cnt_sel) 
        2'd0:   data_disp    <=  ONE    ; //给第1个数码管赋值
        2'd1:   data_disp    <=  TWO    ; //给第2个数码管赋值
        2'd2:   data_disp    <=  THREE  ; //给第3个数码管赋值
        2'd3:   data_disp    <=  FOUR   ; //给第4个数码管赋值
        default:data_disp    <=  4'b0; 
        endcase
    else 
        data_disp   <=  data_disp; 
 
//dot_disp：小数点高电平点亮 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        dot_disp    <=  1'b0; 
    else    if(flag_1ms == 1'b1) 
        dot_disp    <=  point[cnt_sel]; 
    else
        dot_disp    <=  dot_disp; 

//控制数码管段选信号，显示数字 
always@(posedge sys_clk or  negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        seg <=  8'b1111_1111; 
    else     
        case(data_disp) 
            4'h0  : seg  <=  {dot_disp,7'b011_1111};    //显示数字0 
            4'h1  : seg  <=  {dot_disp,7'b000_0110};    //显示数字1 
            4'h2  : seg  <=  {dot_disp,7'b101_1011};    //显示数字2 
            4'h3  : seg  <=  {dot_disp,7'b100_1111};    //显示数字3 
            4'h4  : seg  <=  {dot_disp,7'b110_0110};    //显示数字4 
            4'h5  : seg  <=  {dot_disp,7'b110_1101};    //显示数字5 
            4'h6  : seg  <=  {dot_disp,7'b111_1101};    //显示数字6 
            4'h7  : seg  <=  {dot_disp,7'b000_0111};    //显示数字7 
            4'h8  : seg  <=  {dot_disp,7'b111_1111};    //显示数字8 
            4'h9  : seg  <=  {dot_disp,7'b110_1111};    //显示数字9 
            4'hA  : seg  <=  {dot_disp,7'b111_0111};    //显示字母A 
            4'hB  : seg  <=  {dot_disp,7'b111_1100};    //显示字母B
            4'hC  : seg  <=  {dot_disp,7'b011_1001};    //显示字母C
            4'hD  : seg  <=  {dot_disp,7'b101_1110};    //显示字母D
            4'hE  : seg  <=  {dot_disp,7'b111_1001};    //显示字母E
            4'hF  : seg  <=  {dot_disp,7'b111_0001};    //显示字母F
            default:seg  <=  8'b0000_0000; 
        endcase 
        
//sel:数码管位选信号赋值 
always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        sel <=  4'b1111; 
    else 
        sel <=  sel_reg;
        
bcd_to_8421 bcd_to_8421_inst
( 
    .sys_clk     (sys_clk  ),   //系统时钟，频率100MHz 
    .sys_rst_n   (sys_rst_n),   //复位信号，低电平有效 
    .data_8421   (data     ),   //输入需要转换的数据 
                  
    .unit        (unit     ),   //个位BCD码 
    .ten         (ten      ),   //十位BCD码 
    .hun         (hun      ),   //百位BCD码 
    .tho         (tho      )    //千位BCD码    
); 

endmodule
