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
         input wire ACT,
         input wire BST,
         input wire CFG,
         input wire CKEH,
         input wire CKEL,
         input wire DPD,
         input wire DPDX,
         input wire MRR,
         input wire MRW,
         input wire PD,
         input wire PDX,
         input wire PR,
         input wire PRA,
         input wire RD,
         input wire RDA,
         input wire REF,
         input wire SRF,
         input wire WR,
         input wire WRA,
         input [BGWIDTH:0]bg, // bank group address
         input [BAWIDTH:0]ba, // bank address
         inout [DEVICE_WIDTH-1 : 0]dq,
         inout dqs_c,
         inout dqs_t,
         input [ADDRWIDTH-1 : 0] row,
         input [CADDRWIDTH-1 : 0] column
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
                  .ACT( (bg==bgi)? ACT : 1'b0 ),
                  .BST( (bg==bgi)? BST : 1'b0 ),
                  .CFG( (bg==bgi)? CFG : 1'b0 ),
                  .CKEH( (bg==bgi)? CKEH : 1'b0 ),
                  .CKEL( (bg==bgi)? CKEL : 1'b0 ),
                  .DPD( (bg==bgi)? DPD : 1'b0 ),
                  .DPDX( (bg==bgi)? DPDX : 1'b0 ),
                  .MRR( (bg==bgi)? MRR : 1'b0 ),
                  .MRW( (bg==bgi)? MRW : 1'b0 ),
                  .PD( (bg==bgi)? PD : 1'b0 ),
                  .PDX( (bg==bgi)? PDX : 1'b0 ),
                  .PR( (bg==bgi)? PR : 1'b0 ),
                  .PRA( (bg==bgi)? PRA : 1'b0 ),
                  .RD( (bg==bgi)? RD : 1'b0 ),
                  .RDA( (bg==bgi)? RDA : 1'b0 ),
                  .REF( (bg==bgi)? REF : 1'b0 ),
                  .SRF( (bg==bgi)? SRF : 1'b0 ),
                  .WR( (bg==bgi)? WR : 1'b0 ),
                  .WRA( (bg==bgi)? WRA : 1'b0 ),
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
