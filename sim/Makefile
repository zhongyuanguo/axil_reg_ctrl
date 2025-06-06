

XILINX_HOME ?= D:/Xilinx/Vivado/2024.2
TRUE_DIR  	?= D:/FPGAProjRepo/axil_reg_ctrl

WID			?= default
CWD			?= $(shell pwd)
#SRC			?= $(shell realpath ${CWD}/../src)
SRC			?= ${TRUE_DIR}/src
WORK_DIR	:= ${CWD}/${WID}

TOP_MODULE	?= axil_reg_ctrl
TB_NAME		?= ${TOP_MODULE}_tb
SIM_SNAPSHOT?= ${TOP_MODULE}_sim_snapshot

.PHONY: test init compile

#FILELIST	?= $(shell find ${SRC} -maxdepth 1 -type f -name '*.v')
FILELIST	?= ${SRC}/axil_reg_ctrl.v
FILELIST	+= ${SRC}/../sim/axi_bram_ctrl_1kx32_sim_netlist.v
FILELIST	+= ${SRC}/../sim/axil_ram.v
FILELIST	+= ${SRC}/../sim/axil_reg_ctrl_tb.v
FILELIST	+= ${SRC}/../sim/network_smartconnect_0_0_sim_netlist.v
FILELIST	+= ${SRC}/../sim/network.v
FILELIST	+= ${XILINX_HOME}/data/verilog/src/glbl.v

XVLOG_OPTS  ?= --incr --relax -sv

XVLOG_LIBS  ?= -L worklib
XVLOG_LIBS  += -L unisim
XVLOG_LIBS  += -L secureip

XELAB_OPTS	?= --incr --debug typical --relax --mt 8
XELAB_LIBS  ?= ${XVLOG_LIBS}
XELAB_TOP   ?= worklib.${TB_NAME}
XELAB_TOP   += worklib.glbl


test:
	@echo "Running tests..."
	@echo "FILELIST: ${FILELIST}"
	@echo "WID: ${WID}"
	@echo "TOP_MODULE: ${TOP_MODULE}"
	@echo "XVLOG_OPTS: ${XVLOG_OPTS}"
	@echo "XVLOG_LIBS: ${XVLOG_LIBS}"

init: ${CWD}/${WID}/__init_done__

${CWD}/${WID}/__init_done__:
	@echo "WID: ${WID}"
	@echo "Initializing..."
	@echo "WID: ${WID}"
	@mkdir -p ${WID}
	@touch ./clean_${WID}.sh
	@echo "rm -rf ./${WID}" >> ./clean_${WID}.sh
	@echo "rm -f ./clean_${WID}.sh" >> ./clean_${WID}.sh
	@chmod +x ./clean_${WID}.sh
	@echo "Done."
	@touch ${CWD}/${WID}/__init_done__

compile: init
	@echo "Compiling..."
	cd ${WORK_DIR}; xvlog ${XVLOG_OPTS} ${XVLOG_LIBS} -work worklib ${FILELIST} | tee compile.log

elab: compile
	@echo "Elaborating..."
	cd ${WORK_DIR}; xelab ${XELAB_OPTS} ${XELAB_LIBS} -snapshot ${SIM_SNAPSHOT} ${XELAB_TOP} -log elab.log

sim: elab
	@echo "Simulating..."
	cd ${WORK_DIR}; xsim ${SIM_SNAPSHOT} -gui -log sim.log -vcdfile dump.vcd