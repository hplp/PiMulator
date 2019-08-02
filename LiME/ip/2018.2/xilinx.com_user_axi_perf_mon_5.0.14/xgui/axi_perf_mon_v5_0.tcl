proc EvalSubstituting {parameters procedure {numlevels 1}} {
    set paramlist {}
    if {[string index $numlevels 0]!="#"} {
        set numlevels [expr $numlevels+1]
    }
    foreach parameter $parameters {
        upvar 1 $parameter $parameter\_value
        tcl::lappend paramlist \$$parameter [set $parameter\_value]
    }
    uplevel $numlevels [string map $paramlist $procedure]
}

#Definitional proc to organize widgets for parameters.
set c_family [string tolower [get_project_property ARCHITECTURE]]
proc init_gui { IPINST } {
        variable c_family
#set_property ip_complexity "medium" [ipgui::get_canvasspec -of $IPINST]
	set Component_Name [ ipgui::add_param  $IPINST  -parent  $IPINST -name Component_Name ]
	set Page0     [ ipgui::add_page $IPINST -parent $IPINST  -name "Basic" -layout vertical]
	set Page1     [ ipgui::add_page $IPINST -parent $IPINST -name "Monitor Interfaces(0-3)" -layout horizontal]
	set Page2     [ ipgui::add_page $IPINST -parent $IPINST -name "Monitor Interfaces(4-7)" -layout horizontal]
	set Page3     [ ipgui::add_page $IPINST -parent $IPINST -name "Log Parameters" -layout vertical]
	set SlotPage0 [ ipgui::add_group $IPINST -parent $Page1  -name "Slot 0" -layout horizontal]
	set SlotPage1 [ ipgui::add_group $IPINST -parent $Page1  -name "Slot 1" -layout horizontal]
    ipgui::add_row $IPINST -parent $Page1
	set SlotPage2 [ ipgui::add_group $IPINST -parent $Page1 -name "Slot 2" -layout horizontal]
	set SlotPage3 [ ipgui::add_group $IPINST -parent $Page1 -name "Slot 3" -layout horizontal]
	set SlotPage4 [ ipgui::add_group $IPINST -parent $Page2 -name "Slot 4" -layout horizontal]
	set SlotPage5 [ ipgui::add_group $IPINST -parent $Page2  -name "Slot 5" -layout horizontal]
    ipgui::add_row $IPINST -parent $Page2
	set SlotPage6 [ ipgui::add_group  $IPINST -parent $Page2 -name "Slot 6" -layout horizontal]
	set SlotPage7 [ ipgui::add_group $IPINST -parent $Page2  -name "Slot 7" -layout horizontal]
	#set panel1 [ipgui::add_panel $IPINST -parent $Page0 -name panel1]
    set tabgroup7 [ipgui::add_group $IPINST -parent $Page0 -name {APM Modes} -layout horizontal] 
        set C_ENABLE_ADVANCED [ipgui::add_param $IPINST -parent $tabgroup7 -name C_ENABLE_ADVANCED -widget checkBox]
        set_property tooltip "Enables the Advanced Mode with flexible user configuration for event couting/logging" $C_ENABLE_ADVANCED
        set C_ENABLE_PROFILE [ipgui::add_param $IPINST -parent $tabgroup7 -name C_ENABLE_PROFILE -widget checkBox]
        set_property tooltip "Enables the Profile Mode with lesser user configuration for event counting" $C_ENABLE_PROFILE
        set C_ENABLE_TRACE [ipgui::add_param $IPINST -parent $tabgroup7 -name C_ENABLE_TRACE -widget checkBox]
        set_property tooltip "Enables the Trace Mode with lesser user configuration for event logging" $C_ENABLE_TRACE
    set tabgroup0 [ipgui::add_group $IPINST -parent $Page0 -name {Functional Parameters} -layout horizontal] 
        set C_ENABLE_EVENT_COUNT [ipgui::add_param $IPINST -parent $tabgroup0 -name C_ENABLE_EVENT_COUNT -widget checkBox]
        set_property tooltip "Enables the AXI4/AXI4-Stream/External Event counters for different metrics" $C_ENABLE_EVENT_COUNT
	set C_ENABLE_EVENT_LOG [ipgui::add_param $IPINST -parent $tabgroup0 -name C_ENABLE_EVENT_LOG -widget checkBox]
	ipgui::add_row $IPINST -parent $tabgroup0
        set_property tooltip "Enables the event logging of AXI4/AXI4-Stream/External Events along with timestamp" $C_ENABLE_EVENT_LOG
	set ENABLE_EXT_TRIGGERS [ipgui::add_param $IPINST -parent $tabgroup0 -name ENABLE_EXT_TRIGGERS -widget checkBox]
        set_property tooltip "Enables the external triggers to start and stop the Event counters/Event logging" $ENABLE_EXT_TRIGGERS 
	set C_REG_ALL_MONITOR_SIGNALS [ipgui::add_param $IPINST -parent $tabgroup0 -name C_REG_ALL_MONITOR_SIGNALS -widget checkBox]
        set_property tooltip "Enabling registers the AXI4/AXI4-Stream/External Event monitor interface signals with the corresponding interface clock" $C_REG_ALL_MONITOR_SIGNALS
	set_property display_name "Register Monitor Signals " $C_REG_ALL_MONITOR_SIGNALS
	ipgui::add_row $IPINST -parent $tabgroup0
	set C_NUM_MONITOR_SLOTS [ipgui::add_param $IPINST -parent $tabgroup0 -name C_NUM_MONITOR_SLOTS -widget comboBox]
        set_property tooltip "Number of AXI4/AXI4-Stream and external event slots to be monitored for the event counts and event logging " $C_NUM_MONITOR_SLOTS
	set_property display_name "Number of Monitor interfaces " $C_NUM_MONITOR_SLOTS
    #set tabgroup1 [ipgui::add_group $IPINST -parent $Page0 -name {AXI4LITE Register Interface Parameters} -layout horizontal] 
	ipgui::add_row $IPINST -parent $tabgroup0
        set C_AXI4LITE_CORE_CLK_ASYNC [ipgui::add_param $IPINST -parent $tabgroup0 -name C_AXI4LITE_CORE_CLK_ASYNC -widget checkBox]
        set_property visible false [ipgui::get_guiparamspec -name C_AXI4LITE_CORE_CLK_ASYNC -of $IPINST]
        set_property tooltip "Enabling synchronizes the AXI4Lite and Core clock interface signals" $C_AXI4LITE_CORE_CLK_ASYNC
	#ipgui::add_row $IPINST -parent $tabgroup1
	set C_SUPPORT_ID_REFLECTION [ipgui::add_param $IPINST -parent $tabgroup0 -name C_SUPPORT_ID_REFLECTION -widget checkBox]
	set COUNTER_LOAD_VALUE [ipgui::add_param $IPINST -parent $tabgroup0 -name COUNTER_LOAD_VALUE -widget comboBox]
	set C_S_AXI_ID_WIDTH [ipgui::add_param $IPINST -parent $tabgroup0 -name C_S_AXI_ID_WIDTH -widget comboBox]
 
        set_property visible false [ipgui::get_guiparamspec -name C_SUPPORT_ID_REFLECTION -of $IPINST]
        set_property visible false [ipgui::get_guiparamspec -name COUNTER_LOAD_VALUE -of $IPINST]
        set_property visible false [ipgui::get_guiparamspec -name C_S_AXI_ID_WIDTH -of $IPINST]
    set tabgroup2 [ipgui::add_group $IPINST -parent $Page0 -name {Event Count Parameters} -layout horizontal] 
	#set C_ENABLE_EVENT_COUNT [ipgui::add_param $IPINST -parent $tabgroup2 -name C_ENABLE_EVENT_COUNT -widget checkBox]
	
	#set C_ENABLE_EVENT_LOG [ipgui::add_param $IPINST -parent $tabgroup2 -name C_ENABLE_EVENT_LOG -widget checkBox]
	#ipgui::add_row $IPINST -parent $tabgroup2
	set C_NUM_OF_COUNTERS [ipgui::add_param $IPINST -parent $tabgroup2 -name C_NUM_OF_COUNTERS -widget comboBox]
        set_property tooltip "Number of event counters to capture the AXI4/AXI4-Stream/External Event metrics" $C_NUM_OF_COUNTERS
	set_property display_name "Number Of Event Counters " $C_NUM_OF_COUNTERS
	ipgui::add_row $IPINST -parent $tabgroup2
	set C_METRIC_COUNT_SCALE [ipgui::add_param $IPINST -parent $tabgroup2 -name C_METRIC_COUNT_SCALE -widget comboBox]
        set_property tooltip "Scaling Factor which divides the actual metric and provides in Metric Counters" $C_METRIC_COUNT_SCALE
	ipgui::add_row $IPINST -parent $tabgroup2
	set C_HAVE_SAMPLED_METRIC_CNT [ipgui::add_param $IPINST -parent $tabgroup2 -name C_HAVE_SAMPLED_METRIC_CNT -widget comboBox]	
	set_property display_name "Enable Sampled Event Counters" $C_HAVE_SAMPLED_METRIC_CNT 
        set_property tooltip "Enabling loads the event counter values into sampled event counters after the time loaded in sample interval counter" $C_HAVE_SAMPLED_METRIC_CNT
	#ipgui::add_row $IPINST -parent $tabgroup2
	#set C_NUM_OF_COUNTERS [ipgui::add_param $IPINST -parent $tabgroup2 -name C_NUM_OF_COUNTERS]
	#set C_MAX_REORDER_DEPTH [ipgui::add_param $IPINST -parent $tabgroup2 -name C_MAX_REORDER_DEPTH]
	#set C_MAX_OUTSTAND_DEPTH [ipgui::add_param $IPINST -parent $tabgroup2 -name C_MAX_OUTSTAND_DEPTH]
        #ipgui::add_row $IPINST -parent $tabgroup2
	#set C_METRICS_SAMPLE_COUNT_WIDTH [ipgui::add_param $IPINST -parent $tabgroup2 -name C_METRICS_SAMPLE_COUNT_WIDTH -widget comboBox]
        #set_property tooltip "Width of sample interval counter to load the time to sample event counts" $C_METRICS_SAMPLE_COUNT_WIDTH
        ipgui::add_row $IPINST -parent $tabgroup2
	set C_GLOBAL_COUNT_WIDTH [ipgui::add_param $IPINST -parent $tabgroup2 -name C_GLOBAL_COUNT_WIDTH -widget comboBox]
        set_property tooltip "Width of Global clock counter to know the runtime" $C_GLOBAL_COUNT_WIDTH
    set tabgroup3 [ipgui::add_group $IPINST -parent $Page0 -name {External Event Parameters} -layout horizontal] 
	set ENABLE_EXT_EVENTS [ipgui::add_param $IPINST -parent $tabgroup3 -name ENABLE_EXT_EVENTS -widget checkBox]
        set_property tooltip "Enables the external events to count the number of external events occured in between start and stop and to log the events along with their own start and stop signals" $ENABLE_EXT_EVENTS
	ipgui::add_row $IPINST -parent $tabgroup3
	set C_EXT_EVENT0_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT0_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface0 clock and core clock are different to use Async FIFO" $C_EXT_EVENT0_FIFO_ENABLE
	set C_EXT_EVENT1_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT1_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface1 clock and core clock are different to use Async FIFO" $C_EXT_EVENT1_FIFO_ENABLE
	ipgui::add_row $IPINST -parent $tabgroup3
	set C_EXT_EVENT2_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT2_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface2 clock and core clock are different to use Async FIFO" $C_EXT_EVENT2_FIFO_ENABLE
	set C_EXT_EVENT3_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT3_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface3 clock and core clock are different to use Async FIFO" $C_EXT_EVENT3_FIFO_ENABLE
	ipgui::add_row $IPINST -parent $tabgroup3
	set C_EXT_EVENT4_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT4_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface4 clock and core clock are different to use Async FIFO" $C_EXT_EVENT4_FIFO_ENABLE
	set C_EXT_EVENT5_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT5_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface5 clock and core clock are different to use Async FIFO" $C_EXT_EVENT5_FIFO_ENABLE
	ipgui::add_row $IPINST -parent $tabgroup3
	set C_EXT_EVENT6_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT6_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface6 clock and core clock are different to use Async FIFO" $C_EXT_EVENT6_FIFO_ENABLE
	set C_EXT_EVENT7_FIFO_ENABLE [ipgui::add_param $IPINST -parent $tabgroup3 -name C_EXT_EVENT7_FIFO_ENABLE -widget checkBox]
        set_property tooltip "It has to be enabled when external interface7 clock and core clock are different to use Async FIFO" $C_EXT_EVENT7_FIFO_ENABLE
	
		# set panel4 [ipgui::add_panel $IPINST -parent $Page0 -name panel4 -layout vertical]
	#set C_GLOBAL_COUNT_WIDTH [ipgui::add_param $IPINST -parent $panel4 -name C_GLOBAL_COUNT_WIDTH -widget comboBox]
	
	# Page 1
	
	# set tabgroup2 [ipgui::add_group $IPINST -parent $Page3 -name {Event Log Parameters} -layout vertical] 
	
	#set panel2 [ipgui::add_panel $IPINST -parent $Page3 -name panel2]
     #set tabgroup4pre [ipgui::add_group $IPINST -parent $Page3 -name {Event Log  Offload Protocol} -layout horizontal] 
        set C_LOG_DATA_OFFLD [ipgui::add_param $IPINST -parent $Page3 -name C_LOG_DATA_OFFLD -widget radioGroup -layout horizontal]
        set_property tooltip "Select protocol to offload log data from core." $C_LOG_DATA_OFFLD
        set_property visible false [ipgui::get_guiparamspec -name C_LOG_DATA_OFFLD -of $IPINST]
     set tabgroup4 [ipgui::add_group $IPINST -parent $Page3 -name {Event Log  Streaming FIFO Parameters} -layout horizontal] 
	 set panel3 [ipgui::add_panel $IPINST -parent $tabgroup4 -name panel3 -layout horizontal]
        set C_FIFO_AXIS_SYNC [ipgui::add_param $IPINST -parent $panel3 -name C_FIFO_AXIS_SYNC -widget checkBox]
        set_property tooltip "It has to be enabled when event log streaming clock and core clock are synchronous" $C_FIFO_AXIS_SYNC
	ipgui::add_row $IPINST -parent $tabgroup4
	set C_FIFO_AXIS_DEPTH [ipgui::add_param $IPINST -parent $tabgroup4 -name C_FIFO_AXIS_DEPTH]
        set_property tooltip "Event Log streaming FIFO depth" $C_FIFO_AXIS_DEPTH
	set C_FIFO_AXIS_TID_WIDTH [ipgui::add_param $IPINST -parent $tabgroup4 -name C_FIFO_AXIS_TID_WIDTH -widget comboBox]
        set_property tooltip "Event Log streaming FIFO ID width" $C_FIFO_AXIS_TID_WIDTH
	set S_AXI_OFFLD_ID_WIDTH [ipgui::add_param $IPINST -parent $tabgroup4 -name S_AXI_OFFLD_ID_WIDTH -widget comboBox]
        set_property tooltip "Event Log AXI-MM ID width" $S_AXI_OFFLD_ID_WIDTH
	ipgui::add_row $IPINST -parent $tabgroup4
#	set C_FIFO_AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -parent $tabgroup4 -name C_FIFO_AXIS_TDATA_WIDTH]

	set_property display_name "Use Synchronous FIFO" $C_FIFO_AXIS_SYNC
	set_property display_name "Log Data offload Protocol" $C_LOG_DATA_OFFLD
	set_property display_name "Depth" $C_FIFO_AXIS_DEPTH
#	set_property display_name "TData Width" $C_FIFO_AXIS_TDATA_WIDTH
	set_property display_name "TID Width" $C_FIFO_AXIS_TID_WIDTH
        
        set tabgroup5 [ipgui::add_group $IPINST -parent $Page3 -name {AXI4 Monitor Slots Parameters} -layout horizontal] 
       #set panel3 [ipgui::add_panel $IPINST -parent $Page3 -name panel3 -layout horizontal]
        set C_EN_WR_ADD_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_WR_ADD_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 Write address Flags in Log" $C_EN_WR_ADD_FLAG
        set C_EN_FIRST_WRITE_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_FIRST_WRITE_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 First Write Flags in Log" $C_EN_FIRST_WRITE_FLAG
	ipgui::add_row $IPINST -parent $tabgroup5
        set C_EN_LAST_WRITE_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name  C_EN_LAST_WRITE_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 Last Write Flags in Log" $C_EN_LAST_WRITE_FLAG
        set C_EN_RESPONSE_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_RESPONSE_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 Write response Flags in Log" $C_EN_RESPONSE_FLAG 
	ipgui::add_row $IPINST -parent $tabgroup5
        set C_EN_RD_ADD_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_RD_ADD_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 read address Flags in Log" $C_EN_RD_ADD_FLAG 
        set C_EN_FIRST_READ_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_FIRST_READ_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 first read Flags in Log" $C_EN_FIRST_READ_FLAG 
	ipgui::add_row $IPINST -parent $tabgroup5
        set C_EN_LAST_READ_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_LAST_READ_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 Last read Flags in Log" $C_EN_LAST_READ_FLAG 
        set C_EN_SW_REG_WR_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_SW_REG_WR_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the SW register write data in Log" $C_EN_SW_REG_WR_FLAG 
	ipgui::add_row $IPINST -parent $tabgroup5
        set C_SHOW_AXI_IDS [ipgui::add_param $IPINST -parent $tabgroup5 -name C_SHOW_AXI_IDS -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 Interface slots AWID, BID, ARID and RID signals into the Event Log data" $C_SHOW_AXI_IDS
        set C_SHOW_AXI_LEN [ipgui::add_param $IPINST -parent $tabgroup5 -name C_SHOW_AXI_LEN -widget checkBox]
        set_property tooltip "Enabling captures the AXI4 Interface slots AWLEN, ARLEN signals into the Event Log data" $C_SHOW_AXI_LEN
	ipgui::add_row $IPINST -parent $tabgroup5
        set C_EN_EXT_EVENTS_FLAG [ipgui::add_param $IPINST -parent $tabgroup5 -name C_EN_EXT_EVENTS_FLAG -widget checkBox]
        set_property tooltip "Enabling captures the external events data in Log" $C_EN_EXT_EVENTS_FLAG 

        set tabgroup6 [ipgui::add_group $IPINST -parent $Page3 -name {AXI4 Stream Monitor Slots Parameters} -layout horizontal] 
	#set panel4 [ipgui::add_panel $IPINST -parent $Page3 -name panel4 -layout horizontal]
	set C_SHOW_AXIS_TDEST [ipgui::add_param $IPINST -parent $tabgroup6 -name C_SHOW_AXIS_TDEST -widget checkBox]
        set_property tooltip "Enabling captures the AXI4-Stream Interface slots TDEST signals into the Event Log data" $C_SHOW_AXIS_TDEST
	ipgui::add_row $IPINST -parent $tabgroup6
	set C_SHOW_AXIS_TID [ipgui::add_param $IPINST -parent $tabgroup6 -name C_SHOW_AXIS_TID -widget checkBox]
        set_property tooltip "Enabling captures the AXI4-Stream Interface slots TID signals into the Event Log data" $C_SHOW_AXIS_TDEST
	ipgui::add_row $IPINST -parent $tabgroup6
        set C_SHOW_AXIS_TUSER [ipgui::add_param $IPINST -parent $tabgroup6 -name C_SHOW_AXIS_TUSER -widget checkBox]
        set_property tooltip "Enabling captures the AXI4-Stream Interface slots TUSER signals into the Event Log data" $C_SHOW_AXIS_TDEST
		
	set_property display_name "Enable ID's In Log Data" $C_SHOW_AXI_IDS
	set_property display_name "Enable Transaction Length in Log Data" $C_SHOW_AXI_LEN
	set_property display_name "Enable TDEST in Log Data" $C_SHOW_AXIS_TDEST
	set_property display_name "Enable TID In Log Data" $C_SHOW_AXIS_TID
	set_property display_name "Enable TUSER In Log Data" $C_SHOW_AXIS_TUSER
	
	foreach sync {0 1 2 3 4 5 6 7 } {
	EvalSubstituting {sync} {
		set C_SLOT_0_AXI_PROTOCOL [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXI_PROTOCOL -widget comboBox ]
		ipgui::add_row $IPINST -parent $SlotPage$sync
		#ipgui::add_indent $IPINST -parent $SlotPage$sync
		set C_SLOT_0_FIFO_ENABLE [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_FIFO_ENABLE -widget comboBox]
	        #set_property display_name "Synchronizer" $C_SLOT_0_FIFO_ENABLE
		ipgui::add_row $IPINST -parent $SlotPage$sync
		set C_SLOT_0_AXIS_TUSER_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXIS_TUSER_WIDTH -widget comboBox]
		ipgui::add_row $IPINST -parent $SlotPage$sync
		set C_SLOT_0_AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXIS_TDATA_WIDTH -widget comboBox]
		ipgui::add_row $IPINST -parent $SlotPage$sync
		set C_SLOT_0_AXIS_TID_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXIS_TID_WIDTH -widget comboBox]
		ipgui::add_row $IPINST -parent $SlotPage$sync
		set C_SLOT_0_AXIS_TDEST_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXIS_TDEST_WIDTH -widget comboBox]
		ipgui::add_row $IPINST -parent $SlotPage$sync
 		set C_SLOT_0_AXI_ID_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXI_ID_WIDTH -widget comboBox]
		ipgui::add_row $IPINST -parent $SlotPage$sync
		set C_SLOT_0_AXI_DATA_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXI_DATA_WIDTH -widget comboBox]
		ipgui::add_row $IPINST -parent $SlotPage$sync
		set C_SLOT_0_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -parent $SlotPage$sync -name C_SLOT_$sync_AXI_ADDR_WIDTH -widget comboBox]
		} 0
	}
}

