# Commands to stop a program on the MicroBlaze
puts [connect -url tcp:127.0.0.1:3121]
puts [targets -set -filter {name =~"MicroBlaze*0"}]
puts [stop]
puts [catch { disconnect };list]
puts [exit]
