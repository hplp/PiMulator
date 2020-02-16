# need to get images path defined early
source $env(LIB_DIR)/ppc/util.tcl

proc mconfig { name env_name def } {
    global mconf
    global env

    if { [info exists env($env_name)] } { set mconf($name) $env($env_name) }
    if { ![info exists mconf($name)] } { set mconf($name) $def }
}

mconfig cpus CPUS 1
mconfig threads THREADS 1
mconfig memory MEM_SIZE 4G

# Should we stop on an illeagal instruction
mconfig stop_on_ill MAMBO_STOP_ON_ILL false

# Location of application binary to load
mconfig boot_image SKIBOOT ../../skiboot.lid

# Boot: Memory location to load boot_image, for binary or vmlinux
mconfig boot_load MAMBO_BOOT_LOAD 0x30000000

# Boot: Value of PC after loading, for binary or vmlinux
mconfig boot_pc	MAMBO_BOOT_PC 0x30000010

# Payload: Allow for a Linux style ramdisk/initrd
if { ![info exists env(SKIBOOT_ZIMAGE)] } {
	error "Please set SKIBOOT_ZIMAGE to the path of your zImage.epapr"
}
mconfig payload PAYLOAD $env(SKIBOOT_ZIMAGE)

mconfig linux_cmdline LINUX_CMDLINE ""

# Paylod: Memory location for a Linux style ramdisk/initrd
mconfig payload_addr PAYLOAD_ADDR 0x20000000;

# FW: Where should ePAPR Flat Devtree Binary be loaded
mconfig epapr_dt_addr EPAPR_DT_ADDR 0x1f00000;# place at 31M

# Disk: Location of file to use a bogus disk 0
mconfig rootdisk ROOTDISK none

# Disk: File to use for re COW file: none or <file>
mconfig rootdisk_cow MAMBO_ROOTDISK_COW none

# Disk: COW method to use
mconfig rootdisk_cow_method MAMBO_ROOTDISK_COW_METHOD newcow

# Disk: COW hash size
mconfig rootdisk_cow_hash MAMBO_ROOTDISK_COW_HASH 1024

# Net: What type of networking: none, phea, bogus
mconfig net MAMBO_NET none

# Net: What is the base interface for the tun/tap device
mconfig tap_base MAMBO_NET_TAP_BASE 0


#
# Create machine config
#
set default_config [display default_configure]
define dup $default_config myconf
myconf config cpus $mconf(cpus)
myconf config processor/number_of_threads $mconf(threads)
myconf config memory_size $mconf(memory)
myconf config processor_option/ATTN_STOP true
myconf config processor_option/stop_on_illegal_instruction $mconf(stop_on_ill)
myconf config UART/0/enabled false
myconf config SimpleUART/enabled false
myconf config enable_rtas_support false
myconf config processor/cpu_frequency 512M
myconf config processor/timebase_frequency 1/1
myconf config enable_pseries_nvram false
myconf config machine_option/NO_RAM TRUE
myconf config machine_option/NO_ROM TRUE

if { $default_config == "PEGASUS" } {
    # We need to be DD2 or greater on p8 for the HILE HID bit.
    myconf config processor/initial/PVR 0x4b0201
}
if { $default_config == "P9" } {
    # PVR configured for POWER9 DD2.0 Scale out 24 Core (ie SMT4)
    myconf config processor/initial/PVR 0x4e1200
    myconf config processor/initial/SIM_CTRL1 0xc228000400000000
}
if { [info exists env(SKIBOOT_SIMCONF)] } {
    source $env(SKIBOOT_SIMCONF)
}

define machine myconf mysim

#
# Include various utilities
#

source $env(LIB_DIR)/common/epapr.tcl
if {![info exists of::encode_compat]} {
    source $env(LIB_DIR)/common/openfirmware_utils.tcl
}

# Only source mambo_utils.tcl if it exists in the current directory. That
# allows running mambo in another directory to the one skiboot.tcl is in.
if { [file exists mambo_utils.tcl] } then {
	source mambo_utils.tcl

	if { [info exists env(VMLINUX_MAP)] } {
		global linux_symbol_map

		set fp [open $env(VMLINUX_MAP) r]
		set linux_symbol_map [read $fp]
		close $fp
	}

	if { [info exists env(SKIBOOT_MAP)] } {
		global skiboot_symbol_map

		set fp [open $env(SKIBOOT_MAP) r]
		set skiboot_symbol_map [read $fp]
		close $fp
	}
}

#
# Instanciate xscom
#

set xscom_base 0x1A0000000000
mysim xscom create $xscom_base

# Setup bogus IO