proc validate_PARAM_VALUE.C_SLOT_3_FIFO_ENABLE { PARAM_VALUE.C_SLOT_3_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_3_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_NUM_OF_COUNTERS { PARAM_VALUE.C_NUM_OF_COUNTERS} {

	# Procedure called to validate C_NUM_OF_COUNTERS
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_3_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_SHOW_AXIS_TUSER { PARAM_VALUE.C_SHOW_AXIS_TUSER} {

	# Procedure called to validate C_SHOW_AXIS_TUSER
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_FIFO_ENABLE { PARAM_VALUE.C_SLOT_5_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_5_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_FIFO_AXIS_TID_WIDTH { PARAM_VALUE.C_FIFO_AXIS_TID_WIDTH} {

	# Procedure called to validate C_FIFO_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EN_LAST_WRITE_FLAG { PARAM_VALUE.C_EN_LAST_WRITE_FLAG} {

	# Procedure called to validate C_EN_LAST_WRITE_FLAG
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_FIFO_ENABLE { PARAM_VALUE.C_SLOT_7_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_7_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_EN_RESPONSE_FLAG { PARAM_VALUE.C_EN_RESPONSE_FLAG} {

	# Procedure called to validate C_RESPONSE_FLAG
	return true

}

proc validate_PARAM_VALUE.C_EN_LAST_READ_FLAG { PARAM_VALUE.C_EN_LAST_READ_FLAG} {

	# Procedure called to validate C_EN_LAST_READ_FLAG
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_0_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_MAX_REORDER_DEPTH { PARAM_VALUE.C_MAX_REORDER_DEPTH} {

	# Procedure called to validate C_MAX_REORDER_DEPTH
	return true

}

proc validate_PARAM_VALUE.C_ENABLE_TRACE { PARAM_VALUE.C_ENABLE_TRACE} {

	# Procedure called to validate C_ENABLE_TRACE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EN_FIRST_READ_FLAG { PARAM_VALUE.C_EN_FIRST_READ_FLAG} {

	# Procedure called to validate C_EN_FIRST_READ_FLAG 
	return true

}

proc validate_PARAM_VALUE.C_ENABLE_EVENT_COUNT { PARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_ENABLE_EVENT_COUNT  
  PARAM_VALUE.C_ENABLE_EVENT_LOG} {

	# Procedure called to validate C_ENABLE_EVENT_COUNT
        set advanced [ get_property value ${PARAM_VALUE.C_ENABLE_ADVANCED} ]	
        set event_cnt [ get_property value ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} ]	
        set event_log [ get_property value ${PARAM_VALUE.C_ENABLE_EVENT_LOG} ]	
	if {$advanced == 1 && $event_cnt == 0 && $event_log == 0} {
	   set_property errmsg "Adanced mode has to be set with either event count or event log enabled"  ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} 
	   return false
        } else {
	   return true
	}

}

proc validate_PARAM_VALUE.ENABLE_EXT_EVENTS { PARAM_VALUE.ENABLE_EXT_EVENTS} {

	# Procedure called to validate ENABLE_EXT_EVENTS 
	return true

}

proc validate_PARAM_VALUE.C_EN_RD_ADD_FLAG { PARAM_VALUE.C_EN_RD_ADD_FLAG} {

	# Procedure called to validate C_EN_RD_ADD_FLAG
	return true

}

proc validate_PARAM_VALUE.C_EN_SW_REG_WR_FLAG { PARAM_VALUE.C_EN_SW_REG_WR_FLAG} {

	# Procedure called to validate C_EN_SW_REG_WR_FLAG 
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_METRIC_COUNT_WIDTH { PARAM_VALUE.C_METRIC_COUNT_WIDTH} {

	# Procedure called to validate C_METRIC_COUNT_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT0_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_FIFO_AXIS_SYNC { PARAM_VALUE.C_FIFO_AXIS_SYNC} {

	# Procedure called to validate C_FIFO_AXIS_SYNC
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT2_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_ENABLE_PROFILE { PARAM_VALUE.C_ENABLE_PROFILE} {

	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT4_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_GLOBAL_COUNT_WIDTH { PARAM_VALUE.C_GLOBAL_COUNT_WIDTH} {

	# Procedure called to validate C_GLOBAL_COUNT_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_5_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT6_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SHOW_AXIS_TID { PARAM_VALUE.C_SHOW_AXIS_TID} {

	# Procedure called to validate C_SHOW_AXIS_TID
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_2_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SHOW_AXI_LEN { PARAM_VALUE.C_SHOW_AXI_LEN} {

	# Procedure called to validate C_SHOW_AXI_LEN
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EN_EXT_EVENTS_FLAG { PARAM_VALUE.C_EN_EXT_EVENTS_FLAG} {

	# Procedure called to validate C_EN_EXT_EVENTS_FLAG
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_FIFO_ENABLE { PARAM_VALUE.C_SLOT_0_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_0_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.ENABLE_EXT_TRIGGERS { PARAM_VALUE.ENABLE_EXT_TRIGGERS} {

	# Procedure called to validate ENABLE_EXT_TRIGGERS 
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_FIFO_ENABLE { PARAM_VALUE.C_SLOT_2_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_2_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_EN_WR_ADD_FLAG { PARAM_VALUE.C_EN_WR_ADD_FLAG} {

	# Procedure called to validate C_EN_WR_ADD_FLAG
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_FIFO_ENABLE { PARAM_VALUE.C_SLOT_4_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_4_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_S_AXI_ID_WIDTH { PARAM_VALUE.C_S_AXI_ID_WIDTH} {

	# Procedure called to validate C_S_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_FIFO_ENABLE { PARAM_VALUE.C_SLOT_6_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_6_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SHOW_AXI_IDS { PARAM_VALUE.C_SHOW_AXI_IDS} {

	# Procedure called to validate C_SHOW_AXI_IDS
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_7_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_FIFO_AXIS_DEPTH { PARAM_VALUE.C_FIFO_AXIS_DEPTH} {

	# Procedure called to validate C_FIFO_AXIS_DEPTH
	return true

}

proc validate_PARAM_VALUE.C_EN_FIRST_WRITE_FLAG { PARAM_VALUE.C_EN_FIRST_WRITE_FLAG} {

	# Procedure called to validate C_EN_FIRST_WRITE_FLAG 
	return true

}

proc validate_PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS { PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} {

	# Procedure called to validate C_REG_ALL_MONITOR_SIGNALS
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH { PARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH} {

	# Procedure called to validate C_METRICS_SAMPLE_COUNT_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_4_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SHOW_AXIS_TDEST { PARAM_VALUE.C_SHOW_AXIS_TDEST} {

	# Procedure called to validate C_SHOW_AXIS_TDEST
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_4_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_MAX_OUTSTAND_DEPTH { PARAM_VALUE.C_MAX_OUTSTAND_DEPTH} {

	# Procedure called to validate C_MAX_OUTSTAND_DEPTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_1_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT1_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT3_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT { PARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT} {

	# Procedure called to validate C_HAVE_SAMPLED_METRIC_CNT
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT5_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.COUNTER_LOAD_VALUE { PARAM_VALUE.COUNTER_LOAD_VALUE} {

	# Procedure called to validate COUNTER_LOAD_VALUE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_2_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_ENABLE_EVENT_LOG { PARAM_VALUE.C_ENABLE_EVENT_LOG} {

	# Procedure called to validate C_ENABLE_EVENT_LOG
	return true

}

proc validate_PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE { PARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE} {

	# Procedure called to validate C_EXT_EVENT7_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_NUM_MONITOR_SLOTS { PARAM_VALUE.C_NUM_MONITOR_SLOTS} {

	# Procedure called to validate C_NUM_MONITOR_SLOTS
	return true

}

proc validate_PARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_5_AXIS_TUSER_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_METRIC_COUNT_SCALE { PARAM_VALUE.C_METRIC_COUNT_SCALE} {

	# Procedure called to validate C_METRIC_COUNT_SCALE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH { PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXI_DATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL { PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} {

	# Procedure called to validate C_SLOT_6_AXI_PROTOCOL
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH { PARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH} {

	# Procedure called to validate C_SLOT_1_AXIS_TDATA_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH { PARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH} {

	# Procedure called to validate C_SLOT_3_AXIS_TDEST_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC { PARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC} {

	# Procedure called to validate C_AXI4LITE_CORE_CLK_ASYNC
	return true

}

proc validate_PARAM_VALUE.C_SUPPORT_ID_REFLECTION { PARAM_VALUE.C_SUPPORT_ID_REFLECTION} {

	# Procedure called to validate C_SUPPORT_ID_REFLECTION
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH { PARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXI_ADDR_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_1_FIFO_ENABLE { PARAM_VALUE.C_SLOT_1_FIFO_ENABLE} {

	# Procedure called to validate C_SLOT_1_FIFO_ENABLE
	return true

}

proc validate_PARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH { PARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH} {

	# Procedure called to validate C_SLOT_0_AXIS_TID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_ENABLE_ADVANCED { PARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_ENABLE_PROFILE  
  PARAM_VALUE.C_ENABLE_TRACE} {

	# Procedure called to validate C_ENABLE_ADVANCE
        set en_advanced [ get_property value ${PARAM_VALUE.C_ENABLE_ADVANCED} ]	
        set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]	
        set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]	
	if {($en_profile == 1 || $en_trace == 1) && $en_advanced == 1} {
	   set_property errmsg "Adanced mode can not be set when profile or trace mode is selected"  ${PARAM_VALUE.C_ENABLE_ADVANCED} 
	   return false
	} elseif {$en_profile == 0 && $en_trace == 0 && $en_advanced == 0} {
	   set_property errmsg "APM IP has to be selected with any of the mode selected"  ${PARAM_VALUE.C_ENABLE_ADVANCED} 
  	   return false
        } else {
	   return true
	}

}

proc validate_PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH { PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH} {

	# Procedure called to validate C_SLOT_7_AXI_ID_WIDTH
	return true

}

proc validate_PARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH { PARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH} {

	# Procedure called to validate C_SLOT_6_AXIS_TUSER_WIDTH
	return true

}

##########################################################################################################################################################################333
proc update_MODELPARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot4_tdest [ get_property value ${PARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH} ]
        if { $slot4_tdest == 0 } {
          set slot4_tdest_hdl 1
        } else {
          set slot4_tdest_hdl $slot4_tdest
        }
        set_property value $slot4_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_2_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_0_AXI_PROTOCOL PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

    #set_property value [get_property value  ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} 
    set slot0_proto [ get_property value ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} ]
    if { $slot0_proto == "AXI4" || $slot0_proto == "AXI3" || $slot0_proto == "AXI4LITE" } {
    set slot0_protocol "AXI4"
    } else {
    set slot0_protocol "AXI4S"
    }
    set_property value $slot0_proto  ${MODELPARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} 
    return true

}

proc update_MODELPARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH {  
  MODELPARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH  
  PARAM_VALUE.C_NUM_MONITOR_SLOTS  
  PARAM_VALUE.C_SHOW_AXIS_TDEST PARAM_VALUE.C_SHOW_AXIS_TID PARAM_VALUE.C_SHOW_AXIS_TUSER  
  PARAM_VALUE.C_SHOW_AXI_IDS PARAM_VALUE.C_SHOW_AXI_LEN  
  PARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH  
  PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH  
  PARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set s0_a_w [ get_property value ${PARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH} ]
	set s1_a_w [ get_property value ${PARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH} ]
	set s2_a_w [ get_property value ${PARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH} ]
	set s3_a_w [ get_property value ${PARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH} ]
	set s4_a_w [ get_property value ${PARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH} ]
	set s5_a_w [ get_property value ${PARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH} ]
	set s6_a_w [ get_property value ${PARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH} ]
	set s7_a_w [ get_property value ${PARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH} ]

	set a [ get_property value ${PARAM_VALUE.C_NUM_MONITOR_SLOTS} ]
	set show_id [ get_property value ${PARAM_VALUE.C_SHOW_AXI_IDS} ]
	set show_len [ get_property value ${PARAM_VALUE.C_SHOW_AXI_LEN} ]
	set show_tid [ get_property value ${PARAM_VALUE.C_SHOW_AXIS_TID} ]
	set show_tdest [ get_property value ${PARAM_VALUE.C_SHOW_AXIS_TDEST} ]
	set show_tuser [ get_property value ${PARAM_VALUE.C_SHOW_AXIS_TUSER} ]

	set slot0_protocol [ get_property value ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} ]
	set slot0_id_width [ get_property value ${PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH} ]
	set slot0_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH} ]
	set slot0_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH} ]
	set slot0_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH} ]

	set slot1_protocol [ get_property value ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} ]
	set slot1_id_width [ get_property value ${PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH} ]
	set slot1_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH} ]
	set slot1_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH} ]
	set slot1_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH} ]

	set slot2_protocol [ get_property value ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} ]
	set slot2_id_width [ get_property value ${PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH} ]
	set slot2_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH} ]
	set slot2_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH} ]
	set slot2_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH} ]

	set slot3_protocol [ get_property value ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} ]
	set slot3_id_width [ get_property value ${PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH} ]
	set slot3_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH} ]
	set slot3_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH} ]
	set slot3_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH} ]

	set slot4_protocol [ get_property value ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} ]
	set slot4_id_width [ get_property value ${PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH} ]
	set slot4_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH} ]
	set slot4_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_4_AXIS_TDEST_WIDTH} ]
	set slot4_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH} ]

	set slot5_protocol [ get_property value ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} ]
	set slot5_id_width [ get_property value ${PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH} ]
	set slot5_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH} ]
	set slot5_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH} ]
	set slot5_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH} ]

	set slot6_protocol [ get_property value ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} ]
	set slot6_id_width [ get_property value ${PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH} ]
	set slot6_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH} ]
	set slot6_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH} ]
	set slot6_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH} ]

	set slot7_protocol [ get_property value ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} ]
	set slot7_id_width [ get_property value ${PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH} ]
	set slot7_tid_width [ get_property value ${PARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH} ]
	set slot7_tdest_width [ get_property value ${PARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH} ]
	set slot7_tuser_width [ get_property value ${PARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH} ]

	# burst width
	set bst  8

	#SLOT0       
	if { $slot0_protocol == "AXI4" || $slot0_protocol == "AXI3" || $slot0_protocol == "AXI4LITE" } {
		set slot0_width [expr $s0_a_w*2 + $show_id*$slot0_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot0_protocol == "AXI4S" } {
		set slot0_width [expr $show_tid*$slot0_tid_width+ $show_tdest*$slot0_tdest_width+ $show_tuser* $slot0_tuser_width+2]
	}

	#SLOT1       
	if { $slot1_protocol == "AXI4" || $slot1_protocol == "AXI3" || $slot1_protocol == "AXI4LITE"} {
		set slot1_width [expr $s1_a_w*2 + $show_id*$slot1_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot1_protocol == "AXI4S" } {
		set slot1_width [expr $show_tid*$slot1_tid_width+ $show_tdest*$slot1_tdest_width+ $show_tuser* $slot1_tuser_width+2]
	}

	#SLOT2       
	if { $slot2_protocol == "AXI4" || $slot2_protocol == "AXI3" || $slot2_protocol == "AXI4LITE"} {
		set slot2_width [expr $s2_a_w*2 + $show_id*$slot2_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot2_protocol == "AXI4S" } {
		set slot2_width [expr $show_tid*$slot2_tid_width+ $show_tdest*$slot2_tdest_width+ $show_tuser* $slot2_tuser_width+2]
	}

	#SLOT3       
	if { $slot3_protocol == "AXI4" || $slot3_protocol == "AXI3" || $slot3_protocol == "AXI4LITE"} {
		set slot3_width [expr $s3_a_w*2 + $show_id*$slot3_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot3_protocol == "AXI4S" } {
		set slot3_width [expr $show_tid*$slot3_tid_width+ $show_tdest*$slot3_tdest_width+ $show_tuser* $slot3_tuser_width+2]
	}

	#SLOT4       
	if { $slot4_protocol == "AXI4" || $slot4_protocol == "AXI3" || $slot4_protocol == "AXI4LITE"} {
		set slot4_width [expr $s4_a_w*2 + $show_id*$slot4_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot4_protocol == "AXI4S" } {
		set slot4_width [expr $show_tid*$slot4_tid_width+ $show_tdest*$slot4_tdest_width+ $show_tuser* $slot4_tuser_width+2]
	}
	#SLOT5       
	if { $slot5_protocol == "AXI4" || $slot5_protocol == "AXI3" || $slot5_protocol == "AXI4LITE"} {
		set slot5_width [expr $s5_a_w*2 + $show_id*$slot5_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot5_protocol == "AXI4S" } {
		set slot5_width [expr $show_tid*$slot5_tid_width+ $show_tdest*$slot5_tdest_width+ $show_tuser* $slot5_tuser_width+2]
	}

	#SLOT6       
	if { $slot6_protocol == "AXI4" || $slot6_protocol == "AXI3" || $slot6_protocol == "AXI4LITE"} {
		set slot6_width [expr $s6_a_w*2 + $show_id*$slot6_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot6_protocol == "AXI4S" } {
		set slot6_width [expr $show_tid*$slot6_tid_width+ $show_tdest*$slot6_tdest_width+ $show_tuser* $slot6_tuser_width+2]
	}

	#SLOT7       
	if { $slot7_protocol == "AXI4" || $slot7_protocol == "AXI3" || $slot7_protocol == "AXI4LITE"} {
		set slot7_width [expr $s7_a_w*2 + $show_id*$slot7_id_width*4 + $show_len*$bst*2 + 7]
	} elseif { $slot7_protocol == "AXI4S" } {
		set slot7_width [expr $show_tid*$slot7_tid_width+ $show_tdest*$slot7_tdest_width+ $show_tuser* $slot7_tuser_width+2]
	}

	# time stamp width
	set ts 30
	# event flags width
	set ev  3

	if { $a == 1 } { 
		set fifo_width_temp [expr $slot0_width+$ev*$a+$ts+2]
	} elseif { $a == 2 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$ev*$a+$ts+2]
	} elseif { $a == 3 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$slot2_width+$ev*$a+$ts+2]
	} elseif { $a == 4 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$slot2_width+$slot3_width+$ev*$a+$ts+2]
	} elseif { $a == 5 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$slot2_width+$slot3_width+$slot4_width+$ev*$a+$ts+2]
	} elseif { $a == 6 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$slot2_width+$slot3_width+$slot4_width+$slot5_width+$ev*$a+$ts+2]
	} elseif { $a == 7 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$slot2_width+$slot3_width+$slot4_width+$slot5_width+$slot6_width+$ev*$a+$ts+2]
	} elseif { $a == 8 } {
		set fifo_width_temp [expr $slot0_width+$slot1_width+$slot2_width+$slot3_width+$slot4_width+$slot5_width+$slot6_width+$slot7_width+$ev*$a+$ts+2]
	}

	if { $fifo_width_temp < 50 } {
		set fifo_width 56
	} elseif { $fifo_width_temp % 8 == 0} {
		set fifo_width $fifo_width_temp
	} else {
		set fifo_width [expr $fifo_width_temp + (8 - ($fifo_width_temp % 8))]
	}

	set_property value $fifo_width ${MODELPARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH}
	#set_property value [get_property value ${PARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_LOG_DATA_OFFLD { MODELPARAM_VALUE.C_LOG_DATA_OFFLD PARAM_VALUE.C_LOG_DATA_OFFLD} {

  set val [ get_property value ${PARAM_VALUE.C_LOG_DATA_OFFLD} ]
  if {$val == "Stream" } {
    set offld 0
  } else {
    set offld 1
  } 
  set_property value $offld  ${MODELPARAM_VALUE.C_LOG_DATA_OFFLD} 
  return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot7_tuser [ get_property value ${PARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH} ]
        if { $slot7_tuser == 0 } {
          set slot7_tuser_hdl 1
        } else {
          set slot7_tuser_hdl $slot7_tuser
        }
        set_property value $slot7_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_7_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_3_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot0_tuser [ get_property value ${PARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH} ]
        if { $slot0_tuser == 0 } {
          set slot0_tuser_hdl 1
        } else {
          set slot0_tuser_hdl $slot0_tuser
        }
        set_property value $slot0_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_0_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot1_id [ get_property value ${PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH} ] 
	if { $slot1_id == 0 } {
	  set slot1_id_hdl 1
	} else {
	  set slot1_id_hdl $slot1_id
	}
	set_property value $slot1_id_hdl  ${MODELPARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot3_tid [ get_property value ${PARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH} ]
        if { $slot3_tid == 0 } {
          set slot3_tid_hdl 1
        } else {
          set slot3_tid_hdl $slot3_tid
        }
        set_property value $slot3_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_3_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_EXT_EVENTS_FLAG { MODELPARAM_VALUE.C_EN_EXT_EVENTS_FLAG PARAM_VALUE.C_EN_EXT_EVENTS_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_EXT_EVENTS_FLAG} ]  ${MODELPARAM_VALUE.C_EN_EXT_EVENTS_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.ENABLE_EXT_EVENTS { MODELPARAM_VALUE.ENABLE_EXT_EVENTS PARAM_VALUE.ENABLE_EXT_EVENTS} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.ENABLE_EXT_EVENTS} ]  ${MODELPARAM_VALUE.ENABLE_EXT_EVENTS} 
	
        return true

}

