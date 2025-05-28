include ${emu}/run/hdl_define.mk
include ${emu}/run/hdl_include.mk
include ${emu}/run/vivado_option.mk

# WORK ID
WID				?= default
WORK_DIR        ?= ${unmanaged}/${WID}
CURR_TIME       := $(shell date +%Y/%m/%d_%H : %M)
WDIR_CHK        := $(shell [ -d ${WORK_DIR} ] && echo true | | echo false)
SDIR_CHK        := $(shell [ -d ${WORK_DIR}/synth ] && echo true | | echo false)
PDIR_CHK        := $(shell [ -d ${WORK_DIR}/impl_${PID} ] && echo true | | echo false)

# SETTING FOR EMU-FPGA

TOP_MODULE		:= fpga_top
FILE_LIST		:= ${WORK_DIR}/analyze.tcl

#SYN_XDC		:= ${WORK_DIR}/constraints/fpga_top_timing.xdc
SYN_XDC			:= ${WORK_DIR}/constraints/fpga_top_synth.xdc

# =============================================================================
# RFSOC = 216, LOOPBACK OR DATA CONVERTOR
# =============================================================================
ifneq (, $(findstring rfsoc, ${WID}))
PAR_XDC			:= ${WORK_DIR}/constraints/fpga_top_timing.rfsoc.xdc
else
PAR_XDC			:= ${WORK_DIR}/constraints/fpga_top_timing.xdc
endif

ifneq (, $(findstring lpbk, ${WID}))
ifneq (, $(findstring rfsoc, ${WID}))
# FOR 216 BOARD, LOOPBACK
PAR_XDC			+= ${WORK_DIR}/constraints/fpga_top_pin.rfsoc.xdc
ifneq (, $(findstring wdacen, ${WID}))
PAR_XDC			+= ${WORK_DIR}/constraints/fpga_top_pin.rfsoc.wdac.xdc
endif
# end of wdacen
else
# FOR VU13P, LOOPBACK
PAR_XDC			+= ${WORK_DIR}/constraints/fpga_top_pin.xdc
endif
# end of rfsoc
# FOR 216 BOARD, DATA CONVERTOR
PAR_XDC			+= ${WORK_DIR}/constraints/fpga_top_pin.rfsoc.xdc
PAR_XDC			+= ${WORK_DIR}/constraints/fpga_top_pin.rfsoc.wdac.xdc
PAR_XDC			+= ${WORK_DIR}/constraints/fpga_top_pin.rfsoc.xdac.xdc
endif
# end of lpbk

# FILE_STORE	:= ${emu}/repository
FILE_STORE		:= ${WORK_DIR}

help:

init: clean
ifeq (${WDIR_CHK}, false)
	@cd ${unmanaged}; mkdir ${WID}
	@ln -sf ${unmanaged}/${WID} ${emu}/build/.
endif
	@cp -f ${emu}/run/ *. tcl ${WORK_DIR}/.
	@cp -f ${emu}/src/ *. tcl ${WORK_DIR}/.
	@cp -rf ${emu}/constraints ${WORK_DIR}/.
ifeq (${WDIR_CHK}, true)
	@rm -f ${WORK_DIR}/${WID}_variables. log
endif
	@touch ${WORK_DIR}/${WID}_variables. log

analyze: log ${WORK_DIR}/analyze.f
${WORK_DIR}/analyze.f:
	@python ${emu}/scripts/gen_filelist.py -s ${FILTER_SPEC}

synth: analyze ${WORK_DIR}/synth/post_synth_${TOP_MODULE}.dcp
${WORK_DIR}/synth/post_synth_${TOP_MODULE}.dcp: ${WORK_DIR}/synth/post_synth_${TOP_MODULE}.dcp
ifeq (${SDIR_CHK}, false)
	@cd ${WORK_DIR}; mkdir synth
	@ln -sf ${WORK_DIR}/run_synth_vivado.tcl ${WORK_DIR}/synth/
	@rm -f ${emu}/build/${WID}_synth
	@ln -sf ${WORK_DIR}/synth ${emu}/build/${WID}_synth
endif
	@cd ${WORK_DIR}/synth; vivado -mode batch -source ${WORK_DIR}/synth/run_synth_vivado.tcl

synth_sp: analyze ${WORK_DIR}/synth_sp/post_synth_${TOP_MODULE}.edif
${WORK_DIR}/synth_sp/post_synth_${TOP_MODULE}.edif: ${WORK_DIR}/synth_sp/post_synth_${TOP_MODULE}.edif
ifeq (${SDIR_CHK}, false)
	@cd ${WORK_DIR}; rm -rf synth_sp; mkdir synth_sp
	@ln -sf ${WORK_DIR}/init_synth_synplify.tcl ${WORK_DIR}/synth_sp/
	@ln -sf ${WORK_DIR}/run_synth_synplify.tcl ${WORK_DIR}/synth_sp/
	@ln -sf ${WORK_DIR}/setup_synplify.tcl ${WORK_DIR}/synth_sp/
	@rm -f ${emu}/build/${WID}_synth
	@ln -sf ${WORK_DIR}/synth_sp ${emu}/build/${WID}_synth
