`timescale 1ns / 1ps

module BankGroup
       #(parameter BAWIDTH = 2,
         parameter ADDRWIDTH = 17,
         parameter COLWIDTH = 10,
         parameter DEVICE_WIDTH = 4,
         parameter BL = 8,

         localparam BANKSPERGROUP = BAWIDTH**2,
         localparam ROWS = 2**ADDRWIDTH,
         localparam COLS = 2**COLWIDTH
        )
       (
         input wire clk,
         input wire reset_n,
         input wire halt,
//         input wire [18:0]commands,
         input wire [BAWIDTH-1:0]ba, // bank address
         inout [DEVICE_WIDTH-1:0]dq,
         inout dqs_c,
         inout dqs_t,
         input wire [ADDRWIDTH-1:0] row,
         input wire [COLWIDTH-1:0] column
       );

genvar bi;
generate
  for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
    begin:B
      Bank #(.WIDTH(DEVICE_WIDTH),
                     .ROWS(ROWS),
                     .COLS(COLS),
                     .BL(BL)) Bi (
                     .clk(clk),
                     .reset_n(reset_n),
                     .halt(halt),
                    //  .commands((ba==bi)? commands : {19{1'b0}}),
                     .dq(dq),
                     .dqs_c(dqs_c),
                     .dqs_t(dqs_t),
                     .row(row),
                     .column(column)
                   );
    end
endgenerate

endmodule