proc update_MODELPARAM_VALUE.C_FAMILY { MODELPARAM_VALUE.C_FAMILY} {

variable c_family
set_property value $c_family  ${MODELPARAM_VALUE.C_FAMILY} 
	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_0_FIFO_ENABLE PARAM_VALUE.C_SLOT_0_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_0_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_0_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot5_tdest [ get_property value ${PARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH} ]
        if { $slot5_tdest == 0 } {
          set slot5_tdest_hdl 1
        } else {
          set slot5_tdest_hdl $slot5_tdest
        }
        set_property value $slot5_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_5_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_3_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_2_FIFO_ENABLE PARAM_VALUE.C_SLOT_2_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_2_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_2_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_WR_ADD_FLAG { MODELPARAM_VALUE.C_EN_WR_ADD_FLAG PARAM_VALUE.C_EN_WR_ADD_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_WR_ADD_FLAG} ]  ${MODELPARAM_VALUE.C_EN_WR_ADD_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_2_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_4_FIFO_ENABLE PARAM_VALUE.C_SLOT_4_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_4_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_4_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot2_tid [ get_property value ${PARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH} ]
        if { $slot2_tid == 0 } {
          set slot2_tid_hdl 1
        } else {
          set slot2_tid_hdl $slot2_tid
        }
        set_property value $slot2_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_2_AXIS_TID_WIDTH} 
 
	return true

}

