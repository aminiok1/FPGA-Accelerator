############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
############################################################

# create a new project
open_project termination_detector

# specify the top function
set_top termination_detector

# set source files
add_files termination_detector.cpp
add_files termination_detector.h

# create a new solutoin
open_solution "solution1"

# set board (zynq 7000series)
set_part {xc7z020clg484-1}

# set clock
create_clock -period 10 -name default

# set directive file (optimization pragmas)
config_export -format ip_catalog -rtl verilog

# run c simulation
source "directives.tcl"

# start synthesis 
csynth_design

# export the design
export_design -rtl verilog -format ip_catalog
