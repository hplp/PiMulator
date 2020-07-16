`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// www.systemverilog.io

module dimm(
         reset_n, // DRAM is active only when this signal is HIGH
`ifdef DDR4
         ck_c, // Differential clock input complement All address & control signals are sampled at the crossing of negedge of ck_c
         ck_t, // Differential clock input true All address & control signals are sampled at the crossing of posedge of ck_t
`elsif DDR3
         ck_n, // Differential clock input; All address & control signals are sampled at the crossing of negedge of ck_n
         ck_p, // Differential clock input; All address & control signals are sampled at the crossing of posedge of ck_p
`endif
         cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers

         cs_n, // The memory looks at all the other inputs only if this is LOW
`ifdef DDR4
         act_n, // Activate command input
`endif
`ifdef DDR3
         ras_n,
         cas_n,
         we_n,
`endif
         addr,
         // ras_n -> addr16, cas_n -> addr15, we_n -> addr14
         // Dual function inputs:
         // - when act_n & cs_n are LOW, these are interpreted as Row Address Bits
         // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands

         ba, // bank address
`ifdef DDR4
         bg, // bank group
`endif

         dq, // Data Bus; This is how data is written in and read out
`ifdef DDR4
         dqs_c, // Data Strobe complement, essentially a data valid flag
         dqs_t, // Data Strobe true, essentially a data valid flag
`elsif DDR3
         dqs_n, // Data Strobe n, essentially a data valid flag
         dqs_p, // Data Strobe p, essentially a data valid flag
`endif

         odt,
`ifdef DDR4
         parity
`endif
       );

parameter ADDRWIDTH = 17;
parameter RANKS = 1;
parameter BANKGROUPS = 1;
parameter BGWIDTH = $clog2(BANKGROUPS);
parameter BANKSPERGROUP = 8;
parameter BAWIDTH = $clog2(BANKSPERGROUP);
parameter ROWS = 512;
parameter COLUMNS = 512;
parameter DEVICE_WIDTH = 8; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)

// Declare Ports
input reset_n;
`ifdef DDR4

input ck_c;
input ck_t;
`elsif DDR3
input ck_n;
input ck_p;
`endif

input cke;

input cs_n;
`ifdef DDR4

input act_n;
`endif
  `ifdef DDR3

input ras_n;
input cas_n;
input we_n;
`endif

input [ADDRWIDTH-1:0]addr;

input [BAWIDTH:0]ba;
`ifdef DDR4

input [BGWIDTH:0]bg;
`endif

inout [71:0]dq;
`ifdef DDR4

inout [17:0]dqs_c;
inout [17:0]dqs_t;
`elsif DDR3
inout [17:0]dqs_n;
inout [17:0]dqs_p;
`endif

input odt;
`ifdef DDR4

input parity;
`endif


// implement ddr logic

wire [ADDRWIDTH-1-3:0]addrLSB = addr[ADDRWIDTH-1-3:0];
wire [2:0]addrROW = ((!act_n)&&(!cs_n)) ? addr[ADDRWIDTH-1:ADDRWIDTH-1-3] : 3d'0;

reg halt = 0;
wire ACT = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==1));
wire BST = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==2));
wire CFG = 0;
wire CKEH = cke;
wire CKEL = !cke;
wire DPD = 0;
wire DPDX = 0;
wire MRR = 0;
wire MRW = 0;
wire PD = 0;
wire PDX = 0;
wire PR = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==3));
wire PRA = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==3));
wire RD = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==4));
wire RDA = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==4));
wire REF = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==5));
wire SRF = 0;
wire WR = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==6));
wire WRA = ((act_n) && (!cs_n) && (addr[ADDRWIDTH-1:ADDRWIDTH-4]==6));
wire clk = ck_t && cke;
wire rst;

genvar ri;
genvar bgi;
genvar bi;
generate
  for (ri = 0; ri < RANKS ; ri=ri+1)
    begin:Rank
      for (bgi = 0; bgi < BANKGROUPS ; bgi=bgi+1)
        begin:BankGroup
          for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
            begin:Bank
              memtimingwrp memtimingwrpi (
                             .halt(halt),
                             .ACT((ba==bi)&&act_n&&cke&&reset_n&&(!cs_n)),
                             .BST(BST&&reset_n&&(!cs_n)),
                             .CFG(CFG&&reset_n&&(!cs_n)),
                             .CKEH(CKEH&&reset_n&&(!cs_n)),
                             .CKEL(CKEL&&reset_n&&(!cs_n)),
                             .DPD(DPD&&reset_n&&(!cs_n)),
                             .DPDX(DPDX&&reset_n&&(!cs_n)),
                             .MRR(MRR&&reset_n&&(!cs_n)),
                             .MRW(MRW&&reset_n&&(!cs_n)),
                             .PD(PD&&reset_n&&(!cs_n)),
                             .PDX(PDX&&reset_n&&(!cs_n)),
                             .PR(PR&&reset_n&&(!cs_n)),
                             .PRA(PRA&&reset_n&&(!cs_n)),
                             .RD(RD&&reset_n&&(!cs_n)),
                             .RDA(RDA&&reset_n&&(!cs_n)),
                             .REF(REF&&reset_n&&(!cs_n)),
                             .SRF(SRF&&reset_n&&(!cs_n)),
                             .WR(WR&&reset_n&&(!cs_n)),
                             .WRA(WRA&&reset_n&&(!cs_n)),
                             .clk(clk),
                             .rst(rst)
                           );
            end
        end
    end
endgenerate

endmodule
