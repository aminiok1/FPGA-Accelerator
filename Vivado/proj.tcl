#*****************************************************************************************
# Created by Amin
#
# proj.tcl: Tcl script for re-creating project 'FPGA_Accelerator'
#
# 
# In order to re-create the project, please source this file in the Vivado Tcl Shell:
#
#	from Vivado Gui Tcl Console: source proj.tcl 
#	from windows command lind: vivado –mode batch –source proj.tcl
#
#*****************************************************************************************

# create a new project 
create_project FPGA_Accelerator . -part xc7z020clg484-1

# set properties
set_property board_part em.avnet.com:zed:part0:1.4 [current_project]
set_property coreContainer.enable 1 [current_project]

# add ip repositories (hls ips and controller)
set_property  ip_repo_paths  {../HLS ../ip_repo} [current_project]
update_ip_catalog
update_ip_catalog -rebuild

# create block design
create_bd_design "design_1"
update_compile_order -fileset sources_1

# add ips to the block design
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:controller:1.0 controller_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:hls:mac_kernel:1.0 mac_kernel_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:hls:op_vec_kernel:1.0 op_vec_kernel_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:hls:soft_threshold_kernel:1.0 soft_threshold_kernel_0
endgroup

# add zynq processor
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

# run block automation for ps
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# enable pl-ps interrupts 
startgroup
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
endgroup

# soft threshold connections
connect_bd_net [get_bd_pins controller_0/st_start] [get_bd_pins soft_threshold_kernel_0/ap_start]

connect_bd_net [get_bd_pins controller_0/st_done] [get_bd_pins soft_threshold_kernel_0/ap_done]

connect_bd_intf_net [get_bd_intf_pins soft_threshold_kernel_0/x] [get_bd_intf_pins op_vec_kernel_0/result_st]

connect_bd_net [get_bd_pins controller_0/rho_inv] [get_bd_pins soft_threshold_kernel_0/rho_inv]

# create BRAMs for z and u
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins soft_threshold_kernel_0/u_bram_PORTA]
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins soft_threshold_kernel_0/result_z_PORTA]
endgroup

# set BRAMs as true dual port
startgroup
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells soft_threshold_kernel_0_bram]
endgroup

startgroup
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells soft_threshold_kernel_0_bram_0]
endgroup

# mac kernel connections
connect_bd_intf_net [get_bd_intf_pins mac_kernel_0/result] [get_bd_intf_pins op_vec_kernel_0/in_1_mac]
connect_bd_intf_net [get_bd_intf_pins op_vec_kernel_0/result_mac] [get_bd_intf_pins mac_kernel_0/z_u]

# create BRAM for p and set it as true dual port
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
endgroup
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells blk_mem_gen_0]

# bram connections for mac
connect_bd_net [get_bd_pins blk_mem_gen_0/addra] [get_bd_pins mac_kernel_0/p_address0]
connect_bd_net [get_bd_pins blk_mem_gen_0/wea] [get_bd_pins mac_kernel_0/p_we0]
connect_bd_net [get_bd_pins blk_mem_gen_0/ena] [get_bd_pins mac_kernel_0/p_ce0]
connect_bd_net [get_bd_pins blk_mem_gen_0/dina] [get_bd_pins mac_kernel_0/p_d0]
connect_bd_net [get_bd_pins mac_kernel_0/p_q0] [get_bd_pins blk_mem_gen_0/douta]

connect_bd_net [get_bd_pins mac_kernel_0/ap_start] [get_bd_pins controller_0/mac_start]
connect_bd_net [get_bd_pins mac_kernel_0/ap_done] [get_bd_pins controller_0/mac_done]

# op_vec connections
# create BRAMs for x and q
 startgroup
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins op_vec_kernel_0/in_2_bram_q_PORTA]
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins op_vec_kernel_0/x_PORTA]
endgroup
startgroup
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells op_vec_kernel_0_bram_0]
endgroup
startgroup
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells op_vec_kernel_0_bram]
endgroup

# rest of the connections for op vec
connect_bd_net [get_bd_pins controller_0/op_vec_start] [get_bd_pins op_vec_kernel_0/ap_start]
connect_bd_net [get_bd_pins op_vec_kernel_0/ap_done] [get_bd_pins controller_0/op_vec_done]
connect_bd_net [get_bd_pins controller_0/in_1_sel] [get_bd_pins op_vec_kernel_0/in1_sel_V]
connect_bd_net [get_bd_pins controller_0/alpha] [get_bd_pins op_vec_kernel_0/alpha]
connect_bd_net [get_bd_pins controller_0/in_2_sel] [get_bd_pins op_vec_kernel_0/in2_sel_V]
connect_bd_net [get_bd_pins controller_0/op_sel] [get_bd_pins op_vec_kernel_0/op_sel_V]
connect_bd_net [get_bd_pins op_vec_kernel_0/scale_V] [get_bd_pins controller_0/scale]
connect_bd_intf_net [get_bd_intf_pins op_vec_kernel_0/in_1_bram_z_PORTA] [get_bd_intf_pins soft_threshold_kernel_0_bram_0/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins op_vec_kernel_0/in_2_bram_u_PORTA] [get_bd_intf_pins soft_threshold_kernel_0_bram/BRAM_PORTB]

# create axis data fifo for the feedback port
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0
endgroup
connect_bd_intf_net [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins op_vec_kernel_0/in_2_feedback]
connect_bd_intf_net [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins op_vec_kernel_0/result_feedback]

