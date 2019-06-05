make D=CLIENT,CLOCKS,STATS
xsdb.bat -tcl ../../misc/sdk/fpga_config_zu.tcl ../../../hw_platform_0
xsdb.bat -tcl ../../misc/sdk/mb_start.tcl ../mcu/$1.elf
xsdb.bat -tcl ../../misc/sdk/a53_run.tcl $1.elf
