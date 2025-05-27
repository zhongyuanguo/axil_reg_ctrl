
`timescale 1ns/1ns

module axil_reg_ctrl (
input   wire                            axil_aclk,
input   wire                            axil_aresetn,
output  wire                            m_axil_aclk,
output  wire                            m_axil_aresetn, 

// AXI-Lite Slave Interface
input   wire    [11:0]                  s_axil_awaddr,
input   wire    [2:0]                   s_axil_awprot,
input   wire                            s_axil_awvalid,
output  wire                            s_axil_awready,

input   wire    [31:0]                  s_axil_wdata,
input   wire    [3:0]                   s_axil_wstrb,
input   wire                            s_axil_wvalid,
output  wire                            s_axil_wready,

output  wire    [1:0]                   s_axil_bresp,
output  wire                            s_axil_bvalid,
input   wire                            s_axil_bready,

input   wire    [11:0]                  s_axil_araddr,
input   wire    [2:0]                   s_axil_arprot,
input   wire                            s_axil_arvalid,
output  wire                            s_axil_arready,

output  wire    [31:0]                  s_axil_rdata,
output  wire    [1:0]                   s_axil_rresp,
output  wire                            s_axil_rvalid,
input   wire                            s_axil_rready,

// AXI-Lite Master Interface
output  wire    [11:0]                  m_axil_awaddr,
output  wire                            m_axil_awvalid,
input   wire                            m_axil_awready,

input   wire    [31:0]                  m_axil_wdata,
input   wire    [3:0]                   m_axil_wstrb,
output  wire                            m_axil_wvalid,
input   wire                            m_axil_wready,

input   wire    [1:0]                   m_axil_bresp,
input   wire                            m_axil_bvalid,
output  wire                            m_axil_bready,

output  wire    [11:0]                  m_axil_araddr,
output  wire                            m_axil_arvalid,
input   wire                            m_axil_arready,

input   wire    [31:0]                  m_axil_rdata,
input   wire    [1:0]                   m_axil_rresp,
input   wire                            m_axil_rvalid,
output  wire                            m_axil_rready
);


reg     [31:0]                          spi_rd_addr_reg;
reg     [31:0]                          spi_rd_data_reg;
reg     [31:0]                          spi_wr_addr_reg;
reg     [31:0]                          spi_wr_data_reg;

reg     [2:0]                           m_axil_awvalid_cs;
reg     [2:0]                           m_axil_awvalid_ns;
reg     [11:0]                          m_axil_awaddr_r;
reg                                     m_axil_awvalid_r;

reg     [3:0]                           m_axil_wvalid_cs;
reg     [3:0]                           m_axil_wvalid_ns;

reg     [31:0]                          m_axil_wdata_r;
reg     [3:0]                           m_axil_wstrb_r;
reg                                     m_axil_wvalid_r;
reg                                     m_axil_bready_r;
reg                                     m_axil_wr_done_r;

reg     [3:0]                           m_axil_rd_cs;
reg     [3:0]                           m_axil_rd_ns;

reg     [11:0]                          m_axil_araddr_r;
reg                                     m_axil_arvalid_r;
reg     [31:0]                          m_axil_rdata_r;
reg                                     m_axil_rready_r;
reg                                     m_axil_rd_done_r;

wire                                    spi_rd_addr_reg_sel;
wire                                    spi_wr_addr_reg_sel;
wire                                    spi_rd_data_reg_sel;
wire                                    spi_wr_data_reg_sel;

wire                                    spi_rd_en;
wire                                    spi_wr_en;


reg     [31:0]                          reg_rddata;

wire    [31:0]                          reg_wrdata;
wire    [11:0]                          reg_addr;
wire    [3:0]                           reg_we;
wire                                    reg_en;

wire                                    reg_clk;
wire                                    reg_rst;


axi_bram_ctrl_1kx32 u_axil_ctrl (
.s_axi_aclk                             (axil_aclk),
.s_axi_aresetn                          (axil_aresetn),

.s_axi_awaddr                           (s_axil_awaddr[11:0]),
.s_axi_awprot                           (s_axil_awprot[2:0]),
.s_axi_awvalid                          (s_axil_awvalid),
.s_axi_awready                          (s_axil_awready),
.s_axi_wdata                            (s_axil_wdata[31:0]),
.s_axi_wstrb                            (s_axil_wstrb[3:0]),
.s_axi_wvalid                           (s_axil_wvalid),
.s_axi_wready                           (s_axil_wready),
.s_axi_bresp                            (s_axil_bresp[1:0]),
.s_axi_bvalid                           (s_axil_bvalid),
.s_axi_bready                           (s_axil_bready),

.s_axi_araddr                           (s_axil_araddr[11:0]),
.s_axi_arprot                           (s_axil_arprot[2:0]),
.s_axi_arvalid                          (s_axil_arvalid),
.s_axi_arready                          (s_axil_arready),
.s_axi_rdata                            (s_axil_rdata[31:0]),
.s_axi_rresp                            (s_axil_rresp[1:0]),
.s_axi_rvalid                           (s_axil_rvalid),
.s_axi_rready                           (s_axil_rready),

.bram_rst_a                             (reg_rst),
.bram_clk_a                             (reg_clk),
.bram_en_a                              (reg_en),
.bram_we_a                              (reg_we[3:0]),
.bram_addr_a                            (reg_addr[11:0]),
.bram_wrdata_a                          (reg_wrdata[31:0]),
.bram_rddata_a                          (reg_rddata[31:0]));

assign m_axil_aclk = reg_clk;
assign m_axil_aresetn = ~reg_rst;

// SPI Registers
// Addresses Decode
parameter                                SPI_RD_ADDR = {12{1'b0}}+4'h0;
parameter                                SPI_RD_DATA = {12{1'b0}}+4'h4;
parameter                                SPI_WR_ADDR = {12{1'b0}}+4'h8;
parameter                                SPI_WR_DATA = {12{1'b0}}+4'hC;

assign spi_rd_addr_reg_sel = (reg_addr == SPI_RD_ADDR) ? 1'b1 : 1'b0;
assign spi_wr_addr_reg_sel = (reg_addr == SPI_WR_ADDR) ? 1'b1 : 1'b0;
assign spi_rd_data_reg_sel = (reg_addr == SPI_RD_DATA) ? 1'b1 : 1'b0;
assign spi_wr_data_reg_sel = (reg_addr == SPI_WR_DATA) ? 1'b1 : 1'b0;

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst) 
        reg_rddata <= 32'h0;
    else if (reg_en) begin
        if (spi_rd_addr_reg_sel)
            reg_rddata <= spi_rd_addr_reg[31:0];
        else if (spi_rd_data_reg_sel)
            reg_rddata <= spi_rd_data_reg[31:0];
        else if (spi_wr_addr_reg_sel)
            reg_rddata <= spi_wr_addr_reg[31:0];
        else
            reg_rddata <= 32'h0;
    end
end

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        spi_rd_data_reg <= 32'h0;
    else if (m_axil_rd_done_r)
        spi_rd_data_reg <= m_axil_rdata_r[31:0];
//    else if (s_axil_rd_en_r && spi_rd_data_reg_sel)
//        spi_rd_data_reg <= {DATA_WIDTH{1'b0}};
end

integer i;
always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        spi_rd_addr_reg <= 32'h0;
    else if (spi_rd_addr_reg_sel && reg_en) begin
        for (i=0; i<4; i=i+1) begin: RD_ADDR_LATCH
            if (reg_we[i])
                spi_rd_addr_reg[i*8+:8] <= reg_wrdata[i*8+:8];
        end
    end
    else if (m_axil_rd_done_r)
        // CLEAN BIT31 WHEN DONE
        spi_rd_addr_reg <= {1'b0, spi_rd_addr_reg[30:0]};
end

assign spi_rd_en = spi_rd_addr_reg[31];

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        spi_wr_data_reg <= 32'h0;
    else if (spi_wr_data_reg_sel && reg_en) begin
        for (i=0; i<4; i=i+1) begin: WR_DATA_LATCH
            if (reg_we[i])
                spi_wr_data_reg[i*8+:8] <= reg_wrdata[i*8+:8];
        end
    end
    else if (m_axil_wr_done_r)
        // CLEAN DATA WHEN DONE
        spi_wr_data_reg <= 32'h0;
end

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        spi_wr_addr_reg <= 32'h0;
    else if (spi_wr_addr_reg_sel && reg_en) begin
        for (i=0; i<4; i=i+1) begin: WR_ADDR_LATCH
            if (reg_we[i])
                spi_wr_addr_reg[i*8+:8] <= reg_wrdata[i*8+:8];
        end
    end
    else if (m_axil_wr_done_r)
        // CLEAN BIT31 WHEN DONE
        spi_wr_addr_reg <= {1'b0, spi_wr_addr_reg[30:0]};
end

assign spi_wr_en = spi_wr_addr_reg[31];

// M AW
parameter                                M_AW_IDLE = 3'b001;
parameter                                M_AW_ADDR = 3'b010;
parameter                                M_AW_DONE = 3'b100;

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        m_axil_awvalid_cs <= 3'h0;
    else
        m_axil_awvalid_cs <= m_axil_awvalid_ns;
end

always @* begin
    case (m_axil_awvalid_cs)
    M_AW_IDLE: begin
        m_axil_awaddr_r = 12'h0;
        m_axil_awvalid_r = 1'b0;
        if (spi_wr_en)
            m_axil_awvalid_ns = M_AW_ADDR;
        else
            m_axil_awvalid_ns = M_AW_IDLE;
    end
    M_AW_ADDR: begin
        m_axil_awaddr_r[11:0] = spi_wr_addr_reg[11:0];
        m_axil_awvalid_r = 1'b1;
        if (m_axil_awready)
            m_axil_awvalid_ns = M_AW_DONE;
        else
            m_axil_awvalid_ns = M_AW_ADDR;
    end
    M_AW_DONE: begin
        m_axil_awaddr_r[11:0] = spi_wr_addr_reg[11:0];
        m_axil_awvalid_r = 1'b0;
        m_axil_awvalid_ns = M_AW_IDLE;
    end
    default: begin
        m_axil_awaddr_r[11:0] = 12'h0;
        m_axil_awvalid_r = 1'b0;
        m_axil_awvalid_ns = M_AW_IDLE;
    end
    endcase
end

assign m_axil_awaddr = m_axil_awaddr_r[11:0];
assign m_axil_awvalid = m_axil_awvalid_r;

// M W & B
parameter                                M_W_IDLE = 4'b0001;
parameter                                M_W_DATA = 4'b0010;
parameter                                M_W_DONE = 4'b0100;
parameter                                M_B_DONE = 4'b1000;

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        m_axil_wvalid_cs <= 4'h0;
    else
        m_axil_wvalid_cs <= m_axil_wvalid_ns;
end

always @* begin
    case (m_axil_wvalid_cs)
    M_W_IDLE: begin
        m_axil_wdata_r = 32'h0;
        m_axil_wstrb_r = 4'h0;
        m_axil_wvalid_r = 1'b0;
        m_axil_bready_r = 1'b0;
        m_axil_wr_done_r = 1'b0;
        if (spi_wr_en)
            m_axil_wvalid_ns = M_W_DATA;
        else
            m_axil_wvalid_ns = M_W_IDLE;
    end
    M_W_DATA: begin
        m_axil_wdata_r[31:0] = spi_wr_data_reg[31:0];
        m_axil_wstrb_r[3:0] = 4'hF;
        m_axil_wvalid_r = 1'b1;
        m_axil_bready_r = 1'b0;
        m_axil_wr_done_r = 1'b0;
        if (m_axil_wready)
            m_axil_wvalid_ns = M_W_DONE;
        else
            m_axil_wvalid_ns = M_W_DATA;
    end
    M_W_DONE: begin
        m_axil_wdata_r[31:0] = spi_wr_data_reg[31:0];
        m_axil_wstrb_r[3:0] = 4'h0;
        m_axil_wvalid_r = 1'b0;
        m_axil_bready_r = 1'b0;
        m_axil_wr_done_r = 1'b1;
        m_axil_wvalid_ns = M_B_DONE;
    end
    M_B_DONE: begin
        m_axil_wdata_r[31:0] = 32'h0;
        m_axil_wstrb_r[3:0] = 4'h0;
        m_axil_wvalid_r = 1'b0;
        m_axil_bready_r = 1'b1;
        m_axil_wr_done_r = 1'b0;
        if (m_axil_bvalid)
            m_axil_wvalid_ns = M_W_IDLE;
        else
            m_axil_wvalid_ns = M_B_DONE;
    end
    default: begin
        m_axil_wdata_r[31:0] = 32'h0;
        m_axil_wstrb_r[3:0] = 4'h0;
        m_axil_wvalid_r = 1'b0;
        m_axil_bready_r = 1'b0;
        m_axil_wr_done_r = 1'b0;
        m_axil_wvalid_ns = M_W_IDLE;
    end
    endcase
end

assign m_axil_wdata = m_axil_wdata_r[31:0];
assign m_axil_wstrb = m_axil_wstrb_r[3:0];
assign m_axil_wvalid = m_axil_wvalid_r;
assign m_axil_bready = m_axil_bready_r;

// M AR & R
parameter                                 M_RD_IDLE = 4'b0001;
parameter                                 M_RD_ADDR = 4'b0010;
parameter                                 M_RD_DATA = 4'b0100;
parameter                                 M_RD_DONE = 4'b1000;

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        m_axil_rd_cs <= 4'h0;
    else
        m_axil_rd_cs <= m_axil_rd_ns;
end

always @* begin
    case (m_axil_rd_cs) 
    M_RD_IDLE: begin
        m_axil_araddr_r = 12'h0;
        m_axil_arvalid_r = 1'b0;
        m_axil_rready_r = 1'b0;
        m_axil_rd_done_r = 1'b0;
        if (spi_rd_en)
            m_axil_rd_ns = M_RD_ADDR;
        else
            m_axil_rd_ns = M_RD_IDLE;
    end
    M_RD_ADDR: begin
        m_axil_araddr_r[11:0] = spi_rd_addr_reg[11:0];
        m_axil_arvalid_r = 1'b1;
        m_axil_rready_r = 1'b0;
        m_axil_rd_done_r = 1'b0;
        if (m_axil_arready)
            m_axil_rd_ns = M_RD_DATA;
        else
            m_axil_rd_ns = M_RD_ADDR;
    end
    M_RD_DATA: begin
        m_axil_araddr_r[11:0] = spi_rd_addr_reg[11:0];
        m_axil_arvalid_r = 1'b0;
        m_axil_rready_r = 1'b1;
        m_axil_rd_done_r = 1'b0;
        if (m_axil_rvalid)
            m_axil_rd_ns = M_RD_DONE;
        else
            m_axil_rd_ns = M_RD_DATA;
    end
    M_RD_DONE: begin
        m_axil_araddr_r[11:0] = 12'h0;
        m_axil_arvalid_r = 1'b0;
        m_axil_rready_r = 1'b0;
        m_axil_rd_done_r = 1'b1;
        m_axil_rd_ns = M_RD_IDLE;
    end
    default: begin
        m_axil_araddr_r[11:0] = 12'h0;
        m_axil_arvalid_r = 1'b0;
        m_axil_rready_r = 1'b0;
        m_axil_rd_done_r = 1'b0;
        m_axil_rd_ns = M_RD_IDLE;
    end
    endcase
end

assign m_axil_araddr = m_axil_araddr_r[11:0];
assign m_axil_arvalid = m_axil_arvalid_r;
assign m_axil_rready = m_axil_rready_r;

always @(posedge reg_clk or posedge reg_rst) begin
    if (reg_rst)
        m_axil_rdata_r <= 32'h0;
    else if (m_axil_rvalid && m_axil_rready)
        m_axil_rdata_r <= m_axil_rdata[31:0];
end

endmodule