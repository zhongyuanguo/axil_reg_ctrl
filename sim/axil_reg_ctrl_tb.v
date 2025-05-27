
`timescale 1ns/1ns

module axil_reg_ctrl_tb ();

wire        [31:0]              m_axil_awaddr;
wire        [2:0]               m_axil_awprot;
wire                            m_axil_awvalid;
wire                            m_axil_awready;

wire        [31:0]              m_axil_wdata;
wire        [3:0]               m_axil_wstrb;
wire                            m_axil_wvalid;
wire                            m_axil_wready;

wire        [1:0]               m_axil_bresp;
wire                            m_axil_bvalid;
wire                            m_axil_bready;

wire        [31:0]              m_axil_araddr;
wire        [2:0]               m_axil_arprot;
wire                            m_axil_arvalid;
wire                            m_axil_arready;

wire        [31:0]              m_axil_rdata;
wire        [1:0]               m_axil_rresp;
wire                            m_axil_rvalid;
wire                            m_axil_rready;

wire        [31:0]              s_reg_axil_awaddr;
wire        [2:0]               s_reg_axil_awprot;
wire                            s_reg_axil_awvalid;
wire                            s_reg_axil_awready;

wire        [31:0]              s_reg_axil_wdata;
wire        [3:0]               s_reg_axil_wstrb;
wire                            s_reg_axil_wvalid;
wire                            s_reg_axil_wready;

wire        [1:0]               s_reg_axil_bresp;
wire                            s_reg_axil_bvalid;
wire                            s_reg_axil_bready;

wire        [31:0]              s_reg_axil_araddr;
wire        [2:0]               s_reg_axil_arprot;
wire                            s_reg_axil_arvalid;
wire                            s_reg_axil_arready;

wire        [31:0]              s_reg_axil_rdata;
wire        [1:0]               s_reg_axil_rresp;
wire                            s_reg_axil_rvalid;
wire                            s_reg_axil_rready;

reg         [31:0]              s_axil_awaddr;
reg         [2:0]               s_axil_awprot;
reg                             s_axil_awvalid;
wire                            s_axil_awready;

reg         [31:0]              s_axil_wdata;
reg         [3:0]               s_axil_wstrb;
reg                             s_axil_wvalid;
wire                            s_axil_wready;

wire        [1:0]               s_axil_bresp;
wire                            s_axil_bvalid;
reg                             s_axil_bready;

reg         [31:0]              s_axil_araddr;
reg         [2:0]               s_axil_arprot;
reg                             s_axil_arvalid;
wire                            s_axil_arready;

wire        [31:0]              s_axil_rdata;
wire        [1:0]               s_axil_rresp;
wire                            s_axil_rvalid;
reg                             s_axil_rready;

reg                             axil_aclk=0;
reg                             axil_aresetn;

reg         [31:0]              reg_data;

wire                            m_axil_aclk;
wire                            m_axil_aresetn;

network u_network (
.M00_AXI4L_araddr               (s_reg_axil_araddr[31:0]),
.M00_AXI4L_arprot               (s_reg_axil_arprot[2:0]),
.M00_AXI4L_arready              (s_reg_axil_arready),
.M00_AXI4L_arvalid              (s_reg_axil_arvalid),
.M00_AXI4L_awaddr               (s_reg_axil_awaddr[31:0]),
.M00_AXI4L_awprot               (s_reg_axil_awprot[2:0]),
.M00_AXI4L_awready              (s_reg_axil_awready),
.M00_AXI4L_awvalid              (s_reg_axil_awvalid),
.M00_AXI4L_bready               (s_reg_axil_bready),
.M00_AXI4L_bresp                (s_reg_axil_bresp[1:0]),
.M00_AXI4L_bvalid               (s_reg_axil_bvalid),
.M00_AXI4L_rdata                (s_reg_axil_rdata[31:0]),
.M00_AXI4L_rready               (s_reg_axil_rready),
.M00_AXI4L_rresp                (s_reg_axil_rresp[1:0]),
.M00_AXI4L_rvalid               (s_reg_axil_rvalid),
.M00_AXI4L_wdata                (s_reg_axil_wdata[31:0]),
.M00_AXI4L_wready               (s_reg_axil_wready),
.M00_AXI4L_wstrb                (s_reg_axil_wstrb[3:0]),
.M00_AXI4L_wvalid               (s_reg_axil_wvalid),

.S00_AXI4L_araddr               (s_axil_araddr[31:0]),
.S00_AXI4L_arprot               (s_axil_arprot[2:0]),
.S00_AXI4L_arready              (s_axil_arready),
.S00_AXI4L_arvalid              (s_axil_arvalid),
.S00_AXI4L_awaddr               (s_axil_awaddr[31:0]),
.S00_AXI4L_awprot               (s_axil_arprot[2:0]),
.S00_AXI4L_awready              (s_axil_awready),
.S00_AXI4L_awvalid              (s_axil_awvalid),
.S00_AXI4L_bready               (s_axil_bready),
.S00_AXI4L_bresp                (s_axil_bresp[1:0]),
.S00_AXI4L_bvalid               (s_axil_bvalid),
.S00_AXI4L_rdata                (s_axil_rdata[31:0]),
.S00_AXI4L_rready               (s_axil_rready),
.S00_AXI4L_rresp                (s_axil_rresp[1:0]),
.S00_AXI4L_rvalid               (s_axil_rvalid),
.S00_AXI4L_wdata                (s_axil_wdata[31:0]),
.S00_AXI4L_wready               (s_axil_wready),
.S00_AXI4L_wstrb                (s_axil_wstrb[3:0]),
.S00_AXI4L_wvalid               (s_axil_wvalid),

.aclk                           (axil_aclk),
.aresetn                        (axil_aresetn));


axil_reg_ctrl DUT (
.axil_aclk                      (axil_aclk),
.axil_aresetn                   (axil_aresetn),

.m_axil_aclk                    (m_axil_aclk),
.m_axil_aresetn                 (m_axil_aresetn),

.s_axil_awaddr                  (s_reg_axil_awaddr[11:0]),
.s_axil_awprot                  (s_reg_axil_awprot[2:0]),
.s_axil_awvalid                 (s_reg_axil_awvalid),
.s_axil_awready                 (s_reg_axil_awready),

.s_axil_wdata                   (s_reg_axil_wdata[31:0]),
.s_axil_wstrb                   (s_reg_axil_wstrb[3:0]),
.s_axil_wvalid                  (s_reg_axil_wvalid),
.s_axil_wready                  (s_reg_axil_wready),

.s_axil_bresp                   (s_reg_axil_bresp[1:0]),
.s_axil_bvalid                  (s_reg_axil_bvalid),
.s_axil_bready                  (s_reg_axil_bready),

.s_axil_araddr                  (s_reg_axil_araddr[11:0]),
.s_axil_arprot                  (s_reg_axil_arprot[2:0]),
.s_axil_arvalid                 (s_reg_axil_arvalid),
.s_axil_arready                 (s_reg_axil_arready),

.s_axil_rdata                   (s_reg_axil_rdata[31:0]),
.s_axil_rresp                   (s_reg_axil_rresp[1:0]),
.s_axil_rvalid                  (s_reg_axil_rvalid),
.s_axil_rready                  (s_reg_axil_rready),

.m_axil_awaddr                  (m_axil_awaddr[11:0]),
.m_axil_awvalid                 (m_axil_awvalid),
.m_axil_awready                 (m_axil_awready),

.m_axil_wdata                   (m_axil_wdata[31:0]),
.m_axil_wstrb                   (m_axil_wstrb[3:0]),
.m_axil_wvalid                  (m_axil_wvalid),
.m_axil_wready                  (m_axil_wready),

.m_axil_bresp                   (m_axil_bresp[1:0]),
.m_axil_bvalid                  (m_axil_bvalid),
.m_axil_bready                  (m_axil_bready),

.m_axil_araddr                  (m_axil_araddr[11:0]),
.m_axil_arvalid                 (m_axil_arvalid),
.m_axil_arready                 (m_axil_arready),

.m_axil_rdata                   (m_axil_rdata[31:0]),
.m_axil_rresp                   (m_axil_rresp[1:0]),
.m_axil_rvalid                  (m_axil_rvalid),
.m_axil_rready                  (m_axil_rready));

axil_ram #(.ADDR_WIDTH(12), .DATA_WIDTH(32), .PIPELINE_OUTPUT(0))
u_axil_ram (
.clk                            (m_axil_aclk),
.rst                            (~m_axil_aresetn),

.s_axil_awaddr                  (m_axil_awaddr[11:0]),
.s_axil_awprot                  (3'h0),
.s_axil_awvalid                 (m_axil_awvalid),
.s_axil_awready                 (m_axil_awready),

.s_axil_wdata                   (m_axil_wdata[31:0]),
.s_axil_wstrb                   (m_axil_wstrb[3:0]),
.s_axil_wvalid                  (m_axil_wvalid),
.s_axil_wready                  (m_axil_wready),

.s_axil_bresp                   (m_axil_bresp[1:0]),
.s_axil_bvalid                  (m_axil_bvalid),
.s_axil_bready                  (m_axil_bready),

.s_axil_araddr                  (m_axil_araddr[11:0]),
.s_axil_arprot                  (3'h0),
.s_axil_arvalid                 (m_axil_arvalid),
.s_axil_arready                 (m_axil_arready),

.s_axil_rdata                   (m_axil_rdata[31:0]),
.s_axil_rresp                   (m_axil_rresp[1:0]),
.s_axil_rvalid                  (m_axil_rvalid),
.s_axil_rready                  (m_axil_rready));

always #5 axil_aclk = ~axil_aclk;

initial begin 
s_axil_bready   = 0;

s_axil_awaddr   = 32'h0;
s_axil_awvalid  = 1'b0;
s_axil_awprot   = 3'h0;

s_axil_wdata    = 32'h0;
s_axil_wstrb    = 4'h0;
s_axil_wvalid   = 1'b0;

s_axil_araddr   = 32'h0;
s_axil_arvalid  = 1'b0;
s_axil_arprot   = 3'h0;

s_axil_rready   = 1'b0;


axil_aresetn    = 1;
#100
axil_aresetn    = 0;
#400
axil_aresetn    = 1;

#100
// ONE WRITE AND ONE CHECK


m_axil_byte_check(32'h200, 32'h11223344, 4'hF);
m_axil_byte_check(32'h204, 32'h55667788, 4'hF);
m_axil_byte_check(32'h208, 32'h99aabbcc, 4'hF);
m_axil_byte_check(32'h20c, 32'hddeeff00, 4'hF);

m_axil_byte_check(32'h300, 32'h11223344, 4'h3);
m_axil_byte_check(32'h304, 32'h55667788, 4'h3);
m_axil_byte_check(32'h308, 32'h99aabbcc, 4'h3);
m_axil_byte_check(32'h30c, 32'hddeeff00, 4'h3);

#400
$finish;

end

task m_axil_write_addr;
input   [31:0]                  addr;

begin
    @(posedge axil_aclk);

    s_axil_awaddr <= addr;
    s_axil_awvalid <= 1;
    s_axil_awprot <= 3'h0;

    wait (s_axil_awready);
    @(posedge axil_aclk);
    s_axil_awvalid <= 0;

end
endtask

task m_axil_write_data;
input   [31:0]                  data;
input   [3:0]                   strb;

begin
    @(posedge axil_aclk);

    s_axil_wdata <= data;
    s_axil_wstrb <= strb;
    s_axil_wvalid <= s_axil_wready? 1:0;
//    s_axil_wvalid <= 1;

    s_axil_bready <= 0;

    wait (s_axil_wready);
    @(posedge axil_aclk);
    s_axil_wvalid <= 0;
    s_axil_bready <= 1;
    wait (s_axil_bvalid);

    if (s_axil_bresp != 2'b00) begin
        $display("Error: AXI4-Lite write response not OKAY at time  %t", $time);
    end
    
    @(posedge axil_aclk);
    s_axil_bready <= 0;
end
endtask

task m_axil_write;
input   [31:0]                  addr;
input   [31:0]                  data;
input   [3:0]                   strb;

fork begin
    m_axil_write_addr(addr);
    m_axil_write_data(data, strb);
end join
endtask

task m_axil_read;
input   [31:0]                  addr;
output  [31:0]                  data;

begin
    @(posedge axil_aclk);
    s_axil_araddr <= addr;
    s_axil_arvalid <= 1;
    s_axil_arprot <= 3'h0;

    wait (s_axil_arvalid && s_axil_arready);
    @(posedge axil_aclk);
    s_axil_arvalid <= 0;
    s_axil_rready <= 1;

    wait (s_axil_rvalid);
    data = s_axil_rdata;

    if (s_axil_rresp != 2'b00) begin
        $display("Error: AXI4-Lite read response not OKAY at time  %t", $time);
    end
    @(posedge axil_aclk);
    s_axil_rready <= 0;
    #10;
end
endtask

task m_axil_byte_check;
input   [31:0]                  addr;
input   [31:0]                  data;
input   [3:0]                   strb;

reg     [31:0]                  wr_addr;
reg     [31:0]                  rd_addr;
reg     [31:0]                  wr_data;
reg     [31:0]                  rd_data;

integer i;

begin
    $display("Byte Write Byte Read Check Begin...");

    wr_addr = {1'b1, 15'h0, addr[15:0]};
    // Write Data REG Setting
    m_axil_write(32'h44A0000C, data, strb);
    $display("Write 0x%h in 0x%b to 0xC, Write Data REG", data, strb);
    // Write Address REG Setting
    m_axil_write(32'h44A00008, wr_addr, 4'b1111);
    $display("Write 0x%h in 0x%b to 0x8, Write Addr REG", wr_addr, 4'b1111);
    // Write Address REG Checking
    m_axil_read(32'h44A00008, rd_addr);
    $display("Check Write Status...");
    $display("Write Address REG is 0x%h", rd_addr);
    #50;
    //wait(rd_addr[31]);
    $display("Write Finished");
    // Read Address REG Setting
    m_axil_write(32'h44A00000, wr_addr, 4'b1111);
    $display("Write 0x%h in 0x%b to 0x0, Read Addr REG", wr_addr, 4'b1111);
    // Read Address REG Checking
    m_axil_read(32'h44A00000, rd_addr);
    #50;
    //wait(rd_addr[31]);
    $display("Read Finished");
    // Read Data REG Checking
    m_axil_read(32'h44A00004, rd_data);
    $display("Read 0x%h from 0x4, Read Data REG", rd_data);

    for (i=0; i<4; i=i+1) begin: wstrb
        if (strb[i])
            wr_data[8*i+:8] = data[8*i+:8];
        else
            wr_data[8*i+:8] = 8'h00;
    end

    if (rd_data == wr_data)
        $display("Byte Write Byte Read Check Passed");
    else
        $display("Byte Write Byte Read Check Failed");
end
endtask

endmodule