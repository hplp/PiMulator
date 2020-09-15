`timescale 1ns / 1ps

`define DDR4
// `define DDR3
// todo: DDR3 interface is only declared at this time but not functional

// references: www.systemverilog.io

module dimm
  #(parameter RANKS = 1,
  parameter CHIPS = 18,
  parameter BGWIDTH = 2,
  parameter BAWIDTH = 2,
  parameter ADDRWIDTH = 17,
  parameter COLWIDTH = 10,
  parameter DEVICE_WIDTH = 4, // x4, x8, x16 -> DQWIDTH = DEVICE_WIDTH x CHIPS
  parameter BL = 8, // Burst Length
  
  localparam DQWIDTH = DEVICE_WIDTH*CHIPS, // ECC pins are also connected to chips
  localparam BANKGROUPS = 2**BGWIDTH,
  localparam BANKSPERGROUP = 2**BAWIDTH,
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
  inout [DQWIDTH-1:0]dq, // Data Bus; This is how data is written in and read out
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
  // wire clkd;
  // IBUFGDS #(
  //           .DIFF_TERM("FALSE"),
  //           .IBUF_LOW_PWR("FALSE"),
  //           .IOSTANDARD("DEFAULT")
  //         ) IBUFGDS_inst (
  //           .O(clkd),
  // `ifdef DDR4
  //           .I(ck_t),
  //           .IB(ck_c)
  // `elsif DDR3
  //           .I(ck_p),
  //           .IB(ck_n)
  // `endif
  //         );
  
  wire clk = ck_t && cke; // clkd && cke; // todo: figurehow to use ck_c, if needed
  
  wire ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA;
  CMD #(.ADDRWIDTH(ADDRWIDTH)) CMDi
  (
  `ifdef DDR4
  .act_n(act_n),
  `endif
  `ifdef DDR3
  ras_n(ras_n),
  cas_n(cas_n),
  we_n(we_n),
  `endif
  .cke(cke),
  .A(A),
  .ACT(ACT), .BST(BST), .CFG(CFG), .CKEH(CKEH), .CKEL(CKEL), .DPD(DPD), .DPDX(DPDX), .MRR(MRR), .MRW(MRW), .PD(PD), .PDX(PDX), .PR(PR), .PRA(PRA), .RD(RD), .RDA(RDA), .REF(REF), .SRF(SRF), .WR(WR), .WRA(WRA)
  );
  
  wire [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  TimingFSM #()
  TimingFSMi(
  .clk(clk),
  .reset_n(reset_n),
  .bg(bg),
  .ba(ba),
  .ACT(ACT), .BST(BST), .CFG(CFG), .CKEH(CKEH), .CKEL(CKEL), .DPD(DPD), .DPDX(DPDX), .MRR(MRR), .MRW(MRW), .PD(PD), .PDX(PDX), .PR(PR), .PRA(PRA), .RD(RD), .RDA(RDA), .REF(REF), .SRF(SRF), .WR(WR), .WRA(WRA),
  .BankFSM(BankFSM)
  );
  
  // RAS = Row Address Strobe
  reg [ADDRWIDTH-1:0] rowA = {ADDRWIDTH{1'b0}};
  always@(posedge clk)
  begin
    if(ACT)
    rowA <= A;
    else if (PR)
    rowA <= {ADDRWIDTH{1'b0}};
  end
  
  genvar bi; // bank identifier
  wire [ADDRWIDTH-1:0] addresses [BANKGROUPS*BANKSPERGROUP-1:0];
  generate
    for (bi = 0; bi < BANKGROUPS*BANKSPERGROUP; bi=bi+1)
    begin
      assign addresses[bi] = ({bg,ba}==bi)? A : {ADDRWIDTH{1'b0}};
    end
  endgenerate
  
  wire [DQWIDTH-1:0] dqin [BANKGROUPS*BANKSPERGROUP-1:0];
  generate
    for (bi = 0; bi < BANKGROUPS*BANKSPERGROUP; bi=bi+1)
    begin
      assign dqin[bi] = ({bg,ba}==bi)? dq : {DQWIDTH{1'b0}};
    end
  endgenerate
  
  wire  [0:0]             rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  
  wire [DQWIDTH-1:0]dqout [BANKGROUPS*BANKSPERGROUP-1:0];
  wire [DQWIDTH-1:0]dqout_b = dqout[{bg,ba}];
  wire [ADDRWIDTH-1:0]row [BANKSPERGROUP-1:0][BANKGROUPS-1:0];
  wire [COLWIDTH-1:0]column [BANKSPERGROUP-1:0][BANKGROUPS-1:0];
  
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
        //  .reset_n(reset_n),
        //  .halt(halt),
        .rd_o_wr(rd_o_wr),
        //  .commands((!cs_n[ri])? commands : {19{1'b0}}),
        //  .bg(bg),
        //  .ba(ba),
        .dqin(),
        .dqout(),
        //  .dq(dq[DEVICE_WIDTH*(ci+1)-1:DEVICE_WIDTH*ci]),
        //  .dqs_c(dqs_c[ci]),
        //  .dqs_t(dqs_t[ci]),
        .row(row),
        .column(column)// todo A[COLWIDTH-1:0])
        );
      end
    end
  endgenerate
  
endmodule
