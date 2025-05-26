

XILINX_HOME ?= D:/Xilinx/Vivado/2024.2
TRUE_DIR  	?= D:/FPGAProjRepo/axil_reg_ctrl

WID			?= default
CWD			?= $(shell pwd)
#SRC			?= $(shell realpath ${CWD}/../src)
SRC			?= ${TRUE_DIR}/src
WORK_DIR	:= ${CWD}/${WID}

TOP_MODULE	?= axil_reg_ctrl_tb

.PHONY: test init compile

#FILELIST	?= $(shell find ${SRC} -maxdepth 1 -type f -name '*.v')
FILELIST	?= ${SRC}/axil_reg_ctrl.v
FILELIST	+= ${SRC}/../sim/axi_bram_ctrl_1kx32_sim_netlist.v
FILELIST	+= ${SRC}/../sim/axil_ram.v
FILELIST	+= ${SRC}/../sim/axil_reg_ctrl_tb.v
FILELIST	+= ${XILINX_HOME}/data/verilog/src/glbl.v

XVLOG_OPTS  ?= --incr --relax -sv

XVLOG_LIBS  ?= -L worklib

XELAB_LIBS  ?= ${XVLOG_LIBS}
XELAB_TOP   ?= worklib.${TOP_MODULE}
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


