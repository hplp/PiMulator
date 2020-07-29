`timescale 1ns / 1ps

module BankGroup
       #(parameter ADDRWIDTH = 17,
         parameter BANKSPERGROUP = 2,
         parameter ROWS = 2**ADDRWIDTH,
         parameter COLS = 1024,
         parameter DEVICE_WIDTH = 4,
         parameter BL = 8,

         localparam BAWIDTH = $clog2(BANKSPERGROUP),
         localparam CADDRWIDTH = $clog2(COLS)
        )
       (
         input wire clk,
         input wire rst,
         input halt,
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
         input [BAWIDTH:0]ba, // bank address
         inout [DEVICE_WIDTH-1 : 0]dq,
         inout dqs_c,
         inout dqs_t,
         input [ADDRWIDTH-1 : 0] row,
         input [CADDRWIDTH-1 : 0] column
       );

genvar bi;
generate
  for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
    begin:B
      memtimingwrp #(.WIDTH(DEVICE_WIDTH),
                     .ROWS(ROWS),
                     .COLS(COLS)) mtmgi (
                     .clk(clk),
                     .rst(rst),
                     .halt(halt),
                     .ACT( (ba==bi)? ACT : 1'b0),
                     .BST( (ba==bi)? BST : 1'b0),
                     .CFG( (ba==bi)? CFG : 1'b0),
                     .CKEH( (ba==bi)? CKEH : 1'b0),
                     .CKEL( (ba==bi)? CKEL : 1'b0),
                     .DPD( (ba==bi)? DPD : 1'b0),
                     .DPDX( (ba==bi)? DPDX : 1'b0),
                     .MRR( (ba==bi)? MRR : 1'b0),
                     .MRW( (ba==bi)? MRW : 1'b0),
                     .PD( (ba==bi)? PD : 1'b0),
                     .PDX( (ba==bi)? PDX : 1'b0),
                     .PR( (ba==bi)? PR : 1'b0),
                     .PRA( (ba==bi)? PRA : 1'b0),
                     .RD( (ba==bi)? RD : 1'b0),
                     .RDA( (ba==bi)? RDA : 1'b0),
                     .REF( (ba==bi)? REF : 1'b0),
                     .SRF( (ba==bi)? SRF : 1'b0),
                     .WR( (ba==bi)? WR : 1'b0),
                     .WRA( (ba==bi)? WRA : 1'b0),
                     .dq(dq),// (ba==bi)? dq : {DEVICE_WIDTH{1'b0}}),
                     .dqs_c(dqs_c),// (ba==bi)? dqs_c : 1'b0),
                     .dqs_t(dqs_t),// (ba==bi)? dqs_t : 1'b0),
                     .row(row),// (ba==bi)? row : {ADDRWIDTH{1'b0}}),
                     .column(column)// (ba==bi)? column : {CADDRWIDTH{1'b0}})
                   );
    end
endgenerate

endmodule
