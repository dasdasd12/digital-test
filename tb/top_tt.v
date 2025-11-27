`define SIM

module top_tt();

reg clk;
reg rst_n;

initial
begin
    clk = 0;
    forever #1 clk = ~clk;
end

reg refresh;
reg [7:0] swiches;
reg [4:0] keys;
reg [19:0] tx_data;
reg tx_pulse;

wire tx_done;

initial
begin
    rst_n = 0;
    tx_pulse = 0;
    refresh = 0;
    tx_data = 20'h00000;
    swiches = 8'h00;    
    keys = 4'h0;
    #20;
    rst_n = 1;
    #100;
    swiches = 8'b0000_0001;
    #100;
    keys = 5'b00100;
    #1000;
    keys = 5'b00000;
    #1000;
    swiches = 8'b0000_0011;
    #100;
    keys = 5'b00100;
    #1000;
    keys = 5'b00000;
    // tx_pulse = 1;
    // tx_data = 20'h00003; //refresh
    // refresh = 1;
    // #100;
    // tx_pulse = 0;
    // refresh = 0;
    // wait (tx_done);
    // #200;
    // refresh = 1;
    // #100;
    // refresh = 0;
end


// output declaration of module top
wire [3:0] sel0;
wire [7:0] seg0;
wire [3:0] sel1;
wire [7:0] seg1;
wire uart_rx;
wire [7:0] led;
wire da_clk;
wire ad_clk;
wire [13:0] da_data;
wire [9:0] ad_data;

assign ad_data = da_data[13:4];

top u_top(
    .clk     	(clk      ),
    .rst_n   	(rst_n    ),
    // .refresh 	(refresh  ),
    .swiches 	(swiches  ),
    .keys    	(keys     ),
    .uart_rx 	(uart_rx  ),
    .sel0    	(sel0     ),
    .seg0    	(seg0     ),
    .da_clk  	(da_clk   ),
    .ad_clk  	(ad_clk   ),
    .da_data 	(da_data  ),
    .ad_data 	(ad_data  )
);

uart_tx_cfg u_uart_tx_cfg(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .tx_data_in     (tx_data        ),
    .tx_pulse       (tx_pulse       ),
    .uart_tx        (uart_rx        ),
    .tx_done        (tx_done               )
);


initial 
begin
    $dumpfile("icarus/top_tt.vcd");
    $dumpvars(0, top_tt);
    #3000;
    $finish;
end

endmodule