# create 3 bram controllers (single port) for x, p, and q and connect them to ps
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
endgroup

set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_0]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1
endgroup

set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_1]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_2
endgroup

set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_2]

connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins op_vec_kernel_0_bram/BRAM_PORTB]

connect_bd_intf_net [get_bd_intf_pins op_vec_kernel_0_bram_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_2/BRAM_PORTA]

connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]

# connect to M_AXI)GP0
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_bram_ctrl_0/S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_bram_ctrl_1/S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_bram_ctrl_2/S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins axi_bram_ctrl_2/S_AXI]
endgroup

# connect controller's done pin to ps interrupt
connect_bd_net [get_bd_pins controller_0/done] [get_bd_pins processing_system7_0/IRQ_F2P]

# gpio for start pin and conent to ps master pin
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
endgroup

set_property -dict [list CONFIG.C_GPIO_WIDTH {1} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells axi_gpio_0]
connect_bd_net [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins controller_0/start]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/processing_system7_0/FCLK_CLK0 (100 MHz)} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_gpio_0/S_AXI} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]

# connect clocks and resest pins
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_pins controller_0/clk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_pins mac_kernel_0/ap_clk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_pins soft_threshold_kernel_0/ap_clk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_pins axis_data_fifo_0/s_axis_aclk]
endgroup

# BRAM p clock signal
connect_bd_net [get_bd_pins blk_mem_gen_0/clka] [get_bd_pins processing_system7_0/FCLK_CLK0]

# regenerate and layout
regenerate_bd_layout
save_bd_design

# generate output products (global)
set_property synth_checkpoint_mode None [get_files  ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd]
generate_target all [get_files  ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd]

export_ip_user_files -of_objects [get_files ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd] -no_script -sync -force -quiet
export_simulation -of_objects [get_files ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd] -directory ./FPGA_Accelerator.ip_user_files/sim_scripts -ip_user_files_dir ./FPGA_Accelerator.ip_user_files -ipstatic_source_dir ./FPGA_Accelerator.ip_user_files/ipstatic -lib_map_path [list {modelsim=./FPGA_Accelerator.cache/compile_simlib/modelsim} {questa=./FPGA_Accelerator.cache/compile_simlib/questa} {riviera=./FPGA_Accelerator.cache/compile_simlib/riviera} {activehdl=./FPGA_Accelerator.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet


# generate output products
#generate_target all [get_files  ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd]

#catch { config_ip_cache -export [get_ips -all design_1_controller_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_mac_kernel_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_op_vec_kernel_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_soft_threshold_kernel_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_processing_system7_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_soft_threshold_kernel_0_bram_0] }
#catch { config_ip_cache -export [get_ips -all design_1_soft_threshold_kernel_0_bram_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_blk_mem_gen_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_op_vec_kernel_0_bram_0] }
#catch { config_ip_cache -export [get_ips -all design_1_op_vec_kernel_0_bram_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_axis_data_fifo_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_axi_bram_ctrl_0_0] }
#catch { config_ip_cache -export [get_ips -all design_1_axi_bram_ctrl_1_0] }
#catch { config_ip_cache -export [get_ips -all design_1_axi_bram_ctrl_2_0] }
#catch { config_ip_cache -export [get_ips -all design_1_axi_smc_0] }
#catch { config_ip_cache -export [get_ips -all design_1_rst_ps7_0_100M_0] }
#catch { config_ip_cache -export [get_ips -all design_1_axi_gpio_0_0] }
#
#export_ip_user_files -of_objects [get_files ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd] -no_script -sync -force -quiet
#create_ip_run [get_files -of_objects [get_fileset sources_1] ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd]
#launch_runs -jobs 3 {design_1_controller_0_0_synth_1 design_1_mac_kernel_0_0_synth_1 design_1_op_vec_kernel_0_0_synth_1 design_1_soft_threshold_kernel_0_0_synth_1 design_1_processing_system7_0_0_synth_1 design_1_soft_threshold_kernel_0_bram_0_synth_1 design_1_soft_threshold_kernel_0_bram_0_0_synth_1 design_1_blk_mem_gen_0_0_synth_1 design_1_op_vec_kernel_0_bram_0_synth_1 design_1_op_vec_kernel_0_bram_0_0_synth_1 design_1_axis_data_fifo_0_0_synth_1 design_1_axi_bram_ctrl_0_0_synth_1 design_1_axi_bram_ctrl_1_0_synth_1 design_1_axi_bram_ctrl_2_0_synth_1 design_1_axi_smc_0_synth_1 design_1_rst_ps7_0_100M_0_synth_1 design_1_axi_gpio_0_0_synth_1}
#
#export_simulation -of_objects [get_files ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd] -directory ./FPGA_Accelerator.ip_user_files/sim_scripts -ip_user_files_dir ./FPGA_Accelerator.ip_user_files -ipstatic_source_dir ./FPGA_Accelerator.ip_user_files/ipstatic -lib_map_path [list {modelsim=./FPGA_Accelerator.cache/compile_simlib/modelsim} {questa=./FPGA_Accelerator.cache/compile_simlib/questa} {riviera=./FPGA_Accelerator.cache/compile_simlib/riviera} {activehdl=./FPGA_Accelerator.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet
#

# create hdl wrapper
make_wrapper -files [get_files ./FPGA_Accelerator.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ./FPGA_Accelerator.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v

# run synthesis
launch_runs synth_1 -jobs 3
wait_on_run synth_1


# run implementation
launch_runs impl_1 -jobs 3
wait_on_run impl_1


# generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 3
