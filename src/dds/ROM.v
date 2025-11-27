module ROM #(
    parameter DATA_W    = 16,             // 数据位宽
    parameter ADDR_W    = 8,              // 地址位宽
    parameter INIT_FILE = "rom_data.hex"  // 初始化文件
) (
    input clk,
    input rst_n,

    input      [ADDR_W-1:0] addr,
    output reg [DATA_W-1:0] data_out = 0
);

    // 计算存储器深度
    localparam MEM_DEPTH = 32'd1 << ADDR_W;

    // ROM存储器定义
    reg [DATA_W-1:0] rom_memory[0:MEM_DEPTH-1];

    // 从文件初始化ROM
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom_memory);
            $display("ROM initialized from file: %s", INIT_FILE);
        end else begin
            $display("No INIT_FILE specified, ROM not initialized.");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 0;
        end else begin
            data_out <= rom_memory[addr];
        end
    end

endmodule

module ROM_DULE #(
    parameter DATA_W    = 16,             // 数据位宽
    parameter ADDR_W    = 8,              // 地址位宽
    parameter INIT_FILE = "rom_data.hex"  // 初始化文件
) (
    input clk,
    input rst_n,

    input      [ADDR_W-1:0] addr1,
    output reg [DATA_W-1:0] data_out1 = 0,
    input      [ADDR_W-1:0] addr2,
    output reg [DATA_W-1:0] data_out2 = 0
);

    // 计算存储器深度
    localparam MEM_DEPTH = 32'd1 << ADDR_W;

    // ROM存储器定义
    reg [DATA_W-1:0] rom_memory[0:MEM_DEPTH-1];

    // 从文件初始化ROM
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom_memory);
            $display("ROM initialized from file: %s", INIT_FILE);
        end else begin
            $display("No INIT_FILE specified, ROM not initialized.");
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out1 <= 0;
            data_out2 <= 0;
        end else begin
            data_out1 <= rom_memory[addr1];
            data_out2 <= rom_memory[addr2];
        end
    end

endmodule
