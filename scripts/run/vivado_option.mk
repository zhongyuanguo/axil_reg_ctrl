# VIVADO OPTION

# SYNTHESIS PHASE

# TARGET_FPGA		?= xc7k70tfbg676-2
ifneq (, $(findstring rfsoc, ${WID}))
TARGET_FPGA			?= xczu49dr-ffvf1760-2-e
else
ifneq (, $(findstring lpbk, ${WID}))
TARGET_FPGA			?= xcvu13p-figd2104-2-e
else
TARGET_FPGA			?= xczu49dr-ffvf1760-2-e
endif
endif

# on|off, GCC
GCC_ENABLE			?= on
# full|none|rebuilt
# FLAT_HIER			?= none
FLAT_HIER			?= rebuilt
# default | RuntimeOptimized|AreaOptimized_high|AreaOptimized_medium|AlternateRoutability|AreaMapLargeShiftRegToBRAM ...
SYN_OPTION			?= AlternateRoutability
BUFG_NUM			?= 24

# IMPLEMENT PHASE
PID					?= opt0

# PAR STRATEGY
# RUNTIME
ifneq (, $(findstring opt0, ${PID}))
OPT_DIRECT			:= RuntimeOptimized
PLACE_DIRECT 		:= RuntimeOptimized
PHOPT_DIRECT 		:= RuntimeOptimized
ROUTE_DIRECT 		:= RuntimeOptimized
endif

# EXPLORE
ifneq (, $(findstring opt1, ${PID}))
OPT_DIRECT			:= Explore
PLACE_DIRECT 		:= Explore
PHOPT_DIRECT 		:= Explore
ROUTE_DIRECT 		:= Explore
endif

export TARGET_FPGA
export GCC_ENABLE
export FLAT_HIER
export SYN_OPTION
export BUFG_NUM
export OPT_DIRECT
export PLACE_DIRECT
export PHOPT_DIRECT
export ROUTE_DIRECT
