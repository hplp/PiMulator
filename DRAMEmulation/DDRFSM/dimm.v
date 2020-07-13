`timescale 1ns / 1ps

module dimm(
    act_n,
    adr,
    ba,
    bg,
    ck_c,
    ck_t,
    cke,
    cs_n,
    dq,
    dqs_c,
    dqs_t,
    odt,
    par,
    reset_n
    );

  // Declare Ports
  input act_n;
  input [16:0]adr;
  input [1:0]ba;
  input [1:0]bg;
  input ck_c;
  input ck_t;
  input cke;
  input cs_n;
  inout [71:0]dq;
  inout [17:0]dqs_c;
  inout [17:0]dqs_t;
  input odt;
  input par;
  input reset_n;

  reg halt;
  reg ACT;
  reg BST;
  reg CFG;
  reg CKEH;
  reg CKEL;
  reg DPD;
  reg DPDX;
  reg MRR;
  reg MRW;
  reg PD;
  reg PDX;
  reg PR;
  reg PRA;
  reg RD;
  reg RDA;
  reg REF;
  reg SRF;
  reg WR;
  reg WRA;
  reg clk;
  reg rst;

  memtimingwrp memtimingwrpi (
  .halt(halt),
  .ACT(ACT),
  .BST(BST),
  .CFG(CFG),
  .CKEH(CKEH),
  .CKEL(CKEL),
  .DPD(DPD),
  .DPDX(DPDX),
  .MRR(MRR),
  .MRW(MRW),
  .PD(PD),
  .PDX(PDX),
  .PR(PR),
  .PRA(PRA),
  .RD(RD),
  .RDA(RDA),
  .REF(REF),
  .SRF(SRF),
  .WR(WR),
  .WRA(WRA),
  .clk(clk),
  .rst(rst)
  );
    
endmodule