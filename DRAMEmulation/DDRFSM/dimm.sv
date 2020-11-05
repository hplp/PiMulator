`timescale 1ns / 1ps

`define DDR4
// `define DDR3
// todo: DDR3 interface is only declared at this time but not functional

// references:
// www.systemverilog.io
// https://raw.githubusercontent.com/alexforencich/verilog-axi/master/rtl/

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
  
  // Width of AXI data bus in bits
  parameter AXI_DATA_WIDTH = 32,
  // Width of AXI address bus in bits
  parameter AXI_ADDR_WIDTH = 16,
  // Width of AXI wstrb (width of data bus in words)
  parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
  // Width of AXI ID signal
  parameter AXI_ID_WIDTH = 8,
  
  parameter DQWIDTH = DEVICE_WIDTH*CHIPS, // ECC pins are also connected to chips
  parameter BANKGROUPS = 2**BGWIDTH,
  parameter BANKSPERGROUP = 2**BAWIDTH,
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
  `ifdef DDR4
  input [BGWIDTH-1:0] bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
  `endif
  input [BAWIDTH-1:0] ba, // bank address
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
  input sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
  /*
  * AXI master interface
  */
  output wire [AXI_ID_WIDTH-1:0]    m_axi_awid,
  output wire [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
  output wire [7:0]                 m_axi_awlen,
  output wire [2:0]                 m_axi_awsize,
  output wire [1:0]                 m_axi_awburst,
  output wire                       m_axi_awlock,
  output wire [3:0]                 m_axi_awcache,
  output wire [2:0]                 m_axi_awprot,
  output wire                       m_axi_awvalid,
  input  wire                       m_axi_awready,
  output wire [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
  output wire [AXI_STRB_WIDTH-1:0]  m_axi_wstrb,
  output wire                       m_axi_wlast,
  output wire                       m_axi_wvalid,
  input  wire                       m_axi_wready,
  input  wire [AXI_ID_WIDTH-1:0]    m_axi_bid,
  input  wire [1:0]                 m_axi_bresp,
  input  wire                       m_axi_bvalid,
  output wire                       m_axi_bready,
  output wire [AXI_ID_WIDTH-1:0]    m_axi_arid,
  output wire [AXI_ADDR_WIDTH-1:0]  m_axi_araddr,
  output wire [7:0]                 m_axi_arlen,
  output wire [2:0]                 m_axi_arsize,
  output wire [1:0]                 m_axi_arburst,
  output wire                       m_axi_arlock,
  output wire [3:0]                 m_axi_arcache,
  output wire [2:0]                 m_axi_arprot,
  output wire                       m_axi_arvalid,
  input  wire                       m_axi_arready,
  input  wire [AXI_ID_WIDTH-1:0]    m_axi_rid,
  input  wire [AXI_DATA_WIDTH-1:0]  m_axi_rdata,
  input  wire [1:0]                 m_axi_rresp,
  input  wire                       m_axi_rlast,
  input  wire                       m_axi_rvalid,
  output wire                       m_axi_rready
  );
  
  wire clk = ck_t && cke; // clkd && cke; // todo: figurehow to use ck_c, if needed with the memory controller
  
  genvar ri, ci, bgi, bi; // rank, chip, bank group and bank identifiers
  
  // Command decoding and active row
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
  
  
  // RAS = Row Address Strobe
  reg [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  always@(posedge clk)
  begin
    if(ACT) RowId[bg][ba] <= A;
    else if (PR) RowId[bg][ba] <= {ADDRWIDTH{1'b0}};
  end
  
  // CAS = Column Address Strobe
  reg [COLWIDTH-1:0] Column [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  reg Burst [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  always@(posedge clk)
  begin
    if(WR || WRA || RD || RDA) begin
      Column[bg][ba] <= A[COLWIDTH-1:0];
      Burst[bg][ba] <= 1;
    end
    else if (PR) begin
      Column[bg][ba] <= {COLWIDTH{1'b0}};
      Burst[bg][ba] <= 0;
    end
    else begin
      for (int i = 0; i < BANKGROUPS; i++) begin
        for (int j = 0; j < BANKGROUPS; j++) begin
          if(Burst[i][j]) Column[i][j] <= Column[i][j] + 1;
        end
      end
    end
  end
  
  // CAS = Column Address Strobe plus BL column address increment
  // reg [$clog2(COLS)-1:0]colBL=0;
  // always@(posedge clk)
  //   begin
  //     if((FSMstate==5'b01011) || (FSMstate==5'b01100))
  //       colBL <= column;
  //     else
  //       if ((FSMstate==5'b10010) || (FSMstate==5'b10011) || (FSMstate==5'b01011) || (FSMstate==5'b01100))
  //         colBL <= colBL + 1;
  //       else
  //         colBL <= {$clog2(COLS){1'b0}};
  //   end
  
  //
  // reg [CADDRWIDTH-1:0] column = {CADDRWIDTH{1'b0}};
  // always@(posedge clk)
  //   begin
  //     if(RD || RDA || WR || WRA)
  //       column <= A[CADDRWIDTH-1:0];
  //     else
  //       column <= {CADDRWIDTH{1'b0}};
  //   end
  
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
  
  // Address demultiplexing
  // wire [ADDRWIDTH-1:0] addresses [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  // generate
  //   for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
  //   begin
  //     for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
  //     begin
  //       assign addresses[bgi][bi] = ((bg==bgi)&&(ba==bi))? A : {ADDRWIDTH{1'b0}};
  //     end
  //   end
  // endgenerate
  
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
  .RowId(RowId),
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
  wire RDEN;
  wire RDENORs [BANKGROUPS*BANKSPERGROUP:0];
  generate
    assign RDENORs[0] = 0;
    for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1)
    begin
      for (bi=0; bi<BANKSPERGROUP; bi=bi+1)
      begin
        assign RDENORs[bgi*BANKSPERGROUP+bi+1] = (BankFSM[bgi][bi]==5'b01011) || RDENORs[bgi*BANKSPERGROUP+bi];
      end
    end
  endgenerate
  assign RDEN = RDENORs[BANKGROUPS*BANKSPERGROUP];
  
  tristate #(.W(DQWIDTH)) dqtr (.dqi(dqo),.dqo(dqi),.dq(dq),.enable(RDEN)); // todo: enable must come from FSM
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
  
  // Write Enable bit
  reg  [0:0] rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  always@(posedge clk)
  begin
    if(WR || WRA) rd_o_wr[bg][ba] <= 1;
    else if (PR || RD || RDA) rd_o_wr[bg][ba] <= 0;
  end
  
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
        .column(Column)
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

/*

Copyright (c) 2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/