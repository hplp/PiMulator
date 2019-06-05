set PROG_ELF [lindex $argv 0]
puts "connect"
puts [connect -url tcp:127.0.0.1:3121]
puts [targets -set -filter {name =~"*A53*0"}]
puts [rst -processor]
puts [configparams force-mem-accesses 1]
puts "dow $PROG_ELF"
puts [dow $PROG_ELF]
puts [bpadd -addr &exit]
puts -nonewline "con -block"
puts [con -block]
puts "disconnect"
puts [catch { disconnect };list]
puts [exit]
