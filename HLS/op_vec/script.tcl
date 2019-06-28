############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
############################################################

# create a new project
open_project op_vec

# specify the top function
set_top op_vec_kernel

# set source files
add_files op_vec.h
add_files op_vec.cpp

# add testbench
add_files -tb op_vec_test.cpp -cflags "-Wno-unknown-pragmas"

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

# run c simulation
csim_design

# start synthesis 
csynth_design

# run c/rtl co-simulation
cosim_design -trace_level all -tool xsim

# export the design
export_design -rtl verilog -format ip_catalog