proc update_MODELPARAM_VALUE.C_S_AXI_ID_WIDTH { MODELPARAM_VALUE.C_S_AXI_ID_WIDTH PARAM_VALUE.C_S_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_S_AXI_ID_WIDTH} ]  ${MODELPARAM_VALUE.C_S_AXI_ID_WIDTH} 
       
	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot1_tuser [ get_property value ${PARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH} ]
        if { $slot1_tuser == 0 } {
          set slot1_tuser_hdl 1
        } else {
          set slot1_tuser_hdl $slot1_tuser
        }
        set_property value $slot1_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_1_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_6_FIFO_ENABLE PARAM_VALUE.C_SLOT_6_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_6_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_6_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_5_AXI_PROTOCOL PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

    #set_property value [get_property value  ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} 
    set slot5_proto [ get_property value ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} ]
    if { $slot5_proto == "AXI4" || $slot5_proto == "AXI3" || $slot5_proto == "AXI4LITE"} {
    set slot5_protocol "AXI4"
    } else {
    set slot5_protocol "AXI4S"
    }
    set_property value $slot5_proto  ${MODELPARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} 
    return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_RESPONSE_FLAG { MODELPARAM_VALUE.C_EN_RESPONSE_FLAG PARAM_VALUE.C_EN_RESPONSE_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_RESPONSE_FLAG} ]  ${MODELPARAM_VALUE.C_EN_RESPONSE_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot6_id [ get_property value ${PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH} ] 
	if { $slot6_id == 0 } {
	  set slot6_id_hdl 1
	} else {
	  set slot6_id_hdl $slot6_id
	}
	set_property value $slot6_id_hdl  ${MODELPARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_NUM_MONITOR_SLOTS { MODELPARAM_VALUE.C_NUM_MONITOR_SLOTS PARAM_VALUE.C_NUM_MONITOR_SLOTS} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_NUM_MONITOR_SLOTS} ]  ${MODELPARAM_VALUE.C_NUM_MONITOR_SLOTS} 

	return true

}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_S_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_1_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_AXIS_DWIDTH_ROUND_TO_32 { MODELPARAM_VALUE.C_AXIS_DWIDTH_ROUND_TO_32 MODELPARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH} {

   #set fifo_width [get_property modelparam_value [ipgui::get_modelparamspec C_FIFO_AXIS_TDATA_WIDTH -of $IPINST]]
	set fifo_width [get_property value  ${MODELPARAM_VALUE.C_FIFO_AXIS_TDATA_WIDTH} ]
          if { $fifo_width % 32 == 0} {
            set fifo_width $fifo_width
          } else {
            set fifo_width [expr $fifo_width+ (32 - ($fifo_width % 32))]
           }
  set_property value $fifo_width  ${MODELPARAM_VALUE.C_AXIS_DWIDTH_ROUND_TO_32} 
  return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot6_tdest [ get_property value ${PARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH} ]
        if { $slot6_tdest == 0 } {
          set slot6_tdest_hdl 1
        } else {
          set slot6_tdest_hdl $slot6_tdest
        }
        set_property value $slot6_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_6_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_4_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_2_AXI_PROTOCOL PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

        #set_property value [get_property value  ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} 
    set slot2_proto [ get_property value ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} ]
    if { $slot2_proto == "AXI4" || $slot2_proto == "AXI3" || $slot2_proto == "AXI4LITE"} {
    set slot2_protocol "AXI4"
    } else {
    set slot2_protocol "AXI4S"
    }
    set_property value $slot2_proto  ${MODELPARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} 
    return true

}

