import re
import os
import sys

emu_dir    = os.environ.get("emu")
work_dir   = os.environ.get("WORK_DIR")
work_id    = os.environ.get("WID")
par_id     = os.environ.get("PID")
top_module = os.environ.get("TOP_MODULE")

src_dir    = emu_dir+"/src/trig/src"
impl_dir   = work_dir+"/impl_"+par_id
trig_tcl   = impl_dir+"/ila_gen.tcl"

if "dac" in top_module:
    trig_src = src_dir+"/probe_xdac.v"
    trig_top = "u_probe_xdac"
elif "adc" in top_module:
    trig_src = src_dir+"/probe_xadc.v"
    trig_top = "u_probe_xadc"
else:
    trig_src = src_dir+"/trig.v"
    trig_top = "u_trig"

file_hand= open(trig_src, "r")
tcl_hand = open(trig_tcl, "w")

core_patt  = r"^\(\*\s*KEEP=\"TRUE\"\s*\*\)\s*wire\s*TRIG(\d+)_CLK\s *; "
probe_patt = r"A\(\*\s*KEEP=\"TRUE\"\s*\*\)\s*wire\s*\[ .* \]\s*TRIG\d+_PROBE(\d+)\s *; "

dbg_core  = ""
dbg_probe = ""

for line in file_hand:
    core_match = re.match(core_patt, line)
    probe_match = re.match(probe_patt, line)
if core_match:
    dbg_core = str(core_match.group(1))
    tcl_hand.write("#-------------------------------------------------------------------------------#\n")
    tcl_hand.write("#-----------------------------CREATE ILA CORE-----------------------------------#\n")
    tcl_hand.write("#-------------------------------------------------------------------------------#\n")
    tcl_hand.write("create_debug_core myCore"+dbg_core+" ila \n")
    # tcl_hand.write("set_property C_DATA_DEPTH 2048 [get_debug_cores myCore"+dbg_core+"] \n")
    tcl_hand.write("set_property C_DATA_DEPTH 4096 [get_debug_cores myCore"+dbg_core+"] \n")
    tcl_hand.write("set_property port_width 1 [get_debug_ports myCore"+dbg_core+"/clk] \n")
    tcl_hand.write("connect_debug_port myCore"+dbg_core+"/clk [get_nets -hier -filter {PARENT_CELL == "+trig_top+"&&NAME =~* TRIG"+dbg_core+"_CLK*}] \n")
    tcl_hand.write("\n")
elif probe_match:
    dbg_probe = str(probe_match.group(1))
    tcl_hand.write("#-------------------------------------------------------------------------------#\n")
    tcl_hand.write("#--------------------------CONNECT DEBUG PROBE----------------------------------#\n")
    tcl_hand.write("#-------------------------------------------------------------------------------#\n")
    if not dbg_probe == "0":
        tcl_hand.write("create_debug_port myCore"+dbg_core+" probe"+dbg_probe+" \n")
    # set_property port_width [llength $trig0_probe0] [get_debug_ports myCoer/probe0]
    tcl_hand.write("set_property port_width 256 [get_debug_ports myCore"+dbg_core+"/probe"+dbg_probe+"] \n")
    # set_property MARK_DEBUG true [get_nets -hier -filter {PARENT_CELL == u_probe_xdac&&NAME =~* TRIGO_PROBE0*}]
    tcl_hand.write("set_property MARK_DEBUG true [get_nets -hier -filter {PARENT_CELL == "+trig_top+"&&NAME =~* TRIG"+dbg_core+"_PROBE"+dbg_probe+"*}] \n")
    # connect_debug_port myCoer/probe0 [lsort -dictionary [get_nets -hier -filter {PARENT_CELL == u_probe_xdac&&NAME =~* TRIGO_PROBE0*}]]
    tcl_hand.write("connect_debug_port myCore"+dbg_core+"/probe"+dbg_probe+" [lsort -dictionary [get_nets -hier -filter {PARENT_CELL == "+trig_top+"&&NAME =~* TRIG"+dbg_core+"_PROBE"+dbg_probe+"*}]] \n")
    tcl_hand.write("\n")
tcl_hand. close()
