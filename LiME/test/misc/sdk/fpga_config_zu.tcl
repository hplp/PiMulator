set PLAT_DIR [lindex $argv 0]
puts "connect"
puts [connect -url tcp:127.0.0.1:3121]
puts [source /opt/Xilinx/SDK/2018.2/scripts/sdk/util/zynqmp_utils.tcl]
puts [targets -set -filter {name =~"APU*"}]
puts "rst -srst"
puts [rst -srst]
after 2000
puts "fpga -file $PLAT_DIR/system_wrapper.bit"
puts [fpga -file $PLAT_DIR/system_wrapper.bit]
#puts [targets -set -filter {name =~"APU*"}]
puts [source $PLAT_DIR/psu_init.tcl]
puts [psu_init]
after 1000
puts [psu_ps_pl_isolation_removal]
after 1000
puts [psu_ps_pl_reset_config]
puts [catch { psu_protection };list]
puts "disconnect"
puts [catch { disconnect };list]
puts [exit]