proc update_MODELPARAM_VALUE.C_INSTANCE { MODELPARAM_VALUE.C_INSTANCE PARAM_VALUE.Component_Name} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.Component_Name} ]  ${MODELPARAM_VALUE.C_INSTANCE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot1_tid [ get_property value ${PARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH} ]
        if { $slot1_tid == 0 } {
          set slot1_tid_hdl 1
        } else {
          set slot1_tid_hdl $slot1_tid
        }
        set_property value $slot1_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_1_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_ENABLE_TRACE { MODELPARAM_VALUE.C_ENABLE_TRACE PARAM_VALUE.C_ENABLE_TRACE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_ENABLE_TRACE} ]  ${MODELPARAM_VALUE.C_ENABLE_TRACE} 

	return true

}

proc update_MODELPARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH { MODELPARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH PARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH} ]  ${MODELPARAM_VALUE.C_METRICS_SAMPLE_COUNT_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot3_id [ get_property value ${PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH} ] 
	if { $slot3_id == 0 } {
	  set slot3_id_hdl 1
	} else {
	  set slot3_id_hdl $slot3_id
	}
	set_property value $slot3_id_hdl  ${MODELPARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH} 
 
	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot2_tuser [ get_property value ${PARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH} ]
        if { $slot2_tuser == 0 } {
          set slot2_tuser_hdl 1
        } else {
          set slot2_tuser_hdl $slot2_tuser
        }
        set_property value $slot2_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_2_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SUPPORT_ID_REFLECTION { MODELPARAM_VALUE.C_SUPPORT_ID_REFLECTION PARAM_VALUE.C_SUPPORT_ID_REFLECTION} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SUPPORT_ID_REFLECTION} ]  ${MODELPARAM_VALUE.C_SUPPORT_ID_REFLECTION} 
       
	return true

}

proc update_MODELPARAM_VALUE.C_MAX_OUTSTAND_DEPTH { MODELPARAM_VALUE.C_MAX_OUTSTAND_DEPTH PARAM_VALUE.C_MAX_OUTSTAND_DEPTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_MAX_OUTSTAND_DEPTH} ]  ${MODELPARAM_VALUE.C_MAX_OUTSTAND_DEPTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_0_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot0_tid [ get_property value ${PARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH} ] 
	if { $slot0_tid == 0 } {
	  set slot0_tid_hdl 1
	} else {
	  set slot0_tid_hdl $slot0_tid
	}
	set_property value $slot0_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_0_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot0_id [ get_property value ${PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH} ] 
	if { $slot0_id == 0 } {
	  set slot0_id_hdl 1
	} else {
	  set slot0_id_hdl $slot0_id
	}
	set_property value $slot0_id_hdl  ${MODELPARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot7_tdest [ get_property value ${PARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH} ]
        if { $slot7_tdest == 0 } {
          set slot7_tdest_hdl 1
        } else {
          set slot7_tdest_hdl $slot7_tdest
        }
        set_property value $slot7_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_7_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_5_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot0_tdest [ get_property value ${PARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH} ]
        if { $slot0_tdest == 0 } {
          set slot0_tdest_hdl 1
        } else {
          set slot0_tdest_hdl $slot0_tdest
        }
        set_property value $slot0_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_0_AXIS_TDEST_WIDTH} 
 
	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot3_tuser [ get_property value ${PARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH} ]
        if { $slot3_tuser == 0 } {
          set slot3_tuser_hdl 1
        } else {
          set slot3_tuser_hdl $slot3_tuser
        }
        set_property value $slot3_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_3_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_7_AXI_PROTOCOL PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

         #set_property value [get_property value  ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} 
    set slot7_proto [ get_property value ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} ]
    if { $slot7_proto == "AXI4" || $slot7_proto == "AXI3" || $slot7_proto == "AXI4LITE" } {
    set slot7_protocol "AXI4"
    } else {
    set slot7_protocol "AXI4S"
    }
    set_property value $slot7_proto  ${MODELPARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_LAST_READ_FLAG { MODELPARAM_VALUE.C_EN_LAST_READ_FLAG PARAM_VALUE.C_EN_LAST_READ_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_LAST_READ_FLAG} ]  ${MODELPARAM_VALUE.C_EN_LAST_READ_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_METRIC_COUNT_SCALE { MODELPARAM_VALUE.C_METRIC_COUNT_SCALE PARAM_VALUE.C_METRIC_COUNT_SCALE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_METRIC_COUNT_SCALE} ]  ${MODELPARAM_VALUE.C_METRIC_COUNT_SCALE} 

	return true

}

proc update_MODELPARAM_VALUE.C_FIFO_AXIS_DEPTH { MODELPARAM_VALUE.C_FIFO_AXIS_DEPTH PARAM_VALUE.C_FIFO_AXIS_DEPTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_FIFO_AXIS_DEPTH} ]  ${MODELPARAM_VALUE.C_FIFO_AXIS_DEPTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_MAX_REORDER_DEPTH { MODELPARAM_VALUE.C_MAX_REORDER_DEPTH PARAM_VALUE.C_MAX_REORDER_DEPTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_MAX_REORDER_DEPTH} ]  ${MODELPARAM_VALUE.C_MAX_REORDER_DEPTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS { MODELPARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} ]  ${MODELPARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_FIRST_WRITE_FLAG { MODELPARAM_VALUE.C_EN_FIRST_WRITE_FLAG PARAM_VALUE.C_EN_FIRST_WRITE_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_FIRST_WRITE_FLAG} ]  ${MODELPARAM_VALUE.C_EN_FIRST_WRITE_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_6_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_4_AXI_PROTOCOL PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

   #set_property value [get_property value  ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} 
    set slot4_proto [ get_property value ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} ]
    if { $slot4_proto == "AXI4" || $slot4_proto == "AXI3" || $slot4_proto == "AXI4LITE"} {
    set slot4_protocol "AXI4"
    } else {
    set slot4_protocol "AXI4S"
    }
    set_property value $slot4_proto  ${MODELPARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} 
    return true

}

proc update_MODELPARAM_VALUE.C_SHOW_AXIS_TDEST { MODELPARAM_VALUE.C_SHOW_AXIS_TDEST PARAM_VALUE.C_SHOW_AXIS_TDEST} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SHOW_AXIS_TDEST} ]  ${MODELPARAM_VALUE.C_SHOW_AXIS_TDEST} 

	return true

}

proc update_MODELPARAM_VALUE.C_SHOW_AXI_LEN { MODELPARAM_VALUE.C_SHOW_AXI_LEN PARAM_VALUE.C_SHOW_AXI_LEN} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SHOW_AXI_LEN} ]  ${MODELPARAM_VALUE.C_SHOW_AXI_LEN} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot1_tdest [ get_property value ${PARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH} ]
        if { $slot1_tdest == 0 } {
          set slot1_tdest_hdl 1
        } else {
          set slot1_tdest_hdl $slot1_tdest
        }
        set_property value $slot1_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_1_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_7_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot5_id [ get_property value ${PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH} ] 
	if { $slot5_id == 0 } {
	  set slot5_id_hdl 1
	} else {
	  set slot5_id_hdl $slot5_id
	}
	set_property value $slot5_id_hdl  ${MODELPARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot4_tuser [ get_property value ${PARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH} ]
        if { $slot4_tuser == 0 } {
          set slot4_tuser_hdl 1
        } else {
          set slot4_tuser_hdl $slot4_tuser
        }
        set_property value $slot4_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_4_AXIS_TUSER_WIDTH} 
	
	return true

}

proc update_MODELPARAM_VALUE.C_EN_SW_REG_WR_FLAG { MODELPARAM_VALUE.C_EN_SW_REG_WR_FLAG PARAM_VALUE.C_EN_SW_REG_WR_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_SW_REG_WR_FLAG} ]  ${MODELPARAM_VALUE.C_EN_SW_REG_WR_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot7_tid [ get_property value ${PARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH} ]
        if { $slot7_tid == 0 } {
          set slot7_tid_hdl 1
        } else {
          set slot7_tid_hdl $slot7_tid
        }
        set_property value $slot7_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_7_AXIS_TID_WIDTH} 
 
	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_1_FIFO_ENABLE PARAM_VALUE.C_SLOT_1_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_1_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_1_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_1_AXI_PROTOCOL PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	# set_property value [get_property value  ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} 
    set slot1_proto [ get_property value ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} ]
    if { $slot1_proto == "AXI4" || $slot1_proto == "AXI3" || $slot1_proto == "AXI4LITE"} {
    set slot1_protocol "AXI4"
    } else {
    set slot1_protocol "AXI4S"
    }
    set_property value $slot1_proto  ${MODELPARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} 
    return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_3_FIFO_ENABLE PARAM_VALUE.C_SLOT_3_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_3_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_3_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_5_FIFO_ENABLE PARAM_VALUE.C_SLOT_5_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_5_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_5_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot2_id [ get_property value ${PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH} ] 
	if { $slot2_id == 0 } {
	  set slot2_id_hdl 1
	} else {
	  set slot2_id_hdl $slot2_id
	}
	set_property value $slot2_id_hdl  ${MODELPARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT { MODELPARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT PARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT} ]  ${MODELPARAM_VALUE.C_HAVE_SAMPLED_METRIC_CNT} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_7_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SHOW_AXI_IDS { MODELPARAM_VALUE.C_SHOW_AXI_IDS PARAM_VALUE.C_SHOW_AXI_IDS} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SHOW_AXI_IDS} ]  ${MODELPARAM_VALUE.C_SHOW_AXI_IDS} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_FIFO_ENABLE { MODELPARAM_VALUE.C_SLOT_7_FIFO_ENABLE PARAM_VALUE.C_SLOT_7_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_7_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_SLOT_7_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_6_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot2_tdest [ get_property value ${PARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH} ]
        if { $slot2_tdest == 0 } {
          set slot2_tdest_hdl 1
        } else {
          set slot2_tdest_hdl $slot2_tdest
        }
        set_property value $slot2_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_2_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_0_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_LAST_WRITE_FLAG { MODELPARAM_VALUE.C_EN_LAST_WRITE_FLAG PARAM_VALUE.C_EN_LAST_WRITE_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_LAST_WRITE_FLAG} ]  ${MODELPARAM_VALUE.C_EN_LAST_WRITE_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot6_tid [ get_property value ${PARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH} ]
        if { $slot6_tid == 0 } {
          set slot6_tid_hdl 1
        } else {
          set slot6_tid_hdl $slot6_tid
        }
        set_property value $slot6_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_6_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot5_tuser [ get_property value ${PARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH} ]
        if { $slot5_tuser == 0 } {
          set slot5_tuser_hdl 1
        } else {
          set slot5_tuser_hdl $slot5_tuser
        }
        set_property value $slot5_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_5_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SHOW_AXIS_TID { MODELPARAM_VALUE.C_SHOW_AXIS_TID PARAM_VALUE.C_SHOW_AXIS_TID} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SHOW_AXIS_TID} ]  ${MODELPARAM_VALUE.C_SHOW_AXIS_TID} 

	return true

}

proc update_MODELPARAM_VALUE.C_S_AXI_PROTOCOL { MODELPARAM_VALUE.C_S_AXI_PROTOCOL PARAM_VALUE.C_S_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_S_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_S_AXI_PROTOCOL} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_FIRST_READ_FLAG { MODELPARAM_VALUE.C_EN_FIRST_READ_FLAG PARAM_VALUE.C_EN_FIRST_READ_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_FIRST_READ_FLAG} ]  ${MODELPARAM_VALUE.C_EN_FIRST_READ_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.S_AXI_OFFLD_ID_WIDTH { MODELPARAM_VALUE.S_AXI_OFFLD_ID_WIDTH PARAM_VALUE.S_AXI_OFFLD_ID_WIDTH} {

  # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
 if { [  get_property value ${PARAM_VALUE.S_AXI_OFFLD_ID_WIDTH} ] > 0 } {
  set_property value [get_property value  ${PARAM_VALUE.S_AXI_OFFLD_ID_WIDTH} ]  ${MODELPARAM_VALUE.S_AXI_OFFLD_ID_WIDTH} 
 } else {
  set_property value 1  ${MODELPARAM_VALUE.S_AXI_OFFLD_ID_WIDTH} 
 }
  return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_5_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_ENABLE_EVENT_COUNT { MODELPARAM_VALUE.C_ENABLE_EVENT_COUNT PARAM_VALUE.C_ENABLE_EVENT_COUNT} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} ]  ${MODELPARAM_VALUE.C_ENABLE_EVENT_COUNT} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_6_AXI_PROTOCOL PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

