
# Define for EMU-FPGA
HDL_DEFINE 			:= FPGA

ifneq (, $(findstring notrig, ${WID}))
HDL_DEFINE 			+= NO_TRIG
endif

ifneq (, $(findstring lpbk, ${WID}))
HDL_DEFINE 			+= LOOPBACK
ifneq (, $(findstring rfsoc, ${WID}))
HDL_DEFINE 			+= RFSOC
endif
else
HDL_DEFINE 			+= RFSOC
endif

ifneq (, $(findstring lane8, ${WID}))
HDL_DEFINE 			+= LANE8
endif

ifneq (, $(findstring gen3, ${WID}))
HDL_DEFINE 			+= GEN3
endif

ifneq (, $(findstring gen4, ${WID}))
HDL_DEFINE 			+= GEN4
endif

ifneq (, $(findstring wdacen, ${WID}))
HDL_DEFINE 			+= WDAC_EN
endif

ifneq (, $(findstring sim, ${WID}))
HDL_DEFINE 			+= FPGA_SIM
endif

ifneq (, $(findstring vip, ${WID}))
HDL_DEFINE 			+= VIP_EN
endif

ifneq (, $(findstring xd16b, ${WID}))
HDL_DEFINE 			+= XD16B
endif

# BLOCK DESIGN 
BD_TCL_LIST			:= network
BD_TCL_LIST			+= processor

# XILINX IP
IP_TCL_LIST			:= xdma_pcie_subsys

ifneq (, $(findstring wdacen, ${WID}))
IP_TCL_LIST			+= axi_gpio_o
else
IP_TCL_LIST			+= axi_bram_4k
endif

ifneq (, $(findstring lpbk, ${WID}))
# FOR LOOPBACK
IP_TCL_LIST			+= axis_data_fifo_1k
else           
# FOR DATA CONVERTER
IP_TCL_LIST    		+= usp_rf_data_converter   
#IP_TCL_LIST   		+= axis_data_fifo_2p_2kx256
#IP_TCL_LIST   		+= axis_data_fifo_2p_16x256
#IP_TCL_LIST   		+= axis_data_fifo_2p_64x32
#IP_TCL_LIST   		+= fifo_2p_16x256
IP_TCL_LIST    		+= fifo_2p_2kx256
endif          
IP_TCL_LIST    		+= axil_gpio_in
IP_TCL_LIST    		+= axis_fifo_2p_16x256
IP_TCL_LIST			+= axi_bram_ctrl_16kx32

export HDL_DEFINE
export BD_TCL_LIST
export IP_TCL_LIST