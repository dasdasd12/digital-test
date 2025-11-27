module num2char(
     input        clk,
     input        rst_n,
     input [ 9:0] num,
     output reg [31:0] char
 );
 
    reg [3:0] num_h;
    reg [3:0] num_t;
    reg [3:0] num_o;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            num_h <= 4'd0;
            num_t <= 4'd0;
            num_o <= 4'd0;
            char  <= "0000";
        end else begin
            num_h <= num / 100;
            num_t <= (num / 10) % 10;
            num_o <= num % 10;
            char  <= {"-" , 8'd48 + num_h, 8'd48 + num_t, 8'd48 + num_o};
        end
    end 
 
 endmodule