#set_property value [get_property value  ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} 
    set slot6_proto [ get_property value ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} ]
    if { $slot6_proto == "AXI4" || $slot6_proto == "AXI3" || $slot6_proto == "AXI4LITE"} {
    set slot6_protocol "AXI4"
    } else {
    set slot6_protocol "AXI4S"
    }
    set_property value $slot6_proto  ${MODELPARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} 
	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot5_tid [ get_property value ${PARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH} ]
        if { $slot5_tid == 0 } {
          set slot5_tid_hdl 1
        } else {
          set slot5_tid_hdl $slot5_tid
        }
        set_property value $slot5_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_5_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EN_RD_ADD_FLAG { MODELPARAM_VALUE.C_EN_RD_ADD_FLAG PARAM_VALUE.C_EN_RD_ADD_FLAG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EN_RD_ADD_FLAG} ]  ${MODELPARAM_VALUE.C_EN_RD_ADD_FLAG} 

	return true

}

proc update_MODELPARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC { MODELPARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC PARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC} ]  ${MODELPARAM_VALUE.C_AXI4LITE_CORE_CLK_ASYNC} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH PARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot3_tdest [ get_property value ${PARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH} ]
        if { $slot3_tdest == 0 } {
          set slot3_tdest_hdl 1
        } else {
          set slot3_tdest_hdl $slot3_tdest
        }
        set_property value $slot3_tdest_hdl  ${MODELPARAM_VALUE.C_SLOT_3_AXIS_TDEST_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH PARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_1_AXIS_TDATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_METRIC_COUNT_WIDTH { MODELPARAM_VALUE.C_METRIC_COUNT_WIDTH PARAM_VALUE.C_METRIC_COUNT_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_METRIC_COUNT_WIDTH} ]  ${MODELPARAM_VALUE.C_METRIC_COUNT_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_FIFO_AXIS_SYNC { MODELPARAM_VALUE.C_FIFO_AXIS_SYNC PARAM_VALUE.C_FIFO_AXIS_SYNC} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_FIFO_AXIS_SYNC} ]  ${MODELPARAM_VALUE.C_FIFO_AXIS_SYNC} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot7_id [ get_property value ${PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH} ] 
	if { $slot7_id == 0 } {
	  set slot7_id_hdl 1
	} else {
	  set slot7_id_hdl $slot7_id
	}
	set_property value $slot7_id_hdl  ${MODELPARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH PARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot6_tuser [ get_property value ${PARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH} ]
        if { $slot6_tuser == 0 } {
          set slot6_tuser_hdl 1
        } else {
          set slot6_tuser_hdl $slot6_tuser
        }
        set_property value $slot6_tuser_hdl  ${MODELPARAM_VALUE.C_SLOT_6_AXIS_TUSER_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_ENABLE_ADVANCED { MODELPARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_ENABLE_ADVANCED} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_ENABLE_ADVANCED} ]  ${MODELPARAM_VALUE.C_ENABLE_ADVANCED} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_3_AXI_PROTOCOL { MODELPARAM_VALUE.C_SLOT_3_AXI_PROTOCOL PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} {

	#Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	#set_property value [get_property value  ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} ]  ${MODELPARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} 
    set slot3_proto [ get_property value ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} ]
    if { $slot3_proto == "AXI4" || $slot3_proto == "AXI3" || $slot3_proto == "AXI4LITE"} {
    set slot3_protocol "AXI4"
    } else {
    set slot3_protocol "AXI4S"
    }
    set_property value $slot3_proto  ${MODELPARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} 
    return true

}

proc update_MODELPARAM_VALUE.C_NUM_OF_COUNTERS { MODELPARAM_VALUE.C_NUM_OF_COUNTERS PARAM_VALUE.C_NUM_OF_COUNTERS} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_NUM_OF_COUNTERS} ]  ${MODELPARAM_VALUE.C_NUM_OF_COUNTERS} 

	return true

}

proc update_MODELPARAM_VALUE.C_SHOW_AXIS_TUSER { MODELPARAM_VALUE.C_SHOW_AXIS_TUSER PARAM_VALUE.C_SHOW_AXIS_TUSER} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SHOW_AXIS_TUSER} ]  ${MODELPARAM_VALUE.C_SHOW_AXIS_TUSER} 

	return true

}

proc update_MODELPARAM_VALUE.C_FIFO_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_FIFO_AXIS_TID_WIDTH PARAM_VALUE.C_FIFO_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_FIFO_AXIS_TID_WIDTH} ]  ${MODELPARAM_VALUE.C_FIFO_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH PARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_4_AXI_ADDR_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_ENABLE_PROFILE { MODELPARAM_VALUE.C_ENABLE_PROFILE PARAM_VALUE.C_ENABLE_PROFILE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_ENABLE_PROFILE} ]  ${MODELPARAM_VALUE.C_ENABLE_PROFILE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH PARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot4_tid [ get_property value ${PARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH} ]
        if { $slot4_tid == 0 } {
          set slot4_tid_hdl 1
        } else {
          set slot4_tid_hdl $slot4_tid
        }
        set_property value $slot4_tid_hdl  ${MODELPARAM_VALUE.C_SLOT_4_AXIS_TID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_GLOBAL_COUNT_WIDTH { MODELPARAM_VALUE.C_GLOBAL_COUNT_WIDTH PARAM_VALUE.C_GLOBAL_COUNT_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_GLOBAL_COUNT_WIDTH} ]  ${MODELPARAM_VALUE.C_GLOBAL_COUNT_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.C_ENABLE_EVENT_LOG { MODELPARAM_VALUE.C_ENABLE_EVENT_LOG PARAM_VALUE.C_ENABLE_EVENT_LOG} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_ENABLE_EVENT_LOG} ]  ${MODELPARAM_VALUE.C_ENABLE_EVENT_LOG} 

	return true

}

proc update_MODELPARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE { MODELPARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE} ]  ${MODELPARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE} 

	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH { MODELPARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
        set slot4_id [ get_property value ${PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH} ] 
	if { $slot4_id == 0 } {
	  set slot4_id_hdl 1
	} else {
	  set slot4_id_hdl $slot4_id
	}
	set_property value $slot4_id_hdl  ${MODELPARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH} 

	return true

}

proc update_MODELPARAM_VALUE.COUNTER_LOAD_VALUE { MODELPARAM_VALUE.COUNTER_LOAD_VALUE PARAM_VALUE.COUNTER_LOAD_VALUE} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.COUNTER_LOAD_VALUE} ]  ${MODELPARAM_VALUE.COUNTER_LOAD_VALUE} 
       
	return true

}

proc update_MODELPARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH} {

	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property value [get_property value  ${PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH} ]  ${MODELPARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH} 

	return true

}


############################################################################################################################################################3333333333333333



proc update_gui { IPINST PARAM_VALUE.C_NUM_MONITOR_SLOTS PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL  
  PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL PARAM_VALUE.C_ENABLE_EVENT_COUNT  
  PARAM_VALUE.C_ENABLE_EVENT_LOG PARAM_VALUE.C_NUM_MONITOR_SLOTS PARAM_VALUE.ENABLE_EXT_EVENTS PARAM_VALUE.C_ENABLE_PROFILE  
  PARAM_VALUE.C_ENABLE_TRACE PARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_EXT_EVENT0_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT1_FIFO_ENABLE
  PARAM_VALUE.C_EXT_EVENT2_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT3_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT4_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT5_FIFO_ENABLE
  PARAM_VALUE.C_EXT_EVENT6_FIFO_ENABLE PARAM_VALUE.C_EXT_EVENT7_FIFO_ENABLE} {


 set  SLOT_0_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} ]
 set  SLOT_1_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} ]
 set  SLOT_2_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} ]
 set  SLOT_3_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} ]
 set  SLOT_4_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} ]
 set  SLOT_5_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} ]
 set  SLOT_6_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} ]
 set  SLOT_7_AXI_PROTOCOL [ get_property value ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} ]
 set number [ get_property value ${PARAM_VALUE.C_NUM_MONITOR_SLOTS} ]

 if {$SLOT_0_AXI_PROTOCOL == "AXI3" || $SLOT_0_AXI_PROTOCOL == "AXI4" || $SLOT_0_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_0_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_0_AXI_PROTOCOL "AXI4S"
 }
 if {$SLOT_1_AXI_PROTOCOL == "AXI3" || $SLOT_1_AXI_PROTOCOL == "AXI4" || $SLOT_1_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_1_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_1_AXI_PROTOCOL "AXI4S"
 }
 
 if {$SLOT_2_AXI_PROTOCOL == "AXI3" || $SLOT_2_AXI_PROTOCOL == "AXI4" || $SLOT_2_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_2_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_2_AXI_PROTOCOL "AXI4S"
 }
 
 if {$SLOT_3_AXI_PROTOCOL == "AXI3" || $SLOT_3_AXI_PROTOCOL == "AXI4" || $SLOT_3_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_3_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_3_AXI_PROTOCOL "AXI4S"
 }
 
 if {$SLOT_4_AXI_PROTOCOL == "AXI3" || $SLOT_4_AXI_PROTOCOL == "AXI4" || $SLOT_4_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_4_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_4_AXI_PROTOCOL "AXI4S"
 }
 
 if {$SLOT_5_AXI_PROTOCOL == "AXI3" || $SLOT_5_AXI_PROTOCOL == "AXI4" || $SLOT_5_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_5_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_5_AXI_PROTOCOL "AXI4S"
 }
 
 if {$SLOT_6_AXI_PROTOCOL == "AXI3" || $SLOT_6_AXI_PROTOCOL == "AXI4" || $SLOT_6_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_6_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_6_AXI_PROTOCOL "AXI4S"
 }
 
 if {$SLOT_7_AXI_PROTOCOL == "AXI3" || $SLOT_7_AXI_PROTOCOL == "AXI4" || $SLOT_7_AXI_PROTOCOL == "AXI4LITE"} {
    set C_SLOT_7_AXI_PROTOCOL "AXI4"
 } else {
    set C_SLOT_7_AXI_PROTOCOL "AXI4S"
 }

