import math
from migen import *
from migen.fhdl import verilog

import configparser

# Create migen wrapper for DIMM.sv
class WrappedDIMM(Module):
    def __init__(self, configFile):
        config = configparser.ConfigParser()
        config.sections()
        config.read(configFile)

        PROTOCOL = config['dram_structure']['protocol']
        RANKS = 10
        CHIPS = int(int(config['system']['bus_width']) / int(config['dram_structure']['device_width']))
        BGWIDTH = int(config['dram_structure']['bankgroups']).bit_length()-1
        BAWIDTH = int(config['dram_structure']['banks_per_group']).bit_length()-1
        ADDRWIDTH = int(config['dram_structure']['rows']).bit_length()-1
        COLWIDTH = int(config['dram_structure']['columns']).bit_length()-1
        DEVICE_WIDTH = int(config['dram_structure']['device_width'])
        BL = int(config['dram_structure']['BL'])
        CHWIDTH = 5
        print(PROTOCOL, CHIPS, BGWIDTH, BAWIDTH, ADDRWIDTH, COLWIDTH, DEVICE_WIDTH, BL)

        tCK    = config['timing']['tCK']
        AL     = int(config['timing']['AL'])
        CL     = int(config['timing']['CL'])
        CWL    = int(config['timing']['CWL'])
        tRCD   = int(config['timing']['tRCD'])
        tRP    = int(config['timing']['tRP'])
        tRAS   = int(config['timing']['tRAS'])
        tRFC   = int(config['timing']['tRFC'])
        tRFC2  = int(config['timing']['tRFC2'])
        tRFC4  = int(config['timing']['tRFC4'])
        tREFI  = int(config['timing']['tREFI'])
        tRPRE  = int(config['timing']['tRPRE'])
        tWPRE  = int(config['timing']['tWPRE'])
        tRRD_S = int(config['timing']['tRRD_S'])
        tRRD_L = int(config['timing']['tRRD_L'])
        tWTR_S = int(config['timing']['tWTR_S'])
        tWTR_L = int(config['timing']['tWTR_L'])
        tFAW   = int(config['timing']['tFAW'])
        tWR    = int(config['timing']['tWR'])
        tWR2   = int(config['timing']['tWR2'])
        tRTP   = int(config['timing']['tRTP'])
        tCCD_S = int(config['timing']['tCCD_S'])
        tCCD_L = int(config['timing']['tCCD_L'])
        tCKE   = int(config['timing']['tCKE'])
        tCKESR = int(config['timing']['tCKESR'])
        tXS    = int(config['timing']['tXS'])
        tXP    = int(config['timing']['tXP'])
        tRTRS  = int(config['timing']['tRTRS'])
        print(tCK, AL, CL, CWL, tRCD, tRP, tRAS, tRFC, tRFC2, tRFC4, tREFI, tRPRE, tWPRE, tRRD_S, tRRD_L, tWTR_S, tWTR_L, tFAW, tWR, tWR2, tRTP, tCCD_S, tCCD_L, tCKE, tCKESR, tXS, tXP, tRTRS)

        BANKGROUPS = 2**BGWIDTH
        BANKSPERGROUP = 2**BAWIDTH
        DQWIDTH = DEVICE_WIDTH*CHIPS

        self.act_n = Signal()
        self.addr = Signal(ADDRWIDTH)
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
        # self.cachesync = Signal(BANKGROUPS*BANKSPERGROUP)
        self.stall = Signal()

        self.io = {self.act_n, self.addr, self.bg, self.ba,
                   self.ck2x, self.ck_c, self.ck_t, self.reset_n, self.cke, self.cs_n,
                   self.dq, self.dqs_c, self.dqs_t, self.odt, self.parity, # self.cachesync,
                   self.stall}

        DIMMi = Instance("DIMM", name="WrappedDIMMi",
                        p_RANKS=Instance.PreformattedParam(RANKS),
                        p_CHIPS=Instance.PreformattedParam(CHIPS),
                        p_BGWIDTH=Instance.PreformattedParam(BGWIDTH),
                        p_BAWIDTH=Instance.PreformattedParam(BAWIDTH),
                        p_ADDRWIDTH=Instance.PreformattedParam(ADDRWIDTH),
                        p_COLWIDTH=Instance.PreformattedParam(COLWIDTH),
                        p_DEVICE_WIDTH=Instance.PreformattedParam(DEVICE_WIDTH),
                        p_BL=Instance.PreformattedParam(BL),
                        p_CHWIDTH=Instance.PreformattedParam(CHWIDTH),

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
                        # i_sync=self.cachesync,
                        o_stall=self.stall
                        )

        self.specials += DIMMi


def test_instance_module():
    configFile = '../DRAMsim3/configs/DDR4_8Gb_x4_2666.ini'
    WD = WrappedDIMM(configFile)
    verilog.convert(WD, WD.io, name="WrappedDIMM").write("WrappedDIMM.sv")


if __name__ == "__main__":
    test_instance_module()
