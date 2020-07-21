`timescale 1ns / 1ps

module memtestbench(
       );

parameter width = 8;
parameter rows = 128;
parameter columns = 64;

reg clk;
reg rst;
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
reg [width-1 : 0]dq;
reg [$clog2(rows)-1 : 0] row;
reg [$clog2(columns)-1 : 0] column;
reg wr_req;
reg rd_req;

memtimingwrp #(.width(8), .rows(128), .columns(64)) dut (
               .clk(clk),
               .rst(rst),
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
               .dq(),
               .row(),
               .column(),
               .wr_req(),
               .rd_req()
             );

always #5 clk = ~clk;

initial
  begin
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
    dq = 0;
    row = 0;
    column = 0;
    wr_req = 0;
    rd_req = 0;


    #10 // reset down
     rst = 0;

    #40 // activating
     ACT = 1;
    #10
     ACT = 0;

    #40 // halting
     halt = 1;
    #30
     halt = 0;

    #200 // halting
     halt = 1;
    #40
     halt = 0;

    #20 // writing
     WR = 1;
    wr_req = 1;
    row = 0;
    column = 1;
    dq = 1;
    #10
     row = 0;
    column = 1;
    dq = 1;



    #120
     WR = 0;
    PR = 1;

    #10
     PR = 0;

    #200
     $stop;
  end;

endmodule
