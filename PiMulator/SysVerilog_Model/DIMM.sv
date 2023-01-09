`timescale 1ns / 1ps

`define DDR4
// `define DDR3
// todo: DDR3 interface is only declared at this time but not fully tested

module DIMM // top MEMulator module with DIMM interface
  #(parameter PROTOCOL = "DDR4",
  parameter RANKS = 1, // number of Ranks
  parameter CHIPS = 16, // number of Chips per Rank
  parameter BGWIDTH = 2, // width of Bank Groups, set to 1 for DDR3 and prior gen
  parameter BANKGROUPS = 2**BGWIDTH, // number of Bank Groups, set to 1 for DDR3 and prior gen
  parameter BAWIDTH = 2, // width of Banks per Bank Group
  parameter ADDRWIDTH = 17, // address width for number of rows in array
  parameter COLWIDTH = 10, // address width for number of columns in array
  parameter DEVICE_WIDTH = 4, // data bits per Chip; x4, x8, x16 -> DQWIDTH = DEVICE_WIDTH x CHIPS
  parameter BL = 8, // Burst Length
  parameter CHWIDTH = 5, //6, // address width for number of rows in Memory Emulation Model local BRAM-based array,
  // parameter tRPRE = 1, // Read and Write Preamble on the DQS strobe signals
  // parameter WPRE = 1, // Read and Write Preamble on the DQS strobe signals
  
  // Width of AXI data bus in bits
  parameter AXI_DATA_WIDTH = 32,
  // Width of AXI address bus in bits
  parameter AXI_ADDR_WIDTH = 16,
  // Width of AXI wstrb (width of data bus in words)
  parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
  // Width of AXI ID signal
  parameter AXI_ID_WIDTH = 8,
  
  localparam DQWIDTH = DEVICE_WIDTH*CHIPS, // data width, ECC pins are also accounted as data
  localparam BANKSPERGROUP = 2**BAWIDTH, // number of Banks per Bank Group
  localparam ROWS = 2**ADDRWIDTH, // number of Rows in array
  localparam COLS = 2**COLWIDTH // number of Columns in array
  )
  (
  `ifdef DDR4
  input logic act_n, // Activate command input
  `endif
  input logic [ADDRWIDTH-1:0] A,
  // ras_n -> A16, cas_n -> A15, we_n -> A14
  // Dual function inputs:
  // - when act_n & cs_n are LOW, A0-A16 are interpreted as *Row* Address Bits (RAS Row Address Strobe)
  // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
  // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
  // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
  `ifdef DDR3
  input logic ras_n,
  input logic cas_n,
  input logic we_n,
  `endif
  input logic [BGWIDTH-1:0] bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
  input logic [BAWIDTH-1:0] ba, // bank address
  input logic ck2x, // clock 2x the frequency of ck_t, ck_c, ck_p, ck_n to drive at Dual Data Rate
  input logic ck_cn, // Differential clock input complement All address & control signals are sampled at the crossing of negedge of ck_cn
  input logic ck_tp, // Differential clock input true       All address & control signals are sampled at the crossing of posedge of ck_tp
  input logic cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
  input logic [RANKS-1:0] cs_n, // Chip select; The memory looks at all the other inputs only if this is LOW todo: scale to more ranks
  inout logic [DQWIDTH-1:0] dq, // Data Bus; This is how data is written in and read out
  inout logic [CHIPS-1:0] dqs_cn, // Data Strobe complement (n), essentially a data valid flag
  inout logic [CHIPS-1:0] dqs_tp, // Data Strobe true (p),       essentially a data valid flag
  input logic odt, // todo: on-die termination is possibly irrelevant for FPGA model
  `ifdef DDR4
  input logic parity, // Command and Address parity; todo: parity is possibly of little use for FPGA model
  `endif
  input logic reset_n, // DRAM is active only when this signal is HIGH
  
  output logic stall//, // signal to stall system while MEMSync in Allocate or WriteBack state
  
//  // AXI Port to Synchronize Emulation Memory Cache with Board Memory
//  input logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
//  /*
//  * AXI master interface
//  */
//  output logic [AXI_ID_WIDTH-1:0]    m_axi_awid,
//  output logic [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
//  output logic [7:0]                 m_axi_awlen,
//  output logic [2:0]                 m_axi_awsize,
//  output logic [1:0]                 m_axi_awburst,
//  output logic                       m_axi_awlock,
//  output logic [3:0]                 m_axi_awcache,
//  output logic [2:0]                 m_axi_awprot,
//  output logic                       m_axi_awvalid,
//  input  logic                       m_axi_awready,
//  output logic [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
//  output logic [AXI_STRB_WIDTH-1:0]  m_axi_wstrb,
//  output logic                       m_axi_wlast,
//  output logic                       m_axi_wvalid,
//  input  logic                       m_axi_wready,
//  input  logic [AXI_ID_WIDTH-1:0]    m_axi_bid,
//  input  logic [1:0]                 m_axi_bresp,
//  input  logic                       m_axi_bvalid,
//  output logic                       m_axi_bready,
//  output logic [AXI_ID_WIDTH-1:0]    m_axi_arid,
//  output logic [AXI_ADDR_WIDTH-1:0]  m_axi_araddr,
//  output logic [7:0]                 m_axi_arlen,
//  output logic [2:0]                 m_axi_arsize,
//  output logic [1:0]                 m_axi_arburst,
//  output logic                       m_axi_arlock,
//  output logic [3:0]                 m_axi_arcache,
//  output logic [2:0]                 m_axi_arprot,
//  output logic                       m_axi_arvalid,
//  input  logic                       m_axi_arready,
//  input  logic [AXI_ID_WIDTH-1:0]    m_axi_rid,
//  input  logic [AXI_DATA_WIDTH-1:0]  m_axi_rdata,
//  input  logic [1:0]                 m_axi_rresp,
//  input  logic                       m_axi_rlast,
//  input  logic                       m_axi_rvalid,
//  output logic                       m_axi_rready
  );
  
  genvar ri, ci, bgi, bi; // rank, chip, bank group and bank identifiers
  
  logic clk; // && cke; // clk enabled by cke; todo: possible source of slack
  assign clk = ck2x;
  // todo: do not create another clock but use cke directly at value update
  // todo: figurehow to use ck_c, if needed with the memory controller
  
  // RAS = Row Address Strobe
  logic [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  // CAS = Column Address Strobe
  logic [COLWIDTH-1:0] ColId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  // Write Enable bit
  logic rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  
  // Command decoding, updates RowId, ColId, other control logic
  logic [18:0] commands; // ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA
  CMD #(
  .ADDRWIDTH(ADDRWIDTH),
  .COLWIDTH(COLWIDTH),
  .BGWIDTH(BGWIDTH),
  .BANKGROUPS(BANKGROUPS),
  .BAWIDTH(BAWIDTH),
  .BL(BL)
  ) CMDi (
  `ifdef DDR4
  .act_n(act_n),
  `endif
  `ifdef DDR3
  ras_n(ras_n), cas_n(cas_n), we_n(we_n),
  `endif
  .cke(cke),
  .cs_n(cs_n[0]), // todo: scale up to more ranks
  .clk(clk),
  .bg(bg), .ba(ba),
  .A(A), .RowId(RowId), .ColId(ColId), .rd_o_wr(rd_o_wr),
  .commands(commands)
  );
  
  // Bank Timing FSMs accounts for the state of each bank and the latencies
  logic [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  TimingFSM #(.BGWIDTH(BGWIDTH),
  .BANKGROUPS(BANKGROUPS),
  .BAWIDTH(BAWIDTH))
  TimingFSMi(
  .clk(clk),
  .reset_n(reset_n),
  .bg(bg),
  .ba(ba),
  .commands(commands),
  .BankFSM(BankFSM)
  );
  
  // Memory Emulation Model Data Sync engines (todo: also model row subarray belonging)
  logic [CHWIDTH-1:0] cRowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0]; // TODO: this has to be an input from AXI-2-BoardMemory
  MEMSyncTop #(.BGWIDTH(BGWIDTH),
  .BANKGROUPS(BANKGROUPS),
  .BAWIDTH(BAWIDTH),
  .CHWIDTH(CHWIDTH),
  .ADDRWIDTH(ADDRWIDTH))
  MEMSyncTopi(
  .clk(clk),
  .reset_n(reset_n),
  .RowId(RowId),
  .BankFSM(BankFSM),
  .sync(sync),
  .cRowId(cRowId),
  .stall(stall)
  );
  
  // dq, dqs_tp and dqs_cn tristate split as inputs or outputs
  logic [DQWIDTH-1:0] dqi;
  logic [DQWIDTH-1:0] dqo;
  logic [CHIPS-1:0] dqs_cni;
  logic [CHIPS-1:0] dqs_cno;
  logic [CHIPS-1:0] dqs_tpi;
  logic [CHIPS-1:0] dqs_tpo;
  logic RDEN;
  logic [BANKGROUPS-1:0][BANKSPERGROUP-1:0] RDENs;
  generate
    for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1)
    begin
      for (bi=0; bi<BANKSPERGROUP; bi=bi+1)
      begin
        assign RDENs[bgi][bi] = (BankFSM[bgi][bi]==5'b01011);
      end
    end
  endgenerate
  assign RDEN = |RDENs;
  
  tristate #(.W(DQWIDTH)) dqtr (.dqi(dqo),.dqo(dqi),.dq(dq),.enable(RDEN)); // todo: enable must come from FSM
  tristate #(.W(CHIPS)) dqsctr (.dqi(dqs_cno),.dqo(dqs_cni),.dq(dqs_cn),.enable(commands[5] || commands[4]));
  tristate #(.W(CHIPS)) dqsttr (.dqi(dqs_tpo),.dqo(dqs_tpi),.dq(dqs_tp),.enable(commands[5] || commands[4]));
  
  // dqi is demultiplexed into chipdqi while chipdqo is multiplexed into dqo
  logic [DEVICE_WIDTH-1:0] chipdqi [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  logic [DEVICE_WIDTH-1:0] chipdqo [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0];
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
  
  // Rank and Chip instances that model the shared bus and data placement todo: multi rank logic
  generate
    for (ri = 0; ri < RANKS ; ri=ri+1)
    begin:R
      for (ci = 0; ci < CHIPS ; ci=ci+1)
      begin:C
        Chip #(.BGWIDTH(BGWIDTH),
        .BANKGROUPS(BANKGROUPS),
        .BAWIDTH(BAWIDTH),
        .COLWIDTH(COLWIDTH),
        .DEVICE_WIDTH(DEVICE_WIDTH),
        .CHWIDTH(CHWIDTH)) Ci (
        .clk(clk),
        // all the information on the data bus is in these wire bundles below
        .rd_o_wr(rd_o_wr),
        .dqin(chipdqi[ci]),
        .dqout(chipdqo[ci]),
        .row(cRowId),
        .column(ColId)
        );
      end
    end
  endgenerate
  
endmodule

// references:
// www.systemverilog.io
// https://raw.githubusercontent.com/alexforencich/verilog-axi/master/rtl/

// AXI interface code adopted from https://github.com/alexforencich/verilog-axi
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