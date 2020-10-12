`timescale 1ns / 1ps

module BankGroup
  #(parameter BAWIDTH = 2,
  parameter ADDRWIDTH = 17,
  parameter COLWIDTH = 10,
  parameter DEVICE_WIDTH = 4,
  parameter BL = 8,
  parameter CHWIDTH = 5,
  
  localparam BANKSPERGROUP = 2**BAWIDTH,
  localparam ROWS = 2**ADDRWIDTH,
  localparam COLS = 2**COLWIDTH
  )
  (
  input wire clk,
  input wire  [0:0]             rd_o_wr [BANKSPERGROUP-1:0],
  input wire  [DEVICE_WIDTH-1:0]dqin    [BANKSPERGROUP-1:0],
  output wire [DEVICE_WIDTH-1:0]dqout   [BANKSPERGROUP-1:0],
  input wire  [ADDRWIDTH-1:0]   row     [BANKSPERGROUP-1:0],
  input wire  [COLWIDTH-1:0]    column  [BANKSPERGROUP-1:0]
  );
  
  genvar bi;
  generate
    for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
    begin:B
      Bank #(.DEVICE_WIDTH(DEVICE_WIDTH),
      .ROWS(ROWS),
      .COLS(COLS),
      .BL(BL),
      .CHWIDTH(CHWIDTH)) Bi (
      .clk(clk),
      .rd_o_wr(rd_o_wr[bi]),
      .dqin(dqin[bi]),
      .dqout(dqout[bi]),
      .row(row[bi]),
      .column(column[bi])
      );
    end
  endgenerate
  
endmodule
