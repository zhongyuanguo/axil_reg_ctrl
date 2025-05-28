
source $env(WORK_DIR)/function.tcl

set_part $env(TARGET_FPGA)
#
# STEP#1: define the output directory area.
#

set outputDir $env(WORK_DIR)/synth_sp
# file mkdir $outputDir

#
# STEP#2: setup design sources and constraints
#

# Block Design LIST
foreach f $env(BD_TCL_LIST) {
    source $env(emu)/src/bd_tcl/$f.tcl
    generate_target all [get_files [findFile $outputDir "$f.bd"]]
    # test add
    set top_name [make_wrapper -files [get_files [findFile $outputDir "$f.bd"]] -top]
    #make_wrapper -files [get_files [findFile $outputDir "$f.bd"]] -top
    read_verilog $top_name
    synth_design -top $f\_wrapper -part $env(TARGET_FPGA) -mode out_of_context
    write_verilog -mode synth_stub -cell [get_cells $f\*] ./$f\_stub.v
    #write_checkpoint -cell [get_cells $f\*] ./$f.dcp
    write_edif -cell [get_cells $f\*] ./$f.edf
}

# XILINX IP LIST
foreach f $env(IP_TCL_LIST) {
    source $env(emu)/src/ip_tcl/$f.tcl
    synth_ip [get_files [findFile $outputDir "$f.xci"]]
    convert_ips [get_files [findFile $outputDir "$f.xci"]]
}
