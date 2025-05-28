# Device Options
if {[string match "*rfsoc*" $env(WID) ]} {
set_option -technology ZYNQ-ULTRASCALEPLUS-RFSOC-FPGAS
set_option -part XCZU49DR
set_option -package FFVF1760
set_option -speed_grade -2-e
set_option -part_companion ""
} elseif {[string match "*lpbk*" $env(WID) ]} {
set_option -technology VIRTEX-ULTRASCALEPLUS-FPGAS
set_option -part XCVU13P
set_option -package FIGD2104
set_option -speed_grade -2-e
set_option -part_companion ""
} else {
set_option -technology ZYNQ-ULTRASCALEPLUS-RFSOC-FPGAS
set_option -part XCZU49DR
set_option
-package FFVF1760
set_option -speed_grade -2-e
set_option -part_companion ""
}

#implementation attributes
set_option -vlog_std sysv
set_option -project_relative_includes 1
set_option -use_fsm_explorer 0
# set_option -distributed_compile 1
set_option -hdl_strict_syntax 0
set_option -frequency auto
set_option -srs_instrumentation 1
set_option -write_verilog 1
set_option -write_structural_verilog 0
set_option -write_vhdl 0
set_option -resolve_multiple_driver 1
set_option -rw_check_on_ram 1
# set_option -optimize_ngc 1
set_option -run_prop_extract 1
set_option -maxfan 10000
set_option -disable_io_insertion 0
set_option -pipe 1
set_option -update_models_cp 0
set_option -retiming 1
set_option -no_sequential_opt 0
set_option -no_sequential_opt_bram_mapping both
set_option -fix_gated_and_generated_clocks 1
# set_option -add_dut_hierarchy 0
# set_option -prepare_readback 0
set_option -enable_prepacking 1
set_option -use_vivado 1
set_option -support_xpm 1
set_option -symbolic_fsm_compiler 1
set_option -compiler_compatible 0
set_option -resource_sharing 1
set_option -multi_file_compilation_unit 1
# set_option -auto_infer_blackbox 0
set_option -write_apr_constraint 1