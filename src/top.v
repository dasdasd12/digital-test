`timescale 1ns/1ps

//phase <= phase + phase_inc_base + phase_inc_delta
//phase is 4 timse the rom address
//phase_inc_base+phase_inc_delta = frequency control word
//my rom addr width is 8, so my phase width is 10
//so frequency = (phase_inc_base+phase_inc_delta)*fclk/2^10
//minimum frequency step is fclk/2^10
//base frequency is phase_inc_base*fclk/2^10
// `define ILA

module top(
    input                            clk                 ,
    input                            rst_n               ,

    input                            ch1_p               ,
    input                            ch1_n               ,

    input                            uart_rx             ,
    input               [   4: 0]    keys                ,
    input               [   7: 0]    swiches             ,
    output              [   7: 0]    led                 ,

    output              [   3: 0]    sel0                ,
    output              [   7: 0]    seg0                ,
    output              [   3: 0]    sel1                ,
    output              [   7: 0]    seg1                ,

    output                           da_clk              ,
    output                           ad_clk              ,
    output              [  13: 0]    da_data             ,
    input               [   9: 0]    ad_data              
);

    localparam     DATA_W               = 10       ;
    localparam     PHASE_W              = 24       ;
    localparam     ROM_ADDR_W           = 8        ;
    localparam     phase_inc_base       = 0        ;

    localparam     ID0                  = "0309"   ;
    localparam     ID1                  = "IC23"   ; 

    //--------------------- clock div part ------------------------

    reg            [   9: 0] div_cnt                ;
    reg                      div_clk                ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt <= 10'd0;
        end else if (div_cnt == 10'd4) begin
            div_cnt <= 10'd0;
        end else begin
            div_cnt <= div_cnt + 10'd1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_clk <= 1'b0;
        end else if (div_cnt == 10'd4) begin
            div_clk <= ~div_clk;
        end
    end


    //--------------------- uart part ------------------------

    wire           [  19: 0] command_data           ;
    wire           [  19: 0] wr_data                ;

    uart_rx_cfg u_uart_rx_cfg (
        .clk                    (div_clk                ),
        .rst_n                  (rst_n                  ),
        .rx_en                  (1'b1                   ),
        .uart_rx                (uart_rx                ),
        .command_data           (command_data           ),
        .wr_data                (wr_data                ) 
    );

    wire                     uart_fft_refresh       ;
    wire                     system_resetn          ;
    wire           [   1: 0] uart_wav_sel           ;
    wire           [   2: 0] uart_seg_en            ;
    wire           [   1: 0] uart_fft_rate          ;
    wire           [  11: 0] uart_freq              ;

    uart_command u_uart_command (
        .clk                    (div_clk                ),
        .rst_n                  (rst_n                  ),
        .recive_data            (command_data           ),
        .refresh                (uart_fft_refresh       ),
        .system_resetn          (system_resetn          ),
        .wav_sel                (uart_wav_sel           ),
        .freq                   (uart_freq              ),
        .seg_en                 (uart_seg_en            ),
        .fft_rate               (uart_fft_rate          ) 
    );

    //--------------------- seg part ------------------------

    // output declaration of module seg_ctrl
    wire           [PHASE_W-1: 0] seg_freq_inc           ;
    wire           [   1: 0] seg_wav_sel            ;
    wire           [   3: 0] seg_fft_rate           ;
    wire                     seg_fft_refresh        ;
    //fft output
    wire                     ovalid                 ;
    wire           [   7: 0] odata                  ;
    wire           [   7: 0] oaddr                  ;
    wire           [   7: 0] odata2                 ;
    wire           [   7: 0] oaddr2                 ;

    seg_ctrl #(
        .ID0                    (ID0                    ),
        .ID1                    (ID1                    ) 
    ) u_seg_ctrl(
        .clk                    (div_clk                ),
        .rst_n                  (rst_n                  ),
        .led                    (led                    ),

        .keys                   (keys                   ),
        .swiches                (swiches                ),

        .fft_addr0              (oaddr                  ),
        .fft_data0              (odata                  ),
        .fft_addr1              (oaddr2                 ),
        .fft_data1              (odata2                 ),

        .uart_mode              (uart_seg_en            ),
        .uart_wav_sel           (uart_wav_sel           ),
        .uart_freq              (uart_freq[9:0]         ),
        .uart_fft_rate          (uart_fft_rate          ),

        .wav_sel                (seg_wav_sel            ),
        .freq_inc               (seg_freq_inc           ),
        .FFT_rate               (seg_fft_rate           ),
        .FFT_refresh_reg        (seg_fft_refresh        ),

        .sel0                   (sel0                   ),
        .seg0                   (seg0                   ),
        .sel1                   (sel1                   ),
        .seg1                   (seg1                   ) 
    );

    //--------------------- XADC part -----------------------
    wire                     xadc_busy              ;
    wire                     xadc_en                ;
    wire                     xadc_wen               ;
    wire           [  15: 0] xadc_dout              ;
    wire                     flag                   ;
    wire                     xadc_drdy              ;
    wire                     xadc_eoc               ;
	
	
    reg            [   6: 0] addr                 =7'd17;
    reg            [  15: 0] xadc_din             =16'd17;
    reg            [  16: 0] xadc_data              ;
    reg                      start                  ;
    reg            [   1: 0] delay                  ;
	
	
	assign flag 	= (delay == 2'b01) ? 1'b1 : 1'b0;
	assign xadc_en 	= start							;
	assign xadc_wen = start							;
	
	
	always@(posedge div_clk or negedge rst_n) begin
		if(!rst_n)
			delay <= 'b0;
		else
			delay <= {delay[0], xadc_eoc};
	end
	
	
	always@(posedge div_clk or negedge rst_n) begin
		if(!rst_n)
			start <= 1'b0;
		else if(flag)
			start <= 1'b1;
		else
			start <= 1'b0;
	end
	
	always@(posedge div_clk or negedge rst_n) begin
		if(!rst_n)
			xadc_data <= 'd0;
		else if(xadc_eoc)
			xadc_data <= xadc_dout;
		else
			xadc_data <= xadc_data;
	end

    `ifdef SIM

    `else
	// port for xadc
    xadc_wiz_0 xadc_inst (
        .di_in                  (xadc_din               ),// input wire [15 : 0] di_in
        .daddr_in               (addr                   ),// input wire [6 : 0] daddr_in
        .den_in                 (xadc_en                ),// input wire den_in
        .dwe_in                 (xadc_wen               ),// input wire dwe_in
        .drdy_out               (xadc_drdy              ),// output wire drdy_out
        .do_out                 (xadc_dout              ),// output wire [15 : 0] do_out
		
        .dclk_in                (div_clk                ),// input wire dclk_in
		
        .vauxp1                 (ch1_p                  ),// input wire vauxp1
        .vauxn1                 (ch1_n                  ),// input wire vauxn1
		
        .eoc_out                (xadc_eoc               ),// output wire eoc_out
        .busy_out               (xadc_busy              ) // output wire busy_out
    );
    `endif

    //--------------------- DDS part ------------------------
    wire           [PHASE_W-1: 0] phase_inc_delta        ;
    wire           [DATA_W-1: 0] sin                    ;
    wire           [DATA_W-1: 0] cos                    ;
    wire           [DATA_W-1: 0] sawtooth               ;
    wire           [DATA_W-1: 0] triangle               ;
    wire           [DATA_W-1: 0] square                 ;
    
    wire           [   1: 0] wav_sel                ;

    DDS #(
        .DATA_W                 (DATA_W                 ),
        .PHASE_W                (PHASE_W                ),
        .ROM_ADDR_W             (ROM_ADDR_W             ),
        .phase_inc_base         (phase_inc_base  )      ) 
    u_DDS(
        .clk                    (div_clk                ),
        .rst_n                  (rst_n                  ),
        .phase_inc_delta        (phase_inc_delta        ),
        .sin                    (sin                    ),
        .cos                    (cos                    ),
        .sawtooth               (sawtooth               ),
        .triangle               (triangle               ),
        .square                 (square                 ) 
    );

    reg [DATA_W-1:0] out_wav;
    wire [DATA_W+7:0] da_data_mult;

    always @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            out_wav <= 0;
        end else begin
            case (wav_sel)
                2'b00: out_wav <= sin;
                2'b01: out_wav <= square;
                2'b10: out_wav <= triangle;
                2'b11: out_wav <= sawtooth;
                default: out_wav <= sin;
            endcase
        end
    end
    `ifdef SIM
        assign da_data = {out_wav,4'b0000} + 14'h2000;
    `else 
    mult_gen_0 u_mult_gen_0 (
        .CLK                    (div_clk                ),
        .A                      (out_wav                ),
        .B                      (xadc_data[15:8]        ),
        .P                      (da_data_mult           ) 
    );

    assign da_data = da_data_mult[DATA_W+7-:14] + 14'h2000;

    `endif

    //--------------------- FFT part ------------------------

    wire                     refresh                ;
    wire           [   3: 0] fft_rate               ;
    wire           [   7: 0] amp_out                ;
    wire           [   8: 0] amp_addr               ;
    wire                     out_en                 ;

    reg            [   9: 0] fft_data               ;

    always @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            fft_data <= 10'd0;
        end else begin
            fft_data <= ad_data-10'h200;
        end
    end

    reg                      fft_clk                ;
    reg            [  15: 0] fft_clk_cnt            ;
    reg            [  15: 0] cnt_max                ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_max <= 16'd1000;
        end else begin
            case (fft_rate)
                4'b0001: cnt_max <= 16'd24_999;
                4'b0010: cnt_max <= 16'd24_99;
                4'b0100: cnt_max <= 16'd24_9;
                4'b1000: cnt_max <= 16'd24;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fft_clk_cnt <= 16'd0;
            fft_clk <= 1'b0;
        end else if (fft_clk_cnt == cnt_max) begin
            fft_clk_cnt <= 16'd0;
            fft_clk <= ~fft_clk;
        end else begin
            fft_clk_cnt <= fft_clk_cnt + 16'd1;
        end
    end

    fft_ctrl u_fft_ctrl(
        .clk   	(fft_clk),
        .rst_n 	(rst_n  ),
        .refresh(refresh),
        .data_in(fft_data),
        .amp_out(amp_out),
        .amp_addr(amp_addr),
        .out_en (out_en )
    );

    // output declaration of module MaxMin

    
    MaxMin #(
        .MODESET                ("MAX"                  ),
        .DWIDTH                 (8                      ),
        .RWIDTH                 (7                      ),
        .DSINGED                (0      )               ) 
    u_MaxMin(
        .clock                  (fft_clk                ),
        .reset_n                (rst_n                  ),
        .range                  (7'h7F                  ),
        .ivalid                 (out_en                 ),
        .iaddr                  (amp_addr               ),
        .idata                  (amp_out                ),
        .ovalid                 (ovalid                 ),
        .odata                  (odata                  ),
        .oaddr                  (oaddr                  ),
        .odata2                 (odata2                 ),
        .oaddr2                 (oaddr2                 ) 
    );

    //--------------------- mode change code ------------------------

    assign     phase_inc_delta      = seg_freq_inc    ;
    assign     wav_sel              = seg_wav_sel     ;
    assign     refresh              = swiches[7] ? uart_fft_refresh : seg_fft_refresh;
    assign     fft_rate             = seg_fft_rate    ;

    //--------------------- ILA part ------------------------


    `ifdef SIM

    `elsif ILA

    ila_0 u_ila_0 (
        .clk                    (clk                    ),// input wire clk
        .probe0                 (amp_out                ),
        .probe1                 (amp_addr               ),
        .probe2                 (out_en                )
    );

    `endif

    assign     da_clk               = div_clk         ;
    assign     ad_clk               = fft_clk         ;
endmodule