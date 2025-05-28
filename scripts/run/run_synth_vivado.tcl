# Created by Zhongyuan Guo

source $env(WORK_DIR)/function.tcl

set_part $env(TARGET_FPGA)
#
# STEP#1: define the output directory area.
#

set outputDir $env(WORK_DIR)/synth
# file mkdir $outputDir

#
# STEP#2: setup design sources and constraints

# Block Design LIST
foreach f $env(BD_TCL_LIST) {
    source $env(emu)/src/bd_tcl/$f.tcl
    generate_target {synthesis} [get_files [findFile $outputDir "$f.bd"]]
}

# XILINX IP LIST
foreach f $env(IP_TCL_LIST) {
    source $env(emu)/src/ip_tcl/$f.tcl
    synth_ip [get_files [findFile $outputDir "$f.xci"]]
}

source $env(FILE_LIST)

# XDC
if {[string match "fpga_top" $env(TOP_MODULE)]} {
    foreach f $env(SYN_XDC) {
    read_xdc $f
    }
} else {
    read_xdc $env(SYN_XDC)
}

# TIMING CONSTRAINTS
# read_xdc -unmanaged $env(WORK_DIR)/constraints/fpga_top_synth.xdc

# 
# STEP#3: run synthesis, write design checkpoint, report timing, and utilization estimates
#
reportDate

synth_design -top $env(TOP_MODULE) -part $env(TARGET_FPGA) \
-include_dirs $env(HDL_INCLUDE) -define $env(HDL_DEFINE) \
-flatten_hierarchy $env(FLAT_HIER) -gated_clock_conversion $env(GCC_ENABLE) \
-directive $env(SYN_OPTION) -bufg $env(BUFG_NUM) \
-keep_equivalent_registers -global_retiming on

reportDate

write_checkpoint -force $outputDir/post_synth_$env(TOP_MODULE).dcp
report_timing_summary -file $outputDir/post_synth_$env(TOP_MODULE)_timing_summary.rpt
report_utilization -file $outputDir/post_synth_$env(TOP_MODULE)_util.rpt

# Run custom script to report critical timing paths
# TODEBUG: reportCriticalPaths $outputDir/post_synth_critpath_report.csv
# file copy -force vivado.log $outputDir/$env(PROJ)_synth_vivado.log
