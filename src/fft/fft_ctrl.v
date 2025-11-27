`timescale 1ns/1ps

module fft_ctrl#(
    parameter                           TOTAL_STEP                  = 9                    ,
    parameter                           DATA_WIDTH                  = 10                   ,
    parameter                           SQRT_W                      = 8                    ,
    parameter                           ABS_W                       = 7                    
)(
    input                               clk                        ,
    input                               rst_n                      ,

    input                [   9: 0]      data_in                    ,
    input                               refresh                    ,

    output               [SQRT_W-1: 0]  amp_out                    ,
    output               [       8: 0]  amp_addr                   ,
    output                              out_en                      
);

    localparam                          ADDR_W                      = ABS_W * 2            ;
    wire               [  19: 0]        out_x                       ;
    wire                                out_nd                      ;
    wire                                overflow                    ;

    reg [9:0] iaddr;
    reg [9:0] iaddr_d;

    reg refresh_d0;
    reg refresh_d1;
    wire refresh_pulse;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_d0 <= 1'b0;
            refresh_d1 <= 1'b0;
        end else begin
            refresh_d0 <= refresh;
            refresh_d1 <= refresh_d0;
        end
    end

    assign refresh_pulse = ~refresh_d0 & refresh_d1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            iaddr <= 10'd0;
        end else begin
            if (refresh_pulse) begin
                iaddr <= 10'd0;
            end else begin
                iaddr <= iaddr + 10'd1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            iaddr_d <= 10'd0;
        end else begin
            iaddr_d <= iaddr;
        end
    end

    reg in_nd;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_nd <= 1'b0;
        end 
        else if(iaddr == 10'd511) begin
            in_nd <= 1'b0;
        end
        else if(refresh_pulse) 
            in_nd <= 1'b1;
    end

    dit #(
        .N                                  (256                       ),
        .NLOG2                              (8                         ),
        .X_WDTH                             (10                        ),
        .TF_WDTH                            (10                        ),
        .DEBUGMODE                          (0    )                    ) 
    u_dit(
        .clk                                (clk                       ),
        .rst_n                              (rst_n                     ),
        .in_x                               ({10'd0,data_in}           ),
        .in_nd                              (in_nd                     ),
        .out_x                              (out_x                     ),
        .out_nd                             (out_nd                    ),
        .overflow                           (overflow                  ) 
    );

    reg                [   9: 0]        out_i                       ;
    reg                [   9: 0]        out_r                       ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_r <= 1'b0;
            out_i <= 1'b0;
        end else begin
            out_i <= out_x[19:10];
            out_r <= out_x[9:0];
        end
    end

    wire               [SQRT_W-1: 0]        amp_ori                     ;

    reg                [ABS_W-1: 0]        oReal_abs,                oImag_abs;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            oReal_abs <= 0;
            oImag_abs <= 0;
        end else begin
            oReal_abs <= out_r[DATA_WIDTH-1] ? ~out_r[DATA_WIDTH-2 -: ABS_W] : out_r[DATA_WIDTH-2 -: ABS_W];
            oImag_abs <= out_i[DATA_WIDTH-1] ? ~out_i[DATA_WIDTH-2 -: ABS_W] : out_i[DATA_WIDTH-2 -: ABS_W];
        end
    end

    ROM #(
        .DATA_W                             (SQRT_W                    ),
        .ADDR_W                             (ADDR_W                    ),
        .INIT_FILE                          ("C:/program1/Program/2019.2vivadoprj-master/digital test/rom/sqrt_rom.txt") 
    ) u_ROM (
        .clk                                (clk                       ),
        .rst_n                              (rst_n                     ),
        .addr                               ({oReal_abs, oImag_abs}    ),
        .data_out                           (amp_ori                   ) 
    );

    reg                [   8: 0]        count                       ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 9'd0;
        end else begin
            if (out_nd) begin
                count <= count + 9'd1;
            end
        end
    end

    reg                [   8: 0]        count_d0                     ;
    reg                [   8: 0]        count_d1                     ;
    reg                [   8: 0]        count_d2                     ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_d0 <= 9'd0;
            count_d1 <= 9'd0;
            count_d2 <= 9'd0;
        end else begin
            count_d0 <= count;
            count_d1 <= count_d0;
            count_d2 <= count_d1;
        end
    end

    reg out_d0;
    reg out_d1;
    reg out_d2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_d0 <= 1'b0;
            out_d1 <= 1'b0;
            out_d2 <= 1'b0;
        end else begin
            out_d0 <= out_nd;
            out_d1 <= out_d0;
            out_d2 <= out_d1;
        end
    end

    assign out_en = out_d2;
    assign amp_out = out_d2 ? amp_ori : 10'd0;
    assign amp_addr = count_d2;
    //遍历FFT取最值

    

    // reg [SQRT_W-1:0] amp [0:511];
    // integer j;
    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         // initialize amp memory
    //         for (j = 0; j < 512; j = j + 1) begin
    //             amp[j] <= 0;
    //         end
    //     end else begin
    //         if (out_d2) begin
    //             amp[count_d2] <= amp_ori;
    //         end
    //     end
    // end

    // reg [8:0] cnt;
    
    // reg trs;

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         trs <= 1'b0;
    //     end else begin
    //         if (out_nd&&!out_d0) begin
    //             trs <= 1'b0;
    //         end else if (!out_nd&&out_d0) begin
    //             trs <= 1'b1;
    //         end
    //     end
    // end

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         cnt <= 9'd0;
    //     end else if (trs) begin
    //         if (cnt == 9'd511) begin
    //             cnt <= cnt;
    //         end else begin
    //             cnt <= cnt + 9'd1;
    //         end
    //     end
    //     else begin
    //         cnt <= 9'd0;
    //     end
    // end

    // reg [SQRT_W-1:0] amp_out;

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         amp_out <= 0;
    //     end else begin
    //         amp_out <= amp[cnt];
    //     end
    // end

endmodule