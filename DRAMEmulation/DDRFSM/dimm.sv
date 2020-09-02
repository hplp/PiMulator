`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// references: www.systemverilog.io

module dimm
       #(parameter RANKS = 1,
         parameter CHIPS = 16,
         parameter BGWIDTH = 2,
         parameter BAWIDTH = 2,
         parameter ADDRWIDTH = 17,
         parameter COLWIDTH = 10,
         parameter DEVICE_WIDTH = 4, // x4, x8, x16 -> DQWIDTH = DEVICE_WIDTH x CHIPS
         parameter BL = 8, // Burst Length

         localparam DQWIDTH = DEVICE_WIDTH*CHIPS, // ECC pins are also connected to chips
         localparam BANKGROUPS = BGWIDTH**2,
         localparam BANKSPERGROUP = BAWIDTH**2,
         localparam ROWS = 2**ADDRWIDTH,
         localparam COLS = 2**COLWIDTH
        )
       (
`ifdef DDR4
         input act_n, // Activate command input
`endif
         input [ADDRWIDTH-1:0]A,
         // ras_n -> A16, cas_n -> A15, we_n -> A14
         // Dual function inputs:
         // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
         // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
         // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
         // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
`ifdef DDR3
         input ras_n,
         input cas_n,
         input we_n,
`endif
         input [BAWIDTH-1:0]ba, // bank address
`ifdef DDR4
         input [BGWIDTH-1:0]bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
`endif
`ifdef DDR4
         input ck_c, // Differential clock input complement All address & control signals are sampled at the crossing of negedge of ck_c
         input ck_t, // Differential clock input true All address & control signals are sampled at the crossing of posedge of ck_t
`elsif DDR3
         input ck_n, // Differential clock input; All address & control signals are sampled at the crossing of negedge of ck_n
         input ck_p, // Differential clock input; All address & control signals are sampled at the crossing of posedge of ck_p
`endif
         input cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
         input [RANKS-1:0]cs_n, // The memory looks at all the other inputs only if this is LOW
         inout [DEVICE_WIDTH*CHIPS-1:0]dq, // Data Bus; This is how data is written in and read out
`ifdef DDR4
         inout [CHIPS-1:0]dqs_c, // Data Strobe complement, essentially a data valid flag
         inout [CHIPS-1:0]dqs_t, // Data Strobe true, essentially a data valid flag
`elsif DDR3
         inout [CHIPS-1:0]dqs_n, // Data Strobe n, essentially a data valid flag
         inout [CHIPS-1:0]dqs_p, // Data Strobe p, essentially a data valid flag
`endif
         input odt,
`ifdef DDR4
         input parity,
`endif
         input reset_n // DRAM is active only when this signal is HIGH
       );

// Differential clock buffer
wire clkd;
IBUFGDS #(
          .DIFF_TERM("FALSE"),
          .IBUF_LOW_PWR("FALSE"),
          .IOSTANDARD("DEFAULT")
        ) IBUFGDS_inst (
          .O(clkd),
`ifdef DDR4
          .I(ck_t),
          .IB(ck_c)
`elsif DDR3
          .I(ck_p),
          .IB(ck_n)
`endif
        );

wire A16 = A[16]; // RAS_n
wire A15 = A[15]; // CAS_n
wire A14 = A[14]; // WE_n
wire A10 = A[10]; // AP

// implement ddr logic // todo
reg halt = 0;
wire ACT = (!act_n); // entire A is the Row Address at this time
wire BST = (act_n && A[ADDRWIDTH-2]); // todo
wire CFG = 0;
wire CKEH = 0;//cke;
wire CKEL = 0;//!cke;
wire DPD = 0;
wire DPDX = 0;
wire MRR = 0;
wire MRW = 0;
wire PD = 0;
wire PDX = 0;
wire PR  = (act_n && !A16 &&  A15 && !A14 && !A10); // PRE
wire PRA = (act_n && !A16 &&  A15 && !A14 &&  A10);
wire RD  = (act_n &&  A16 && !A15 &&  A14 && !A10);
wire RDA = (act_n &&  A16 && !A15 &&  A14 &&  A10);
wire REF = (act_n && !A16 && !A15 &&  A14         &&  cke);
wire SRF = (act_n && !A16 && !A15 &&  A14         && !cke); // SRE
wire WR  = (act_n &&  A16 && !A15 && !A14 && !A10);
wire WRA = (act_n &&  A16 && !A15 && !A14 &&  A10);
wire clk = clkd && cke;

