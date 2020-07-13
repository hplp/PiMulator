`timescale 1ns / 1ps

module memtestbench(
    );

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
  reg halt;
  
  memtimingwrp dut (
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
  
  always #5 clk = ~clk;
  
 initial begin
 clk = 0;
 rst = 1;
 halt = 0;
 ACT = 0;
 BST = 0;
 CFG = 0;
 CKEH = 0;
 CKEL = 0;
 DPD = 0;
 DPDX = 0;
 MRR = 0;
 MRW = 0;
 PD = 0;
 PDX = 0;
 PR = 0;
 PRA = 0;
 RD = 0;
 RDA = 0;
 REF = 0;
 SRF = 0;
 WR = 0;
 WRA = 0;
 
 #10 // reset down
 rst = 0;
 
 #40 // activating
 ACT = 1;
 #10 // activated
 ACT = 0;
 
 #40
 halt = 1;
 #30
 halt = 0;
 
 #200
 halt = 1;
 #40
 halt = 0;
 #20
 RD = 1;

 #120
 RD = 0;
 PR = 1;

 #10
 PR = 0;
 
 #200
 $stop;
 end;
  
endmodule