if {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4" || $C_SLOT_4_AXI_PROTOCOL == "AXI4" || $C_SLOT_5_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_6_AXI_PROTOCOL == "AXI4" || $C_SLOT_7_AXI_PROTOCOL == "AXI4") && $number == 8} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST] 		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4" || $C_SLOT_4_AXI_PROTOCOL == "AXI4" || $C_SLOT_5_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_6_AXI_PROTOCOL == "AXI4") && $number == 7} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST] 		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4" || $C_SLOT_4_AXI_PROTOCOL == "AXI4" || $C_SLOT_5_AXI_PROTOCOL == "AXI4") 
     && $number == 6} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST] 
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4" || $C_SLOT_4_AXI_PROTOCOL == "AXI4") && $number == 5} {  
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST] 
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4") && $number == 4} {  
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST] 
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4") 
      && $number == 3} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST]
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4" || $C_SLOT_1_AXI_PROTOCOL == "AXI4") && $number == 2} { 
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST]
 } elseif {$C_SLOT_0_AXI_PROTOCOL == "AXI4" && $number == 1} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST]
 } else {
   set_property visible false [ipgui::get_groupspec -name "AXI4 Monitor Slots Parameters" -of $IPINST] 		
 }

 if {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4S" || $C_SLOT_4_AXI_PROTOCOL == "AXI4S" || $C_SLOT_5_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_6_AXI_PROTOCOL == "AXI4S" || $C_SLOT_7_AXI_PROTOCOL == "AXI4S") && $number == 8} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4S" || $C_SLOT_4_AXI_PROTOCOL == "AXI4S" || $C_SLOT_5_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_6_AXI_PROTOCOL == "AXI4S") && $number == 7} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4S" || $C_SLOT_4_AXI_PROTOCOL == "AXI4S" || $C_SLOT_5_AXI_PROTOCOL == "AXI4S") 
     && $number == 6} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4S" || $C_SLOT_4_AXI_PROTOCOL == "AXI4S") && $number == 5} {  
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4S" 
     || $C_SLOT_3_AXI_PROTOCOL == "AXI4S") && $number == 4} {  
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S"  || $C_SLOT_2_AXI_PROTOCOL == "AXI4S") 
      && $number == 3} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]		
 } elseif {($C_SLOT_0_AXI_PROTOCOL == "AXI4S" || $C_SLOT_1_AXI_PROTOCOL == "AXI4S") && $number == 2} { 
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]
 } elseif {$C_SLOT_0_AXI_PROTOCOL == "AXI4S" && $number == 1} {
   set_property visible true [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST]
 } else {
   set_property visible false [ipgui::get_groupspec -name "AXI4 Stream Monitor Slots Parameters" -of $IPINST] 		
 }

 
 set  EVENT_COUNT [ get_property value ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} ]
 set  EVENT_LOG [ get_property value ${PARAM_VALUE.C_ENABLE_EVENT_LOG} ]
 set  num [ get_property value ${PARAM_VALUE.C_NUM_MONITOR_SLOTS} ]
 set  ext_event_cnt [ get_property value ${PARAM_VALUE.ENABLE_EXT_EVENTS} ] 
 set  en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ] 
 set  en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ] 
 set  en_advance [ get_property value ${PARAM_VALUE.C_ENABLE_ADVANCED} ]

        for {set i 0} {$i<8} {incr i} {
		set ext_event "PARAM_VALUE.C_EXT_EVENT${i}_FIFO_ENABLE"
            if {$i < $num && ($EVENT_COUNT == 1 || $EVENT_LOG ==1 || $en_profile ==1 || $en_trace ==1)} {
		set_property visible true [ipgui::get_groupspec -name "Slot $i" -of $IPINST]
                #if {$en_trace ==1} {
		#set_property value 1  [set $ext_event] 
                #} elseif {$en_profile == 1} {
		#set_property value 0  [set $ext_event]  
                #} elseif {$ext_event_cnt == 1}  {
		#}
		if {$ext_event_cnt == 1}  {
		#set_property visible true  [set $ext_event]  
		set_property visible true [ipgui::get_guiparamspec C_EXT_EVENT${i}_FIFO_ENABLE -of $IPINST] 
                } else {
		#set_property visible false  [set $ext_event]  
		set_property visible false [ipgui::get_guiparamspec C_EXT_EVENT${i}_FIFO_ENABLE -of $IPINST] 
                }
            } else {
		set_property visible false [ipgui::get_groupspec -name "Slot $i" -of $IPINST]
		#set_property visible false  [set $ext_event] 
		set_property visible false [ipgui::get_guiparamspec  C_EXT_EVENT${i}_FIFO_ENABLE -of $IPINST] 
            } 
        }
        if { $EVENT_COUNT == 1 || $EVENT_LOG ==1 || $en_profile ==1 || $en_trace ==1} {
		set_property visible true  [ipgui::get_guiparamspec C_NUM_MONITOR_SLOTS -of $IPINST]  
            if { $EVENT_COUNT == 1 || $EVENT_LOG ==1} {
                set_property visible true [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST] 
		set_property visible true [ipgui::get_guiparamspec C_REG_ALL_MONITOR_SIGNALS -of $IPINST] 
            } else {
                set_property visible false [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST] 
		set_property visible false [ipgui::get_guiparamspec C_REG_ALL_MONITOR_SIGNALS -of $IPINST] 
            }
            if { $EVENT_COUNT == 1 } {
                set_property visible true [ipgui::get_groupspec -name "Event Count Parameters" -of $IPINST]
            } else {
                set_property visible false [ipgui::get_groupspec -name "Event Count Parameters" -of $IPINST]
            }

                if {$num < 5} {
              	set_property visible false [ipgui::get_pagespec -name "Monitor Interfaces(4-7)" -of $IPINST]
              	set_property visible true [ipgui::get_pagespec -name "Monitor Interfaces(0-3)" -of $IPINST]
                } else {
              	set_property visible true [ipgui::get_pagespec -name "Monitor Interfaces(4-7)" -of $IPINST]
              	set_property visible true [ipgui::get_pagespec -name "Monitor Interfaces(0-3)" -of $IPINST]
                }
	
             } else {
		set_property visible false  [ipgui::get_guiparamspec C_NUM_MONITOR_SLOTS -of $IPINST]
		set_property visible false  [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST]  
		set_property visible false  [ipgui::get_guiparamspec C_REG_ALL_MONITOR_SIGNALS -of $IPINST] 
              	set_property visible false [ipgui::get_pagespec -name "Monitor Interfaces(0-3)" -of $IPINST]
              	set_property visible false [ipgui::get_pagespec -name "Monitor Interfaces(4-7)" -of $IPINST]
                set_property visible false [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
             }
               	
        #if {$en_profile ==1 || $en_trace ==1} {
         # for {set j 0} {$j<8} {incr j} {
          # EvalSubstituting {j} {
           # set axi_prot "PARAM_VALUE.C_SLOT_${j}_AXI_PROTOCOL"
           # set_property range "AXI4,AXI3,AXI4LITE"  [set $axi_prot] 
           #} 0
          #}
       # } else {
        # for {set j 0} {$j<8} {incr j} {
        #   EvalSubstituting {j} {
	#    set axi_prot "PARAM_VALUE.C_SLOT_$j_AXI_PROTOCOL"
         #   set_property range "AXI4,AXI3,AXI4S,AXI4LITE"  [set $axi_prot] 
          # } 0
          #}
        #}

      if {$en_advance == 1} {
         set_property visible true [ipgui::get_groupspec -name "Functional Parameters" -of $IPINST]
      } elseif {$en_profile ==1 || $en_trace ==1} {
         set_property visible true [ipgui::get_groupspec -name "Functional Parameters" -of $IPINST]
      } else {
         set_property visible false [ipgui::get_groupspec -name "Functional Parameters" -of $IPINST]
      }
 

}



for {set i 0} {$i<8} {incr i} {
EvalSubstituting {i} {
proc update_PARAM_VALUE.C_EXT_EVENT${i}_FIFO_ENABLE {PARAM_VALUE.C_EXT_EVENT${i}_FIFO_ENABLE PARAM_VALUE.C_ENABLE_TRACE PARAM_VALUE.C_ENABLE_PROFILE } {
		set ext_event "PARAM_VALUE.C_EXT_EVENT${i}_FIFO_ENABLE"
		set  en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]
		set  en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ] 
		if {$en_trace ==1} {
		set_property value 1  [set $ext_event] 
                } elseif {$en_profile == 1} {
		set_property value 0  [set $ext_event]  
                } 

}
} 0
}

for {set i 0} {$i<8} {incr i} {
EvalSubstituting {i} {
proc update_PARAM_VALUE.C_SLOT_${i}_AXI_PROTOCOL {PARAM_VALUE.C_SLOT_${i}_AXI_PROTOCOL PARAM_VALUE.C_ENABLE_TRACE PARAM_VALUE.C_ENABLE_PROFILE } {
		set  en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]
		set  en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
		if {$en_profile ==1 || $en_trace ==1} {
           		set axi_prot "PARAM_VALUE.C_SLOT_${i}_AXI_PROTOCOL"
           		set_property range "AXI4,AXI3,AXI4LITE"  [set $axi_prot] 
        	} else {
   			set axi_prot "PARAM_VALUE.C_SLOT_${i}_AXI_PROTOCOL"
       			set_property range "AXI4,AXI3,AXI4S,AXI4LITE"  [set $axi_prot] 
       		}
}
} 0
}

proc update_PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS { PARAM_VALUE.C_ENABLE_PROFILE  
  PARAM_VALUE.C_ENABLE_TRACE PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} {

    set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
    set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]

    if {$en_profile == 1 || $en_trace == 1} {
      
      set_property value 0  ${PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} 
      set_property enabled false  ${PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} 
     
    } else {
  
      set_property enabled true  ${PARAM_VALUE.C_REG_ALL_MONITOR_SIGNALS} 
     
    }

}



proc update_PARAM_VALUE.ENABLE_EXT_TRIGGERS {PARAM_VALUE.ENABLE_EXT_TRIGGERS PARAM_VALUE.C_ENABLE_PROFILE  PARAM_VALUE.C_ENABLE_TRACE} {
	set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
    set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]

    if {$en_profile == 1 || $en_trace == 1} {
	    set_property value 1  ${PARAM_VALUE.ENABLE_EXT_TRIGGERS}
    } else {
	    set_property value 0  ${PARAM_VALUE.ENABLE_EXT_TRIGGERS} 
    }
      
}

proc update_PARAM_VALUE.ENABLE_EXT_EVENTS {PARAM_VALUE.ENABLE_EXT_EVENTS PARAM_VALUE.C_ENABLE_PROFILE PARAM_VALUE.C_ENABLE_TRACE} {
	 set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
    	set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]

      if {$en_profile == 1 || $en_trace == 1} {
	    if {$en_trace ==1 } {
         	set_property value 1  ${PARAM_VALUE.ENABLE_EXT_EVENTS} 
      	    } elseif {$en_profile ==1} {
         	set_property value 0  ${PARAM_VALUE.ENABLE_EXT_EVENTS} 
            }
    } else {
	    set_property value 0  ${PARAM_VALUE.ENABLE_EXT_EVENTS} 
    
    }
}

proc update_PARAM_VALUE.C_ENABLE_EVENT_COUNT {PARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_ENABLE_EVENT_COUNT PARAM_VALUE.C_ENABLE_PROFILE PARAM_VALUE.C_ENABLE_TRACE} {
	set en_advanced  [get_property value ${PARAM_VALUE.C_ENABLE_ADVANCED}]
	if {$en_advanced == 1} {
		set_property value 1 ${PARAM_VALUE.C_ENABLE_EVENT_COUNT}
	} else {
		set_property value 0 ${PARAM_VALUE.C_ENABLE_EVENT_COUNT}
	}

	set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
    	set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]

    if {$en_profile == 1 || $en_trace == 1} {
      set_property value 0  ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} 
      set_property enabled false  ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} 
      } else {
	      set_property enabled true  ${PARAM_VALUE.C_ENABLE_EVENT_COUNT} 
      }

}

proc update_PARAM_VALUE.C_ENABLE_EVENT_LOG {PARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_ENABLE_EVENT_LOG PARAM_VALUE.C_ENABLE_PROFILE PARAM_VALUE.C_ENABLE_TRACE} {
	set en_advanced  [get_property value ${PARAM_VALUE.C_ENABLE_ADVANCED}]
	if {$en_advanced == 1} {
	} else {
		set_property value 0 ${PARAM_VALUE.C_ENABLE_EVENT_LOG}
	}

	set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
    	set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]

    if {$en_profile == 1 || $en_trace == 1} {
      set_property value 0  ${PARAM_VALUE.C_ENABLE_EVENT_LOG} 
      set_property enabled false  ${PARAM_VALUE.C_ENABLE_EVENT_LOG}
      } else {
	      set_property enabled true  ${PARAM_VALUE.C_ENABLE_EVENT_LOG}
      }
}

proc update_PARAM_VALUE.C_ENABLE_ADVANCED {PARAM_VALUE.C_ENABLE_ADVANCED PARAM_VALUE.C_ENABLE_PROFILE PARAM_VALUE.C_ENABLE_TRACE} {
      
      set en_profile [ get_property value  ${PARAM_VALUE.C_ENABLE_PROFILE}]
      set en_trace [ get_property value  ${PARAM_VALUE.C_ENABLE_TRACE}]
    
       if {$en_profile == 1 || $en_trace == 1} {
	    set_property enabled false  ${PARAM_VALUE.C_ENABLE_ADVANCED} 
	    set_property value 0  ${PARAM_VALUE.C_ENABLE_ADVANCED}
    } else {
	    set_property enabled true  ${PARAM_VALUE.C_ENABLE_ADVANCED} 
      	    set_property value 1  ${PARAM_VALUE.C_ENABLE_ADVANCED} 
    }
}