//wire [18:0]commands = {ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA};

// RAS = Row Address Strobe
reg [ADDRWIDTH-1:0] row = {ADDRWIDTH{1'b0}};
always@(posedge clk)
  begin
    if(ACT)
      row <= A;
    else if (PR)
      row <= {ADDRWIDTH{1'b0}};
  end

genvar ri, ci;
generate
  for (ri = 0; ri < RANKS ; ri=ri+1)
    begin:R
      for (ci = 0; ci < CHIPS ; ci=ci+1)
        begin:C
          Chip #(.BGWIDTH(BGWIDTH),
                 .BAWIDTH(BAWIDTH),
                 .ADDRWIDTH(ADDRWIDTH),
                 .COLWIDTH(COLWIDTH),
                 .DEVICE_WIDTH(DEVICE_WIDTH),
                 .BL(BL)) Ci (
                 .clk(clk),
                 .reset_n(reset_n),
                 .halt(halt),
                 //  .commands((!cs_n[ri])? commands : {19{1'b0}}),
                 .bg(bg),
                 .ba(ba),
                 .dq(dq[DEVICE_WIDTH*(ci+1)-1:DEVICE_WIDTH*ci]),
                 .dqs_c(dqs_c[ci]),
                 .dqs_t(dqs_t[ci]),
                 .row(row),
                 .column(A[COLWIDTH-1:0])
               );
        end
    end
endgenerate

wire [4:0] MFSM [BANKGROUPS*BANKSPERGROUP-1:0];
genvar bi; // bank identifier
generate
  for (bi = 0; bi < BANKGROUPS*BANKSPERGROUP; bi=bi+1)
    begin:MT
      memtiming MTi (
                  .tCLct(),
                  .tRCDct(),
                  .tRFCct(),
                  .tRPct(),
                  .state(MFSM[bi]),
                  .ACT( ({bg,ba}==bi)? ACT  : 1'b0),
                  .BST( ({bg,ba}==bi)? BST  : 1'b0),
                  .CFG( ({bg,ba}==bi)? CFG  : 1'b0),
                  .CKEH(({bg,ba}==bi)? CKEH : 1'b0),
                  .CKEL(({bg,ba}==bi)? CKEL : 1'b0),
                  .DPD( ({bg,ba}==bi)? DPD  : 1'b0),
                  .DPDX(({bg,ba}==bi)? DPDX : 1'b0),
                  .MRR( ({bg,ba}==bi)? MRR  : 1'b0),
                  .MRW( ({bg,ba}==bi)? MRW  : 1'b0),
                  .PD(  ({bg,ba}==bi)? PD   : 1'b0),
                  .PDX( ({bg,ba}==bi)? PDX  : 1'b0),
                  .PR(  ({bg,ba}==bi)? PR   : 1'b0),
                  .PRA( ({bg,ba}==bi)? PRA  : 1'b0),
                  .RD(  ({bg,ba}==bi)? RD   : 1'b0),
                  .RDA( ({bg,ba}==bi)? RDA  : 1'b0),
                  .REF( ({bg,ba}==bi)? REF  : 1'b0),
                  .SRF( ({bg,ba}==bi)? SRF  : 1'b0),
                  .WR(  ({bg,ba}==bi)? WR   : 1'b0),
                  .WRA( ({bg,ba}==bi)? WRA  : 1'b0),
                  .clk(clk), // TODO put eclk
                  .rst(!reset_n)
                );
    end
endgenerate

wire [ADDRWIDTH-1:0] addresses [BANKGROUPS*BANKSPERGROUP-1:0];
generate
  for (bi = 0; bi < BANKGROUPS*BANKSPERGROUP; bi=bi+1)
    begin
      assign addresses[bi] = ({bg,ba}==bi)? A : {ADDRWIDTH{1'b0}};
    end
endgenerate

endmodule
