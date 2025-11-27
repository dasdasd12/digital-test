module seg_ctrl(
    input                            clk                 ,
    input                            rst_n               ,
    output reg          [   7: 0]    led                 ,

    input               [   4: 0]    keys                ,
    input               [   7: 0]    swiches             ,

    input               [   7: 0]    fft_data0           ,
    input               [   7: 0]    fft_data1           ,
    input               [   7: 0]    fft_addr0           ,
    input               [   7: 0]    fft_addr1           ,

    //if uses uart mode
    input               [   2: 0]    uart_mode           ,
    input               [   9: 0]    uart_freq           ,
    input               [   1: 0]    uart_wav_sel        ,
    input               [   1: 0]    uart_fft_rate       ,

    //if uses button mode 
    output reg          [  23: 0]    freq_inc            ,
    output reg          [   1: 0]    wav_sel             ,
    output reg          [   3: 0]    FFT_rate            ,
    output reg                       FFT_refresh_reg     ,

    output              [   3: 0]    sel0                ,//0 is left , 1 is right
    output              [   7: 0]    seg0                ,
    output              [   3: 0]    sel1                ,
    output              [   7: 0]    seg1                 
);
    parameter ID0 = "0309";
    parameter ID1 = "IC23";

    //todo Generate keys -------------------------------------------------------------

    wire                     key_right_pulse        ;
    key u_key_right (
        .clk                    (clk                    ),
        .key                    (keys[0]                ),
        .key_pulse              (key_right_pulse        ) 
    );

    wire                     key_left_pulse         ;
    key u_key_left (
        .clk                    (clk                    ),
        .key                    (keys[3]                ),
        .key_pulse              (key_left_pulse         ) 
    );

    wire                     key_up_pulse           ;
    key u_key_up (
        .clk                    (clk                    ),
        .key                    (keys[4]                ),
        .key_pulse              (key_up_pulse           ) 
    );

    wire                     key_down_pulse         ;
    key u_key_down (
        .clk                    (clk                    ),
        .key                    (keys[1]                ),
        .key_pulse              (key_down_pulse         ) 
    );

    wire                     key_center_pulse       ;
    key u_key_center (
        .clk                    (clk                    ),
        .key                    (keys[2]                ),
        .key_pulse              (key_center_pulse       ) 
    );

    //todo Swiches Mode ---------------------------------------------------------------

    localparam     ID_DISP              = 8'h00    ;
    localparam     DA_KHZ               = 8'h01    ;
    localparam     DA_HZ                = 8'h02    ;
    localparam     DA_SCAN              = 8'h04    ;
    localparam     FFT                  = 8'h03    ;
    localparam     UART                 = 8'h05    ;

    reg            [   7: 0] mode                   ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode <= ID_DISP;
            led <= 8'd0;
        end else begin
            casex(swiches)
                8'b0xxx_xxx0: begin
                    mode <= ID_DISP;
                    led <= 8'b0000_0000;
                end
                8'b0xxx_0001: begin 
                    mode <= DA_KHZ;
                    led <= 8'b0000_0001;
                end
                8'b0xxx_0101: begin 
                    mode <= DA_HZ;
                    led <= 8'b0000_0101;
                end
                8'b0xxx_1x01: begin 
                    mode <= DA_SCAN;
                    led <= 8'b0000_1001;
                end
                8'b0xxx_xx11: begin 
                    mode <= FFT;
                    led <= {2'b00,FFT_rate,2'b11};
                end
                8'b1xxx_xxxx: begin
                    led <= 8'b1000_0000;
                    if(uart_mode == 3'd0)
                        mode <= ID_DISP;
                    else if(uart_mode == 3'd1)
                        mode <= DA_KHZ;
                    else if(uart_mode == 3'd2)
                        mode <= DA_HZ;
                    else if(uart_mode == 3'd3)
                        mode <= FFT;
                    else if(uart_mode == 3'd4)
                        mode <= DA_SCAN;
                end
                default: begin 
                    mode <= mode;
                    led <= led;
                end
            endcase
        end
    end

    //todo DISP CONTENT CONTROL ------------------------------------------------------

    reg            [   9: 0] seg_freq              ;
    reg            [   7: 0] position               ;
    //Point
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            position  <= 8'b0000_0001;
        end
        else if (swiches[7] || mode == FFT || mode == DA_SCAN) begin
            position <= 8'b0000_0001;
        end
        else if(!swiches[7] && (mode == DA_HZ || mode == DA_KHZ)) begin
            if (key_right_pulse) begin
                position <= {position[0],position[7:1]};
            end
            else if (key_left_pulse) begin
                position <= {position[6:0],position[7]};
            end
        end
    end
    //DA
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg_freq <= 10'd500;
        end else if (mode == DA_HZ || mode == DA_KHZ) begin
            if(key_up_pulse) begin
                case(position)
                    8'b0000_0001:
                        if (seg_freq == 10'd999)
                            seg_freq <= 10'd0;
                        else
                            seg_freq <= seg_freq + 10'd1;
                    8'b0000_0010:
                        if (seg_freq > 10'd989)
                            seg_freq <= seg_freq - 10'd990;
                        else
                            seg_freq <= seg_freq + 10'd10;
                    8'b0000_0100:
                        if (seg_freq > 10'd899)
                            seg_freq <= seg_freq - 10'd900;
                        else
                            seg_freq <= seg_freq + 10'd100;
                    default: seg_freq <= seg_freq;
                endcase
            end else if (key_down_pulse) begin
                case(position)
                    8'b0000_0001:
                        if (seg_freq == 10'd0)
                            seg_freq <= 10'd999;
                        else
                            seg_freq <= seg_freq - 10'd1;
                    8'b0000_0010:
                        if (seg_freq < 10'd10)
                            seg_freq <= seg_freq + 10'd990;
                        else
                            seg_freq <= seg_freq - 10'd10;
                    8'b0000_0100:
                        if (seg_freq < 10'd100)
                            seg_freq <= seg_freq + 10'd900;
                        else
                            seg_freq <= seg_freq - 10'd100;
                    default: seg_freq <= seg_freq;
                endcase
            end
        end else begin
            seg_freq <= seg_freq;
        end
    end

    reg            [  31: 0] wav_disp               ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wav_sel <= 2'd0;
        end else if (!swiches[7] && (mode == DA_HZ || mode == DA_KHZ)) begin
            if (position == 8'b0000_1000 && key_center_pulse) begin
                wav_sel <= wav_sel + 2'd1;
            end else begin
                wav_sel <= wav_sel;
            end
        end
        else if (swiches[7]) begin
            wav_sel <= uart_wav_sel;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wav_disp <= 32'd0;
        end else begin
            case(wav_sel)
                2'b00: wav_disp <= "SINE";
                2'b01: wav_disp <= "SQRA";
                2'b10: wav_disp <= "TRIA";
                2'b11: wav_disp <= "SAUU";
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq_inc <= 24'd0;
        end else if (key_center_pulse) begin
            case(mode)
                DA_KHZ: begin
                    if (!swiches[7])
                        freq_inc <= seg_freq * 10'd1000 * 3'd5 / 3'd3;
                    else
                        freq_inc <= uart_freq * 10'd1000 * 3'd5 / 3'd3;
                end
                DA_HZ: begin
                    if (!swiches[7])
                        freq_inc <= seg_freq * 3'd5 / 3'd3;
                    else
                        freq_inc <= uart_freq * 3'd5 / 3'd3;
                end
                default: freq_inc <= freq_inc;
            endcase
        end
        else if(mode == DA_SCAN) begin
            if(freq_inc == 24'h00FFFF)
                freq_inc <= 24'd0;
            else
                freq_inc <= freq_inc + 1'b1;
            end
    end

    // output declaration of module num2char
    wire           [  31: 0] freq_char              ;
    wire           [   9: 0] freq_num               ;

    assign freq_num = swiches[7] ? uart_freq[9:0] : seg_freq[9:0];
    
    num2char dis_freq(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .num                    (freq_num               ),
        .char                   (freq_char              ) 
    );
    

    //FFT

    //fft page control
    
    reg            [   2: 0] page                   ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            page <= 3'b001;
        end else if (mode == FFT) begin
            if(key_up_pulse)
                page <= {page[1:0],page[2]};
            else if (key_down_pulse)
                page <= {page[0],page[2:1]};
        end
        else begin
            page <= 3'b001;
        end
    end



    //seg control fft refresh
    
    reg            [  15: 0] refresh_cnt            ;
    `ifdef SIM
        localparam REFRESH_MAX = 16'd199; //simulation
    `else
        localparam REFRESH_MAX = 16'd19999; //real board
    `endif

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_cnt <= 16'd0;
        end else if (mode == FFT && FFT_refresh_reg) begin
            if (refresh_cnt == REFRESH_MAX) begin
                refresh_cnt <= 16'd0;
            end else begin
                refresh_cnt <= refresh_cnt + 16'd1;
            end
        end
        else begin
            refresh_cnt <= 16'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            FFT_refresh_reg <= 1'b0;
        end else if (mode == FFT) begin
            if(key_center_pulse)
                FFT_refresh_reg <= 1'b1;
            else if (refresh_cnt == REFRESH_MAX)
                FFT_refresh_reg <= 1'b0;
        end
        else begin
            FFT_refresh_reg <= 1'b0;
        end
    end

    //seg control fft rate

    localparam     ONE_K                = 4'b0001    ;
    localparam     TEN_K                = 4'b0010    ;
    localparam     HUN_K                = 4'b0100    ;
    localparam     ONE_M                = 4'b1000    ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            FFT_rate <= ONE_M;
        end else if (mode == FFT) begin
            if (!swiches[7]) begin
                casex(swiches[5:2])
                    4'b0000: FFT_rate <= ONE_M;
                    4'b0001: FFT_rate <= ONE_K;
                    4'b001x: FFT_rate <= TEN_K;
                    4'b01xx: FFT_rate <= HUN_K;
                    4'b1xxx: FFT_rate <= ONE_M;
                endcase
            end
            else begin
                case(uart_fft_rate)
                    2'b00: FFT_rate <= ONE_K;
                    2'b01: FFT_rate <= TEN_K;
                    2'b10: FFT_rate <= HUN_K;
                    2'b11: FFT_rate <= ONE_M;
                endcase
            end
        end
        else begin
            FFT_rate <= ONE_M;
        end
    end

    // fft data to be displayed
    reg            [  19: 0] fft_point_0            ;
    reg            [  19: 0] fft_point_1            ;

    wire           [  31: 0] fft_point_char0        ;
    wire           [  31: 0] fft_point_char1        ;
    wire           [  31: 0] fft_amp_char0          ;
    wire           [  31: 0] fft_amp_char1          ;
    reg            [  31: 0] fft_acc_char           ;
    reg            [  31: 0] fft_tens               ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fft_point_0 <= 20'd0;
            fft_point_1 <= 20'd0;
        end else if (mode == FFT) begin
            fft_point_0 <= fft_addr0 * 10'd1000 / 10'd128  ;
            fft_point_1 <= fft_addr1 * 10'd1000 / 10'd128  ;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            fft_acc_char <= "0800";
            fft_tens <= "-1E2";
        end
        else if(mode == FFT) begin
            case(FFT_rate)
                ONE_K: begin
                    fft_acc_char <= "0008";
                    fft_tens <= "-1E0";
                end
                TEN_K: begin
                    fft_acc_char <= "0080";
                    fft_tens <= "-1E1";
                end
                HUN_K: begin
                    fft_acc_char <= "0800";
                    fft_tens <= "-1E2";
                end
                ONE_M: begin
                    fft_acc_char <= "8000";
                    fft_tens <= "-1E3";
                end
            endcase
        end
    end

    num2char pfft_char0(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .num                    (fft_point_0[9:0]       ),
        .char                   (fft_point_char0        ) 
    );

    num2char pfft_char1(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .num                    (fft_point_1[9:0]       ),
        .char                   (fft_point_char1        ) 
    );
    
    
    num2char afft_char0(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .num                    ({1'b0,fft_data0,1'b0}  ),
        .char                   (fft_amp_char0          ) 
    );

    num2char afft_char1(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .num                    ({1'b0,fft_data1,1'b0}  ),
        .char                   (fft_amp_char1          ) 
    );

    reg            [  31: 0] fft_char0              ;
    reg            [  31: 0] fft_char1              ;
    reg            [   3: 0] fft_dot1               ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fft_char0 <= 32'd0;
            fft_char1 <= 32'd0;
        end else if (mode == FFT) begin
            case(page)
                3'b001: begin
                    fft_char0 <= fft_point_char0;
                    fft_char1 <= fft_point_char1;
                    fft_dot1  <= 4'b0000;
                end
                3'b010: begin
                    fft_char0 <= fft_amp_char0;
                    fft_char1 <= fft_amp_char1;
                    fft_dot1  <= 4'b0000;
                end
                3'b100: begin
                    fft_char0 <= fft_tens;
                    fft_char1 <= fft_acc_char;
                    fft_dot1  <= 4'b0000;
                end
                default: begin
                    fft_char0 <= "0000";
                    fft_char1 <= "0000";
                    fft_dot1  <= 4'b0000;
                end
            endcase
        end
    end

    //todo Data to be displayed ------------------------------------------------------

    reg            [  31: 0] data_in0               ;
    reg            [  31: 0] data_in1               ;
    reg            [   3: 0] dot_in0                ;
    reg            [   3: 0] dot_in1                ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in0 <= 32'd0;
            data_in1 <= 32'd0;
            dot_in0  <= 4'd0;
            dot_in1  <= 4'd0;
        end else begin
            case (mode)
                ID_DISP: begin
                    data_in0 <= ID0;
                    data_in1 <= ID1;
                    dot_in0  <= 4'b0000;
                    dot_in1  <= 4'b0001;
                end
                DA_KHZ,DA_HZ: begin
                    data_in0 <= freq_char;
                    data_in1 <= wav_disp;
                    dot_in0  <= position[3:0];
                    dot_in1  <= position[7:4];
                end
                DA_SCAN: begin
                    data_in0 <= "AN--";
                    data_in1 <= "--SC";
                    dot_in0  <= "0000";
                    dot_in1  <= "0000";
                end
                FFT: begin
                    data_in0 <= fft_char0;
                    data_in1 <= fft_char1;
                    dot_in0  <= 4'b0000;
                    dot_in1  <= fft_dot1;
                end
                default: begin
                    data_in0 <= 32'd0;
                    data_in1 <= 32'd0;
                    dot_in0  <= 4'd0;
                    dot_in1  <= 4'd0;
                end
            endcase
        end
    end

    //todo Segment Display Control ---------------------------------------------------
    
    seg_disp #(
        .CLK_FREQ               (50_000_000             ),
        .REFRESH_RATE           (1000        )          ) 
    u_seg_disp0(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .data_in                (data_in0               ),
        .dot_in                 (dot_in0                ),
        .sel                    (sel0                   ),
        .seg                    (seg0                   ) 
    );
    
    seg_disp #(
        .CLK_FREQ               (50_000_000             ),
        .REFRESH_RATE           (1000        )          ) 
    u_seg_disp(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .data_in                (data_in1               ),
        .dot_in                 (dot_in1                ),
        .sel                    (sel1                   ),
        .seg                    (seg1                   ) 
    );

endmodule