if { $mconf(rootdisk) != "none" } {
    # Now load the bogus disk image
    switch $mconf(rootdisk_cow) {
	none {
	    mysim bogus disk init 0 $mconf(rootdisk) rw
	    puts "bogusdisk initialized for $mconf(rootdisk)"
	}
	default {
	    mysim bogus disk init 0 $mconf(rootdisk) \
		$mconf(rootdisk_cow_method) \
		$mconf(rootdisk_cow) $mconf(rootdisk_cow_hash)
	}
    }
}
switch $mconf(net) {
    none {
	puts "No network support selected"
    }
    bogus - bogusnet {
	set net_tap [format "tap%d" $mconf(tap_base)]
	mysim bogus net init 0 $mconf(net_mac) $net_tap
    }
    default {
	error "Bad net \[none | bogus]: $mconf(net)"
    }
}

# Device tree fixups

set root_node [mysim of find_device "/"]

mysim of addprop $root_node string "epapr-version" "ePAPR-1.0"
mysim of setprop $root_node "compatible" "ibm,powernv"

set cpus_node [mysim of find_device "/cpus"]
mysim of addprop $cpus_node int "#address-cells" 1
mysim of addprop $cpus_node int "#size-cells" 0

set mem0_node [mysim of find_device "/memory@0"]
mysim of addprop $mem0_node int "ibm,chip-id" 0

set xscom_node [ mysim of addchild $root_node xscom [format %x $xscom_base]]
set reg [list $xscom_base 0x10000000]
mysim of addprop $xscom_node array64 "reg" reg
mysim of addprop $xscom_node empty "scom-controller" ""
mysim of addprop $xscom_node int "ibm,chip-id" 0
mysim of addprop $xscom_node int "#address-cells" 1
mysim of addprop $xscom_node int "#size-cells" 1
set compat [list]
lappend compat "ibm,xscom"
lappend compat "ibm,power8-xscom"
set compat [of::encode_compat $compat]
mysim of addprop $xscom_node byte_array "compatible" $compat

# Load any initramfs
set cpio_start 0x80000000
set cpio_end $cpio_start
set cpio_size 0
if { [info exists env(SKIBOOT_INITRD)] } {

    set cpios [split $env(SKIBOOT_INITRD) ","]

    foreach cpio_file $cpios {
	    set cpio_file [string trim $cpio_file]
	    set cpio_size [file size $cpio_file]
	    mysim mcm 0 memory fread $cpio_end $cpio_size $cpio_file
	    set cpio_end [expr $cpio_end + $cpio_size]
    }

    set chosen_node [mysim of find_device /chosen]
    mysim of addprop $chosen_node int "linux,initrd-start" $cpio_start
    mysim of addprop $chosen_node int "linux,initrd-end"   $cpio_end
}

# Default NVRAM is blank and will be formatted by Skiboot if no file is provided
set fake_nvram_start $cpio_end
set fake_nvram_size 0x40000
# Load any fake NVRAM file if provided
if { [info exists env(SKIBOOT_NVRAM)] } {
    # Set up and write NVRAM file
    set fake_nvram_file $env(SKIBOOT_NVRAM)
    set fake_nvram_size [file size $fake_nvram_file]
    mysim mcm 0 memory fread $fake_nvram_start $fake_nvram_size $fake_nvram_file
}

# Add device tree entry for NVRAM
set reserved_memory [mysim of addchild $root_node "reserved-memory" ""]
mysim of addprop $reserved_memory int "#size-cells" 2
mysim of addprop $reserved_memory int "#address-cells" 2
mysim of addprop $reserved_memory empty "ranges" ""

set initramfs_res [mysim of addchild $reserved_memory "initramfs" ""]
set reg [list $cpio_start $cpio_size ]
mysim of addprop $initramfs_res array64 "reg" reg
mysim of addprop $initramfs_res empty "name" "initramfs"

set fake_nvram_node [mysim of addchild $reserved_memory "ibm,fake-nvram" ""]
set reg [list $fake_nvram_start $fake_nvram_size ]
mysim of addprop $fake_nvram_node array64 "reg" reg
mysim of addprop $fake_nvram_node empty "name" "ibm,fake-nvram"

# Allow P9 to use all idle states
if { $default_config == "P9" } {
    set opal_node [mysim of addchild $root_node "ibm,opal" ""]
    set power_mgt_node [mysim of addchild $opal_node "power-mgt" ""]
    mysim of addprop $power_mgt_node int "ibm,enabled-stop-levels" 0xffffffff
}