endif
	@cd ${WORK_DIR}/synth_sp; vivado -mode batch -source ${WORK_DIR}/synth_sp/init_synth_synplify.tcl
	@cd ${WORK_DIR}/synth_sp; synplify_premier_dp -batch -tcl ${WORK_DIR}/synth_sp/run_synth_synplify. tcl

par: ${WORK_DIR}/synth/post_synth_${TOP_MODULE}.dcp ${WORK_DIR}/impl_${PID}/post_route_${TOP_MODULE}.dcp
${WORK_DIR}/impl_${PID}/post_route_${TOP_MODULE}.dcp: ${WORK_DIR}/impl_${PID}/post_route_${TOP_MODULE}.dcp
ifeq (${PDIR_CHK}, false)
	@cd ${WORK_DIR}; mkdir impl_${PID}
	@ln -sf ${WORK_DIR}/run_par_vivado.tcl ${WORK_DIR}/impl_${PID}/
	@rm -f ${emu}/build/${WID}_impl_${PID}
	@ln -sf ${WORK_DIR}/impl_${PID} ${emu}/build/${WID}_impl_${PID}
endif
ifeq (, $(findstring notrig, ${WID}))
	@cd ${WORK_DIR}; python ${emu}/scripts/ila_gen.py
	@cd ${WORK_DIR}; python ${emu}/scripts/ltx_rename. py
endif
	@cd ${WORK_DIR}/impl_${PID}; vivado -mode batch -source ${WORK_DIR}/impl_${PID}/run_par_vivado.tcl
	@cd ${emu}/build; tar -czvf ${FILE_STORE}/${WID}_impl_${PID}.tar.gz -x ${emu}/run/exclude_file.f -- dereference ${WID}_impl_${PID}/*
	@ln -sf ${FILE_STORE}/${WID}_impl_${PID}.tar.gz ${emu}/repository

clean:
	@rm -f ${emu}/build/clean_${WID}. cshrc
	@echo "cd ${unmanaged}; rm -rf ${WID}" >> ${emu}/build/clean_${WID}.cshrc
	@echo "cd ${emu}/repository; rm -f ./${WID}_impl_*.tar.gz" >> ${emu}/build/clean_${WID}.cshrc
	@echo "cd ${emu}/build; rm -rf ./${WID}" >> ${emu}/build/clean_${WID}.cshrc
	@echo "cd ${emu}/build; rm -rf ./${WID}_synth" >> ${emu}/build/clean_${WID}.cshrc
	@echo "cd ${emu}/build; rm -rf ./${WID}_impl_*" >> ${emu}/build/clean_${WID}.cshrc
	@echo "cd ${emu}/build; rm -rf ./clean_${WID}.cshrc" >>${emu}/build/clean_${WID}.cshrc
	@chmod +x ${emu}/build/clean_${WID}.cshrc

test:
	@echo "WID: " ${WID}
	@echo ${FILE_LIST}
	@echo ${TOP_MODULE}
	@echo ${HDL_DEFINE}
	@echo ${SYN_OPTION}
	@echo ${COMPILE_SPEC}

log: init
	@echo "This build is created at ${CURR_TIME}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "WID: ${WID}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "WORK_DIR: ${WORK_DIR}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "FILE_LIST: ${FILE_LIST}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "SYN_XDC: ${SYN_XDC}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "PAR_XDC: ${PAR_XDC}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "TOP_MODULE: ${TOP_MODULE}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "HDL_DEFINE: ${HDL_DEFINE}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "HDL_INCLUDE: ${HDL_INCLUDE}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "TARGET_FPGA: ${TARGET_FPGA}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "GCC_ENABLE: ${GCC_ENABLE}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "FLAT_HIER: ${FLAT_HIER}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "SYN_OPTION: ${SYN_OPTION}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "BUFG_NUM: ${BUFG_NUM}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "BD_TCL_LIST: ${BD_TCL_LIST}" >> ${WORK_DIR}/${WID}_variables.log
	@echo "IP_TCL_LIST: ${IP_TCL_LIST}" >> ${WORK_DIR}/${WID}_variables.log

targz:
	@cd ${emu}/build; tar -czvf ${FILE_STORE}/${WID}_impl_${PID}.tar.gz -x ${emu}/run/exclude_file.f --dereference ${WID}_impl_${PID}/*
	@ln -sf ${FILE_STORE}/${WID}_impl_${PID}.tar.gz ${emu}/repository

export WID
export PID
export WORK_DIR
export FILE_LIST
export SYN_XDC
export PAR_XDC
export TOP_MODULE
