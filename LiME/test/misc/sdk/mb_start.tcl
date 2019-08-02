# Commands to start a program on the MicroBlaze
set PROG_ELF [lindex $argv 0]
puts "connect"
puts [connect -url tcp:127.0.0.1:3121]
puts [targets -set -filter {name =~"MicroBlaze*0"}]
puts [rst -processor]
puts [configparams force-mem-accesses 1]
puts "dow $PROG_ELF"
puts [dow $PROG_ELF]
puts [bpadd -addr &exit]
puts -nonewline "con"
puts [con]
puts "disconnect"
puts [catch { disconnect };list]
puts [exit]
