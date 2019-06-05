
proc init {cellpath otherInfo } {
  # cell initialization here
  set cell [get_bd_cells $cellpath]
  set paramList { C_SLOT_0_AXI_ID_WIDTH C_SLOT_0_AXI_DATA_WIDTH C_SLOT_0_AXI_ADDR_WIDTH C_SLOT_1_AXI_ID_WIDTH C_SLOT_1_AXI_DATA_WIDTH C_SLOT_1_AXI_ADDR_WIDTH C_SLOT_2_AXI_ID_WIDTH C_SLOT_2_AXI_DATA_WIDTH C_SLOT_2_AXI_ADDR_WIDTH C_SLOT_3_AXI_ID_WIDTH C_SLOT_3_AXI_DATA_WIDTH C_SLOT_3_AXI_ADDR_WIDTH C_SLOT_4_AXI_ID_WIDTH C_SLOT_4_AXI_DATA_WIDTH C_SLOT_4_AXI_ADDR_WIDTH C_SLOT_5_AXI_ID_WIDTH C_SLOT_5_AXI_DATA_WIDTH C_SLOT_5_AXI_ADDR_WIDTH C_SLOT_6_AXI_ID_WIDTH C_SLOT_6_AXI_DATA_WIDTH C_SLOT_6_AXI_ADDR_WIDTH C_SLOT_7_AXI_ID_WIDTH C_SLOT_7_AXI_DATA_WIDTH C_SLOT_7_AXI_ADDR_WIDTH C_SLOT_0_AXIS_TID_WIDTH C_SLOT_0_AXIS_TDATA_WIDTH C_SLOT_0_AXIS_TDEST_WIDTH C_SLOT_0_AXIS_TUSER_WIDTH C_SLOT_1_AXIS_TID_WIDTH C_SLOT_1_AXIS_TDATA_WIDTH C_SLOT_1_AXIS_TDEST_WIDTH C_SLOT_1_AXIS_TUSER_WIDTH C_SLOT_2_AXIS_TID_WIDTH C_SLOT_2_AXIS_TDATA_WIDTH C_SLOT_2_AXIS_TDEST_WIDTH C_SLOT_2_AXIS_TUSER_WIDTH C_SLOT_3_AXIS_TID_WIDTH C_SLOT_3_AXIS_TDATA_WIDTH C_SLOT_3_AXIS_TDEST_WIDTH C_SLOT_3_AXIS_TUSER_WIDTH C_SLOT_4_AXIS_TID_WIDTH C_SLOT_4_AXIS_TDATA_WIDTH C_SLOT_4_AXIS_TDEST_WIDTH C_SLOT_4_AXIS_TUSER_WIDTH C_SLOT_5_AXIS_TID_WIDTH C_SLOT_5_AXIS_TDATA_WIDTH C_SLOT_5_AXIS_TDEST_WIDTH C_SLOT_5_AXIS_TUSER_WIDTH C_SLOT_6_AXIS_TID_WIDTH C_SLOT_6_AXIS_TDATA_WIDTH C_SLOT_6_AXIS_TDEST_WIDTH C_SLOT_6_AXIS_TUSER_WIDTH C_SLOT_7_AXIS_TID_WIDTH C_SLOT_7_AXIS_TDATA_WIDTH C_SLOT_7_AXIS_TDEST_WIDTH C_SLOT_7_AXIS_TUSER_WIDTH C_EXT_EVENT0_FIFO_ENABLE C_EXT_EVENT1_FIFO_ENABLE C_EXT_EVENT2_FIFO_ENABLE C_EXT_EVENT3_FIFO_ENABLE C_EXT_EVENT4_FIFO_ENABLE C_EXT_EVENT5_FIFO_ENABLE C_EXT_EVENT6_FIFO_ENABLE C_EXT_EVENT7_FIFO_ENABLE C_SLOT_0_FIFO_ENABLE C_SLOT_1_FIFO_ENABLE C_SLOT_2_FIFO_ENABLE C_SLOT_3_FIFO_ENABLE C_SLOT_4_FIFO_ENABLE C_SLOT_5_FIFO_ENABLE C_SLOT_6_FIFO_ENABLE C_SLOT_7_FIFO_ENABLE C_AXI4LITE_CORE_CLK_ASYNC C_FIFO_AXIS_SYNC}
  bd::mark_propagate_only $cell $paramList
}

