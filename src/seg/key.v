`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 15:49:18
// Design Name: 
// Module Name: key
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

// `define wait_bit 8
// `define up_state 0
// `define down_state 1

module key (
    input  clk,
    input  key,
    output key_pulse
);
    `ifdef SIM
        localparam WAIT_BIT=2;
    `else
        localparam WAIT_BIT=8;
    `endif 
    // 消抖并且产生脉冲
    reg state = 0, state_d = 0;
    reg [WAIT_BIT-1:0]counter = 0;

    always @(posedge clk) begin
        state_d <= state;
        if (state == 1'b0) begin
            if (key == 1'b1) begin
                counter <= counter + 1'b1;
            end else begin
                counter <= 'd0;
            end
            if (counter == (2**WAIT_BIT-1)) begin
                counter <= 'd0;
                state <= 1'b1;
            end
        end else if (state == 1'b1) begin
            if (key == 1'b0) begin
                counter <= counter + 1'b1;
            end else begin
                counter <= 'd0;
            end
            if (counter == (2**WAIT_BIT-1)) begin
                counter <= 'd0;
                state <= 1'b0;
            end
        end
    end

    // always @(posedge clk) begin
    //     if (state == `up_state && state_d == `down_state) begin
    //         key_pulse <= 1;
    //     end else begin
    //         key_pulse <= 0;
    //     end
    // end
    
    assign key_pulse = (state == 1'b0) && (state_d == 1'b1);

endmodule
