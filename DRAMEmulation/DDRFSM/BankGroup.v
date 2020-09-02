`timescale 1ns / 1ps

module BankGroup
       #(parameter BAWIDTH = 2,
         parameter ADDRWIDTH = 17,
         parameter COLWIDTH = 10,
         parameter DEVICE_WIDTH = 4,
         parameter BL = 8,

         localparam BANKSPERGROUP = 2**BAWIDTH,
         localparam ROWS = 2**ADDRWIDTH,
         localparam COLS = 2**COLWIDTH
        )
       (
         input wire clk,
         input wire [BANKSPERGROUP-1:0]rd_o_wr,
         input [BANKSPERGROUP-1:0][DEVICE_WIDTH-1:0]dqin,
         output [BANKSPERGROUP-1:0][DEVICE_WIDTH-1:0]dqout,
         input wire [BANKSPERGROUP-1:0][ADDRWIDTH-1:0]row,
         input wire [BANKSPERGROUP-1:0][COLWIDTH-1:0]column
       );

genvar bi;
generate
  for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
    begin:B
      Bank #(.DEVICE_WIDTH(DEVICE_WIDTH),
             .ROWS(ROWS),
             .COLS(COLS),
             .BL(BL)) Bi (
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
