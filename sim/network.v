//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Tue May 27 04:45:27 2025
//Host        : mOonshine running 64-bit major release  (build 9200)
//Command     : generate_target network.bd
//Design      : network
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "network,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=network,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "network.hwdef" *) 
module network
   (M00_AXI4L_araddr,
    M00_AXI4L_arprot,
    M00_AXI4L_arready,
    M00_AXI4L_arvalid,
    M00_AXI4L_awaddr,
    M00_AXI4L_awprot,
    M00_AXI4L_awready,
    M00_AXI4L_awvalid,
    M00_AXI4L_bready,
    M00_AXI4L_bresp,
    M00_AXI4L_bvalid,
    M00_AXI4L_rdata,
    M00_AXI4L_rready,
    M00_AXI4L_rresp,
    M00_AXI4L_rvalid,
    M00_AXI4L_wdata,
    M00_AXI4L_wready,
    M00_AXI4L_wstrb,
    M00_AXI4L_wvalid,
    S00_AXI4L_araddr,
    S00_AXI4L_arprot,
    S00_AXI4L_arready,
    S00_AXI4L_arvalid,
    S00_AXI4L_awaddr,
    S00_AXI4L_awprot,
    S00_AXI4L_awready,
    S00_AXI4L_awvalid,
    S00_AXI4L_bready,
    S00_AXI4L_bresp,
    S00_AXI4L_bvalid,
    S00_AXI4L_rdata,
    S00_AXI4L_rready,
    S00_AXI4L_rresp,
    S00_AXI4L_rvalid,
    S00_AXI4L_wdata,
    S00_AXI4L_wready,
    S00_AXI4L_wstrb,
    S00_AXI4L_wvalid,
    aclk,
    aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L ARADDR" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXI4L, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN network_aclk_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]M00_AXI4L_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L ARPROT" *) output [2:0]M00_AXI4L_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L ARREADY" *) input M00_AXI4L_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L ARVALID" *) output M00_AXI4L_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L AWADDR" *) output [31:0]M00_AXI4L_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L AWPROT" *) output [2:0]M00_AXI4L_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L AWREADY" *) input M00_AXI4L_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L AWVALID" *) output M00_AXI4L_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L BREADY" *) output M00_AXI4L_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L BRESP" *) input [1:0]M00_AXI4L_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L BVALID" *) input M00_AXI4L_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L RDATA" *) input [31:0]M00_AXI4L_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L RREADY" *) output M00_AXI4L_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L RRESP" *) input [1:0]M00_AXI4L_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L RVALID" *) input M00_AXI4L_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L WDATA" *) output [31:0]M00_AXI4L_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L WREADY" *) input M00_AXI4L_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L WSTRB" *) output [3:0]M00_AXI4L_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M00_AXI4L WVALID" *) output M00_AXI4L_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L ARADDR" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXI4L, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN network_aclk_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]S00_AXI4L_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L ARPROT" *) input [2:0]S00_AXI4L_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L ARREADY" *) output S00_AXI4L_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L ARVALID" *) input S00_AXI4L_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L AWADDR" *) input [31:0]S00_AXI4L_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L AWPROT" *) input [2:0]S00_AXI4L_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L AWREADY" *) output S00_AXI4L_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L AWVALID" *) input S00_AXI4L_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L BREADY" *) input S00_AXI4L_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L BRESP" *) output [1:0]S00_AXI4L_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L BVALID" *) output S00_AXI4L_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L RDATA" *) output [31:0]S00_AXI4L_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L RREADY" *) input S00_AXI4L_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L RRESP" *) output [1:0]S00_AXI4L_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L RVALID" *) output S00_AXI4L_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L WDATA" *) input [31:0]S00_AXI4L_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L WREADY" *) output S00_AXI4L_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L WSTRB" *) input [3:0]S00_AXI4L_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI4L WVALID" *) input S00_AXI4L_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF S00_AXI4L:M00_AXI4L, CLK_DOMAIN network_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;

  wire [31:0]M00_AXI4L_araddr;
  wire [2:0]M00_AXI4L_arprot;
  wire M00_AXI4L_arready;
  wire M00_AXI4L_arvalid;
  wire [31:0]M00_AXI4L_awaddr;
  wire [2:0]M00_AXI4L_awprot;
  wire M00_AXI4L_awready;
  wire M00_AXI4L_awvalid;
  wire M00_AXI4L_bready;
  wire [1:0]M00_AXI4L_bresp;
  wire M00_AXI4L_bvalid;
  wire [31:0]M00_AXI4L_rdata;
  wire M00_AXI4L_rready;
  wire [1:0]M00_AXI4L_rresp;
  wire M00_AXI4L_rvalid;
  wire [31:0]M00_AXI4L_wdata;
  wire M00_AXI4L_wready;
  wire [3:0]M00_AXI4L_wstrb;
  wire M00_AXI4L_wvalid;
  wire [31:0]S00_AXI4L_araddr;
  wire [2:0]S00_AXI4L_arprot;
  wire S00_AXI4L_arready;
  wire S00_AXI4L_arvalid;
  wire [31:0]S00_AXI4L_awaddr;
  wire [2:0]S00_AXI4L_awprot;
  wire S00_AXI4L_awready;
  wire S00_AXI4L_awvalid;
  wire S00_AXI4L_bready;
  wire [1:0]S00_AXI4L_bresp;
  wire S00_AXI4L_bvalid;
  wire [31:0]S00_AXI4L_rdata;
  wire S00_AXI4L_rready;
  wire [1:0]S00_AXI4L_rresp;
  wire S00_AXI4L_rvalid;
  wire [31:0]S00_AXI4L_wdata;
  wire S00_AXI4L_wready;
  wire [3:0]S00_AXI4L_wstrb;
  wire S00_AXI4L_wvalid;
  wire aclk;
  wire aresetn;

  network_smartconnect_0_0 smartconnect_top
       (.M00_AXI_araddr(M00_AXI4L_araddr),
        .M00_AXI_arprot(M00_AXI4L_arprot),
        .M00_AXI_arready(M00_AXI4L_arready),
        .M00_AXI_arvalid(M00_AXI4L_arvalid),
        .M00_AXI_awaddr(M00_AXI4L_awaddr),
        .M00_AXI_awprot(M00_AXI4L_awprot),
        .M00_AXI_awready(M00_AXI4L_awready),
        .M00_AXI_awvalid(M00_AXI4L_awvalid),
        .M00_AXI_bready(M00_AXI4L_bready),
        .M00_AXI_bresp(M00_AXI4L_bresp),
        .M00_AXI_bvalid(M00_AXI4L_bvalid),
        .M00_AXI_rdata(M00_AXI4L_rdata),
        .M00_AXI_rready(M00_AXI4L_rready),
        .M00_AXI_rresp(M00_AXI4L_rresp),
        .M00_AXI_rvalid(M00_AXI4L_rvalid),
        .M00_AXI_wdata(M00_AXI4L_wdata),
        .M00_AXI_wready(M00_AXI4L_wready),
        .M00_AXI_wstrb(M00_AXI4L_wstrb),
        .M00_AXI_wvalid(M00_AXI4L_wvalid),
        .S00_AXI_araddr(S00_AXI4L_araddr),
        .S00_AXI_arprot(S00_AXI4L_arprot),
        .S00_AXI_arready(S00_AXI4L_arready),
        .S00_AXI_arvalid(S00_AXI4L_arvalid),
        .S00_AXI_awaddr(S00_AXI4L_awaddr),
        .S00_AXI_awprot(S00_AXI4L_awprot),
        .S00_AXI_awready(S00_AXI4L_awready),
        .S00_AXI_awvalid(S00_AXI4L_awvalid),
        .S00_AXI_bready(S00_AXI4L_bready),
        .S00_AXI_bresp(S00_AXI4L_bresp),
        .S00_AXI_bvalid(S00_AXI4L_bvalid),
        .S00_AXI_rdata(S00_AXI4L_rdata),
        .S00_AXI_rready(S00_AXI4L_rready),
        .S00_AXI_rresp(S00_AXI4L_rresp),
        .S00_AXI_rvalid(S00_AXI4L_rvalid),
        .S00_AXI_wdata(S00_AXI4L_wdata),
        .S00_AXI_wready(S00_AXI4L_wready),
        .S00_AXI_wstrb(S00_AXI4L_wstrb),
        .S00_AXI_wvalid(S00_AXI4L_wvalid),
        .aclk(aclk),
        .aresetn(aresetn));
endmodule
