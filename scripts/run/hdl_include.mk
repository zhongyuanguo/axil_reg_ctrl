

COMPILE_SPEC				:= ${emu}/src/emu_top/src

# TOP MODULE
COMPILE_SPEC				+= ${emu}/src/fpga_top/src

# BASIC FILTER
FILTER_SPEC					:= ${emu}/run/filter.txt

HDL_INCLUDE					:= ${inc_dir}
HDL_INCLUDE					+= ${emu}/src/fpga_top/src
HDL_INCLUDE					+= ${emu}/src/emu_top/src

export COMPILE_SPEC
export FILTER_SPEC
export HDL_INCLUDE