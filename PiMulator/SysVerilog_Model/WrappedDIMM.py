import math
from migen import *
from migen.fhdl import verilog

import configparser
import os.path

# Create migen wrapper for DIMM.sv
class WrappedDIMM(Module):
    def __init__(self, configFile):
        config = configparser.ConfigParser(inline_comment_prefixes=';')
        config.sections()
        if os.path.isfile(configFile):
            config.read(configFile)
        else:
            print("Error: file " + configFile + " not found!")
            exit()

        PROTOCOL = config['dram_structure']['protocol']
        CHIPS = int(int(config['system']['bus_width']) / int(config['dram_structure']['device_width']))
        BGWIDTH = int(config['dram_structure']['bankgroups']).bit_length()-1
        BAWIDTH = int(config['dram_structure']['banks_per_group']).bit_length()-1
        ADDRWIDTH = int(config['dram_structure']['rows']).bit_length()-1
        COLWIDTH = int(config['dram_structure']['columns']).bit_length()-1
        DEVICE_WIDTH = int(config['dram_structure']['device_width'])
        BL = int(config['dram_structure']['BL'])
        CHWIDTH = 5

        BANKGROUPS = 2**BGWIDTH
        BANKSPERGROUP = 2**BAWIDTH
        DQWIDTH = DEVICE_WIDTH*CHIPS

        devices_per_rank = int(config['system']['bus_width']) / DEVICE_WIDTH
        page_size = int(config['dram_structure']['columns']) * DEVICE_WIDTH / 8 # page size in bytes
        megs_per_bank = page_size * (int(config['dram_structure']['rows']) / 1024) / 1024
        megs_per_rank = megs_per_bank * (BANKGROUPS*BANKSPERGROUP) * devices_per_rank
        RANKS = int(int(config['system']['channel_size']) / megs_per_rank)
        print("PROTOCOL=%s, RANKS=%d, CHIPS=%d, BGWIDTH=%d, BAWIDTH=%d, ADDRWIDTH=%d, COLWIDTH=%d, DEVICE_WIDTH=%d, BL=%d" % (PROTOCOL, RANKS, CHIPS, BGWIDTH, BAWIDTH, ADDRWIDTH, COLWIDTH, DEVICE_WIDTH, BL))

        tCK    = float(config['timing']['tCK'])
        AL     = int(config['timing']['AL'])     if config.has_option('timing','AL')     else 0
        CL     = int(config['timing']['CL'])     if config.has_option('timing','CL')     else 0
        CWL    = int(config['timing']['CWL'])    if config.has_option('timing','CWL')    else 0
        tRCD   = int(config['timing']['tRCD'])   if config.has_option('timing','tRCD')   else 0
        tRP    = int(config['timing']['tRP'])    if config.has_option('timing','tRP')    else 0
        tRAS   = int(config['timing']['tRAS'])   if config.has_option('timing','tRAS')   else 0
        tRFC   = int(config['timing']['tRFC'])   if config.has_option('timing','tRFC')   else 0
        tRFC2  = int(config['timing']['tRFC2'])  if config.has_option('timing','tRFC2')  else 0
        tRFC4  = int(config['timing']['tRFC4'])  if config.has_option('timing','tRFC4')  else 0
        tREFI  = int(config['timing']['tREFI'])  if config.has_option('timing','tREFI')  else 0
        tRPRE  = int(config['timing']['tRPRE'])  if config.has_option('timing','tRPRE')  else 0
        tWPRE  = int(config['timing']['tWPRE'])  if config.has_option('timing','tWPRE')  else 0
        tRRD_S = int(config['timing']['tRRD_S']) if config.has_option('timing','tRRD_S') else 0
        tRRD_L = int(config['timing']['tRRD_L']) if config.has_option('timing','tRRD_L') else 0
        tWTR_S = int(config['timing']['tWTR_S']) if config.has_option('timing','tWTR_S') else 0
        tWTR_L = int(config['timing']['tWTR_L']) if config.has_option('timing','tWTR_L') else 0
        tFAW   = int(config['timing']['tFAW'])   if config.has_option('timing','tFAW')   else 0
        tWR    = int(config['timing']['tWR'])    if config.has_option('timing','tWR')    else 0
        tWR2   = int(config['timing']['tWR2'])   if config.has_option('timing','tWR2')   else 0
        tRTP   = int(config['timing']['tRTP'])   if config.has_option('timing','tRTP')   else 0
        tCCD_S = int(config['timing']['tCCD_S']) if config.has_option('timing','tCCD_S') else 0
        tCCD_L = int(config['timing']['tCCD_L']) if config.has_option('timing','tCCD_L') else 0
        tCKE   = int(config['timing']['tCKE'])   if config.has_option('timing','tCKE')   else 0
        tCKESR = int(config['timing']['tCKESR']) if config.has_option('timing','tCKESR') else 0
        tXS    = int(config['timing']['tXS'])    if config.has_option('timing','tXS')    else 0
        tXP    = int(config['timing']['tXP'])    if config.has_option('timing','tXP')    else 0
        tRTRS  = int(config['timing']['tRTRS'])  if config.has_option('timing','tRTRS')  else 0
        print("tCK=%f, AL=%d, CL=%d, CWL=%d, tRCD=%d, tRP=%d, tRAS=%d,\n tRFC=%d, tRFC2=%d, tRFC4=%d, tREFI=%d, tRPRE=%d, tWPRE=%d, tRRD_S=%d,\n tRRD_L=%d, tWTR_S=%d, tWTR_L=%d, tFAW=%d, tWR=%d, tWR2=%d, tRTP=%d,\n tCCD_S=%d, tCCD_L=%d, tCKE=%d, tCKESR=%d, tXS=%d, tXP=%d, tRTRS=%d" % (tCK, AL, CL, CWL, tRCD, tRP, tRAS, tRFC, tRFC2, tRFC4, tREFI, tRPRE, tWPRE, tRRD_S, tRRD_L, tWTR_S, tWTR_L, tFAW, tWR, tWR2, tRTP, tCCD_S, tCCD_L, tCKE, tCKESR, tXS, tXP, tRTRS))

        self.act_n = Signal()
        self.addr = Signal(ADDRWIDTH)
        if (BGWIDTH>0):
            self.bg = Signal(BGWIDTH)
        self.ba = Signal(BAWIDTH)
        self.ck2x = Signal()
        self.ck_c = Signal()
        self.ck_t = Signal()
        self.reset_n = Signal()
        self.cke = Signal()
        self.cs_n = Signal(RANKS)
        self.dq = Signal(DEVICE_WIDTH*CHIPS)
        self.dqs_c = Signal(CHIPS)
        self.dqs_t = Signal(CHIPS)
        self.odt = Signal()
        self.parity = Signal()
        self.stall = Signal()

        if (BGWIDTH>0):
            self.io = {self.act_n, self.addr, self.bg, self.ba, self.ck2x, self.ck_c, self.ck_t, self.reset_n, self.cke, self.cs_n,
                    self.dq, self.dqs_c, self.dqs_t, self.odt, self.parity, self.stall}
            DIMMi = Instance("DIMM", name="WrappedDIMMi",
                            p_PROTOCOL=PROTOCOL, # parse ok
                            p_RANKS=Instance.PreformattedParam(RANKS), # parse ok
                            p_CHIPS=Instance.PreformattedParam(CHIPS), # parse ok
                            p_BGWIDTH=Instance.PreformattedParam(BGWIDTH), # parse ok
                            p_BAWIDTH=Instance.PreformattedParam(BAWIDTH), # parse ok
                            p_ADDRWIDTH=Instance.PreformattedParam(ADDRWIDTH), # parse ok
                            p_COLWIDTH=Instance.PreformattedParam(COLWIDTH), # parse ok
                            p_DEVICE_WIDTH=Instance.PreformattedParam(DEVICE_WIDTH), # parse ok
                            p_BL=Instance.PreformattedParam(BL), # parse ok
                            p_CHWIDTH=Instance.PreformattedParam(CHWIDTH), # FPGA host specific

                            i_act_n=self.act_n,
                            i_A=self.addr,
                            i_bg=self.bg,
                            i_ba=self.ba,
                            i_ck2x=self.ck2x,
                            i_ck_c=self.ck_c,
                            i_ck_t=self.ck_t,
                            i_cke=self.cke,
                            i_cs_n=self.cs_n,
                            i_reset_n=self.reset_n,

                            io_dq=self.dq,
                            io_dqs_c=self.dqs_c,
                            io_dqs_t=self.dqs_t,

                            i_odt=self.odt,
                            i_parity=self.parity,
                            o_stall=self.stall
                            )
        else:
            self.io = {self.act_n, self.addr, self.ba, self.ck2x, self.ck_c, self.ck_t, self.reset_n, self.cke, self.cs_n,
                    self.dq, self.dqs_c, self.dqs_t, self.odt, self.parity, self.stall}
            DIMMi = Instance("DIMM", name="WrappedDIMMi",
                            p_PROTOCOL=PROTOCOL, # parse ok
                            p_RANKS=Instance.PreformattedParam(RANKS), # parse ok
                            p_CHIPS=Instance.PreformattedParam(CHIPS), # parse ok
                            p_BGWIDTH=Instance.PreformattedParam(BGWIDTH), # parse ok
                            p_BAWIDTH=Instance.PreformattedParam(BAWIDTH), # parse ok
                            p_ADDRWIDTH=Instance.PreformattedParam(ADDRWIDTH), # parse ok
                            p_COLWIDTH=Instance.PreformattedParam(COLWIDTH), # parse ok
                            p_DEVICE_WIDTH=Instance.PreformattedParam(DEVICE_WIDTH), # parse ok
                            p_BL=Instance.PreformattedParam(BL), # parse ok
                            p_CHWIDTH=Instance.PreformattedParam(CHWIDTH), # FPGA host specific

                            i_act_n=self.act_n,
                            i_A=self.addr,
                            i_ba=self.ba,
                            i_ck2x=self.ck2x,
                            i_ck_c=self.ck_c,
                            i_ck_t=self.ck_t,
                            i_cke=self.cke,
                            i_cs_n=self.cs_n,
                            i_reset_n=self.reset_n,

                            io_dq=self.dq,
                            io_dqs_c=self.dqs_c,
                            io_dqs_t=self.dqs_t,

                            i_odt=self.odt,
                            i_parity=self.parity,
                            o_stall=self.stall
                            )

        self.specials += DIMMi


