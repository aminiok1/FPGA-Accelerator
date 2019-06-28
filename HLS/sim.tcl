# Run the following commands in Vivado (GUI mode only)
# set argv [list "PATH_TO_SIM_DIR" SOL_NAME]
# set argc [llength $argv]
# set argv0 PATH_TO_TCL/sim.tcl
# source $argv0

# example for "PATH_TO_SIM_DIR" --> D:/FPGA-Accelerator/HLS/MAC_HLS/solution5/sim/verilog
# example for SOL_NAME 			--> mac_kernel

cd [lindex $argv 0]
current_fileset
open_wave_database [lindex $argv 1].wdb
open_wave_config [lindex $argv 1].wcfg