# Init CPUs
set pir 0
for { set c 0 } { $c < $mconf(cpus) } { incr c } {
    set cpu_node [mysim of find_device "/cpus/PowerPC@$pir"]
    mysim of addprop $cpu_node int "ibm,pir" $pir
    set reg  [list 0x0000001c00000028 0xffffffffffffffff]
    mysim of addprop $cpu_node array64 "ibm,processor-segment-sizes" reg

    mysim of addprop $cpu_node int "ibm,chip-id" $c

    # Create a chip node to tell skiboot to create another chip for this CPU.
    # This bubbles up to Linux which will then see a new chip (aka nid).
    # For chip 0 the xscom node above has already definied chip 0, so skip it.
    if { $c > 0 } {
        set node [mysim of addchild $root_node "mambo-chip" [format %x $c]]
        mysim of addprop $node int "ibm,chip-id" $c
        mysim of addprop $node string "compatible" "ibm,mambo-chip"
    }

    set reg {}
    lappend reg 0x0000000c 0x00000010 0x00000018 0x00000022
    mysim of addprop $cpu_node array "ibm,processor-page-sizes" reg

    set reg {}
    lappend reg 0x0c 0x000 3 0x0c 0x0000 ;#  4K seg  4k pages
    lappend reg              0x10 0x0007 ;#  4K seg 64k pages
    lappend reg              0x18 0x0038 ;#  4K seg 16M pages
    lappend reg 0x10 0x110 2 0x10 0x0001 ;# 64K seg 64k pages
    lappend reg              0x18 0x0008 ;# 64K seg 16M pages
    lappend reg 0x18 0x100 1 0x18 0x0000 ;# 16M seg 16M pages
    lappend reg 0x22 0x120 1 0x22 0x0003 ;# 16G seg 16G pages
    mysim of addprop $cpu_node array "ibm,segment-page-sizes" reg

    if { $default_config == "P9" } {
        # Set actual page size encodings
        set reg {}
        # 4K pages
        lappend reg 0x0000000c
        # 64K pages
        lappend reg 0xa0000010
        # 2M pages
        lappend reg 0x20000015
        # 1G pages
        lappend reg 0x4000001e
        mysim of addprop $cpu_node array "ibm,processor-radix-AP-encodings" reg

        set reg {}
	# POWER9 PAPR defines upto bytes 62-63
	# header + bytes 0-5
	lappend reg 0x4000f63fc70080c0
	# bytes 6-13
	lappend reg 0x8000000000000000
	# bytes 14-21
	lappend reg 0x0000800080008000
	# bytes 22-29 22/23=TM
	lappend reg 0x8000800080008000
	# bytes 30-37
	lappend reg 0x80008000C0008000
	# bytes 38-45 40/41=radix
	lappend reg 0x8000800080008000
	# bytes 46-55
	lappend reg 0x8000800080008000
	# bytes 54-61 58/59=seg tbl
	lappend reg 0x8000800080008000
	# bytes 62-69
	lappend reg 0x8000000000000000
	mysim of addprop $cpu_node array64 "ibm,pa-features" reg
    } else {
        set reg {}
	lappend reg 0x6000f63fc70080c0
	mysim of addprop $cpu_node array64 "ibm,pa-features" reg
    }

    set irqreg [list]
    for { set t 0 } { $t < $mconf(threads) } { incr t } {
	mysim mcm 0 cpu $c thread $t set spr pc $mconf(boot_pc)
	mysim mcm 0 cpu $c thread $t set gpr 3 $mconf(epapr_dt_addr)
	mysim mcm 0 cpu $c thread $t config_on
	mysim mcm 0 cpu $c thread $t set spr pir $pir
	lappend irqreg $pir
	incr pir
    }
    mysim of addprop $cpu_node array "ibm,ppc-interrupt-server#s" irqreg
}

