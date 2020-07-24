`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module dimmtestbench(
       );

parameter ADDRWIDTH = 17;
parameter RANKS = 1;
parameter BANKGROUPS = 16;
parameter BANKSPERGROUP = 4;
parameter ROWS = 2**ADDRWIDTH;
parameter COLS = 1024;
parameter DEVICE_WIDTH = 4; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)

localparam BGWIDTH = $clog2(BANKGROUPS);
localparam BAWIDTH = $clog2(BANKSPERGROUP);

reg reset_n;
`ifdef DDR4
reg ck_c;
reg ck_t;
`elsif DDR3
reg ck_n;
reg ck_p;
`endif
reg cke;
reg cs_n;
`ifdef DDR4
reg act_n;
`endif
`ifdef DDR3
reg ras_n;
reg cas_n;
reg we_n;
`endif
reg [ADDRWIDTH-1:0]addr;
reg [BAWIDTH-1:0]ba;
`ifdef DDR4
reg [BGWIDTH-1:0]bg;
`endif
wire [DEVICE_WIDTH*BANKGROUPS-1:0]dq;
reg [DEVICE_WIDTH*BANKGROUPS-1:0]dq_reg;
`ifdef DDR4
wire [BANKGROUPS+1:0]dqs_c;
reg [BANKGROUPS+1:0]dqs_c_reg;
wire [BANKGROUPS+1:0]dqs_t;
reg [BANKGROUPS+1:0]dqs_t_reg;
`elsif DDR3
wire [BANKGROUPS+1:0]dqs_n;
reg [BANKGROUPS+1:0]dqs_n_reg;
wire [BANKGROUPS+1:0]dqs_p;
reg [BANKGROUPS+1:0]dqs_p_reg;
`endif
reg odt;
`ifdef DDR4
reg parity;
`endif

dimm #(.ADDRWIDTH(ADDRWIDTH),
       .RANKS(RANKS),
       .BANKGROUPS(BANKGROUPS),
       .BANKSPERGROUP(BANKSPERGROUP),
       .ROWS(ROWS),
       .COLS(COLS),
       .DEVICE_WIDTH(DEVICE_WIDTH)
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
       .addr(addr),
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
assign ck_c = !ck_t;

initial
  begin
    ck_t = 0;
    reset_n = 0;

    #10 // reset high
     reset_n = 1;

    #210
     $stop;
  end;

endmodule
