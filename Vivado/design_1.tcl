
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART em.avnet.com:zed:part0:1.4 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:hls:mac_kernel:1.0\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:hls:soft_threshold_kernel:1.0\
xilinx.com:hls:termination_detector:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:user:controller:1.0\
xilinx.com:ip:fifo_generator:13.2\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:hls:op_vec_kernel:1.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: zold_td_fifo
proc create_hier_cell_zold_td_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_zold_td_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_2, and set properties
  set fifo_generator_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_2 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_2

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_1

  # Create instance: util_vector_logic_2, and set properties
  set util_vector_logic_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_2 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_2

  # Create port connections
  connect_bd_net -net fifo_generator_2_dout1 [get_bd_pins dout] [get_bd_pins fifo_generator_2/dout]
  connect_bd_net -net fifo_generator_2_empty [get_bd_pins fifo_generator_2/empty] [get_bd_pins util_vector_logic_2/Op1]
  connect_bd_net -net fifo_generator_2_full [get_bd_pins fifo_generator_2/full] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_2/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_2/srst]
  connect_bd_net -net soft_threshold_kernel_0_z_old_td_din [get_bd_pins din] [get_bd_pins fifo_generator_2/din]
  connect_bd_net -net soft_threshold_kernel_0_z_old_td_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_2/wr_en]
  connect_bd_net -net termination_detector_0_z_old_td_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_2/rd_en]
  connect_bd_net -net util_vector_logic_1_Res1 [get_bd_pins Res] [get_bd_pins util_vector_logic_1/Res]
  connect_bd_net -net util_vector_logic_2_Res1 [get_bd_pins Res1] [get_bd_pins util_vector_logic_2/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: z_td_fifo
proc create_hier_cell_z_td_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_z_td_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_3, and set properties
  set fifo_generator_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_3 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_3

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_4, and set properties
  set util_vector_logic_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_4 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_4

  # Create port connections
  connect_bd_net -net fifo_generator_3_dout [get_bd_pins dout] [get_bd_pins fifo_generator_3/dout]
  connect_bd_net -net fifo_generator_3_empty [get_bd_pins fifo_generator_3/empty] [get_bd_pins util_vector_logic_4/Op1]
  connect_bd_net -net fifo_generator_3_full [get_bd_pins fifo_generator_3/full] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_3/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_3/srst]
  connect_bd_net -net soft_threshold_kernel_0_z_td_din [get_bd_pins din] [get_bd_pins fifo_generator_3/din]
  connect_bd_net -net soft_threshold_kernel_0_z_td_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_3/wr_en]
  connect_bd_net -net termination_detector_0_z_td_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_3/rd_en]
  connect_bd_net -net util_vector_logic_0_Res1 [get_bd_pins Res] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_4_Res1 [get_bd_pins Res1] [get_bd_pins util_vector_logic_4/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: x_td_fifo
proc create_hier_cell_x_td_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_x_td_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_0, and set properties
  set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0 ]
  set_property USER_COMMENTS.comment_4 "x_td" [get_bd_cells /x_td_fifo/fifo_generator_0]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_0

  # Create instance: util_vector_logic_3, and set properties
  set util_vector_logic_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_3 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_3

  # Create instance: util_vector_logic_5, and set properties
  set util_vector_logic_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_5 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_5

  # Create port connections
  connect_bd_net -net fifo_generator_0_dout1 [get_bd_pins dout] [get_bd_pins fifo_generator_0/dout]
  connect_bd_net -net fifo_generator_0_empty [get_bd_pins fifo_generator_0/empty] [get_bd_pins util_vector_logic_5/Op1]
  connect_bd_net -net fifo_generator_0_full [get_bd_pins fifo_generator_0/full] [get_bd_pins util_vector_logic_3/Op1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_0/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_0/srst]
  connect_bd_net -net soft_threshold_kernel_0_x_td_din [get_bd_pins din] [get_bd_pins fifo_generator_0/din]
  connect_bd_net -net soft_threshold_kernel_0_x_td_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_0/wr_en]
  connect_bd_net -net termination_detector_0_x_td_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_0/rd_en]
  connect_bd_net -net util_vector_logic_3_Res1 [get_bd_pins Res] [get_bd_pins util_vector_logic_3/Res]
  connect_bd_net -net util_vector_logic_5_Res1 [get_bd_pins Res1] [get_bd_pins util_vector_logic_5/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: x_bram
proc create_hier_cell_x_bram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_x_bram() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTA
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_bram_ctrl_4, and set properties
  set axi_bram_ctrl_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_4 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_4

  # Create instance: op_vec_kernel_0_bram_0, and set properties
  set op_vec_kernel_0_bram_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 op_vec_kernel_0_bram_0 ]
  set_property -dict [ list \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $op_vec_kernel_0_bram_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_4_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_4/BRAM_PORTA] [get_bd_intf_pins op_vec_kernel_0_bram_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_smc_M03_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_4/S_AXI]
  connect_bd_intf_net -intf_net op_vec_kernel_0_x_PORTA [get_bd_intf_pins BRAM_PORTA] [get_bd_intf_pins op_vec_kernel_0_bram_0/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_bram_ctrl_4/s_axi_aclk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_4/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: vec_st_fifo
proc create_hier_cell_vec_st_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_vec_st_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_2, and set properties
  set fifo_generator_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_2 ]
  set_property -dict [ list \
   CONFIG.Data_Count {true} \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_2

  # Create instance: util_vector_logic_3, and set properties
  set util_vector_logic_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_3 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_3

  # Create instance: util_vector_logic_4, and set properties
  set util_vector_logic_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_4 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_4

  # Create port connections
  connect_bd_net -net fifo_generator_2_dout [get_bd_pins dout] [get_bd_pins fifo_generator_2/dout]
  connect_bd_net -net fifo_generator_2_empty [get_bd_pins fifo_generator_2/empty] [get_bd_pins util_vector_logic_4/Op1]
  connect_bd_net -net fifo_generator_2_full [get_bd_pins fifo_generator_2/full] [get_bd_pins util_vector_logic_3/Op1]
  connect_bd_net -net op_vec_kernel_0_result_st_din [get_bd_pins din] [get_bd_pins fifo_generator_2/din]
  connect_bd_net -net op_vec_kernel_0_result_st_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_2/wr_en]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_2/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_2/srst]
  connect_bd_net -net soft_threshold_kernel_0_x_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_2/rd_en]
  connect_bd_net -net util_vector_logic_3_Res [get_bd_pins Res1] [get_bd_pins util_vector_logic_3/Res]
  connect_bd_net -net util_vector_logic_4_Res [get_bd_pins Res] [get_bd_pins util_vector_logic_4/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: vec_mac_fifo
proc create_hier_cell_vec_mac_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_vec_mac_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_0, and set properties
  set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0 ]
  set_property -dict [ list \
   CONFIG.Data_Count {false} \
   CONFIG.Data_Count_Width {9} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {255} \
   CONFIG.Full_Threshold_Negate_Value {254} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {256} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {256} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {9} \
   CONFIG.Reset_Pin {true} \
   CONFIG.Reset_Type {Synchronous_Reset} \
   CONFIG.Use_Dout_Reset {true} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {9} \
 ] $fifo_generator_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_5, and set properties
  set util_vector_logic_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_5 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_5

  # Create port connections
  connect_bd_net -net fifo_generator_0_dout [get_bd_pins dout] [get_bd_pins fifo_generator_0/dout]
  connect_bd_net -net fifo_generator_0_empty [get_bd_pins fifo_generator_0/empty] [get_bd_pins util_vector_logic_5/Op1]
  connect_bd_net -net fifo_generator_0_full [get_bd_pins fifo_generator_0/full] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net mac_kernel_0_z_u_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_0/rd_en]
  connect_bd_net -net op_vec_kernel_0_result_mac_din [get_bd_pins din] [get_bd_pins fifo_generator_0/din]
  connect_bd_net -net op_vec_kernel_0_result_mac_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_0/wr_en]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_0/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_0/srst]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins Res] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_5_Res [get_bd_pins Res1] [get_bd_pins util_vector_logic_5/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: u_td_fifo
proc create_hier_cell_u_td_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_u_td_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_1, and set properties
  set fifo_generator_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_1 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_1

  # Create instance: util_vector_logic_6, and set properties
  set util_vector_logic_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_6 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_6

  # Create instance: util_vector_logic_7, and set properties
  set util_vector_logic_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_7 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_7

  # Create port connections
  connect_bd_net -net fifo_generator_1_dout1 [get_bd_pins dout] [get_bd_pins fifo_generator_1/dout]
  connect_bd_net -net fifo_generator_1_empty [get_bd_pins fifo_generator_1/empty] [get_bd_pins util_vector_logic_7/Op1]
  connect_bd_net -net fifo_generator_1_full [get_bd_pins fifo_generator_1/full] [get_bd_pins util_vector_logic_6/Op1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_1/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_1/srst]
  connect_bd_net -net soft_threshold_kernel_0_u_td_din [get_bd_pins din] [get_bd_pins fifo_generator_1/din]
  connect_bd_net -net soft_threshold_kernel_0_u_td_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_1/wr_en]
  connect_bd_net -net termination_detector_0_u_td_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_1/rd_en]
  connect_bd_net -net util_vector_logic_6_Res [get_bd_pins Res] [get_bd_pins util_vector_logic_6/Res]
  connect_bd_net -net util_vector_logic_7_Res [get_bd_pins Res1] [get_bd_pins util_vector_logic_7/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: q_bram
proc create_hier_cell_q_bram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_q_bram() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTB
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_bram_ctrl_2, and set properties
  set axi_bram_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_2 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_2

  # Create instance: axi_bram_ctrl_2_bram, and set properties
  set axi_bram_ctrl_2_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_2_bram ]
  set_property USER_COMMENTS.comment_3 "VECTOR Q" [get_bd_cells /q_bram/axi_bram_ctrl_2_bram]
  set_property -dict [ list \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $axi_bram_ctrl_2_bram

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_2_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_2/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_2_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_smc_M02_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_2/S_AXI]
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_2_bram_q_PORTA [get_bd_intf_pins BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_2_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_bram_ctrl_2/s_axi_aclk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_2/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: p_bram
proc create_hier_cell_p_bram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_p_bram() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -from 9 -to 0 addra
  create_bd_pin -dir I -from 31 -to 0 dina
  create_bd_pin -dir O -from 31 -to 0 douta
  create_bd_pin -dir I ena
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -from 3 -to 0 wea

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: mac_kernel_0_bram, and set properties
  set mac_kernel_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 mac_kernel_0_bram ]
  set_property USER_COMMENTS.comment_0 "MATRIX P" [get_bd_cells /p_bram/mac_kernel_0_bram]
  set_property -dict [ list \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $mac_kernel_0_bram

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins mac_kernel_0_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

  # Create port connections
  connect_bd_net -net mac_kernel_0_bram_douta [get_bd_pins douta] [get_bd_pins mac_kernel_0_bram/douta]
  connect_bd_net -net mac_kernel_0_p_address0 [get_bd_pins addra] [get_bd_pins mac_kernel_0_bram/addra]
  connect_bd_net -net mac_kernel_0_p_ce0 [get_bd_pins ena] [get_bd_pins mac_kernel_0_bram/ena]
  connect_bd_net -net mac_kernel_0_p_d0 [get_bd_pins dina] [get_bd_pins mac_kernel_0_bram/dina]
  connect_bd_net -net mac_kernel_0_p_we0 [get_bd_pins wea] [get_bd_pins mac_kernel_0_bram/wea]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins mac_kernel_0_bram/clka]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: op_vec_kernel
