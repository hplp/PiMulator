`timescale 1ns / 1ps

`define DDR4
// `define DDR3
// todo: DDR3 interface is only declared at this time but not functional

// references: www.systemverilog.io

module dimm
  #(parameter RANKS = 1,
  parameter CHIPS = 18,
  parameter BGWIDTH = 2,
  parameter BAWIDTH = 2,
  parameter ADDRWIDTH = 17,
  parameter COLWIDTH = 10,
  parameter DEVICE_WIDTH = 4, // x4, x8, x16 -> DQWIDTH = DEVICE_WIDTH x CHIPS
  parameter BL = 8, // Burst Length
  parameter CHWIDTH = 5, // Emulation Memory Cache Width
  
  localparam DQWIDTH = DEVICE_WIDTH*CHIPS, // ECC pins are also connected to chips
  localparam BANKGROUPS = 2**BGWIDTH,
  localparam BANKSPERGROUP = 2**BAWIDTH,
  localparam ROWS = 2**ADDRWIDTH,
  localparam COLS = 2**COLWIDTH
  )
  (
  `ifdef DDR4
  input act_n, // Activate command input
  `endif
  input [ADDRWIDTH-1:0] A,
  // ras_n -> A16, cas_n -> A15, we_n -> A14
  // Dual function inputs:
  // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
  // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
  // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
  // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
  `ifdef DDR3
  input ras_n,
  input cas_n,
  input we_n,
  `endif
  input [BAWIDTH-1:0] ba, // bank address
  `ifdef DDR4
  input [BGWIDTH-1:0] bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
  `endif
  `ifdef DDR4
  input ck_c, // Differential clock input complement All address & control signals are sampled at the crossing of negedge of ck_c
  input ck_t, // Differential clock input true All address & control signals are sampled at the crossing of posedge of ck_t
  `elsif DDR3
  input ck_n, // Differential clock input; All address & control signals are sampled at the crossing of negedge of ck_n
  input ck_p, // Differential clock input; All address & control signals are sampled at the crossing of posedge of ck_p
  `endif
  input cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
  input [RANKS-1:0] cs_n, // The memory looks at all the other inputs only if this is LOW
  inout [DQWIDTH-1:0] dq, // Data Bus; This is how data is written in and read out
  `ifdef DDR4
  inout [CHIPS-1:0] dqs_c, // Data Strobe complement, essentially a data valid flag
  inout [CHIPS-1:0] dqs_t, // Data Strobe true, essentially a data valid flag
  `elsif DDR3
  inout [CHIPS-1:0] dqs_n, // Data Strobe n, essentially a data valid flag
  inout [CHIPS-1:0] dqs_p, // Data Strobe p, essentially a data valid flag
  `endif
  input odt,
  `ifdef DDR4
  input parity,
  `endif
  input reset_n, // DRAM is active only when this signal is HIGH
  
  // AXI Port to Synchronize Emulation Memory Cache with Board Memory
  input sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0]
  );
  
  wire clk = ck_t && cke; // clkd && cke; // todo: figurehow to use ck_c, if needed with the memory controller
  
  genvar ri, ci, bgi, bi; // rank, chip, bank group and bank identifiers
  
  // Command decoding
  wire ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA;
  CMD #(.ADDRWIDTH(ADDRWIDTH)) CMDi
  (
  `ifdef DDR4
  .act_n(act_n),
  `endif
  `ifdef DDR3
  ras_n(ras_n),
  cas_n(cas_n),
  we_n(we_n),
  `endif
  .cke(cke),
  .A(A),
  .ACT(ACT), .BST(BST), .CFG(CFG), .CKEH(CKEH), .CKEL(CKEL), .DPD(DPD), .DPDX(DPDX), .MRR(MRR), .MRW(MRW), .PD(PD), .PDX(PDX), .PR(PR), .PRA(PRA), .RD(RD), .RDA(RDA), .REF(REF), .SRF(SRF), .WR(WR), .WRA(WRA)
  );
  
  // Bank Timing FSMs
  wire [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  TimingFSM #(.BGWIDTH(BGWIDTH),
  .BAWIDTH(BAWIDTH))
  TimingFSMi(
  .clk(clk),
  .reset_n(reset_n),
  `ifdef DDR4
  .bg(bg),
  `endif
  .ba(ba),
  .ACT(ACT), .BST(BST), .CFG(CFG), .CKEH(CKEH), .CKEL(CKEL), .DPD(DPD), .DPDX(DPDX), .MRR(MRR), .MRW(MRW), .PD(PD), .PDX(PDX), .PR(PR), .PRA(PRA), .RD(RD), .RDA(RDA), .REF(REF), .SRF(SRF), .WR(WR), .WRA(WRA),
  .BankFSM(BankFSM)
  );
  
  // address demultiplexing
  wire [ADDRWIDTH-1:0] addresses [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  generate
    for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
    begin
      for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
      begin
        assign addresses[bgi][bi] = ((bg==bgi)&&(ba==bi))? A : {ADDRWIDTH{1'b0}};
      end
    end
  endgenerate
  
  // Emulation Memory Cache
  wire [CHWIDTH-1:0] cRowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  CacheFSM #(.BGWIDTH(BGWIDTH),
  .BAWIDTH(BAWIDTH),
  .CHWIDTH(CHWIDTH),
  .ADDRWIDTH(ADDRWIDTH))
  CacheFSMi(
  .clk(clk),
  .reset_n(reset_n),
  `ifdef DDR4
  .bg(bg),
  `endif
  .ba(ba),
  .RowId(addresses),
  .BankFSM(BankFSM),
  .sync(sync),
  .cRowId(cRowId),
  .hold(hold)
  );
  
  // dq, dqs_t and dqs_c tristate split as inputs or outputs
  wire [DQWIDTH-1:0] dqi;
  wire [DQWIDTH-1:0] dqo;
  wire [CHIPS-1:0] dqs_ci;
  wire [CHIPS-1:0] dqs_co;
  wire [CHIPS-1:0] dqs_ti;
  wire [CHIPS-1:0] dqs_to;
  tristate #(.W(DQWIDTH)) dqtr (.dqi(dqo),.dqo(dqi),.dq(dq),.enable(RD || RDA));
  tristate #(.W(CHIPS)) dqsctr (.dqi(dqs_co),.dqo(dqs_ci),.dq(dqs_c),.enable(RD || RDA));
  tristate #(.W(CHIPS)) dqsttr (.dqi(dqs_to),.dqo(dqs_ti),.dq(dqs_t),.enable(RD || RDA));
  
  // dqi is demultiplexed into chipdqi while chipdqo is multiplexed into dqo
  wire [DEVICE_WIDTH-1:0] chipdqi [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  wire [DEVICE_WIDTH-1:0] chipdqo [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  generate
    for (ci = 0; ci < CHIPS; ci=ci+1)
    begin
      assign dqo[(ci+1)*DEVICE_WIDTH-1:ci*DEVICE_WIDTH] = chipdqo[ci][bg][ba];
      for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
      begin
        for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
        begin 
          assign chipdqi[ci][bgi][bi] = ((bg==bgi)&&(ba==bi))? dqi[(ci+1)*DEVICE_WIDTH-1:ci*DEVICE_WIDTH] : {DEVICE_WIDTH{1'b0}};
        end
      end
    end
  endgenerate
  
  // RAS = Row Address Strobe
  // reg [ADDRWIDTH-1:0] rowA = {ADDRWIDTH{1'b0}};
  // always@(posedge clk)
  // begin
  //   if(ACT)
  //   rowA <= A;
  //   else if (PR)
  //   rowA <= {ADDRWIDTH{1'b0}};
  // end
  wire  [0:0]             rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  wire [ADDRWIDTH-1:0]row [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  wire [COLWIDTH-1:0]column [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  
  // Rank and Chip instances todo: multi rank logic
  generate
    for (ri = 0; ri < RANKS ; ri=ri+1)
    begin:R
      for (ci = 0; ci < CHIPS ; ci=ci+1)
      begin:C
        Chip #(.BGWIDTH(BGWIDTH),
        .BAWIDTH(BAWIDTH),
        .COLWIDTH(COLWIDTH),
        .DEVICE_WIDTH(DEVICE_WIDTH),
        .BL(BL),
        .CHWIDTH(CHWIDTH)) Ci (
        .clk(clk),
        //  .reset_n(reset_n),
        .rd_o_wr(rd_o_wr),
        //  .commands((!cs_n[ri])? commands : {19{1'b0}}),
        //  .bg(bg),
        //  .ba(ba),
        .dqin(chipdqi[ci]),
        .dqout(chipdqo[ci]),
        //  .dqs_c(dqs_c[ci]),
        //  .dqs_t(dqs_t[ci]),
        .row(cRowId),
        .column(column)// todo A[COLWIDTH-1:0])
        );
      end
    end
  endgenerate
  
endmodule


// Differential clock buffer
// wire clkd;
// IBUFGDS #(
//           .DIFF_TERM("FALSE"),
//           .IBUF_LOW_PWR("FALSE"),
//           .IOSTANDARD("DEFAULT")
//         ) IBUFGDS_inst (
//           .O(clkd),
// `ifdef DDR4
//           .I(ck_t),
//           .IB(ck_c)
// `elsif DDR3
//           .I(ck_p),
//           .IB(ck_n)
// `endif
//         );