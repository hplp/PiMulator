set PDIR ../standalone
setws sdk
# hw_platform_0
createhw -name hw_platform_0 -hwspec [lindex $argv 0]
# patch psu_init.*
exec sed -i.bak -f $PDIR/sar.sed sdk/hw_platform_0/psu_init.c
exec sed -i.bak -f $PDIR/sar.sed sdk/hw_platform_0/psu_init_gpl.c
exec sed -i.bak -f $PDIR/sar.sed sdk/hw_platform_0/psu_init.tcl
# FSBL & BSP
createapp -name fsbl -app {Zynq MP FSBL} -proc psu_cortexa53_0 -hwproject hw_platform_0 -os standalone -lang C -arch 64
configapp -app fsbl build-config release
# patch translation table
exec cp -p $PDIR/translation_table.S sdk/fsbl_bsp/psu_cortexa53_0/libsrc/standalone_v6_7/src
exec cp -p $PDIR/translation_table.S sdk/fsbl/src/xfsbl_translation_table.S
# PMUFW
createapp -name pmufw -app {ZynqMP PMU Firmware} -proc psu_pmu_0 -hwproject hw_platform_0 -os standalone -lang C
configapp -app pmufw build-config release
# build & close
projects -build
closehw hw_platform_0