#Add In-Memory Collection Counter nodes
if { $default_config == "P9" } {
   #Add the base node "imc-counters"
   set imc_c [mysim of addchild $root_node "imc-counters" ""]
   mysim of addprop $imc_c string "compatible" "ibm,opal-in-memory-counters"
   mysim of addprop $imc_c int "#address-cells" 1
   mysim of addprop $imc_c int "#size-cells" 1
   mysim of addprop $imc_c int "version-id" 1

      #Add a common mcs event node
      set mcs_et [mysim of addchild $imc_c "nest-mcs-events" ""]
      mysim of addprop $mcs_et int "#address-cells" 1
      mysim of addprop $mcs_et int "#size-cells" 1

         #Add a event
         set et [mysim of addchild $mcs_et event [format %x 0]]
         mysim of addprop  $et string "event-name" "64B_RD_OR_WR_DISP_PORT01"
         mysim of addprop  $et string "unit" "MiB/s"
         mysim of addprop  $et string "scale" "4"
         mysim of addprop  $et int "reg" 0

        #Add a event
        set et [mysim of addchild $mcs_et event [format %x 1]]
        mysim of addprop  $et string "event-name" "64B_WR_DISP_PORT01"
        mysim of addprop  $et string "unit" "MiB/s"
        mysim of addprop  $et int "reg" 40

        #Add a event
        set et [mysim of addchild $mcs_et event [format %x 2]]
        mysim of addprop  $et string "event-name" "64B_RD_DISP_PORT01"
        mysim of addprop  $et string "scale" "100"
        mysim of addprop  $et int "reg" 64

        #Add a event
        set et [mysim of addchild $mcs_et event [format %x 3]]
        mysim of addprop  $et string "event-name" "64B_XX_DISP_PORT01"
        mysim of addprop  $et int "reg" 32

     #Add a mcs device node
     set mcs_01 [mysim of addchild $imc_c "mcs01" ""]
     mysim of addprop $mcs_01 string "compatible" "ibm,imc-counters"
     mysim of addprop  $mcs_01 string "events-prefix" "PM_MCS01_"
     mysim of addprop  $mcs_01 int "reg" 65536
     mysim of addprop  $mcs_01 int "size" 262144
     mysim of addprop  $mcs_01 int "offset" 1572864
     mysim of addprop  $mcs_01 int "events" $mcs_et
     mysim of addprop  $mcs_01 int "type" 16
     mysim of addprop $mcs_01 string "unit" "KiB/s"
     mysim of addprop $mcs_01 string "scale" "8"

      #Add a common core event node
      set ct_et [mysim of addchild $imc_c "core-thread-events" ""]
      mysim of addprop $ct_et int "#address-cells" 1
      mysim of addprop $ct_et int "#size-cells" 1

         #Add a event
         set cet [mysim of addchild $ct_et event [format %x 200]]
         mysim of addprop  $cet string "event-name" "0THRD_NON_IDLE_PCYC"
         mysim of addprop  $cet string "desc" "The number of processor cycles when all threads are idle"
         mysim of addprop  $cet int "reg" 200

     #Add a core device node
     set core [mysim of addchild $imc_c "core" ""]
     mysim of addprop $core string "compatible" "ibm,imc-counters"
     mysim of addprop  $core string "events-prefix" "CPM_"
     mysim of addprop  $core int "reg" 24
     mysim of addprop  $core int "size" 8192
     mysim of addprop  $core string "scale" "512"
     mysim of addprop  $core int "events" $ct_et
     mysim of addprop  $core int "type" 4

     #Add a thread device node
     set thread [mysim of addchild $imc_c "thread" ""]
     mysim of addprop $thread string "compatible" "ibm,imc-counters"
     mysim of addprop  $thread string "events-prefix" "CPM_"
     mysim of addprop  $thread int "reg" 24
     mysim of addprop  $thread int "size" 8192
     mysim of addprop  $thread string "scale" "512"
     mysim of addprop  $thread int "events" $ct_et
     mysim of addprop  $thread int "type" 1
}

mconfig enable_stb SKIBOOT_ENABLE_MAMBO_STB 0

if { [info exists env(SKIBOOT_ENABLE_MAMBO_STB)] } {
    set stb_node [ mysim of addchild $root_node "ibm,secureboot" "" ]
    mysim of addprop $stb_node string "compatible" "ibm,secureboot-v1-softrom"
    mysim of addprop $stb_node string "secure-enabled" ""
    mysim of addprop $stb_node string "trusted-enabled" ""
    mysim of addprop $stb_node string "hash-algo" "sha512"
    set hw_key_hash {}
    lappend hw_key_hash 0x40d487ff
    lappend hw_key_hash 0x7380ed6a
    lappend hw_key_hash 0xd54775d5
    lappend hw_key_hash 0x795fea0d
    lappend hw_key_hash 0xe2f541fe
    lappend hw_key_hash 0xa9db06b8
    lappend hw_key_hash 0x466a42a3
    lappend hw_key_hash 0x20e65f75
    lappend hw_key_hash 0xb4866546
    lappend hw_key_hash 0x0017d907
    lappend hw_key_hash 0x515dc2a5
    lappend hw_key_hash 0xf9fc5095
    lappend hw_key_hash 0x4d6ee0c9
    lappend hw_key_hash 0xb67d219d
    lappend hw_key_hash 0xfb708535
    lappend hw_key_hash 0x1d01d6d1
    mysim of addprop $stb_node array "hw-key-hash" hw_key_hash
}

# Kernel command line args, appended to any from the device tree
# e.g.: of::set_bootargs "xmon"
#
# Can be set from the environment by setting LINUX_CMDLINE.
of::set_bootargs $mconf(linux_cmdline)

# Load images

set boot_size [file size $mconf(boot_image)]
mysim memory fread $mconf(boot_load) $boot_size $mconf(boot_image)

set payload_size [file size $mconf(payload)]
mysim memory fread $mconf(payload_addr) $payload_size $mconf(payload)

# Flatten it
epapr::of2dtb mysim $mconf(epapr_dt_addr)

# Set run speed
mysim mode fastest

if { [info exists env(SKIBOOT_AUTORUN)] } {
    mysim go
}
