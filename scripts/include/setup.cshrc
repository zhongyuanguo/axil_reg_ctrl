# THIS IS INITIAL SCRIPT FOR EMU-FPGA ENVIRONMENT

echo "Begin Initialization ..."

# SETTING VARIABLES

# PROJECT NAME
setenv PROJ "DEMO16x16"
echo "The Project is ${PROJ}."

# DIRECTORY INITIAL
setenv CURR `pwd`
setenv WORK `echo "${CURR}" | awk -F "/${USER}/" '{split($2, a, "/"); print a[1]}'`
setenv BASE `echo "${CURR}" | awk -F "/${USER}/" '{print $1}'`
setenv DESI "${BASE}/${USER}/${WORK}/${PROJ}"
echo "The Project Space : ${DESI}"

if ("${WORK}" == "${PROJ}") then
echo "End Initialization Failed."
echo "Please Create A Workspace. DO NOT Use The Main Directory."

else

# SETTING VARIABLES (THEM ARE ABOUT TO CHANGE)
#TODO#setenv ip_dir "${DESI}/dev/rtl/ip"
#TODO#setenv sys_dir "${DESI}/dev/rtl/system"
#TODO#setenv inc_dir "${DESI}/dev/rtl/include"
#TODO#echo "IP Directory        : ${ip_dir}"
#TODO#echo "System Directory    : ${sys_dir}"
#TODO#echo "Include Directory   : ${inc_dir}"

# EMU-FPGA DIRECTORY
setenv emu "${DESI}/emu"
echo "EMU-FPGA Directory : ${emu}"
# setenv unmanaged "${emu}/scratch"
# MOVE UNMANAGED DIR OUT FROM DATABASE
setenv unmanaged "${BASE}/${USER}/${WORK}/scratch"
if !(-d ${unmanaged}) then
mkdir ${unmanaged}
endif
echo "Build Scratch Space: ${unmanaged}"

# VIVADO VERSION CONTROL
setenv XILINX_VIVADO_VERSION "2024.1"
setenv XILINX_VIVADO_HOME "/apps/xilinx/vivado-${XILINX_VIVADO_VERSION}/Vivado/${XILINX_VIVADO_VERSION}"
viv24p1

# CHIP DESIGN DIRECTORY
setenv dev "${DESI}/dev"

echo "End Initialization Successful."

endif
