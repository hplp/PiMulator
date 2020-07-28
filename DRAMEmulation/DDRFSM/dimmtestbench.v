`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module dimmtestbench(
       );

parameter ADDRWIDTH = 17;
parameter RANKS = 1;
parameter CHIPS = 2;
parameter BANKGROUPS = 2;
parameter BANKSPERGROUP = 2;
parameter ROWS = 2**ADDRWIDTH;
parameter COLS = 1024;
parameter DEVICE_WIDTH = 16; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)
parameter BL = 8; // Burst Length
parameter ECC_WIDTH = 16; // number of ECC pins

localparam DQWIDTH = DEVICE_WIDTH*CHIPS + ECC_WIDTH; // 64 bits + 8 bits for ECC
localparam DQSWIDTH = CHIPS + ECC_WIDTH/DEVICE_WIDTH;
localparam RWIDTH = $clog2(RANKS);
localparam BGWIDTH = $clog2(BANKGROUPS);
localparam BAWIDTH = $clog2(BANKSPERGROUP);
localparam CADDRWIDTH = $clog2(COLS);

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

assign dq = (addr[14]) ? dq_reg:{DEVICE_WIDTH*BANKGROUPS{1'bZ}};
assign dqs_c = (addr[14]) ? dqs_c_reg:{BANKGROUPS{1'bZ}};
assign dqs_t = (addr[14]) ? dqs_t_reg:{BANKGROUPS{1'bZ}};

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
always #5 ck_c = ~ck_c;
//assign ck_c = !ck_t;

initial
  begin
    ck_t = 0;
    ck_c = 1;
    reset_n = 0;
    cke = 1;
    cs_n = 0;
    act_n = 0;

    #10 // reset high
     reset_n = 1;
    act_n = 1;
    addr = 17'b11111111111111111;
    bg = 3'b111;
    ba = 2'b11;
    dq_reg = 64'h8899AABBCCDDEEFF;
    dqs_t_reg = 18'b111111111111111111;
    dqs_c_reg = 18'b000000000000000000;

    #210
     $stop;
  end;

endmodule
