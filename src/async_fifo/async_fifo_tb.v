`timescale 1ns / 1ps

module async_fifo_tb;

    // 参数定义
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;
    parameter FIFO_DEPTH = 1 << ADDR_WIDTH;

    // 信号声明
    reg wr_clk;
    reg wr_rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] din;
    wire full;
    wire almost_full;
    
    reg rd_clk;
    reg rd_rst_n;
    reg rd_en;
    wire [DATA_WIDTH-1:0] dout;
    wire empty;
    wire almost_empty;
    
    // 时钟生成
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk; // 10ns周期(100MHz)
    end
    
    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk; // 14ns周期(71.4MHz)
    end
    
    // 实例化被测模块
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        .almost_full(almost_full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .dout(dout),
        .empty(empty),
        .almost_empty(almost_empty)
    );
    
    // 测试序列
    initial begin
        // 初始化信号
        wr_rst_n = 0;
        rd_rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        din = 0;
        
        // 复位
        #20;
        wr_rst_n = 1;
        rd_rst_n = 1;
        #20;
        
        // 测试1: 写入比读出快 - 填充FIFO
        $display("Test1: Write faster than read");
        write_task(200);
        read_task(100);
        #100;
        
        // 测试2: 读出比写入快 - 清空FIFO
        $display("Test2: Read faster than write");
        write_task(100);
        read_task(200);
        #100;
        
        // 测试3: 同时读写 - 稳定状态
        $display("Test3: Stable");
        fork
            write_task(300);
            read_task(300);
        join
        #100;
        
        // 测试4: 填充到满
        $display("Test4: Fill to full");
        write_task(FIFO_DEPTH);
        #100;
        
        // 测试5: 从空读取
        $display("Test5: Read from empty");
        read_task(20);
        #100;
        
        // 测试6: 随机读写
        $display("Test6, Random test");
        random_test(500);
        #100;
        
        // 结束仿真
        $display("Finished!!!");
        $finish;
    end
    
    // 写入任务
    task write_task;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge wr_clk);
                wr_en = ~full;
                din = $random;
                if (wr_en) begin
                    $display("Write data: %0d Time: %0t", din, $time);
                end
            end
            wr_en = 0;
        end
    endtask
    
    // 读取任务
    task read_task;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge rd_clk);
                rd_en = ~empty;
                if (rd_en) begin
                    $display("Read data: %0d Time: %0t", dout, $time);
                end
            end
            rd_en = 0;
        end
    endtask
    
    // 随机测试任务
    task random_test;
        input integer cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge wr_clk);
                wr_en = ($random % 2) && (~full);
                din = $random;
                
                @(posedge rd_clk);
                rd_en = ($random % 2) && (~empty);
            end
            wr_en = 0;
            rd_en = 0;
        end
    endtask
    
    // 监控状态标志
    initial begin
        $monitor("Time: %0t, Status: full=%b, almost_full=%b, empty=%b, almost_empty=%b", 
                 $time, full, almost_full, empty, almost_empty);
    end

endmodule    