`timescale 1ns / 100ps
module uart_rx_cfg (
    input             clk,
    input             rst_n,
    input             uart_rx,
    input             rx_en,

    output reg [19:0] wr_data,
    output     [19:0] command_data
);

    wire [ 7:0] rx_data;
    wire        rx_data_valid;

    reg  [ 2:0] bit_cnt/*synthesis syn_preserve = 1*/;

    assign command_data = bit_cnt == 3'd5 ? wr_data : 20'b0;


    uart_rx #(
        .CLK_FRE  (10),
        .BAUD_RATE(115200)
    ) u_uart_rx (
        .clk          (clk),
        .rst_n        (rst_n),
        .rx_data      (rx_data),
        .rx_data_valid(rx_data_valid),
        .rx_data_ready(rx_en),
        .rx_pin       (uart_rx)
    );

    wire [3:0] hex_data_out;

    // Module-local function to convert ASCII to 4-bit hex (keeps declarations inside module scope)
    function [3:0] ascii_to_hex_fn;
        input [7:0] ch;
        begin
            case (ch)
                "0": ascii_to_hex_fn = 4'h0;
                "1": ascii_to_hex_fn = 4'h1;
                "2": ascii_to_hex_fn = 4'h2;
                "3": ascii_to_hex_fn = 4'h3;
                "4": ascii_to_hex_fn = 4'h4;
                "5": ascii_to_hex_fn = 4'h5;
                "6": ascii_to_hex_fn = 4'h6;
                "7": ascii_to_hex_fn = 4'h7;
                "8": ascii_to_hex_fn = 4'h8;
                "9": ascii_to_hex_fn = 4'h9;
                "A", "a": ascii_to_hex_fn = 4'hA;
                "B", "b": ascii_to_hex_fn = 4'hB;
                "C", "c": ascii_to_hex_fn = 4'hC;
                "D", "d": ascii_to_hex_fn = 4'hD;
                "E", "e": ascii_to_hex_fn = 4'hE;
                "F", "f": ascii_to_hex_fn = 4'hF;
                default:    ascii_to_hex_fn = 4'h0;
            endcase
        end
    endfunction

    assign hex_data_out = ascii_to_hex_fn(rx_data);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 3'b0;
        end else if (bit_cnt == 3'd5) begin
            bit_cnt <= 3'b0;
        end else if (rx_data_valid) begin
            bit_cnt <= bit_cnt + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_data <= 20'b0;
        end else if (rx_data_valid) begin
            wr_data[(5-bit_cnt)*4-1'b1-:4] <= hex_data_out;
        end
    end

endmodule
