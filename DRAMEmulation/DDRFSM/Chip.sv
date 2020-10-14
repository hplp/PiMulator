`timescale 1ns / 1ps

module Chip
  #(parameter BGWIDTH = 2,
  parameter BAWIDTH = 2,
  parameter COLWIDTH = 10,
  parameter DEVICE_WIDTH = 4,
  parameter BL = 8,
  parameter CHWIDTH = 5,
  
  localparam BANKGROUPS = 2**BGWIDTH,
  localparam BANKSPERGROUP = 2**BAWIDTH,
  localparam COLS = 2**COLWIDTH
  )
  (
  input wire clk,
  input wire  [0:0]             rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
  input wire  [DEVICE_WIDTH-1:0]dqin    [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
  output wire [DEVICE_WIDTH-1:0]dqout   [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
  input wire  [CHWIDTH-1:0]     row     [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
  input wire  [COLWIDTH-1:0]    column  [BANKGROUPS-1:0][BANKSPERGROUP-1:0]
  );
  
  genvar bgi;
  generate
    for (bgi = 0; bgi < BANKGROUPS ; bgi=bgi+1)
    begin:BG
      BankGroup #(.BAWIDTH(BAWIDTH),
      .COLWIDTH(COLWIDTH),
      .DEVICE_WIDTH(DEVICE_WIDTH),
      .BL(BL),
      .CHWIDTH(CHWIDTH)) BGi (
      .clk(clk),
      .rd_o_wr(rd_o_wr[bgi]),
      .dqin(dqin[bgi]),
      .dqout(dqout[bgi]),
      .row(row[bgi]),
      .column(column[bgi])
      );
    end
  endgenerate
  
endmodule