def test_instance_module():
    configFile = '../DRAMsim3/configs/ddr4_debug.ini'
    WD = WrappedDIMM(configFile)
    verilog.convert(WD, WD.io, name="WrappedDIMM").write("WrappedDIMM.sv")


if __name__ == "__main__":
    test_instance_module()

# DDR3_1Gb_x8_1333 DDR3_4Gb_x16_1600 DDR3_4Gb_x16_1866 DDR3_4Gb_x4_1600 DDR3_4Gb_x4_1866 DDR3_4Gb_x8_1600 DDR3_4Gb_x8_1866
# DDR3_8Gb_x16_1600 DDR3_8Gb_x16_1866 DDR3_8Gb_x4_1600 DDR3_8Gb_x4_1866 DDR3_8Gb_x8_1600 DDR3_8Gb_x8_1866 ddr3_debug

# DDR4_4Gb_x16_1866 DDR4_4Gb_x16_2133_2 DDR4_4Gb_x16_2133 DDR4_4Gb_x16_2400_2 DDR4_4Gb_x16_2400 DDR4_4Gb_x16_2666_2 DDR4_4Gb_x16_2666
# DDR4_4Gb_x4_1866 DDR4_4Gb_x4_2133_2 DDR4_4Gb_x4_2133 DDR4_4Gb_x4_2400_2 DDR4_4Gb_x4_2400 DDR4_4Gb_x4_2666_2 DDR4_4Gb_x4_2666
# DDR4_4Gb_x8_1866 DDR4_4Gb_x8_2133_2 DDR4_4Gb_x8_2133 DDR4_4Gb_x8_2400_2 # DDR4_4Gb_x8_2400 DDR4_4Gb_x8_2666_2 DDR4_4Gb_x8_2666
# DDR4_8Gb_x16_1866 DDR4_8Gb_x16_2133_2 DDR4_8Gb_x16_2133 # DDR4_8Gb_x16_2400_2 DDR4_8Gb_x16_2400 DDR4_8Gb_x16_2666_2 DDR4_8Gb_x16_2666
# DDR4_8Gb_x16_2933_2 DDR4_8Gb_x16_2933 # DDR4_8Gb_x16_3200 DDR4_8Gb_x4_1866 DDR4_8Gb_x4_2133_2 DDR4_8Gb_x4_2133 DDR4_8Gb_x4_2400_2
# DDR4_8Gb_x4_2400 DDR4_8Gb_x4_2666_2 DDR4_8Gb_x4_2666 DDR4_8Gb_x4_2933_2 DDR4_8Gb_x4_2933 DDR4_8Gb_x4_3200 DDR4_8Gb_x8_1866 DDR4_8Gb_x8_2133_2
# DDR4_8Gb_x8_2133 DDR4_8Gb_x8_2400_2 DDR4_8Gb_x8_2400 DDR4_8Gb_x8_2666_2 DDR4_8Gb_x8_2666 DDR4_8Gb_x8_2933_2 DDR4_8Gb_x8_2933 DDR4_8Gb_x8_3200 ddr4_debug

# GDDR5_1Gb_x32 GDDR5_8Gb_x32 GDDR5X_8Gb_x32 GDDR6_8Gb_x16
# HBM1_4Gb_x128 HBM2_4Gb_x128 HBM2_8Gb_x128 HBM_4Gb_x128
# HMC2_8GB_4Lx16 HMC_2GB_4Lx16_dummy HMC_2GB_4Lx16 HMC_4GB_4Lx16
# lpddr_2Gb_x16 LPDDR3_8Gb_x32_1333 LPDDR3_8Gb_x32_1600 LPDDR3_8Gb_x32_1866 LPDDR4_8Gb_x16_2400
# ST-1.2x ST-1.5x ST-2.0x