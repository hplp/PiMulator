`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module dimmtestbench(
       );

parameter ADDRWIDTH = 17;
parameter RANKS = 1;
parameter CHIPS = 16;
parameter BANKGROUPS = 4;
parameter BANKSPERGROUP = 4;
parameter ROWS = 2**ADDRWIDTH;
parameter COLS = 1024;
parameter DEVICE_WIDTH = 4; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)
parameter BL = 8; // Burst Length
parameter ECC_WIDTH = 8; // number of ECC pins

localparam DQWIDTH = DEVICE_WIDTH*CHIPS + ECC_WIDTH; // 64 bits + 8 bits for ECC
localparam DQSWIDTH = CHIPS + ECC_WIDTH/DEVICE_WIDTH;
localparam BGWIDTH = $clog2(BANKGROUPS);
localparam BAWIDTH = $clog2(BANKSPERGROUP);
localparam CADDRWIDTH = $clog2(COLS);

localparam PAGESIZE = (DEVICE_WIDTH*COLS*CHIPS)/(1024); // Kb
localparam CHIPSIZE = (DEVICE_WIDTH*COLS*(ROWS/1024)*BANKSPERGROUP*BANKGROUPS)/(1024); // Mb
localparam DIMMSIZE = (CHIPSIZE*CHIPS)/(1024*8); // GB

reg reset_n;
`ifdef DDR4
reg ck_c;
reg ck_t;
`elsif DDR3
reg ck_n;
reg ck_p;
`endif
reg cke;
reg [RANKS-1:0]cs_n;
`ifdef DDR4
reg act_n;
`endif
`ifdef DDR3
reg ras_n;
reg cas_n;
reg we_n;
`endif
reg [ADDRWIDTH-1:0]A;
reg [BAWIDTH:0]ba;
`ifdef DDR4
reg [BGWIDTH:0]bg;
`endif
wire [DQWIDTH-1:0]dq;
reg [DQWIDTH-1:0]dq_reg;
`ifdef DDR4
wire [DQSWIDTH-1:0]dqs_c;
reg [DQSWIDTH-1:0]dqs_c_reg;
wire [DQSWIDTH-1:0]dqs_t;
reg [DQSWIDTH-1:0]dqs_t_reg;
`elsif DDR3
wire [DQSWIDTH-1:0]dqs_n;
reg [DQSWIDTH-1:0]dqs_n_reg;
wire [DQSWIDTH-1:0]dqs_p;
reg [DQSWIDTH-1:0]dqs_p_reg;
`endif
reg odt;
`ifdef DDR4
reg parity;
`endif

reg writing;

assign dq = (writing) ? dq_reg:{DQWIDTH{1'bZ}};
assign dqs_c = (writing) ? dqs_c_reg:{DQSWIDTH{1'bZ}};
assign dqs_t = (writing) ? dqs_t_reg:{DQSWIDTH{1'bZ}};

dimm #(.ADDRWIDTH(ADDRWIDTH),
       .RANKS(RANKS),
       .CHIPS(CHIPS),
       .BANKGROUPS(BANKGROUPS),
       .BANKSPERGROUP(BANKSPERGROUP),
       .ROWS(ROWS),
       .COLS(COLS),
       .DEVICE_WIDTH(DEVICE_WIDTH),
       .BL(BL),
       .ECC_WIDTH(ECC_WIDTH)
      ) dut (
       .reset_n(reset_n),
`ifdef DDR4
       .ck_c(ck_c),
       .ck_t(ck_t),
`elsif DDR3
       .ck_n(ck_n),
       .ck_p(ck_p),
`endif
       .cke(cke),
       .cs_n(cs_n),
`ifdef DDR4
       .act_n(act_n),
`endif
`ifdef DDR3
       .ras_n(ras_n),
       .cas_n(cas_n),
       .we_n(we_n),
`endif
       .A(A),
       .ba(ba),
`ifdef DDR4
       .bg(bg),
`endif
       .dq(dq),
`ifdef DDR4
       .dqs_c(dqs_c),
       .dqs_t(dqs_t),
`elsif DDR3
       .dqs_n(dqs_n),
       .dqs_p(dqs_p),
`endif
       .odt(odt),
`ifdef DDR4
       .parity(parity)
`endif
     );

always #5 ck_t = ~ck_t;
always #5 ck_c = ~ck_c;

initial
  begin
    reset_n = 0;
    ck_t = 0;
    ck_c = 1;
    cke = 1;
    cs_n = {RANKS{1'b1}};
    act_n = 1;
    A = {ADDRWIDTH{1'b0}};
    bg = 0;
    ba = 0;
    dq_reg = {DQWIDTH{1'b0}};
    dqs_t_reg = {DQSWIDTH{1'b1}};
    dqs_c_reg = {DQSWIDTH{1'b0}};
    odt = 0;
    parity = 0;
    writing = 0;

    #10 // reset high
     reset_n = 1;
    cs_n = {RANKS{1'b0}};

    #50 // activating
     act_n = 0;
    #10
     act_n = 1;

    #320
     A = 17'b10000000000000000;
    writing = 1;
    dq_reg = 72'h000123456789ABCDEF;
    dqs_t_reg = 18'b111111111111111111;
    dqs_c_reg = 18'b000000000000000000;

    #10
     A = 17'b01000000000000000;
    writing = 0;

    #10
     A = 17'b00000000000000000;

    #20
     $stop;
  end;

endmodule
