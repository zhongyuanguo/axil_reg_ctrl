
source $env(WORK_DIR)/function.tcl

set outputDir $env(WORK_DIR)/synth_sp

# Project Create
project -new $env(TOP_MODULE).prj
project -log_file "$env(TOP_MODULE)_results.log"
project -save $env(TOP_MODULE).prj

# Loading Synplify options
source $outputDir/setup_synplify.tcl

# Add source files.
# Step 1. Verilog/System Verilog
set vlog_file "$env(WORK_DIR)/analyze_verilog.f"
set vlog_file_id [open $vlog_file r]
while {[gets $vlog_file_id line] != -1} {
    add_file -verilog "$line"
}

# Step 2. VHDL
set vhdl_file "$env(WORK_DIR)/analyze_vhdl.f"
set vhdl_file_id [open $vhdl_file r]
while {[gets $vhdl_file_id line] != -1} {
    add_file -vhdl "$line"
}

# Step 3. BD
foreach f $env(BD_TCL_LIST) {
    #set bd_path [exec dirname [findFile $outputDir "$f.bd"]]
    #process_bd_ip -bdfile "$bd_path/$f.bd" -repopath "$bd_path/ip"
    #set dcp_path [exec dirname [findFile $outputDir "$f\_stub.v"]]
    #add_file -verilog "$dcp_path/hdl/$f\_wrapper.v"
    #add_file -verilog "$dcp_path/$f\_stub.v"
    #add_vivado_ip -dcp "$dcp_path/$f.dcp" -mode absorb -synthesize -vm -ip_location "$dcp_path/ip"
    #add_vivado_ip -dcp "$dcp_path/$f.dcp" -mode absorb -synthesize -vm -ip_location "$dcp_path"
    #add_vivado_ip -dcp "$dcp_path/$f.dcp" -mode white_box
    #add_file -edif "$dcp_path/$f.edf"
    add_file -edif [findFile $outputDir "$f.edf"]
    add_file -verilog [findFile $outputDir "$f\_stub.v"]
}

# Step 4. IP
foreach f $env(IP_TCL_LIST) {
    #set ip_path [exec dirname [findFile $outputDir "$f.xci"]]
    #add_vivado_ip -dcp "$ip_path/$f.dcp" -mode absorb -synthesize -vm -ip_location "$ip_path/ip"
    #add_vivado_ip -dcp "$ip_path/$f.dcp" -mode white_box
    add_vivado_ip -xcix [findFile $outputDir "$f.xcix"] \
    -mode absorb -synthesize -edif -ip_location "$outputDir/synplify/ipcores"
}

# Top-module
set_option -top_module $env(TOP_MODULE)

# Constraints
add_file -fpga_constraints $env(WORK_DIR)/constraints.xdc

# Project Control
hdl_define -set $env(HDL_DEFINE)

project -run
project -close $env(TOP_MODULE).prj