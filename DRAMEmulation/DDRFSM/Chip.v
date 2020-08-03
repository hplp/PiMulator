`timescale 1ns / 1ps

module Chip
       #(parameter ADDRWIDTH = 17,
         parameter BANKGROUPS = 2,
         parameter BANKSPERGROUP = 2,
         parameter ROWS = 2**ADDRWIDTH,
         parameter COLS = 1024,
         parameter DEVICE_WIDTH = 4,
         parameter BL = 8,

         localparam BGWIDTH = $clog2(BANKGROUPS),
         localparam BAWIDTH = $clog2(BANKSPERGROUP),
         localparam CADDRWIDTH = $clog2(COLS)
        )
       (
         input wire clk,
         input wire rst,
         input wire halt,
         input wire [18:0]commands,
         input wire [BGWIDTH:0]bg, // bank group address
         input wire [BAWIDTH:0]ba, // bank address
         inout [DEVICE_WIDTH-1:0]dq,
         inout dqs_c,
         inout dqs_t,
         input wire [ADDRWIDTH-1:0] row,
         input wire [CADDRWIDTH-1:0] column
       );

genvar bgi;
generate
  for (bgi = 0; bgi < BANKGROUPS ; bgi=bgi+1)
    begin:BG
      BankGroup #(.ADDRWIDTH(ADDRWIDTH),
                  .BANKSPERGROUP(BANKSPERGROUP),
                  .ROWS(ROWS),
                  .COLS(COLS),
                  .DEVICE_WIDTH(DEVICE_WIDTH),
                  .BL(BL)) BGi (
                  .clk(clk),
                  .rst(rst),
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
