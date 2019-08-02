setws sdk
openhw hw_platform_0
repo -set device-tree-xlnx
hsi create_sw_design devtree -os device_tree -proc psu_cortexa53_0
hsi generate_target -dir dts
closehw hw_platform_0
