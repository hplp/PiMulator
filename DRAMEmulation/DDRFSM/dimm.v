`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// references: www.systemverilog.io

module dimm
       #(parameter ADDRWIDTH = 17,
         parameter RANKS = 1,
         parameter CHIPS = 16,
         parameter BANKGROUPS = 4,
         parameter BANKSPERGROUP = 4,
         parameter ROWS = 2**ADDRWIDTH,
         parameter COLS = 1024,
         parameter DEVICE_WIDTH = 4, // x4, x8, x16 -> DQWIDTH = DEVICE_WIDTH x CHIPS
         parameter BL = 8, // Burst Length
         parameter ECC_WIDTH = 8, // number of ECC pins

         localparam DQWIDTH = DEVICE_WIDTH*CHIPS + ECC_WIDTH, // 64 bits + 8 bits for ECC
         localparam DQSWIDTH = CHIPS + ECC_WIDTH/DEVICE_WIDTH,
         localparam BGWIDTH = $clog2(BANKGROUPS),
         localparam BAWIDTH = $clog2(BANKSPERGROUP),
         localparam CADDRWIDTH = $clog2(COLS)
        )
       (
         input reset_n, // DRAM is active only when this signal is HIGH
`ifdef DDR4
         input ck_c, // Differential clock input complement All address & control signals are sampled at the crossing of negedge of ck_c
         input ck_t, // Differential clock input true All address & control signals are sampled at the crossing of posedge of ck_t
`elsif DDR3
         input ck_n, // Differential clock input; All address & control signals are sampled at the crossing of negedge of ck_n
         input ck_p, // Differential clock input; All address & control signals are sampled at the crossing of posedge of ck_p
`endif
         input cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
         input [RANKS-1:0]cs_n, // The memory looks at all the other inputs only if this is LOW
`ifdef DDR4
         input act_n, // Activate command input
`endif
`ifdef DDR3
         input ras_n,
         input cas_n,
         input we_n,
`endif
         input [ADDRWIDTH-1:0]A,
         // ras_n -> A16, cas_n -> A15, we_n -> A14
         // Dual function inputs:
         // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
         // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
         // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
         // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
         input [BAWIDTH:0]ba, // bank address
`ifdef DDR4
         input [BGWIDTH:0]bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
`endif
         inout [DQWIDTH-1:0]dq, // Data Bus; This is how data is written in and read out
`ifdef DDR4
         inout [DQSWIDTH-1:0]dqs_c, // Data Strobe complement, essentially a data valid flag
         inout [DQSWIDTH-1:0]dqs_t, // Data Strobe true, essentially a data valid flag
`elsif DDR3
         inout [DQSWIDTH-1:0]dqs_n, // Data Strobe n, essentially a data valid flag
         inout [DQSWIDTH-1:0]dqs_p, // Data Strobe p, essentially a data valid flag
`endif
         input odt,
`ifdef DDR4
         input parity
`endif
       );

// implement ddr logic // todo
reg halt = 0;
wire ACT = ((act_n) && A[ADDRWIDTH-1]); // todo
wire BST = ((act_n) && A[ADDRWIDTH-2]); // todo
wire CFG = 0;
wire CKEH = cke;
wire CKEL = !cke;
wire DPD = 0;
wire DPDX = 0;
wire MRR = 0;
wire MRW = 0;
wire PD = 0;
wire PDX = 0;
wire PR = ((act_n) && A[ADDRWIDTH-3]); // todo
wire PRA = ((act_n) && A[ADDRWIDTH-4]); // todo
wire RD = ((act_n) && A[ADDRWIDTH-5]); // todo
wire RDA = ((act_n) && A[ADDRWIDTH-6]); // todo
wire REF = ((act_n) && A[ADDRWIDTH-7]); // todo
wire SRF = 0;
wire WR = ((act_n) && A[ADDRWIDTH-8]); // todo
wire WRA = ((act_n) && A[ADDRWIDTH-9]); // todo
wire clk = ck_t && cke;
wire rst = !reset_n;

reg RAS, CAS, WE;

always @(posedge ck_t) // todo or posedge ck_c)
  begin
    if (reset_n) // DRAM active
      begin
`ifdef DDR4
        RAS <= A[ADDRWIDTH-1];
        CAS <= A[ADDRWIDTH-2];
        WE <= A[ADDRWIDTH-3];
`elsif DDR3
        RAS <= ras_n;
        CAS <= cas_n;
        WE <= we_n;
`endif

      end
  end

genvar ri, ci;
generate
  for (ri = 0; ri < RANKS ; ri=ri+1)
    begin:R
      for (ci = 0; ci < CHIPS ; ci=ci+1)
        begin:C
          Chip #(.ADDRWIDTH(ADDRWIDTH),
                 .BANKGROUPS(BANKGROUPS),
                 .BANKSPERGROUP(BANKSPERGROUP),
                 .ROWS(ROWS),
                 .COLS(COLS),
                 .DEVICE_WIDTH(DEVICE_WIDTH),
                 .BL(BL)) Ci (
                 .clk(clk),
                 .rst(rst),
                 .halt(halt),
                 .ACT((!cs_n[ri]) && ACT),
                 .BST((!cs_n[ri]) && BST),
                 .CFG((!cs_n[ri]) && CFG),
                 .CKEH((!cs_n[ri]) && CKEH),
                 .CKEL((!cs_n[ri]) && CKEL),
                 .DPD((!cs_n[ri]) && DPD),
                 .DPDX((!cs_n[ri]) && DPDX),
                 .MRR((!cs_n[ri]) && MRR),
                 .MRW((!cs_n[ri]) && MRW),
                 .PD((!cs_n[ri]) && PD),
                 .PDX((!cs_n[ri]) && PDX),
                 .PR((!cs_n[ri]) && PR),
                 .PRA((!cs_n[ri]) && PRA),
                 .RD((!cs_n[ri]) && RD),
                 .RDA((!cs_n[ri]) && RDA),
                 .REF((!cs_n[ri]) && REF),
                 .SRF((!cs_n[ri]) && SRF),
                 .WR((!cs_n[ri]) && WR),
                 .WRA((!cs_n[ri]) && WRA),
                 .bg(bg),
                 .ba(ba),
                 .dq(dq[DEVICE_WIDTH*(ci+1)-1:DEVICE_WIDTH*ci]),
                 .dqs_c(dqs_c[ci]),
                 .dqs_t(dqs_t[ci]),
                 .row(A),
                 .column(A[CADDRWIDTH-1:0])
               );
        end
    end
endgenerate

endmodule