proc post_configure_ip {cellpath otherInfo } {
# Any updates to interface properties based on user configuration
# Not needed, can be removed
}

proc clk_chk {cellpath core_clk test_clk } {
    if {$core_clk < $test_clk} {
       bd::send_msg -of $cellpath -type ERROR -msg_id 1 -text " 
       ##############################################################################
       Core Clock should be the fastest clock among all clocks of AXI Performance Monitor Core.
       ##############################################################################"
    }
}
proc propagate {cellpath otherInfo } {

    # standard parameter propagation here
    set ip [get_bd_cells $cellpath]


    set core_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/core_aclk]]
    set axi_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/s_axi_aclk]]
    set num_slots [get_property CONFIG.C_NUM_MONITOR_SLOTS $ip]
    set en_profile [get_property CONFIG.C_ENABLE_PROFILE $ip]
    set en_trace [get_property CONFIG.C_ENABLE_TRACE $ip]
    set en_count [get_property CONFIG.C_ENABLE_EVENT_COUNT $ip]
    set en_log [get_property CONFIG.C_ENABLE_EVENT_LOG $ip]
    set core_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/core_aclk]]
    set axi_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/s_axi_aclk]]
    set core_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/core_aclk]]
    set axi_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/s_axi_aclk]]
     # AXI4-Lite interface synchronizer enable/disable propagation
     clk_chk $cellpath $core_clk $axi_clk
     if { $core_clk !=0 && $axi_clk !=0 && $core_clk == $axi_clk && $core_clk_phase == $axi_clk_phase
          && $core_clk_domain == $axi_clk_domain} {
            set_property CONFIG.C_AXI4LITE_CORE_CLK_ASYNC 0 $ip
     } else {
            set_property CONFIG.C_AXI4LITE_CORE_CLK_ASYNC 1 $ip
     }

     # Event log streaming interface synchronizer enable/disable propagation
     if { $en_log == 1 || $en_trace == 1} {
        set axis_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/m_axis_aclk]]
        set axis_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/m_axis_aclk]]
        set axis_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/m_axis_aclk]]
        clk_chk $cellpath $core_clk $axis_clk
        if { $core_clk !=0 && $axis_clk !=0 && $core_clk == $axis_clk && $core_clk_phase == $axis_clk_phase
	     && $core_clk_domain == $axis_clk_domain} {
               set_property CONFIG.C_FIFO_AXIS_SYNC 1 $ip
        } else {
               set_property CONFIG.C_FIFO_AXIS_SYNC 0 $ip
        }
     }

    # External event interface FIFO enable parameter propagations
    set en_ext [get_property CONFIG.ENABLE_EXT_EVENTS $ip]

    if { $en_ext == 1 && ($en_count == 1 || $en_log == 1 || $en_trace ==1)} {
         set ext0_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_0]]
         set ext0_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_0]]
         set ext0_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_0]]
        clk_chk $cellpath $core_clk $ext0_clk
         if { $core_clk !=0 && $ext0_clk !=0 && $core_clk == $ext0_clk && $core_clk_phase == $ext0_clk_phase
	     && $core_clk_domain == $ext0_clk_domain} {
            set_property CONFIG.C_EXT_EVENT0_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_EXT_EVENT0_FIFO_ENABLE 1 $ip
         }
         if { $num_slots > 1} {
            set ext1_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_1]]
            set ext1_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_1]]
            set ext1_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_1]]
        clk_chk $cellpath $core_clk $ext1_clk
            if { $core_clk !=0 && $ext1_clk !=0 && $core_clk == $ext1_clk && $core_clk_phase == $ext1_clk_phase
	         && $core_clk_domain == $ext1_clk_domain} {
               set_property CONFIG.C_EXT_EVENT1_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT1_FIFO_ENABLE 1 $ip
            }
         }
         if { $num_slots > 2} {
            set ext2_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_2]]
            set ext2_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_2]]
            set ext2_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_2]]
        clk_chk $cellpath $core_clk $ext2_clk
            if { $core_clk !=0 && $ext2_clk !=0 && $core_clk == $ext2_clk && $core_clk_phase == $ext2_clk_phase
	         && $core_clk_domain == $ext2_clk_domain} {
               set_property CONFIG.C_EXT_EVENT2_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT2_FIFO_ENABLE 1 $ip
            }
         }
         if { $num_slots > 3} {
            set ext3_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_3]]
            set ext3_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_3]]
            set ext3_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_3]]
        clk_chk $cellpath $core_clk $ext3_clk
            if { $core_clk !=0 && $ext3_clk !=0 && $core_clk == $ext3_clk && $core_clk_phase == $ext3_clk_phase
	         && $core_clk_domain == $ext3_clk_domain} {
               set_property CONFIG.C_EXT_EVENT3_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT3_FIFO_ENABLE 1 $ip
            }
         }
         if { $num_slots > 4} {
            set ext4_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_4]]
            set ext4_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_4]]
            set ext4_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_4]]
        clk_chk $cellpath $core_clk $ext4_clk
            if { $core_clk !=0 && $ext4_clk !=0 && $core_clk == $ext4_clk && $core_clk_phase == $ext4_clk_phase
	         && $core_clk_domain == $ext4_clk_domain} {
               set_property CONFIG.C_EXT_EVENT4_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT4_FIFO_ENABLE 1 $ip
            }
         }
         if { $num_slots > 5} {
            set ext5_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_5]]
            set ext5_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_5]]
            set ext5_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_5]]
        clk_chk $cellpath $core_clk $ext5_clk
            if { $core_clk !=0 && $ext5_clk !=0 && $core_clk == $ext5_clk &&  $core_clk_phase == $ext5_clk_phase
	        && $core_clk_domain == $ext5_clk_domain} {
               set_property CONFIG.C_EXT_EVENT5_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT5_FIFO_ENABLE 1 $ip
            }
         }
         if { $num_slots > 6} {
            set ext6_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_6]]
            set ext6_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_6]]
            set ext6_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_6]]
        clk_chk $cellpath $core_clk $ext6_clk
            if { $core_clk !=0 && $ext6_clk !=0 && $core_clk == $ext6_clk && $core_clk_phase == $ext6_clk_phase
	        && $core_clk_domain == $ext6_clk_domain} {
               set_property CONFIG.C_EXT_EVENT6_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT6_FIFO_ENABLE 1 $ip
            }
         }
         if { $num_slots > 7} {
            set ext7_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/ext_clk_7]]
            set ext7_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/ext_clk_7]]
            set ext7_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/ext_clk_7]]
        clk_chk $cellpath $core_clk $ext7_clk
            if { $core_clk !=0 && $ext7_clk !=0 && $core_clk == $ext7_clk && $core_clk_phase == $ext7_clk_phase
	         && $core_clk_domain == $ext7_clk_domain} {
               set_property CONFIG.C_EXT_EVENT7_FIFO_ENABLE 0 $ip
            } else {
               set_property CONFIG.C_EXT_EVENT7_FIFO_ENABLE 1 $ip
            }
         }
 
    }

    set slot0_protocol [get_property CONFIG.C_SLOT_0_AXI_PROTOCOL $ip]

    if { ($slot0_protocol == "AXI4" || $slot0_protocol == "AXI3" || $slot0_protocol == "AXI4LITE" ) && ($en_count == 1 || $en_log == 1 || $en_profile ==1 || $en_trace ==1) }  {
    
    # Slot0 AXI4 parameter propagations
    if { ($slot0_protocol == "AXI4LITE") } {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_0_AXI4LITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_0_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_0_AXI_ID_WIDTH $id_width $ip

    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_0_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_0_AXI_DATA_WIDTH $data_width $ip

    set slot0_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_0_axi_aclk]]
    set slot0_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_0_axi_aclk]]
    set slot0_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_0_axi_aclk]]
        clk_chk $cellpath $core_clk $slot0_aclk
         if { $core_clk !=0 && $slot0_aclk !=0 && $core_clk == $slot0_aclk && $core_clk_phase == $slot0_aclk_phase
	      && $core_clk_domain == $slot0_aclk_domain} {
            set_property CONFIG.C_SLOT_0_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_0_FIFO_ENABLE 1 $ip
         }
  
    } elseif { $en_count == 1 || $en_log == 1 } {
    
    # Slot0 AXI4S parameter propagations
    set intf_in [get_bd_intf_pins ${ip}/SLOT_0_AXIS]
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_0_AXIS_TID_WIDTH $tid_width $ip
    
    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_0_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_0_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot0_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_0_axis_aclk]]
    set slot0_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_0_axis_aclk]]
    set slot0_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_0_axis_aclk]]
        clk_chk $cellpath $core_clk $slot0_asclk
         if { $core_clk !=0 && $slot0_asclk !=0 && $core_clk == $slot0_asclk && $core_clk_phase == $slot0_asclk_phase 
	      && $core_clk_domain == $slot0_asclk_domain} {
            set_property CONFIG.C_SLOT_0_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_0_FIFO_ENABLE 1 $ip
         }
    } 

    set slot1_protocol [get_property CONFIG.C_SLOT_1_AXI_PROTOCOL $ip]

    if {$num_slots > 1 &&  ($slot1_protocol == "AXI4" || $slot1_protocol == "AXI3" || $slot1_protocol == "AXI4LITE" ) }  {
    
    # Slot1 AXI4 parameter propagations
    if { ($slot1_protocol == "AXI4LITE")} {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_1_AXI4LITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_1_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_1_AXI_ID_WIDTH $id_width $ip
    
    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_1_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_1_AXI_DATA_WIDTH $data_width $ip
  
    set slot1_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_1_axi_aclk]]
    set slot1_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_1_axi_aclk]]
    set slot1_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_1_axi_aclk]]
        clk_chk $cellpath $core_clk $slot1_aclk
        if { $core_clk !=0 && $slot1_aclk !=0 && $core_clk == $slot1_aclk && $core_clk_phase == $slot1_aclk_phase 
	     && $core_clk_domain == $slot1_aclk_domain} {
            set_property CONFIG.C_SLOT_1_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_1_FIFO_ENABLE 1 $ip
         }
    } elseif { $num_slots > 1 } {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_1_AXIS]
    # Slot1 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_1_AXIS_TID_WIDTH $tid_width $ip

    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_1_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_1_AXIS_TDEST_WIDTH $tdest_width $ip
 
    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_1_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot1_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_1_axis_aclk]]
    set slot1_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_1_axis_aclk]]
    set slot1_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_1_axis_aclk]]
        clk_chk $cellpath $core_clk $slot1_asclk
        if { $core_clk !=0 && $slot1_asclk !=0 && $core_clk == $slot1_asclk && $core_clk_phase == $slot1_asclk_phase
	     && $core_clk_domain == $slot1_asclk_domain} {
            set_property CONFIG.C_SLOT_1_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_1_FIFO_ENABLE 1 $ip
         }
    } 
    
    set slot2_protocol [get_property CONFIG.C_SLOT_2_AXI_PROTOCOL $ip]

    if {$num_slots > 2 &&  ($slot2_protocol == "AXI4" || $slot2_protocol == "AXI3" || $slot2_protocol == "AXI4LITE" )}  {
    
    # Slot2 AXI4 parameter propagations
    if { ($slot2_protocol == "AXI4LITE")} {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_2_AXI4LITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_2_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_2_AXI_ID_WIDTH $id_width $ip
    
    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_2_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_2_AXI_DATA_WIDTH $data_width $ip
  
    set slot2_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_2_axi_aclk]]
    set slot2_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_2_axi_aclk]]
    set slot2_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_2_axi_aclk]]
        clk_chk $cellpath $core_clk $slot2_aclk
        if { $core_clk !=0 && $slot2_aclk !=0 && $core_clk == $slot2_aclk && $core_clk_phase == $slot2_aclk_phase
	     && $core_clk_domain == $slot2_aclk_domain} {
            set_property CONFIG.C_SLOT_2_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_2_FIFO_ENABLE 1 $ip
         }
    } elseif { $num_slots > 2 } {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_2_AXIS]
    # Slot2 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_2_AXIS_TID_WIDTH $tid_width $ip

    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_2_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_2_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_2_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot2_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_2_axis_aclk]]
    set slot2_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_2_axis_aclk]]
    set slot2_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_2_axis_aclk]]
        clk_chk $cellpath $core_clk $slot2_asclk
        if { $core_clk !=0 && $slot2_asclk !=0 && $core_clk == $slot2_asclk && $core_clk_phase == $slot2_asclk_phase
	     && $core_clk_domain == $slot2_asclk_domain} {
            set_property CONFIG.C_SLOT_2_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_2_FIFO_ENABLE 1 $ip
         }
    } 

   set slot3_protocol [get_property CONFIG.C_SLOT_3_AXI_PROTOCOL $ip]

    if {$num_slots > 3 &&  ($slot3_protocol == "AXI4" || $slot3_protocol == "AXI3" || $slot3_protocol == "AXI4LITE" )}  {
    
    # Slot3 AXI4 parameter propagations
    if { ($slot3_protocol == "AXI4LITE")} {
     set intf_in [get_bd_intf_pins ${ip}/SLOT_3_AXI4LITE]
    } else {
     set intf_in [get_bd_intf_pins ${ip}/SLOT_3_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_3_AXI_ID_WIDTH $id_width $ip
    
    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_3_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_3_AXI_DATA_WIDTH $data_width $ip
  
    set slot3_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_3_axi_aclk]]
    set slot3_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_3_axi_aclk]]
    set slot3_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_3_axi_aclk]]
        clk_chk $cellpath $core_clk $slot3_aclk
        if { $core_clk !=0 && $slot3_aclk !=0 && $core_clk == $slot3_aclk && $core_clk_phase == $slot3_aclk_phase
	     && $core_clk_domain == $slot3_aclk_domain} {
            set_property CONFIG.C_SLOT_3_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_3_FIFO_ENABLE 1 $ip
         }
    } elseif { $num_slots > 3 } {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_3_AXIS]
    # Slot3 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_3_AXIS_TID_WIDTH $tid_width $ip
    
    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_3_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_3_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_3_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot3_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_3_axis_aclk]]
    set slot3_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_3_axis_aclk]]
    set slot3_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_3_axis_aclk]]
        clk_chk $cellpath $core_clk $slot3_asclk
        if { $core_clk !=0 && $slot3_asclk !=0 && $core_clk == $slot3_asclk && $core_clk_phase == $slot3_asclk_phase
	    && $core_clk_domain == $slot3_asclk_domain} {
            set_property CONFIG.C_SLOT_3_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_3_FIFO_ENABLE 1 $ip
         }
    } 
 
    set slot4_protocol [get_property CONFIG.C_SLOT_4_AXI_PROTOCOL $ip]

    if {$num_slots > 4 &&  ($slot4_protocol == "AXI4" || $slot4_protocol == "AXI3" || $slot4_protocol == "AXI4LITE" )}  {
    
    # Slot4 AXI4 parameter propagations
    if { ($slot4_protocol == "AXI4LITE")} {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_4_AXI4LITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_4_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_4_AXI_ID_WIDTH $id_width $ip

    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_4_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_4_AXI_DATA_WIDTH $data_width $ip
  
    set slot4_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_4_axi_aclk]]
    set slot4_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_4_axi_aclk]]
    set slot4_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_4_axi_aclk]]
        clk_chk $cellpath $core_clk $slot4_aclk
        if { $core_clk !=0 && $slot4_aclk !=0 && $core_clk == $slot4_aclk && $core_clk_phase == $slot4_aclk_phase
	     && $core_clk_domain == $slot4_aclk_domain} {
            set_property CONFIG.C_SLOT_4_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_4_FIFO_ENABLE 1 $ip
         }
    } elseif {$num_slots > 4} {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_4_AXIS]
    # Slot4 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_4_AXIS_TID_WIDTH $tid_width $ip
 
    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_4_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_4_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_4_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot4_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_4_axis_aclk]]
    set slot4_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_4_axis_aclk]]
    set slot4_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_4_axis_aclk]]
        clk_chk $cellpath $core_clk $slot4_asclk
        if { $core_clk !=0 && $slot4_asclk !=0 && $core_clk == $slot4_asclk && $core_clk_phase == $slot4_asclk_phase
	     && $core_clk_domain == $slot4_asclk_domain} {
            set_property CONFIG.C_SLOT_4_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_4_FIFO_ENABLE 1 $ip
         }
    } 

    set slot5_protocol [get_property CONFIG.C_SLOT_5_AXI_PROTOCOL $ip]

    if {$num_slots > 5 &&  ($slot5_protocol == "AXI4" || $slot5_protocol == "AXI3" || $slot5_protocol == "AXI4LITE" )}  {
    
    # Slot5 AXI4 parameter propagations
    if { ($slot5_protocol == "AXI4LITE")} {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_5_AXI4LITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_5_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_5_AXI_ID_WIDTH $id_width $ip

    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_5_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_5_AXI_DATA_WIDTH $data_width $ip
  
    set slot5_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_5_axi_aclk]]
    set slot5_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_5_axi_aclk]]
    set slot5_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_5_axi_aclk]]
        clk_chk $cellpath $core_clk $slot5_aclk
        if { $core_clk !=0 && $slot5_aclk !=0 && $core_clk == $slot5_aclk && $core_clk_phase == $slot5_aclk_phase
	     && $core_clk_domain == $slot5_aclk_domain} {
            set_property CONFIG.C_SLOT_5_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_5_FIFO_ENABLE 1 $ip
         }

    } elseif {$num_slots > 5} {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_5_AXIS]
    # Slot5 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_5_AXIS_TID_WIDTH $tid_width $ip
    
    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_5_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_5_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_5_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot5_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_5_axis_aclk]]
    set slot5_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_5_axis_aclk]]
    set slot5_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_5_axis_aclk]]
        clk_chk $cellpath $core_clk $slot5_asclk
        if { $core_clk !=0 && $slot5_asclk !=0 && $core_clk == $slot5_asclk && $core_clk_phase == $slot5_asclk_phase
	     && $core_clk_domain == $slot5_asclk_domain} {
            set_property CONFIG.C_SLOT_5_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_5_FIFO_ENABLE 1 $ip
         }
    } 

   set slot6_protocol [get_property CONFIG.C_SLOT_6_AXI_PROTOCOL $ip]

    if {$num_slots > 6 &&  ($slot6_protocol == "AXI4" || $slot6_protocol == "AXI3" || $slot6_protocol == "AXI4LITE" )}  {
    
    # Slot6 AXI4 parameter propagations
    if { ($slot6_protocol == "AXI4LITE")} {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_6_AXI4LITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_6_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_6_AXI_ID_WIDTH $id_width $ip
    
    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_6_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_6_AXI_DATA_WIDTH $data_width $ip
  
    set slot6_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_6_axi_aclk]]
    set slot6_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_6_axi_aclk]]
    set slot6_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_6_axi_aclk]]
        clk_chk $cellpath $core_clk $slot6_aclk
        if { $core_clk !=0 && $slot6_aclk !=0 && $core_clk == $slot6_aclk && $core_clk_phase == $slot6_aclk_phase
	     && $core_clk_domain == $slot6_aclk_domain} {
            set_property CONFIG.C_SLOT_6_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_6_FIFO_ENABLE 1 $ip
         }

    } elseif {$num_slots > 6} {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_6_AXIS]
    # Slot6 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_6_AXIS_TID_WIDTH $tid_width $ip
    
    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_6_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_6_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_6_AXIS_TUSER_WIDTH $tuser_width $ip

    set slot6_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_6_axis_aclk]]
    set slot6_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_6_axis_aclk]]
    set slot6_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_6_axis_aclk]]
        clk_chk $cellpath $core_clk $slot6_asclk
        if { $core_clk !=0 && $slot6_asclk !=0 && $core_clk == $slot6_asclk && $core_clk_phase == $slot6_asclk_phase 
	    && $core_clk_domain == $slot6_asclk_domain} {
            set_property CONFIG.C_SLOT_6_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_6_FIFO_ENABLE 1 $ip
         }

    } 

    set slot7_protocol [get_property CONFIG.C_SLOT_7_AXI_PROTOCOL $ip]

    if {$num_slots > 7 &&  ($slot7_protocol == "AXI4" || $slot7_protocol == "AXI3" || $slot7_protocol == "AXI4LITE" )}  {
    
    # Slot7 AXI4 parameter propagations
    if { ($slot7_protocol == "AXI4LITE")} {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_7_AXI4lITE]
    } else {
      set intf_in [get_bd_intf_pins ${ip}/SLOT_7_AXI]
    }
    set id_width [get_property CONFIG.ID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_7_AXI_ID_WIDTH $id_width $ip
 
    set addr_width [get_property CONFIG.ADDR_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_7_AXI_ADDR_WIDTH $addr_width $ip

    set data_width [get_property CONFIG.DATA_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_7_AXI_DATA_WIDTH $data_width $ip
  
    set slot7_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_7_axi_aclk]]
    set slot7_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_7_axi_aclk]]
    set slot7_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_7_axi_aclk]]
        clk_chk $cellpath $core_clk $slot7_aclk
        if { $core_clk !=0 && $slot7_aclk !=0 && $core_clk == $slot7_aclk && $core_clk_phase == $slot7_aclk_phase
	     && $core_clk_domain == $slot7_aclk_domain} {
            set_property CONFIG.C_SLOT_7_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_7_FIFO_ENABLE 1 $ip
         }
    } elseif {$num_slots > 7} {
    
    set intf_in [get_bd_intf_pins ${ip}/SLOT_7_AXIS]
    # Slot7 AXI4S parameter propagations
    set tid_width [get_property CONFIG.TID_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_7_AXIS_TID_WIDTH $tid_width $ip
    
    set tbyte [get_property CONFIG.TDATA_NUM_BYTES $intf_in]
    set tdata_width [expr $tbyte*8] 
    set_property CONFIG.C_SLOT_7_AXIS_TDATA_WIDTH $tdata_width $ip

    set tdest_width [get_property CONFIG.TDEST_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_7_AXIS_TDEST_WIDTH $tdest_width $ip

    set tuser_width [get_property CONFIG.TUSER_WIDTH $intf_in]
    set_property CONFIG.C_SLOT_7_AXIS_TUSER_WIDTH $tuser_width $ip


    set slot7_asclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/slot_7_axis_aclk]]
    set slot7_asclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/slot_7_axis_aclk]]
    set slot7_asclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/slot_7_axis_aclk]]
        clk_chk $cellpath $core_clk $slot7_asclk
        if { $core_clk !=0 && $slot7_asclk !=0 && $core_clk == $slot7_asclk && $core_clk_phase == $slot7_asclk_phase
	     && $core_clk_domain == $slot7_asclk_domain} {
            set_property CONFIG.C_SLOT_7_FIFO_ENABLE 0 $ip
         } else {
            set_property CONFIG.C_SLOT_7_FIFO_ENABLE 1 $ip
         }
    } 
 
}





