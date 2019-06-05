namespace eval axi_perf_mon_v5_0_utils {

  proc upgrade_from_axi_perf_mon_v2_00_a {XcoName} {

       upvar $XcoName xco
       namespace import ::xcoUpgradeLib::*
       removeParameter C_MAX_OUTSTAND_DEPTH xco
       removeParameter C_METRICS_SAMPLE_COUNT_WIDTH xco
       removeParameter C_MAX_REORDER_DEPTH xco
       removeParameter C_FIFO_AXIS_TDATA_WIDTH xco
       addParameter C_S_AXI_ID_WIDTH 1 xco
       addParameter C_ENABLE_ADVANCED 1 xco
       addParameter C_METRIC_COUNT_SCALE 1 xco
       addParameter C_SUPPORT_ID_REFLECTION 0 xco
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_0_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_0_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_1_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_1_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_2_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_2_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_3_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_3_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_4_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_4_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_5_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_5_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_6_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_6_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_7_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_7_AXI_PROTOCOL "AXI4" xco 
       }
       return
     }


  proc upgrade_from_axi_perf_mon_v2_01_a {XcoName} {

       upvar $XcoName xco
       namespace import ::xcoUpgradeLib::*
       removeParameter C_FIFO_AXIS_TDATA_WIDTH xco
       addParameter C_S_AXI_ID_WIDTH 1 xco
       removeParameter C_METRICS_SAMPLE_COUNT_WIDTH xco
       removeParameter C_MAX_REORDER_DEPTH xco
       removeParameter C_MAX_OUTSTAND_DEPTH xco
       addParameter C_ENABLE_ADVANCED 1 xco
       addParameter C_METRIC_COUNT_SCALE 1 xco
       addParameter C_SUPPORT_ID_REFLECTION 0 xco
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_0_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_0_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_1_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_1_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_2_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_2_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_3_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_3_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_4_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_4_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_5_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_5_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_6_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_6_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_7_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_7_AXI_PROTOCOL "AXI4" xco 
       }
       return
     }

  proc upgrade_from_axi_perf_mon_v3_00_a {XcoName} {

       upvar $XcoName xco
       namespace import ::xcoUpgradeLib::*
       addParameter C_S_AXI_ID_WIDTH 1 xco
       removeParameter C_METRICS_SAMPLE_COUNT_WIDTH xco
       removeParameter C_MAX_REORDER_DEPTH xco
       removeParameter C_MAX_OUTSTAND_DEPTH xco
       addParameter C_ENABLE_ADVANCED 1 xco
       addParameter C_METRIC_COUNT_SCALE 1 xco
       addParameter C_SUPPORT_ID_REFLECTION 0 xco
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_0_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_0_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_1_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_1_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_2_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_2_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_3_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_3_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_4_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_4_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_5_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_5_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_6_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_6_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_7_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_7_AXI_PROTOCOL "AXI4" xco 
       }
       return
     }
  
  proc upgrade_from_axi_perf_mon_v4_0 {XcoName} {

       upvar $XcoName xco
       namespace import ::xcoUpgradeLib::*
       removeParameter C_METRICS_SAMPLE_COUNT_WIDTH xco
       removeParameter C_MAX_REORDER_DEPTH xco
       removeParameter C_MAX_OUTSTAND_DEPTH xco
       addParameter C_ENABLE_ADVANCED 1 xco
       addParameter C_METRIC_COUNT_SCALE 1 xco
       addParameter C_SUPPORT_ID_REFLECTION 0 xco
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_0_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_0_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_1_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_1_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_2_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_2_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_3_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_3_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_4_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_4_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_5_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_5_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_6_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_6_AXI_PROTOCOL "AXI4" xco 
       }
       if { [string equal -nocase "AXI4MM" [getParameter C_SLOT_7_AXI_PROTOCOL xco]] } {
            setParameter C_SLOT_7_AXI_PROTOCOL "AXI4" xco 
       }
       return
     }

}



