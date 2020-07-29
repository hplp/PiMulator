`timescale 1ns / 1ps

module Chiptestbench(
       );

parameter ADDRWIDTH = 17;
parameter BANKGROUPS = 2;
parameter BANKSPERGROUP = 2;
parameter DEVICE_WIDTH = 4;
parameter ROWS = 131072;
parameter COLS = 1024;

localparam BGWIDTH = $clog2(BANKGROUPS);
localparam BAWIDTH = $clog2(BANKSPERGROUP);
localparam CADDRWIDTH = $clog2(COLS);

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
reg [BGWIDTH : 0]bg; // bank group address
reg [BAWIDTH : 0]ba; // bank address
wire [DEVICE_WIDTH-1 : 0]dq;
wire dqs_c;
wire dqs_t;
reg [$clog2(ROWS)-1 : 0] row;
reg [$clog2(COLS)-1 : 0] column;

reg [DEVICE_WIDTH-1 : 0]dq_reg;
assign dq = (WR || WRA) ? dq_reg : {DEVICE_WIDTH{1'bZ}};
assign dqs_t = (WR || WRA) ? 1'b1 : 1'bZ;
assign dqs_c = (WR || WRA) ? 1'b0 : 1'bZ;

Chip #(.ADDRWIDTH(ADDRWIDTH),
       .BANKGROUPS(BANKGROUPS),
       .BANKSPERGROUP(BANKSPERGROUP),
       .DEVICE_WIDTH(DEVICE_WIDTH),
       .ROWS(ROWS),
       .COLS(COLS)) dut (
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
       .bg(bg),
       .ba(ba),
       .dq(dq),
       .dqs_c(dqs_c),
       .dqs_t(dqs_t),
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
    bg = 0;
    ba = 0;
    dq_reg = 0;
    row = 0;
    column = 0;

    #10 // reset down
     rst = 0;

    #50 // activating
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

    #80 // writing
     WR = 1;
    row = 0;
    column = 1;
    dq_reg = 2;
    #10
     row = 1;
    column = 4;
    dq_reg = 5;
    #10
     row = 0;
    column = 7;
    dq_reg = 8;
    #10
     row = 1;
    column = 0;
    dq_reg = 1;
    #10
     row = 0;
    column = 3;
    dq_reg = 4;
    #10
     row = 1;
    column = 6;
    dq_reg = 7;

    #10 // reading
     WR = 0;
    RD = 1;
    row = 0;
    column = 1;
    dq_reg = 2;
    #10
     row = 1;
    column = 4;
    dq_reg = 5;
    #10
     row = 0;
    column = 7;
    dq_reg = 8;
    #10
     row = 1;
    column = 0;
    dq_reg = 1;
    #10
     row = 0;
    column = 3;
    dq_reg = 4;
    #10
     row = 1;
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

    #210
     $stop;
  end;

endmodule
