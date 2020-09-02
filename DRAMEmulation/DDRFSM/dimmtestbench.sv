`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module dimmtestbench(
       );

parameter RANKS = 1;
parameter CHIPS = 16;
parameter BGWIDTH = 2;
parameter BAWIDTH = 2;
parameter ADDRWIDTH = 17;
parameter COLWIDTH = 10;
parameter DEVICE_WIDTH = 4; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)
parameter BL = 8; // Burst Length

localparam DQWIDTH = DEVICE_WIDTH*CHIPS; // 64 bits + 8 bits for ECC
localparam BANKGROUPS = BGWIDTH**2;
localparam BANKSPERGROUP = BAWIDTH**2;
localparam ROWS = 2**ADDRWIDTH;
localparam COLS = COLWIDTH**2;

localparam CHIPSIZE = (DEVICE_WIDTH*COLS*(ROWS/1024)*BANKSPERGROUP*BANKGROUPS)/(1024); // Mbit
localparam DIMMSIZE = (CHIPSIZE*CHIPS)/(1024*8); // GB

localparam tCK = 0.75;

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
reg [BAWIDTH-1:0]ba;
`ifdef DDR4
reg [BGWIDTH-1:0]bg;
`endif
wire [DQWIDTH-1:0]dq;
reg [DQWIDTH-1:0]dq_reg;
`ifdef DDR4
wire [CHIPS-1:0]dqs_c;
reg [CHIPS-1:0]dqs_c_reg;
wire [CHIPS-1:0]dqs_t;
reg [CHIPS-1:0]dqs_t_reg;
`elsif DDR3
wire [CHIPS-1:0]dqs_n;
reg [CHIPS-1:0]dqs_n_reg;
wire [CHIPS-1:0]dqs_p;
reg [CHIPS-1:0]dqs_p_reg;
`endif
reg odt;
`ifdef DDR4
reg parity;
`endif

reg writing;

assign dq = (writing) ? dq_reg:{8'd0, {DQWIDTH-8{1'bZ}}};
assign dqs_c = (writing) ? dqs_c_reg:{2'd0,{CHIPS-2{1'bZ}}};
assign dqs_t = (writing) ? dqs_t_reg:{2'd1,{CHIPS-2{1'bZ}}};

dimm #(.RANKS(RANKS),
       .CHIPS(CHIPS),
       .BGWIDTH(BGWIDTH),
       .BAWIDTH(BAWIDTH),
       .ADDRWIDTH(ADDRWIDTH),
       .COLWIDTH(COLWIDTH),
       .DEVICE_WIDTH(DEVICE_WIDTH),
       .BL(BL)
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

always #(tCK*0.5) ck_t = ~ck_t;
always #(tCK*0.5) ck_c = ~ck_c;

integer i; // loop variable

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
    dqs_t_reg = {CHIPS{1'b0}};
    dqs_c_reg = {CHIPS{1'b0}};
    odt = 0;
    parity = 0;
    writing = 0;

    #tCK // reset high
     reset_n = 1;
    cs_n = 1'b0;

    #(tCK*5) // activating
     act_n = 0;
    bg = 1;
    ba = 1;
    A = 17'b00000000000000001;
    #tCK
     act_n = 1;
    A = 17'b00000000000000000;
    #(tCK*15) // tRCD
     #(tCK*15) // tCL

     // write
     for (i = 0; i < BL; i = i + 1)
       begin
         #tCK
          A = (i==0)? 17'b10000000000000000 : 17'b00000000000000000;
         writing = 1;
         dq_reg = {8'd0, $random, $random, $random, $random, $random, $random, $random, $random };
         dqs_t_reg = 18'b111111111111111111;
         dqs_c_reg = 18'b000000000000000000;
       end

     // after write
     //      #tCK
     //       A = 17'b00000000000000000;
     //     dq_reg = 72'd0;
     //     dqs_t_reg = 18'd0;
     //     dqs_c_reg = 18'd0;
     //     writing = 0;

     // read
     for (i = 0; i < BL; i = i + 1)
       begin
         #tCK
          A = (i==0)? 17'b10100000000000000 : 17'b00000000000000000;
         dq_reg = 72'd0;
         dqs_t_reg = 18'd0;
         dqs_c_reg = 18'd0;
         writing = 0;
       end

     // precharge and back to idle
     #tCK
      A = 17'b01000000000000000;

    #tCK
     bg = 0;
    ba = 0;
    A = 17'b01000000000000000;
    #(4*tCK)
     $stop;
  end;

endmodule
