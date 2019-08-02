set PLAT_DIR [lindex $argv 0]
puts "connect"
puts [connect -url tcp:127.0.0.1:3121]
puts [targets -set -filter {name =~"APU*"} -index 0]
puts [rst -srst]
#puts [reset_zynqpl]
after 500
puts [configparams force-mem-accesses 1]
puts "fpga -file $PLAT_DIR/system_wrapper.bit"
puts [fpga -file $PLAT_DIR/system_wrapper.bit]
puts [source $PLAT_DIR/ps7_init.tcl]
puts [ps7_init]
puts [ps7_post_config]
#puts [xclearzynqresetstatus 64]
puts "disconnect"
puts [catch { disconnect };list]
puts [exit]
