module seg_disp(
    input clk,
    input rst_n,

    input [31:0] data_in,
    input [3:0]  dot_in,
    output [3:0]  sel,
    output reg [7:0]  seg
);
    parameter CLK_FREQ = 50_000_000; // 50MHz
    parameter REFRESH_RATE = 1000;    // 1kHz
    localparam CNT_MAX = CLK_FREQ/REFRESH_RATE; // 1kHz for 50MHz clk
    //         1
    //      ------
    //   6 |      |  2
    //     |   7  |
    //      ------
    //   5 |      |  3
    //     |      |
    //      ------
    //         4
    function [6:0] word2seg;
        input [7:0] word;
        begin
            case(word)
                "1": word2seg = 7'b0000110;
                "2": word2seg = 7'b1011011;
                "3": word2seg = 7'b1001111;
                "4": word2seg = 7'b1100110;
                "5": word2seg = 7'b1101101;
                "6": word2seg = 7'b1111101;
                "7": word2seg = 7'b0000111;
                "8": word2seg = 7'b1111111;
                "9": word2seg = 7'b1101111;
                "0": word2seg = 7'b0111111;
                "A", "a": word2seg = 7'b1110111;
                "B", "b": word2seg = 7'b1111100;
                "C", "c": word2seg = 7'b0111001;
                "D", "d": word2seg = 7'b1011110;
                "E", "e": word2seg = 7'b1111001;
                "F", "f": word2seg = 7'b1110001;
                "G", "g": word2seg = 7'b0111101;
                "H", "h": word2seg = 7'b1110110;
                "I", "i": word2seg = 7'b0110000;
                "J", "j": word2seg = 7'b0011110;
                "L", "l": word2seg = 7'b0111000;
                "N", "n": word2seg = 7'b0110111;
                "O", "o": word2seg = 7'b1011100;
                "P", "p": word2seg = 7'b1110011;
                "Q", "q": word2seg = 7'b1100111;
                "R", "r": word2seg = 7'b1010000;
                "S", "s": word2seg = 7'b1101101;
                "T", "t": word2seg = 7'b0110001;
                "U", "u": word2seg = 7'b0111110;
                "-": word2seg = 7'b1000000;
                " ": word2seg = 7'b0000000;
                8'hFF: word2seg = 7'b0000000; //blank
                default:    word2seg = 7'b0000000;
            endcase
        end
    endfunction

    reg [7:0] seg_data[3:0];
    reg [27:0] data_reg;
    integer i;
    integer j;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= 28'd0;
        end else begin
            for (i=0; i<4; i=i+1) begin
                data_reg[i*7 +: 7] <= word2seg(data_in[i*8 +: 8]);
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j=0; j<4; j=j+1) begin
                seg_data[j] <= 8'd0;
            end
        end else begin
            for (j=0; j<4; j=j+1) begin
                seg_data[j] <= {dot_in[j], data_reg[j*7 +: 7]};
            end
        end
    end

    reg [3:0] sel_reg;
    reg [31:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 32'd0;
        end else if (cnt == CNT_MAX - 1) begin
            cnt <= 32'd0;
        end else begin
            cnt <= cnt + 32'd1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_reg <= 4'b0001;
        end else if (cnt == CNT_MAX - 1) begin
            sel_reg <= {sel_reg[2:0], sel_reg[3]};
        end
    end

    assign sel = sel_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg <= 8'd0;
        end else begin
            case (sel_reg)
                4'b0001: seg <= seg_data[0];
                4'b0010: seg <= seg_data[1];
                4'b0100: seg <= seg_data[2];
                4'b1000: seg <= seg_data[3];
                4'b0000: seg <= 8'd0;
            endcase
        end
    end

endmodule