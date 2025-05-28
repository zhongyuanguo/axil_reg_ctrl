import re
import os
import sys
import math

emu_dir     = os.environ.get("emu")
work_dir    = os.environ.get("WORK_DIR")
work_id     = os.environ.get("WID")
par_id      = os.environ.get("PID")
top_module  = os.environ.get("TOP_MODULE")

src_dir     = emu_dir+"/src/trig/src"
impl_dir    = work_dir+"/impl_"+par_id
trig_tcl    = impl_dir+"/ltx_rename.tcl"

if "dac" in top_module:
    trig_src = src_dir+"/probe_xdac.v"
    trig_top = "u_probe_xdac"
elif "adc" in top_module:
    trig_src = src_dir+"/probe_xadc.v"
    trig_top = "u_probe_xadc"
else:
    trig_src = src_dir+"/trig.v"
    trig_top = "u_trig"

file_hand   = open(trig_src, "r")
tcl_hand    = open(trig_tcl, "w")

sign_begin = r"^assign TRIG(\d+)_PROBE(\d+)\s*= \s*{"
sign_end = r"^}\s*; "
commit_patt = r"^//.* "
bus_patt = r"^[,|\s|*([\w|.|\[|\]+)\[(\d+):(\d+)\]$"
sign_patt = r"^[,|\s|]*([\w|.|\[|\]]+)$"
sbus_patt = r"^[,\|s|]*([\w|.|\[|\]]+)\[(\d+)\]$"

c_state = 0
probe_list = []

dbg_core = 0
dbg_probe = 0
sign_name = ""
bus_max = 0
bus_min = 0

def appendBus(signName, busMax, busMin) :
    for i in range(busMax, busMin-1, -1):
        add_name = signName+"["+str(i)+"]"
        probe_list.append(add_name)
    return

def appendProbeList():
    list_len = len(probe_list)
    append_num = 256 - list_len + 1
    for string in range(append_num) :
        probe_list.insert(0, "None")
    return

def genRepScript():
    probe_list. reverse()
    probe_num = 0
    # for i in range(256):
    for probe_line in probe_list:
        bus_match = re.match(bus_patt, probe_line)
        sign_match = re.match(sign_patt, probe_line)
        sbus_match = re.match(sbus_patt, probe_line)

        # if not string == "None":

            # set_property NAME. CUSTOM <name> [get_hw_probes u_probe_xdac/TRIGO_PROBE0[0] -of [get_hw_ilas myCore0]]
            # set_property NAME. SELECT custom [get_hw_probes u_probe_xdac/TRIGO_PROBE0[0] -of [get_hw_ilas myCore0]]

        if bus_match:
            bus_name = bus_match.group(1)
            bus_name = bus_name. replace("[", "")
            bus_name = bus_name. replace("]", "")

            bus_max = bus_match. group(2)
            bus_min = bus_match.group(3)
            bus_name += "["+bus_max+":"+bus_min+"]"

            probe_max = int(bus_max)-int (bus_min)+probe_num
            # create_hw_probe -map <probe> <name> <core>
            # create_hw_probe -map {probe0[3:0]} user_probe_1[3:0] [get_hw_ila -filter {CELL_NAME =~* myCore0}]
            tcl_hand.write("create_hw_probe -quiet -map {probe"+dbg_probe+"["+str(probe_max)+":"+str(probe_num)+"]} {"+bus_name+"} [get_hw_ilas -filter {CELL_NAME =~* myCore"+dbg_core+"}] \n")
            probe_num = probe_max+1

        elif sbus_match:
            bus_name = sbus_match.group(1)
            bus_name = bus_name.replace("[", "")
            bus_name = bus_name.replace("]", "")

            bus_max = sbus_match.group(2)
            bus_min = sbus_match.group(2)
            bus_name += "["+bus_max+": "+bus_min+"]"
            tcl_hand.write("create_hw_probe -quiet -map {probe"+dbg_probe+"["+str(probe_num)+"]} {"+bus_name+"} [get_hw_ilas -filter {CELL_NAME =~* myCore"+dbg_core+"}] \n")
            probe_num += 1

        elif sign_match:
        # else:
            sign_name = sign_match.group(1)
            sign_name = sign_name. replace("[", "")
            sign_name = sign_name. replace("]", "")
            tcl_hand.write("create_hw_probe -quiet -map {probe"+dbg_probe+"["+str(probe_num)+"]} {"+sign_name+"} [get_hw_ilas -filter {CELL_NAME =~* myCore"+dbg_core+"}] \n")
            probe_num += 1
    return

for line in file_hand:
    begin_match = re.match(sign_begin, line)
    end_match = re.match(sign_end, line)
    commit_match= re.match(commit_patt, line)
    bus_match = re.match(bus_patt, line)
    sign_match = re.match(sign_patt, line)
    sbus_match = re.match(sbus_patt, line)
    if commit_match:
        continue
    elif begin_match and c_state == 0:
        c_state = 1
        dbg_core = begin_match.group(1)
        dbg_probe = begin_match.group(2)
        tcl_hand.write("#-------------------------------------------------------------------------# \n")
        tcl_hand.write("# Begin: myCore"+dbg_core+":probe"+dbg_probe+"----------------------------# \n")
        tcl_hand.write("#-------------------------------------------------------------------------# \n")
    elif end_match and c_state == 1:
        c_state = 0
        # appendProbeList()
        genRepScript()
        probe_list = []
        tcl_hand.write("#-------------------------------------------------------------------------# \n")
        tcl_hand.write("# End: myCore"+dbg_core+":probe"+dbg_probe+"------------------------------# \n")
        tcl_hand.write("#-------------------------------------------------------------------------# \n")
        tcl_hand.write("\n\n")
    elif not begin_match and not end_match and c_state == 1:
        if bus_match:
            sign_name = bus_match.group(1)
            bus_max = bus_match.group(2)
            bus_min = bus_match.group(3)
            #appendBus(sign_name, bus_max, bus_min)
            sign_name += "["+bus_max+":"+bus_min+"]"
            probe_list.append(sign_name)
    elif sign_match:
        sign_name = sign_match.group(1)
        probe_list. append(sign_name)
    elif sbus_match:
        sign_name = sbus_match.group(1)
        bus_max = sbus_match.group(2)
        sign_name += "["+bus_max+":"+bus_max+"]"
        probe_list.append(sign_name)

tcl_hand.close()
