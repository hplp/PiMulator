`timescale 1ns / 1ps

module Chip
       #(parameter BGWIDTH = 2,
         parameter BAWIDTH = 2,
         parameter ADDRWIDTH = 17,
         parameter COLWIDTH = 10,
         parameter DEVICE_WIDTH = 4,
         parameter BL = 8,

         localparam BANKGROUPS = 2**BGWIDTH,
         localparam BANKSPERGROUP = 2**BAWIDTH,
         localparam ROWS = 2**ADDRWIDTH,
         localparam COLS = 2**COLWIDTH
        )
       (
         input wire clk,
         input wire [BANKGROUPS-1:0][BANKSPERGROUP-1:0]rd_o_wr,
         input [BANKGROUPS-1:0][BANKSPERGROUP-1:0][DEVICE_WIDTH-1:0]dqin,
         output [BANKGROUPS-1:0][BANKSPERGROUP-1:0][DEVICE_WIDTH-1:0]dqout,
         input wire [BANKGROUPS-1:0][BANKSPERGROUP-1:0][ADDRWIDTH-1:0]row,
         input wire [BANKGROUPS-1:0][BANKSPERGROUP-1:0][COLWIDTH-1:0]column
       );

genvar bgi;
generate
  for (bgi = 0; bgi < BANKGROUPS ; bgi=bgi+1)
    begin:BG
      BankGroup #(.BAWIDTH(BAWIDTH),
                  .ADDRWIDTH(ADDRWIDTH),
                  .COLWIDTH(COLWIDTH),
                  .DEVICE_WIDTH(DEVICE_WIDTH),
                  .BL(BL)) BGi (
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