proc create_hier_cell_op_vec_kernel { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_op_vec_kernel() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 in_1_bram_z_PORTA
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 in_2_bram_q_PORTA
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 in_2_bram_u_PORTA

  # Create pins
  create_bd_pin -dir I -from 31 -to 0 -type data alpha
  create_bd_pin -dir O ap_done
  create_bd_pin -dir I ap_start
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 0 -to 0 -type data in1_sel_V
  create_bd_pin -dir I -from 1 -to 0 -type data in2_sel_V
  create_bd_pin -dir I -from 31 -to 0 in_1_mac_dout
  create_bd_pin -dir I in_1_mac_empty_n
  create_bd_pin -dir O in_1_mac_read
  create_bd_pin -dir I -from 0 -to 0 -type data op_sel_V
  create_bd_pin -dir O -from 31 -to 0 result_mac_din
  create_bd_pin -dir I result_mac_full_n
  create_bd_pin -dir O result_mac_write
  create_bd_pin -dir O -from 31 -to 0 result_st_din
  create_bd_pin -dir I result_st_full_n
  create_bd_pin -dir O result_st_write
  create_bd_pin -dir I -from 0 -to 0 -type data scale_V
  create_bd_pin -dir I srst

  # Create instance: fifo_generator_0, and set properties
  set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_0

  # Create instance: op_vec_kernel_0, and set properties
  set op_vec_kernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:op_vec_kernel:1.0 op_vec_kernel_0 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_1

  # Create interface connections
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_1_bram_z_PORTA [get_bd_intf_pins in_1_bram_z_PORTA] [get_bd_intf_pins op_vec_kernel_0/in_1_bram_z_PORTA]
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_2_bram_q_PORTA [get_bd_intf_pins in_2_bram_q_PORTA] [get_bd_intf_pins op_vec_kernel_0/in_2_bram_q_PORTA]
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_2_bram_u_PORTA [get_bd_intf_pins in_2_bram_u_PORTA] [get_bd_intf_pins op_vec_kernel_0/in_2_bram_u_PORTA]

  # Create port connections
  connect_bd_net -net controller_0_alpha [get_bd_pins alpha] [get_bd_pins op_vec_kernel_0/alpha]
  connect_bd_net -net controller_0_in_1_sel [get_bd_pins in1_sel_V] [get_bd_pins op_vec_kernel_0/in1_sel_V]
  connect_bd_net -net controller_0_in_2_sel [get_bd_pins in2_sel_V] [get_bd_pins op_vec_kernel_0/in2_sel_V]
  connect_bd_net -net controller_0_op_sel [get_bd_pins op_sel_V] [get_bd_pins op_vec_kernel_0/op_sel_V]
  connect_bd_net -net controller_0_op_vec_start [get_bd_pins ap_start] [get_bd_pins op_vec_kernel_0/ap_start]
  connect_bd_net -net controller_0_scale [get_bd_pins scale_V] [get_bd_pins op_vec_kernel_0/scale_V]
  connect_bd_net -net fifo_generator_0_dout [get_bd_pins fifo_generator_0/dout] [get_bd_pins op_vec_kernel_0/in_2_feedback_dout]
  connect_bd_net -net fifo_generator_0_empty [get_bd_pins fifo_generator_0/empty] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net fifo_generator_0_full [get_bd_pins fifo_generator_0/full] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net fifo_generator_1_dout [get_bd_pins in_1_mac_dout] [get_bd_pins op_vec_kernel_0/in_1_mac_dout]
  connect_bd_net -net op_vec_kernel_0_ap_ready [get_bd_pins ap_done] [get_bd_pins op_vec_kernel_0/ap_ready]
  connect_bd_net -net op_vec_kernel_0_in_1_mac_read [get_bd_pins in_1_mac_read] [get_bd_pins op_vec_kernel_0/in_1_mac_read]
  connect_bd_net -net op_vec_kernel_0_in_2_feedback_read [get_bd_pins fifo_generator_0/rd_en] [get_bd_pins op_vec_kernel_0/in_2_feedback_read]
  connect_bd_net -net op_vec_kernel_0_result_feedback_din [get_bd_pins fifo_generator_0/din] [get_bd_pins op_vec_kernel_0/result_feedback_din]
  connect_bd_net -net op_vec_kernel_0_result_feedback_write [get_bd_pins fifo_generator_0/wr_en] [get_bd_pins op_vec_kernel_0/result_feedback_write]
  connect_bd_net -net op_vec_kernel_0_result_mac_din [get_bd_pins result_mac_din] [get_bd_pins op_vec_kernel_0/result_mac_din]
  connect_bd_net -net op_vec_kernel_0_result_mac_write [get_bd_pins result_mac_write] [get_bd_pins op_vec_kernel_0/result_mac_write]
  connect_bd_net -net op_vec_kernel_0_result_st_din [get_bd_pins result_st_din] [get_bd_pins op_vec_kernel_0/result_st_din]
  connect_bd_net -net op_vec_kernel_0_result_st_write [get_bd_pins result_st_write] [get_bd_pins op_vec_kernel_0/result_st_write]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_0/clk] [get_bd_pins op_vec_kernel_0/ap_clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_0/srst] [get_bd_pins op_vec_kernel_0/ap_rst]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins result_mac_full_n] [get_bd_pins op_vec_kernel_0/result_mac_full_n]
  connect_bd_net -net util_vector_logic_0_Res1 [get_bd_pins op_vec_kernel_0/result_feedback_full_n] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins op_vec_kernel_0/in_2_feedback_empty_n] [get_bd_pins util_vector_logic_1/Res]
  connect_bd_net -net util_vector_logic_2_Res [get_bd_pins in_1_mac_empty_n] [get_bd_pins op_vec_kernel_0/in_1_mac_empty_n]
  connect_bd_net -net util_vector_logic_3_Res [get_bd_pins result_st_full_n] [get_bd_pins op_vec_kernel_0/result_st_full_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mac_vec_fifo
proc create_hier_cell_mac_vec_fifo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_mac_vec_fifo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 Res1
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 31 -to 0 din
  create_bd_pin -dir O -from 31 -to 0 dout
  create_bd_pin -dir I rd_en
  create_bd_pin -dir I srst
  create_bd_pin -dir I wr_en

  # Create instance: fifo_generator_1, and set properties
  set fifo_generator_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_1 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {8} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Full_Threshold_Assert_Value {127} \
   CONFIG.Full_Threshold_Negate_Value {126} \
   CONFIG.Input_Data_Width {32} \
   CONFIG.Input_Depth {128} \
   CONFIG.Output_Data_Width {32} \
   CONFIG.Output_Depth {128} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {8} \
   CONFIG.Use_Extra_Logic {true} \
   CONFIG.Write_Data_Count_Width {8} \
 ] $fifo_generator_1

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_1

  # Create instance: util_vector_logic_2, and set properties
  set util_vector_logic_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_2 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_2

  # Create port connections
  connect_bd_net -net fifo_generator_1_dout [get_bd_pins dout] [get_bd_pins fifo_generator_1/dout]
  connect_bd_net -net fifo_generator_1_empty [get_bd_pins fifo_generator_1/empty] [get_bd_pins util_vector_logic_2/Op1]
  connect_bd_net -net fifo_generator_1_full [get_bd_pins fifo_generator_1/full] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net mac_kernel_0_result_din [get_bd_pins din] [get_bd_pins fifo_generator_1/din]
  connect_bd_net -net mac_kernel_0_result_write [get_bd_pins wr_en] [get_bd_pins fifo_generator_1/wr_en]
  connect_bd_net -net op_vec_kernel_0_in_1_mac_read [get_bd_pins rd_en] [get_bd_pins fifo_generator_1/rd_en]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins fifo_generator_1/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins srst] [get_bd_pins fifo_generator_1/srst]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins Res] [get_bd_pins util_vector_logic_1/Res]
  connect_bd_net -net util_vector_logic_2_Res [get_bd_pins Res1] [get_bd_pins util_vector_logic_2/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: controller
proc create_hier_cell_controller { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_controller() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir O -from 31 -to 0 alpha
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir O done
  create_bd_pin -dir O in_1_sel
  create_bd_pin -dir O -from 1 -to 0 in_2_sel
  create_bd_pin -dir I mac_done
  create_bd_pin -dir O mac_start
  create_bd_pin -dir O op_sel
  create_bd_pin -dir I op_vec_done
  create_bd_pin -dir O op_vec_start
  create_bd_pin -dir O -from 31 -to 0 rho
  create_bd_pin -dir O -from 31 -to 0 rho_inv
  create_bd_pin -dir I -type rst rst
  create_bd_pin -dir O scale
  create_bd_pin -dir O -from 15 -to 0 st_ctr
  create_bd_pin -dir I st_done
  create_bd_pin -dir O st_start
  create_bd_pin -dir O td_start
  create_bd_pin -dir I terminate

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {0} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_1

  # Create instance: controller_0, and set properties
  set controller_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:controller:1.0 controller_0 ]
  set_property -dict [ list \
   CONFIG.ITERATION_COUNT {2} \
 ] $controller_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_smc_M04_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]

  # Create port connections
  connect_bd_net -net IRQ_F2P_1 [get_bd_pins done] [get_bd_pins controller_0/done]
  connect_bd_net -net alpha_1 [get_bd_pins alpha] [get_bd_pins controller_0/alpha]
  connect_bd_net -net ap_start_1 [get_bd_pins op_vec_start] [get_bd_pins controller_0/op_vec_start]
  connect_bd_net -net controller_0_mac_start [get_bd_pins mac_start] [get_bd_pins controller_0/mac_start]
  connect_bd_net -net controller_0_rho [get_bd_pins rho] [get_bd_pins controller_0/rho]
  connect_bd_net -net controller_0_rho_inv [get_bd_pins rho_inv] [get_bd_pins controller_0/rho_inv]
  connect_bd_net -net controller_0_scale [get_bd_pins scale] [get_bd_pins controller_0/scale]
  connect_bd_net -net controller_0_st_ctr [get_bd_pins st_ctr] [get_bd_pins controller_0/st_ctr]
  connect_bd_net -net controller_0_st_start [get_bd_pins st_start] [get_bd_pins controller_0/st_start]
  connect_bd_net -net controller_0_td_start [get_bd_pins td_start] [get_bd_pins controller_0/td_start]
  connect_bd_net -net controller_gpio_io_o [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins controller_0/start]
  connect_bd_net -net in1_sel_V_1 [get_bd_pins in_1_sel] [get_bd_pins controller_0/in_1_sel]
  connect_bd_net -net in2_sel_V_1 [get_bd_pins in_2_sel] [get_bd_pins controller_0/in_2_sel]
  connect_bd_net -net mac_kernel_0_ap_done [get_bd_pins mac_done] [get_bd_pins controller_0/mac_done]
  connect_bd_net -net op_sel_V_1 [get_bd_pins op_sel] [get_bd_pins controller_0/op_sel]
  connect_bd_net -net op_vec_kernel_0_ap_done [get_bd_pins op_vec_done] [get_bd_pins controller_0/op_vec_done]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins controller_0/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins rst] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins controller_0/rst]
  connect_bd_net -net soft_threshold_kernel_0_ap_done [get_bd_pins st_done] [get_bd_pins controller_0/st_done]
  connect_bd_net -net terminate_1 [get_bd_pins terminate] [get_bd_pins controller_0/terminate]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: PS