proc update_PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0   ${PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_0_AXI_ID_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_0_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0  ${PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_1_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_1_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0  ${PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_2_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_2_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0   ${PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_3_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_3_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0  ${PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_4_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_4_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0   ${PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_5_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_5_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0   ${PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_6_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64 ${PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_6_AXI_DATA_WIDTH}
                }
}

proc update_PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH {PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  set_property range 0,0  ${PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH}
		
                } else {
                  set_property range 0,16 ${PARAM_VALUE.C_SLOT_7_AXI_ID_WIDTH}
		 
                }
}

proc update_PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH {PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH} {
	set val [get_property value ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL}]
		if {$val == "AXI4LITE" } {
                  
		  set_property range 32,64  ${PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH}
                } else {
                  
		  set_property range 32,64,128,256,512,1024 ${PARAM_VALUE.C_SLOT_7_AXI_DATA_WIDTH}
                }
}

#########################################################################################################################################################################33333333
proc update_gui_for_PARAM_VALUE.C_LOG_DATA_OFFLD {IPINST PARAM_VALUE.C_LOG_DATA_OFFLD} {
	set offld  [get_property value ${PARAM_VALUE.C_LOG_DATA_OFFLD}]
	if {$offld =="Stream"} {
	set_property visible true [ipgui::get_guiparamspec C_FIFO_AXIS_TID_WIDTH -of $IPINST ]
		set_property visible false [ipgui::get_guiparamspec S_AXI_OFFLD_ID_WIDTH -of $IPINST ]
	} else {
		set_property visible false [ipgui::get_guiparamspec C_FIFO_AXIS_TID_WIDTH -of $IPINST ]
		set_property visible true [ipgui::get_guiparamspec S_AXI_OFFLD_ID_WIDTH -of $IPINST ]
	}
}



proc update_gui_for_PARAM_VALUE.C_ENABLE_EVENT_COUNT {IPINST PARAM_VALUE.C_ENABLE_EVENT_COUNT } {


 
      set event_cnt [get_property value ${PARAM_VALUE.C_ENABLE_EVENT_COUNT}]
	# Procedure called when C_ENABLE_EVENT_COUNT is updated
        if {$event_cnt == 1} {
           set_property visible true [ipgui::get_groupspec -name "Event Count Parameters" -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_HAVE_SAMPLED_METRIC_CNT -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_NUM_OF_COUNTERS -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_METRIC_COUNT_SCALE -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name ENABLE_EXT_TRIGGERS -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_REG_ALL_MONITOR_SIGNALS -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_GLOBAL_COUNT_WIDTH -of $IPINST]
        } else {
           set_property visible false [ipgui::get_groupspec -name "Event Count Parameters" -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_HAVE_SAMPLED_METRIC_CNT -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_HAVE_SAMPLED_METRIC_CNT -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_NUM_OF_COUNTERS -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_METRIC_COUNT_SCALE -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name ENABLE_EXT_TRIGGERS -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_REG_ALL_MONITOR_SIGNALS -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_GLOBAL_COUNT_WIDTH -of $IPINST]
        }

}

proc update_gui_for_PARAM_VALUE.C_ENABLE_EVENT_LOG {IPINST PARAM_VALUE.C_ENABLE_EVENT_LOG PARAM_VALUE.C_ENABLE_TRACE} {
	
	  set event_log [get_property value ${PARAM_VALUE.C_ENABLE_EVENT_LOG}]
	  set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]
      	if {$event_log ==1 || $en_trace == 1 } {
    		set_property visible true [ipgui::get_pagespec -name "Log Parameters" -of $IPINST]

		if {$en_trace == 1} {
		set_property visible true [ipgui::get_guiparamspec -name C_EN_WR_ADD_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_FIRST_WRITE_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_LAST_WRITE_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_RESPONSE_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_RD_ADD_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_FIRST_READ_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_LAST_READ_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_SW_REG_WR_FLAG -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_EXT_EVENTS_FLAG -of $IPINST]
    } else {
		set_property visible false [ipgui::get_guiparamspec -name C_EN_WR_ADD_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_FIRST_WRITE_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_LAST_WRITE_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_RESPONSE_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_RD_ADD_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_FIRST_READ_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_LAST_READ_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_SW_REG_WR_FLAG -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_EXT_EVENTS_FLAG -of $IPINST]
    }	
	} else {
		set_property visible false [ipgui::get_pagespec -name "Log Parameters" -of $IPINST]
	}

	

}




proc update_gui_for_PARAM_VALUE.C_ENABLE_PROFILE  {IPINST PARAM_VALUE.C_ENABLE_PROFILE } {

	set en_profile [ get_property value ${PARAM_VALUE.C_ENABLE_PROFILE} ]
    
      if {$en_profile == 1} {
      set_property visible false [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
      set_property visible false  [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST] 
    } else {
      set_property visible true  [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST]
      set_property visible true [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
     
    }
}


proc update_gui_for_PARAM_VALUE.C_ENABLE_TRACE  {IPINST PARAM_VALUE.C_ENABLE_TRACE PARAM_VALUE.C_ENABLE_EVENT_LOG} {

    	set en_trace [ get_property value ${PARAM_VALUE.C_ENABLE_TRACE} ]
	set event_log [get_property value ${PARAM_VALUE.C_ENABLE_EVENT_LOG}]
     if {$en_trace == 1} {
      set_property visible false [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
      set_property visible false  [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST] 
    } else {
      set_property visible true  [ipgui::get_guiparamspec ENABLE_EXT_TRIGGERS -of $IPINST] 
      set_property visible true [ipgui::get_groupspec -name "External Event Parameters" -of $IPINST]
      
    }

  if {$event_log ==1 || $en_trace == 1 } {
    		set_property visible true [ipgui::get_pagespec -name "Log Parameters" -of $IPINST]

		if {$en_trace == 1} {
		set_property visible true [ipgui::get_guiparamspec -name C_EN_WR_ADD_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_FIRST_WRITE_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_LAST_WRITE_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_RESPONSE_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_RD_ADD_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_FIRST_READ_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_LAST_READ_FLAG  -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_SW_REG_WR_FLAG -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_EN_EXT_EVENTS_FLAG -of $IPINST]
    } else {
		set_property visible false [ipgui::get_guiparamspec -name C_EN_WR_ADD_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_FIRST_WRITE_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_LAST_WRITE_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_RESPONSE_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_RD_ADD_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_FIRST_READ_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_LAST_READ_FLAG  -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_SW_REG_WR_FLAG -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_EN_EXT_EVENTS_FLAG -of $IPINST]
    }	
	} else {
		set_property visible false [ipgui::get_pagespec -name "Log Parameters" -of $IPINST]
	}
 
}

proc update_gui_for_PARAM_VALUE.C_ENABLE_ADVANCED {IPINST PARAM_VALUE.C_ENABLE_ADVANCED } {

      set en_advanced  [get_property value ${PARAM_VALUE.C_ENABLE_ADVANCED}]
	if {$en_advanced == 1} {
	set_property visible true [ipgui::get_guiparamspec C_ENABLE_EVENT_LOG -of $IPINST ]
		set_property visible true [ipgui::get_guiparamspec C_ENABLE_EVENT_COUNT -of $IPINST ]
		set_property tooltip "" [ipgui::get_guiparamspec C_ENABLE_ADVANCED -of $IPINST ]
	} else {
		set_property visible false [ipgui::get_guiparamspec C_ENABLE_EVENT_LOG -of $IPINST ]
		set_property visible false [ipgui::get_guiparamspec C_ENABLE_EVENT_COUNT -of $IPINST ]
		 set_property tooltip "To enable Advanced mode, both profile and trace mode must be deselected" [ipgui::get_guiparamspec C_ENABLE_ADVANCED -of $IPINST ]
	}
}



proc update_gui_for_PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_7_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_7_AXI_PROTOCOL}]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXI_ID_WIDTH -of $IPINST]
              
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_7_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_7_AXIS_TDATA_WIDTH -of $IPINST]
	}
	
}

proc update_gui_for_PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_6_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_6_AXI_PROTOCOL} ]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXI_ID_WIDTH -of $IPINST]
              
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_6_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_6_AXIS_TDATA_WIDTH -of $IPINST]
	}
}

proc update_gui_for_PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_5_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_5_AXI_PROTOCOL}]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXI_ID_WIDTH -of $IPINST]
                
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_5_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_5_AXIS_TDATA_WIDTH -of $IPINST]
	}
}

proc update_gui_for_PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_4_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_4_AXI_PROTOCOL}]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXI_ID_WIDTH -of $IPINST]
                
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_4_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_4_AXIS_TDATA_WIDTH -of $IPINST]
	}

}

proc update_gui_for_PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_3_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_3_AXI_PROTOCOL} ]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXI_ID_WIDTH -of $IPINST]
                
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_3_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_3_AXIS_TDATA_WIDTH -of $IPINST]
	}

}
proc update_gui_for_PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_2_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_2_AXI_PROTOCOL}]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXI_ID_WIDTH -of $IPINST]
                
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_2_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_2_AXIS_TDATA_WIDTH -of $IPINST]
	}

}

proc update_gui_for_PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_1_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_1_AXI_PROTOCOL} ]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXI_ID_WIDTH -of $IPINST]
                
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_1_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_1_AXIS_TDATA_WIDTH -of $IPINST]
	}

}


proc update_gui_for_PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL {IPINST PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL} {
	# Procedure called when C_SLOT_0_AXI_PROTOCOL is updated
	set val [get_property value ${PARAM_VALUE.C_SLOT_0_AXI_PROTOCOL}]
	if {$val == "AXI4" || $val == "AXI3" || $val == "AXI4LITE"} {
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TID_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TDATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXI_DATA_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXI_ID_WIDTH -of $IPINST]
                
	} else { 
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXI_ADDR_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXI_DATA_WIDTH -of $IPINST]
		set_property visible false [ipgui::get_guiparamspec -name C_SLOT_0_AXI_ID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TID_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TUSER_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TDEST_WIDTH -of $IPINST]
		set_property visible true [ipgui::get_guiparamspec -name C_SLOT_0_AXIS_TDATA_WIDTH -of $IPINST]
	}

	#return true
}



proc update_gui_for_PARAM_VALUE.C_SUPPORT_ID_REFLECTION {IPINST PARAM_VALUE.C_SUPPORT_ID_REFLECTION} {
        set id_reflection [get_property value ${PARAM_VALUE.C_SUPPORT_ID_REFLECTION}]
	# Procedure called when C_SUPPORT_ID_REFLECTION is updated
        if {$id_reflection == 0} {
           set_property visible false [ipgui::get_guiparamspec -name C_S_AXI_ID_WIDTH -of $IPINST]
        } else {
           set_property visible true [ipgui::get_guiparamspec -name C_S_AXI_ID_WIDTH -of $IPINST]
        }
 
	return true
}

proc update_gui_for_PARAM_VALUE.C_ENABLE_EVENT_COUNT {IPINST PARAM_VALUE.C_ENABLE_EVENT_COUNT} {
	set event_cnt [get_property value ${PARAM_VALUE.C_ENABLE_EVENT_COUNT}]
	# Procedure called when C_ENABLE_EVENT_COUNT is updated
        if {$event_cnt == 1} {
           set_property visible true [ipgui::get_groupspec -name "Event Count Parameters" -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_HAVE_SAMPLED_METRIC_CNT -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_NUM_OF_COUNTERS -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_METRIC_COUNT_SCALE -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name ENABLE_EXT_TRIGGERS -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_REG_ALL_MONITOR_SIGNALS -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_GLOBAL_COUNT_WIDTH -of $IPINST]
        } else {
           set_property visible false [ipgui::get_groupspec -name "Event Count Parameters" -of $IPINST]
           set_property visible true [ipgui::get_guiparamspec -name C_HAVE_SAMPLED_METRIC_CNT -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_HAVE_SAMPLED_METRIC_CNT -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_NUM_OF_COUNTERS -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_METRIC_COUNT_SCALE -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name ENABLE_EXT_TRIGGERS -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_REG_ALL_MONITOR_SIGNALS -of $IPINST]
           set_property visible false [ipgui::get_guiparamspec -name C_GLOBAL_COUNT_WIDTH -of $IPINST]
        }
       
}
