`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// references: www.systemverilog.io

module dimm
       #(parameter ADDRWIDTH = 17,
         parameter RANKS = 1,
         parameter CHIPS = 16,
         parameter BANKGROUPS = 4,
         parameter BANKSPERGROUP = 4,
         parameter ROWS = 2**ADDRWIDTH,
         parameter COLS = 1024,
         parameter DEVICE_WIDTH = 4, // x4, x8, x16 -> DQWIDTH = DEVICE_WIDTH x CHIPS
         parameter BL = 8, // Burst Length
         parameter ECC_WIDTH = 8, // number of ECC pins

         localparam DQWIDTH = DEVICE_WIDTH*CHIPS + ECC_WIDTH, // 64 bits + 8 bits for ECC
         localparam DQSWIDTH = CHIPS + ECC_WIDTH/DEVICE_WIDTH,
         localparam BGWIDTH = $clog2(BANKGROUPS),
         localparam BAWIDTH = $clog2(BANKSPERGROUP),
         localparam CADDRWIDTH = $clog2(COLS)
        )
       (
         input reset_n, // DRAM is active only when this signal is HIGH
`ifdef DDR4
         input ck_c, // Differential clock input complement All address & control signals are sampled at the crossing of negedge of ck_c
         input ck_t, // Differential clock input true All address & control signals are sampled at the crossing of posedge of ck_t
`elsif DDR3
         input ck_n, // Differential clock input; All address & control signals are sampled at the crossing of negedge of ck_n
         input ck_p, // Differential clock input; All address & control signals are sampled at the crossing of posedge of ck_p
`endif
         input cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
         input [RANKS-1:0]cs_n, // The memory looks at all the other inputs only if this is LOW
`ifdef DDR4
         input act_n, // Activate command input
`endif
`ifdef DDR3
         input ras_n,
         input cas_n,
         input we_n,
`endif
         input [ADDRWIDTH-1:0]A,
         // ras_n -> A16, cas_n -> A15, we_n -> A14
         // Dual function inputs:
         // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
         // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
         // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
         // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
         input [BAWIDTH:0]ba, // bank address
`ifdef DDR4
         input [BGWIDTH:0]bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
`endif
         inout [DQWIDTH-1:0]dq, // Data Bus; This is how data is written in and read out
`ifdef DDR4
         inout [DQSWIDTH-1:0]dqs_c, // Data Strobe complement, essentially a data valid flag
         inout [DQSWIDTH-1:0]dqs_t, // Data Strobe true, essentially a data valid flag
`elsif DDR3
         inout [DQSWIDTH-1:0]dqs_n, // Data Strobe n, essentially a data valid flag
         inout [DQSWIDTH-1:0]dqs_p, // Data Strobe p, essentially a data valid flag
`endif
         input odt,
`ifdef DDR4
         input parity
`endif
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

wire [18:0]commands = {ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA};

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
          Chip #(.ADDRWIDTH(ADDRWIDTH),
                 .BANKGROUPS(BANKGROUPS),
                 .BANKSPERGROUP(BANKSPERGROUP),
                 .ROWS(ROWS),
                 .COLS(COLS),
                 .DEVICE_WIDTH(DEVICE_WIDTH),
                 .BL(BL)) Ci (
                 .clk(clk),
                 .reset_n(reset_n),
                 .halt(halt),
                 .commands((!cs_n[ri])? commands : {19{1'b0}}),
                 .bg(bg),
                 .ba(ba),
                 .dq(dq[DEVICE_WIDTH*(ci+1)-1:DEVICE_WIDTH*ci]),
                 .dqs_c(dqs_c[ci]),
                 .dqs_t(dqs_t[ci]),
                 .row(row),
                 .column(A[CADDRWIDTH-1:0])
               );
        end
    end
endgenerate

endmodule
