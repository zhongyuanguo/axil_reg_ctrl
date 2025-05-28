# set_property SEVERITY {Warning} [get_drc_checks RTSTAT-4]

source $env(WORK_DIR)/function.tcl

set_part $env(TARGET_FPGA)

set outputDir $env(WORK_DIR)/impl_$env(PID)
# file mkdir $outputDir

#read_checkpoint $env(emu)/src/trig/src/vio_0.dcp
read_checkpoint $env(emu)/src/trig/src/jtag_axi4lite.dcp
read_checkpoint $env(WORK_DIR)/synth/post_synth_$env(TOP_MODULE) .dcp
#source $env(WORK_DIR)/dcp_loading.tcl

#source $env(WORK_DIR)/constraints/fpga_top_par_const.tcl

if {[string match "fpga_top" $env(TOP_MODULE) ]} {
    foreach f $env(PAR_XDC) {
        read_xdc $f
    }
} else {
    read_xdc $env(PAR_XDC)
}

puts "Link Up Begin ..."
link_design -top $env(TOP_MODULE) -part $env(TARGET_FPGA)
write_checkpoint -force $outputDir/post_link_$env(TOP_MODULE).dcp
report_timing_summary -file $outputDir/post_link_$env(TOP_MODULE)_timing_summary.rpt

reportDate
puts "Link Up Succesful ..."
# INSERT DEBUG CORE
# BEGIN
if { ![string match "*notrig*" $env(WID)] } {
    puts "Insert Debug Cores Begin ..."
    source $outputDir/ila_gen.tcl
    implement_debug_core
    write_debug_probes -force ./$env(TOP_MODULE) .1tx
    puts "Insert Debug Cores Succesful ..."
} else {
    puts "No Debug Core Insert ..."
}
# END
puts "Optimization Begin ..."
opt_design -directive $env(OPT_DIRECT)
puts "Optimization Succesful ..."

puts "Placement Begin ..."
place_design -directive $env(PLACE_DIRECT)

phys_opt_design -directive $env(PHOPT_DIRECT)
write_checkpoint -force $outputDir/post_place_$env(TOP_MODULE).dcp
# report_timing_summary -file $outputDir/post_place_timing_summary.rpt
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 100 -nworst 100 -input_pins -routable_nets -file $outputDir/post_place_$env(TOP_MODULE)_timing_summary.rpt
reportDate
puts "Placement Succesful ..."

puts "Routing Begin ..."
route_design -directive $env(ROUTE_DIRECT)
phys_opt_design -hold_fix
write_checkpoint -force $outputDir/post_route_$env(TOP_MODULE) . dcp
# report_timing_summary -file $outputDir/post_route_$env(TOP_MODULE)_timing_summary.rpt
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 100 -nworst 100 -input_pins -routable_nets -file $outputDir/post_route_$env(TOP_MODULE)_timing_summary.rpt
reportDate

puts "Routing Succesful ..."

write_bitstream -force $outputDir/$env(TOP_MODULE).bit
# file copy vivado. log $outputDir/$env(PROJ)_impl_vivado.log

write_hw_platform -fixed -include_bit -force -file $outputDir/$env(TOP_MODULE).xsa
