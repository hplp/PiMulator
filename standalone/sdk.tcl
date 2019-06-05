setws sdk
# hw_platform_0
createhw -name hw_platform_0 -hwspec [lindex $argv 0]
# patch psu_init.*
exec sed -i.bak -f sar.sed sdk/hw_platform_0/psu_init.c
exec sed -i.bak -f sar.sed sdk/hw_platform_0/psu_init_gpl.c
exec sed -i.bak -f sar.sed sdk/hw_platform_0/psu_init.tcl
# A53 BSP
createbsp -name standalone_bsp_a53 -proc psu_cortexa53_0 -hwproject hw_platform_0 -arch 64
setlib -bsp standalone_bsp_a53 -lib xilffs
# PARAMETER READ_ONLY = false
# PARAMETER USE_MKFS = false
updatemss -mss sdk/standalone_bsp_a53/system.mss
regenbsp -bsp standalone_bsp_a53
# patch translation table
exec cp -p translation_table.S sdk/standalone_bsp_a53/psu_cortexa53_0/libsrc/standalone_v6_7/src
# MB BSP
createbsp -name standalone_bsp_mb -proc engine_0_microblaze_0 -hwproject hw_platform_0
updatemss -mss sdk/standalone_bsp_mb/system.mss
regenbsp -bsp standalone_bsp_mb
# build & close
projects -build
closehw hw_platform_0
