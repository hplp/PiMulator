`timescale 1ns / 1ps

module Chip
       #(parameter BGWIDTH = 2,
         parameter BAWIDTH = 2,
         parameter ADDRWIDTH = 17,
         parameter COLWIDTH = 10,
         parameter DEVICE_WIDTH = 4,
         parameter BL = 8,

         localparam BANKGROUPS = BGWIDTH**2,
         localparam BANKSPERGROUP = BAWIDTH**2,
         localparam ROWS = 2**ADDRWIDTH,
         localparam COLS = 2**COLWIDTH
        )
       (
         input wire clk,
         input wire reset_n,
         input wire halt,
         input wire [18:0]commands,
         input wire [BGWIDTH:0]bg, // bank group address
         input wire [BAWIDTH:0]ba, // bank address
         inout [DEVICE_WIDTH-1:0]dq,
         inout dqs_c,
         inout dqs_t,
         input wire [ADDRWIDTH-1:0] row,
         input wire [COLWIDTH-1:0] column
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
                  .reset_n(reset_n),
                  .halt(halt),
                  .commands((bg==bgi)? commands : {19{1'b0}}),
                  .ba(ba),
                  .dq(dq),
                  .dqs_c(dqs_c),
                  .dqs_t(dqs_t),
                  .row(row),
                  .column(column)
                );
    end
endgenerate

endmodule
