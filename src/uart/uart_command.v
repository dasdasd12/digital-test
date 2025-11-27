module uart_command (
    input clk,
    input rst_n,

    input      [19:0] recive_data,
    output reg        refresh,
    output reg        system_resetn,
    output reg [1:0] wav_sel,
    output reg [11:0] freq,
    output reg [2:0] seg_en,
    output reg [1:0] fft_rate
);

    //                  command map             // 
    //       address         |     function     //

    //       0xFFFF0         |    seg_en = 0    //  disenable frequency display
    //       0xFFFF1         |    seg_en = 1    //  enable da frequency display KHz
    //       0xFFFF2         |    seg_en = 2    //  enable da frequency display Hz
    //       0xFFFF3         |    seg_en = 3    //  enable fft mode
    //       0xFFFF4         |    seg_en = 4    //  enable scan mode

    //       0xFFFE0         |    fft_set 0     //  fft rate is 1k
    //       0xFFFE1         |    fft_set 1     //  fft rate is 10k
    //       0xFFFE2         |    fft_set 2     //  fft rate is 100k
    //       0xFFFE3         |    fft_set 3     //  fft rate is 1M
    //       0xFFFE4         |     refresh      //  fft_refresh

    //       0xFFFD0         |      sine        //  sine wave
    //       0xFFFD1         |     square       //  square wave
    //       0xFFFD2         |    triangle      //  triangle wave
    //       0xFFFD3         |    sawtooth      //  sawtooth wave
    //       0xFDxxx         |    freq = xxx    //  set frequency

    reg [15:0] refresh_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_cnt <= 16'd0;
        end else begin
            if (refresh_cnt == 16'd19999) begin
                refresh_cnt <= 16'd0;
            end else if(refresh) begin
                refresh_cnt <= refresh_cnt + 1'b1;
            end
            else begin
                refresh_cnt <= 16'd0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh <= 1'b0;
        end else if (recive_data == 20'hFFFE4) begin
            refresh <= 1'b1;
        end else if (refresh_cnt == 16'd19999) begin
            refresh <= 1'b0;
        end
        else    
            refresh <= refresh;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wav_sel <= 2'b00;
        end else if (recive_data == 20'hFFFD0) begin
            wav_sel <= 2'b00; //sine
        end else if (recive_data == 20'hFFFD1) begin
            wav_sel <= 2'b01; //square
        end else if (recive_data == 20'hFFFD2) begin
            wav_sel <= 2'b10; //triangle
        end else if (recive_data == 20'hFFFD3) begin
            wav_sel <= 2'b11; //sawtooth
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fft_rate <= 2'b10;
        end else if (recive_data == 20'hFFFE0) begin
            fft_rate <= 2'b00; //1k
        end else if (recive_data == 20'hFFFE1) begin
            fft_rate <= 2'b01; //10k
        end else if (recive_data == 20'hFFFE2) begin
            fft_rate <= 2'b10; //100k
        end else if (recive_data == 20'hFFFE3) begin
            fft_rate <= 2'b11; //1M
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg_en <= 3'b00;
        end else if(recive_data == 20'hFFFF0) begin
            seg_en <= 3'd0;
        end else if(recive_data == 20'hFFFF1) begin
            seg_en <= 3'd1;
        end else if(recive_data == 20'hFFFF2) begin
            seg_en <= 3'd2; 
        end else if(recive_data == 20'hFFFF3) begin
            seg_en <= 3'd3; 
        end else if(recive_data == 20'hFFFF4) begin
            seg_en <= 3'd4; 
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq <= 12'd500;
        end else if (recive_data[19:12] == 8'hFD) begin
            freq <= recive_data[11:0];
        end 
    end

endmodule
