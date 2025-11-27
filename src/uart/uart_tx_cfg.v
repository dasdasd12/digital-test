`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/15 20:50:16
// Design Name: 
// Module Name: uart_tx_cfg
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


module uart_tx_cfg (
    input             clk,
    input             rst_n,
    input             tx_pulse,
    input     [ 19:0] tx_data_in,
    output            uart_tx,
    output            tx_done
);

    localparam IDLE = 2'b00, SEND = 2'b01;

    localparam BIT_NUM = 5'd5;

    wire [         39:0] data_ascii;

    wire                 tx_data_ready;
    wire [          7:0] tx_data;
    wire                 tx_data_valid;

    reg                  tx_data_valid_reg;
    reg  [          4:0] tx_cnt;
    reg  [          1:0] state;

    // include ASCII conversion macros (keeps macros visible inside module scope)
    function [7:0] hex_to_ascii_fn;
        input [3:0] ch;
        begin
            case (ch)
                4'h0: hex_to_ascii_fn = "0";
                4'h1: hex_to_ascii_fn = "1";
                4'h2: hex_to_ascii_fn = "2";
                4'h3: hex_to_ascii_fn = "3";
                4'h4: hex_to_ascii_fn = "4";
                4'h5: hex_to_ascii_fn = "5";
                4'h6: hex_to_ascii_fn = "6";
                4'h7: hex_to_ascii_fn = "7";
                4'h8: hex_to_ascii_fn = "8";
                4'h9: hex_to_ascii_fn = "9";
                4'hA: hex_to_ascii_fn = "A";
                4'hB: hex_to_ascii_fn = "B";
                4'hC: hex_to_ascii_fn = "C";
                4'hD: hex_to_ascii_fn = "D";
                4'hE: hex_to_ascii_fn = "E";
                4'hF: hex_to_ascii_fn = "F";
            endcase
        end
    endfunction

    assign tx_done        = tx_cnt == BIT_NUM - 1 && tx_data_ready;
    assign tx_data        = data_ascii[(BIT_NUM-tx_cnt)*8-1-:8];
    assign tx_data_valid  = state == SEND;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data_valid_reg <= 1'b0;
        end else begin
            tx_data_valid_reg <= tx_data_valid;
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_cnt <= 4'd0;
        end else if (state == SEND && tx_data_ready) begin
            if (tx_cnt == BIT_NUM - 1) begin
                tx_cnt <= 4'd0;
            end else begin
                tx_cnt <= tx_cnt + 4'd1;
            end
        end else begin
            tx_cnt <= tx_cnt;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (tx_pulse && ~tx_done) begin
                        state <= SEND;
                    end else begin
                        state <= IDLE;
                    end
                end
                SEND: begin
                    if (tx_done) state <= IDLE;
                    else state <= SEND;
                end
                default: state <= IDLE;
            endcase
        end
    end


    assign data_ascii[7-:8]  = hex_to_ascii_fn(tx_data_in[3-:4]);
    assign data_ascii[15-:8] = hex_to_ascii_fn(tx_data_in[7-:4]);
    assign data_ascii[23-:8] = hex_to_ascii_fn(tx_data_in[11-:4]);
    assign data_ascii[31-:8] = hex_to_ascii_fn(tx_data_in[15-:4]);
    assign data_ascii[39-:8] = hex_to_ascii_fn(tx_data_in[19-:4]);


    uart_tx #(
        .CLK_FRE  (100),
        .BAUD_RATE(115200)
    ) u_uart_tx (
        .clk          (clk),
        .rst_n        (rst_n),
        .tx_data      (tx_data),
        .tx_data_valid(tx_data_valid),
        .tx_data_ready(tx_data_ready),
        .tx_pin       (uart_tx)
    );

endmodule