proc create_hier_cell_PS { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_PS() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_GP0

  # Create pins
  create_bd_pin -dir O -type clk FCLK_CLK0
  create_bd_pin -dir I -from 0 -to 0 -type intr IRQ_F2P
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_reset

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666667} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_CLK0_FREQ {100000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_EMIO_TTC0 {1} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_TTC0 {1} \
   CONFIG.PCW_EN_UART1 {1} \
   CONFIG.PCW_EN_USB0 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150.000000} \
   CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_IRQ_F2P_INTR {1} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {disabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {disabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {disabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {disabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {disabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {inout} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {disabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {inout} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {disabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_16_PULLUP {disabled} \
   CONFIG.PCW_MIO_16_SLEW {fast} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_17_PULLUP {disabled} \
   CONFIG.PCW_MIO_17_SLEW {fast} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_18_PULLUP {disabled} \
   CONFIG.PCW_MIO_18_SLEW {fast} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_19_PULLUP {disabled} \
   CONFIG.PCW_MIO_19_SLEW {fast} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {disabled} \
   CONFIG.PCW_MIO_1_SLEW {fast} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_20_PULLUP {disabled} \
   CONFIG.PCW_MIO_20_SLEW {fast} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_21_PULLUP {disabled} \
   CONFIG.PCW_MIO_21_SLEW {fast} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_22_PULLUP {disabled} \
   CONFIG.PCW_MIO_22_SLEW {fast} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_23_PULLUP {disabled} \
   CONFIG.PCW_MIO_23_SLEW {fast} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_24_PULLUP {disabled} \
   CONFIG.PCW_MIO_24_SLEW {fast} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_25_PULLUP {disabled} \
   CONFIG.PCW_MIO_25_SLEW {fast} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_26_PULLUP {disabled} \
   CONFIG.PCW_MIO_26_SLEW {fast} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_27_PULLUP {disabled} \
   CONFIG.PCW_MIO_27_SLEW {fast} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_28_PULLUP {disabled} \
   CONFIG.PCW_MIO_28_SLEW {fast} \
   CONFIG.PCW_MIO_29_DIRECTION {in} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_29_PULLUP {disabled} \
   CONFIG.PCW_MIO_29_SLEW {fast} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {fast} \
   CONFIG.PCW_MIO_30_DIRECTION {out} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_30_PULLUP {disabled} \
   CONFIG.PCW_MIO_30_SLEW {fast} \
   CONFIG.PCW_MIO_31_DIRECTION {in} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_31_PULLUP {disabled} \
   CONFIG.PCW_MIO_31_SLEW {fast} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_32_PULLUP {disabled} \
   CONFIG.PCW_MIO_32_SLEW {fast} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_33_PULLUP {disabled} \
   CONFIG.PCW_MIO_33_SLEW {fast} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_34_PULLUP {disabled} \
   CONFIG.PCW_MIO_34_SLEW {fast} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_35_PULLUP {disabled} \
   CONFIG.PCW_MIO_35_SLEW {fast} \
   CONFIG.PCW_MIO_36_DIRECTION {in} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_36_PULLUP {disabled} \
   CONFIG.PCW_MIO_36_SLEW {fast} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_37_PULLUP {disabled} \
   CONFIG.PCW_MIO_37_SLEW {fast} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_38_PULLUP {disabled} \
   CONFIG.PCW_MIO_38_SLEW {fast} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_39_PULLUP {disabled} \
   CONFIG.PCW_MIO_39_SLEW {fast} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {fast} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {disabled} \
   CONFIG.PCW_MIO_40_SLEW {fast} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {disabled} \
   CONFIG.PCW_MIO_41_SLEW {fast} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {disabled} \
   CONFIG.PCW_MIO_42_SLEW {fast} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {disabled} \
   CONFIG.PCW_MIO_43_SLEW {fast} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {disabled} \
   CONFIG.PCW_MIO_44_SLEW {fast} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {disabled} \
   CONFIG.PCW_MIO_45_SLEW {fast} \
   CONFIG.PCW_MIO_46_DIRECTION {in} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_46_PULLUP {disabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {in} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_47_PULLUP {disabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {out} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {disabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {in} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {disabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {fast} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_50_PULLUP {disabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_51_PULLUP {disabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {out} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_52_PULLUP {disabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_53_PULLUP {disabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {fast} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {fast} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {fast} \
   CONFIG.PCW_MIO_9_DIRECTION {inout} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {disabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#UART 1#UART 1#GPIO#GPIO#Enet 0#Enet 0} \
   CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#gpio[8]#gpio[9]#gpio[10]#gpio[11]#gpio[12]#gpio[13]#gpio[14]#gpio[15]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#wp#cd#tx#rx#gpio[50]#gpio[51]#mdc#mdio} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_WP_IO {MIO 46} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
   CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BL {8} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.41} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.411} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.341} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.358} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {2048 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.025} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.028} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.001} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.001} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333313} \
   CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J128M16 HA-15E} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {14} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {45.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {36.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {49.5} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
   CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB0_RESET_ENABLE {0} \
   CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
   CONFIG.PCW_USE_S_AXI_ACP {1} \
   CONFIG.PCW_USE_S_AXI_HP0 {0} \
   CONFIG.preset {ZedBoard} \
 ] $processing_system7_0

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins M_AXI_GP0] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net mac_kernel_0_interrupt [get_bd_pins IRQ_F2P] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_ACP_ACLK] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins peripheral_reset] [get_bd_pins rst_ps7_0_100M/peripheral_reset]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports

  # Create instance: PS
  create_hier_cell_PS [current_bd_instance .] PS

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_GPIO_WIDTH {16} \
 ] $axi_gpio_0

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [ list \
   CONFIG.NUM_MI {5} \
   CONFIG.NUM_SI {1} \
 ] $axi_smc

  # Create instance: controller
  create_hier_cell_controller [current_bd_instance .] controller

  # Create instance: mac_kernel_0, and set properties
  set mac_kernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:mac_kernel:1.0 mac_kernel_0 ]

  # Create instance: mac_kernel_0_bram_0, and set properties
  set mac_kernel_0_bram_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 mac_kernel_0_bram_0 ]
  set_property USER_COMMENTS.comment_1 "VECTOR Z" [get_bd_cells /mac_kernel_0_bram_0]
  set_property -dict [ list \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $mac_kernel_0_bram_0

  # Create instance: mac_vec_fifo
  create_hier_cell_mac_vec_fifo [current_bd_instance .] mac_vec_fifo

  # Create instance: op_vec_kernel
  create_hier_cell_op_vec_kernel [current_bd_instance .] op_vec_kernel

  # Create instance: op_vec_kernel_0_bram, and set properties
  set op_vec_kernel_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 op_vec_kernel_0_bram ]
  set_property USER_COMMENTS.comment_2 "VECTOR U" [get_bd_cells /op_vec_kernel_0_bram]
  set_property -dict [ list \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $op_vec_kernel_0_bram

  # Create instance: p_bram
  create_hier_cell_p_bram [current_bd_instance .] p_bram

  # Create instance: q_bram
  create_hier_cell_q_bram [current_bd_instance .] q_bram

  # Create instance: soft_threshold_kernel_0, and set properties
  set soft_threshold_kernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:soft_threshold_kernel:1.0 soft_threshold_kernel_0 ]

  # Create instance: termination_detector_0, and set properties
  set termination_detector_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:termination_detector:1.0 termination_detector_0 ]

  # Create instance: u_td_fifo
  create_hier_cell_u_td_fifo [current_bd_instance .] u_td_fifo

  # Create instance: vec_mac_fifo
  create_hier_cell_vec_mac_fifo [current_bd_instance .] vec_mac_fifo

  # Create instance: vec_st_fifo
  create_hier_cell_vec_st_fifo [current_bd_instance .] vec_st_fifo

  # Create instance: x_bram
  create_hier_cell_x_bram [current_bd_instance .] x_bram

  # Create instance: x_td_fifo
  create_hier_cell_x_td_fifo [current_bd_instance .] x_td_fifo

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {2} \
 ] $xlconstant_1

  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {2} \
 ] $xlconstant_2

  # Create instance: z_td_fifo
  create_hier_cell_z_td_fifo [current_bd_instance .] z_td_fifo

  # Create instance: zold_td_fifo
  create_hier_cell_zold_td_fifo [current_bd_instance .] zold_td_fifo

  # Create interface connections
  connect_bd_intf_net -intf_net BRAM_PORTA_1 [get_bd_intf_pins termination_detector_0/x_out_PORTA] [get_bd_intf_pins x_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins p_bram/S_AXI]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_smc/M01_AXI]
  connect_bd_intf_net -intf_net axi_smc_M02_AXI [get_bd_intf_pins axi_smc/M02_AXI] [get_bd_intf_pins q_bram/S_AXI]
  connect_bd_intf_net -intf_net axi_smc_M03_AXI [get_bd_intf_pins axi_smc/M03_AXI] [get_bd_intf_pins x_bram/S_AXI]
  connect_bd_intf_net -intf_net axi_smc_M04_AXI [get_bd_intf_pins axi_smc/M04_AXI] [get_bd_intf_pins controller/S_AXI]
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_1_bram_z_PORTA [get_bd_intf_pins mac_kernel_0_bram_0/BRAM_PORTA] [get_bd_intf_pins op_vec_kernel/in_1_bram_z_PORTA]
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_2_bram_q_PORTA [get_bd_intf_pins op_vec_kernel/in_2_bram_q_PORTA] [get_bd_intf_pins q_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net op_vec_kernel_0_in_2_bram_u_PORTA [get_bd_intf_pins op_vec_kernel/in_2_bram_u_PORTA] [get_bd_intf_pins op_vec_kernel_0_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins PS/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins PS/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins PS/M_AXI_GP0] [get_bd_intf_pins axi_smc/S00_AXI]
  connect_bd_intf_net -intf_net soft_threshold_kernel_0_u_bram_PORTA [get_bd_intf_pins op_vec_kernel_0_bram/BRAM_PORTB] [get_bd_intf_pins soft_threshold_kernel_0/u_bram_PORTA]

  # Create port connections
  connect_bd_net -net alpha_1 [get_bd_pins controller/alpha] [get_bd_pins op_vec_kernel/alpha]
  connect_bd_net -net ap_start_1 [get_bd_pins controller/op_vec_start] [get_bd_pins op_vec_kernel/ap_start]
  connect_bd_net -net controller_0_rho_inv [get_bd_pins controller/rho_inv] [get_bd_pins soft_threshold_kernel_0/rho_inv]
  connect_bd_net -net controller_0_scale [get_bd_pins controller/scale] [get_bd_pins op_vec_kernel/scale_V]
  connect_bd_net -net controller_done [get_bd_pins PS/IRQ_F2P] [get_bd_pins controller/done]
  connect_bd_net -net controller_rho [get_bd_pins controller/rho] [get_bd_pins termination_detector_0/rho]
  connect_bd_net -net controller_st_ctr [get_bd_pins axi_gpio_0/gpio_io_i] [get_bd_pins controller/st_ctr]
  connect_bd_net -net controller_st_start [get_bd_pins controller/st_start] [get_bd_pins soft_threshold_kernel_0/ap_start]
  connect_bd_net -net controller_td_start [get_bd_pins controller/td_start] [get_bd_pins termination_detector_0/ap_start]
  connect_bd_net -net fifo_generator_0_dout [get_bd_pins mac_kernel_0/z_u_dout] [get_bd_pins vec_mac_fifo/dout]
  connect_bd_net -net fifo_generator_0_dout1 [get_bd_pins termination_detector_0/x_td_dout] [get_bd_pins x_td_fifo/dout]
  connect_bd_net -net fifo_generator_1_dout [get_bd_pins mac_vec_fifo/dout] [get_bd_pins op_vec_kernel/in_1_mac_dout]
  connect_bd_net -net fifo_generator_1_dout1 [get_bd_pins termination_detector_0/u_td_dout] [get_bd_pins u_td_fifo/dout]
  connect_bd_net -net fifo_generator_2_dout [get_bd_pins soft_threshold_kernel_0/x_dout] [get_bd_pins vec_st_fifo/dout]
  connect_bd_net -net fifo_generator_2_dout1 [get_bd_pins termination_detector_0/z_old_td_dout] [get_bd_pins zold_td_fifo/dout]
  connect_bd_net -net fifo_generator_3_dout [get_bd_pins termination_detector_0/z_td_dout] [get_bd_pins z_td_fifo/dout]
  connect_bd_net -net in1_sel_V_1 [get_bd_pins controller/in_1_sel] [get_bd_pins op_vec_kernel/in1_sel_V]
  connect_bd_net -net in2_sel_V_1 [get_bd_pins controller/in_2_sel] [get_bd_pins op_vec_kernel/in2_sel_V]
  connect_bd_net -net mac_kernel_0_ap_done [get_bd_pins controller/mac_done] [get_bd_pins mac_kernel_0/ap_done]
  connect_bd_net -net mac_kernel_0_bram_0_doutb [get_bd_pins mac_kernel_0_bram_0/doutb] [get_bd_pins soft_threshold_kernel_0/result_z_q0]
  connect_bd_net -net mac_kernel_0_bram_douta [get_bd_pins mac_kernel_0/p_q0] [get_bd_pins p_bram/douta]
  connect_bd_net -net mac_kernel_0_p_address0 [get_bd_pins mac_kernel_0/p_address0] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net mac_kernel_0_p_ce0 [get_bd_pins mac_kernel_0/p_ce0] [get_bd_pins p_bram/ena]
  connect_bd_net -net mac_kernel_0_p_d0 [get_bd_pins mac_kernel_0/p_d0] [get_bd_pins p_bram/dina]
  connect_bd_net -net mac_kernel_0_p_we0 [get_bd_pins mac_kernel_0/p_we0] [get_bd_pins p_bram/wea]
  connect_bd_net -net mac_kernel_0_result_din [get_bd_pins mac_kernel_0/result_din] [get_bd_pins mac_vec_fifo/din]
  connect_bd_net -net mac_kernel_0_result_write [get_bd_pins mac_kernel_0/result_write] [get_bd_pins mac_vec_fifo/wr_en]
  connect_bd_net -net mac_kernel_0_z_u_read [get_bd_pins mac_kernel_0/z_u_read] [get_bd_pins vec_mac_fifo/rd_en]
  connect_bd_net -net op_sel_V_1 [get_bd_pins controller/op_sel] [get_bd_pins op_vec_kernel/op_sel_V]
  connect_bd_net -net op_vec_kernel_0_ap_done [get_bd_pins controller/op_vec_done] [get_bd_pins op_vec_kernel/ap_done]
  connect_bd_net -net op_vec_kernel_0_in_1_mac_read [get_bd_pins mac_vec_fifo/rd_en] [get_bd_pins op_vec_kernel/in_1_mac_read]
  connect_bd_net -net op_vec_kernel_0_result_mac_din [get_bd_pins op_vec_kernel/result_mac_din] [get_bd_pins vec_mac_fifo/din]
  connect_bd_net -net op_vec_kernel_0_result_mac_write [get_bd_pins op_vec_kernel/result_mac_write] [get_bd_pins vec_mac_fifo/wr_en]
  connect_bd_net -net op_vec_kernel_0_result_st_din [get_bd_pins op_vec_kernel/result_st_din] [get_bd_pins vec_st_fifo/din]
  connect_bd_net -net op_vec_kernel_0_result_st_write [get_bd_pins op_vec_kernel/result_st_write] [get_bd_pins vec_st_fifo/wr_en]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins PS/FCLK_CLK0] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins controller/clk] [get_bd_pins mac_kernel_0/ap_clk] [get_bd_pins mac_kernel_0_bram_0/clkb] [get_bd_pins mac_vec_fifo/clk] [get_bd_pins op_vec_kernel/clk] [get_bd_pins p_bram/s_axi_aclk] [get_bd_pins q_bram/s_axi_aclk] [get_bd_pins soft_threshold_kernel_0/ap_clk] [get_bd_pins termination_detector_0/ap_clk] [get_bd_pins u_td_fifo/clk] [get_bd_pins vec_mac_fifo/clk] [get_bd_pins vec_st_fifo/clk] [get_bd_pins x_bram/s_axi_aclk] [get_bd_pins x_td_fifo/clk] [get_bd_pins z_td_fifo/clk] [get_bd_pins zold_td_fifo/clk]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins PS/peripheral_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_smc/aresetn] [get_bd_pins controller/rst] [get_bd_pins p_bram/s_axi_aresetn] [get_bd_pins q_bram/s_axi_aresetn] [get_bd_pins x_bram/s_axi_aresetn]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins PS/peripheral_reset] [get_bd_pins mac_kernel_0/ap_rst] [get_bd_pins mac_vec_fifo/srst] [get_bd_pins op_vec_kernel/srst] [get_bd_pins soft_threshold_kernel_0/ap_rst] [get_bd_pins termination_detector_0/ap_rst] [get_bd_pins u_td_fifo/srst] [get_bd_pins vec_mac_fifo/srst] [get_bd_pins vec_st_fifo/srst] [get_bd_pins x_td_fifo/srst] [get_bd_pins z_td_fifo/srst] [get_bd_pins zold_td_fifo/srst]
  connect_bd_net -net soft_threshold_kernel_0_ap_ready [get_bd_pins controller/st_done] [get_bd_pins soft_threshold_kernel_0/ap_ready]
  connect_bd_net -net soft_threshold_kernel_0_result_z_address0 [get_bd_pins soft_threshold_kernel_0/result_z_address0] [get_bd_pins xlconcat_1/In1]
  connect_bd_net -net soft_threshold_kernel_0_result_z_ce0 [get_bd_pins mac_kernel_0_bram_0/enb] [get_bd_pins soft_threshold_kernel_0/result_z_ce0]
  connect_bd_net -net soft_threshold_kernel_0_result_z_d0 [get_bd_pins mac_kernel_0_bram_0/dinb] [get_bd_pins soft_threshold_kernel_0/result_z_d0]
  connect_bd_net -net soft_threshold_kernel_0_result_z_we0 [get_bd_pins mac_kernel_0_bram_0/web] [get_bd_pins soft_threshold_kernel_0/result_z_we0]
  connect_bd_net -net soft_threshold_kernel_0_u_td_din [get_bd_pins soft_threshold_kernel_0/u_td_din] [get_bd_pins u_td_fifo/din]
  connect_bd_net -net soft_threshold_kernel_0_u_td_write [get_bd_pins soft_threshold_kernel_0/u_td_write] [get_bd_pins u_td_fifo/wr_en]
  connect_bd_net -net soft_threshold_kernel_0_x_read [get_bd_pins soft_threshold_kernel_0/x_read] [get_bd_pins vec_st_fifo/rd_en]
  connect_bd_net -net soft_threshold_kernel_0_x_td_din [get_bd_pins soft_threshold_kernel_0/x_td_din] [get_bd_pins x_td_fifo/din]
  connect_bd_net -net soft_threshold_kernel_0_x_td_write [get_bd_pins soft_threshold_kernel_0/x_td_write] [get_bd_pins x_td_fifo/wr_en]
  connect_bd_net -net soft_threshold_kernel_0_z_old_td_din [get_bd_pins soft_threshold_kernel_0/z_old_td_din] [get_bd_pins zold_td_fifo/din]
  connect_bd_net -net soft_threshold_kernel_0_z_old_td_write [get_bd_pins soft_threshold_kernel_0/z_old_td_write] [get_bd_pins zold_td_fifo/wr_en]
  connect_bd_net -net soft_threshold_kernel_0_z_td_din [get_bd_pins soft_threshold_kernel_0/z_td_din] [get_bd_pins z_td_fifo/din]
  connect_bd_net -net soft_threshold_kernel_0_z_td_write [get_bd_pins soft_threshold_kernel_0/z_td_write] [get_bd_pins z_td_fifo/wr_en]
  connect_bd_net -net termination_detector_0_terminate [get_bd_pins controller/terminate] [get_bd_pins termination_detector_0/terminate]
  connect_bd_net -net termination_detector_0_u_td_read [get_bd_pins termination_detector_0/u_td_read] [get_bd_pins u_td_fifo/rd_en]
  connect_bd_net -net termination_detector_0_x_td_read [get_bd_pins termination_detector_0/x_td_read] [get_bd_pins x_td_fifo/rd_en]
  connect_bd_net -net termination_detector_0_z_old_td_read [get_bd_pins termination_detector_0/z_old_td_read] [get_bd_pins zold_td_fifo/rd_en]
  connect_bd_net -net termination_detector_0_z_td_read [get_bd_pins termination_detector_0/z_td_read] [get_bd_pins z_td_fifo/rd_en]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins op_vec_kernel/result_mac_full_n] [get_bd_pins vec_mac_fifo/Res]
  connect_bd_net -net util_vector_logic_0_Res1 [get_bd_pins soft_threshold_kernel_0/z_td_full_n] [get_bd_pins z_td_fifo/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins mac_kernel_0/result_full_n] [get_bd_pins mac_vec_fifo/Res]
  connect_bd_net -net util_vector_logic_1_Res1 [get_bd_pins soft_threshold_kernel_0/z_old_td_full_n] [get_bd_pins zold_td_fifo/Res]
  connect_bd_net -net util_vector_logic_2_Res [get_bd_pins mac_vec_fifo/Res1] [get_bd_pins op_vec_kernel/in_1_mac_empty_n]
  connect_bd_net -net util_vector_logic_2_Res1 [get_bd_pins termination_detector_0/z_old_td_empty_n] [get_bd_pins zold_td_fifo/Res1]
  connect_bd_net -net util_vector_logic_3_Res [get_bd_pins op_vec_kernel/result_st_full_n] [get_bd_pins vec_st_fifo/Res1]
  connect_bd_net -net util_vector_logic_3_Res1 [get_bd_pins soft_threshold_kernel_0/x_td_full_n] [get_bd_pins x_td_fifo/Res]
  connect_bd_net -net util_vector_logic_4_Res [get_bd_pins soft_threshold_kernel_0/x_empty_n] [get_bd_pins vec_st_fifo/Res]
  connect_bd_net -net util_vector_logic_4_Res1 [get_bd_pins termination_detector_0/z_td_empty_n] [get_bd_pins z_td_fifo/Res1]
  connect_bd_net -net util_vector_logic_5_Res [get_bd_pins mac_kernel_0/z_u_empty_n] [get_bd_pins vec_mac_fifo/Res1]
  connect_bd_net -net util_vector_logic_5_Res1 [get_bd_pins termination_detector_0/x_td_empty_n] [get_bd_pins x_td_fifo/Res1]
  connect_bd_net -net util_vector_logic_6_Res [get_bd_pins soft_threshold_kernel_0/u_td_full_n] [get_bd_pins u_td_fifo/Res]
  connect_bd_net -net util_vector_logic_7_Res [get_bd_pins termination_detector_0/u_td_empty_n] [get_bd_pins u_td_fifo/Res1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins p_bram/addra] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins mac_kernel_0_bram_0/addrb] [get_bd_pins xlconcat_1/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins mac_kernel_0/ap_start] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconcat_0/In0] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconcat_1/In0] [get_bd_pins xlconstant_2/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00002000 -offset 0x4B000000 [get_bd_addr_spaces PS/processing_system7_0/Data] [get_bd_addr_segs p_bram/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00002000 -offset 0x44000000 [get_bd_addr_spaces PS/processing_system7_0/Data] [get_bd_addr_segs q_bram/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x00002000 -offset 0x40000000 [get_bd_addr_spaces PS/processing_system7_0/Data] [get_bd_addr_segs x_bram/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces PS/processing_system7_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41210000 [get_bd_addr_spaces PS/processing_system7_0/Data] [get_bd_addr_segs controller/axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


