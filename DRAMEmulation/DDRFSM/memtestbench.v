`timescale 1ns / 1ps

module memtestbench(
       );

parameter WIDTH = 8;
parameter BankBRAM = 128; // amount of BRAM per bank in bytes
parameter ROWS = 128;
parameter COLS = 64;

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
wire [WIDTH-1 : 0]dq;
reg [WIDTH-1 : 0]dq_reg;
reg [$clog2(ROWS)-1 : 0] row;
reg [$clog2(COLS)-1 : 0] column;

assign dq = (WR || WRA) ? dq_reg:{WIDTH{1'bZ}};

memtimingwrp #(.WIDTH(WIDTH), .BankBRAM(BankBRAM), .ROWS(ROWS), .COLS(COLS)) dut (
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
               .dq(dq),
               .row(row),
               .column(column)
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
    dq_reg = 0;
    row = 0;
    column = 0;

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
    row = 0;
    column = 1;
    dq_reg = 2;
    #10
     row = 3;
    column = 4;
    dq_reg = 5;
    #10
     row = 6;
    column = 7;
    dq_reg = 8;
    #10
     row = 9;
    column = 0;
    dq_reg = 1;
    #10
     row = 2;
    column = 3;
    dq_reg = 4;
    #10
     row = 5;
    column = 6;
    dq_reg = 7;

    #10 // reading
     WR = 0;
    RD = 1;
    row = 0;
    column = 1;
    dq_reg = 2;
    #10
     row = 3;
    column = 4;
    dq_reg = 5;
    #10
     row = 6;
    column = 7;
    dq_reg = 8;
    #10
     row = 9;
    column = 0;
    dq_reg = 1;
    #10
     row = 2;
    column = 3;
    dq_reg = 4;
    #10
     row = 5;
    column = 6;
    dq_reg = 7;

    #10
     RD = 0;
    row = 0;
    column = 0;
    dq_reg = 0;
    PR = 1;

    #10
     PR = 0;

    #200
     $stop;
  end;

endmodule
