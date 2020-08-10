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
         input wire halt,
         input wire [18:0]commands,
         input wire [BAWIDTH:0]ba, // bank address
         inout [DEVICE_WIDTH-1:0]dq,
         inout dqs_c,
         inout dqs_t,
         input wire [ADDRWIDTH-1:0] row,
         input wire [CADDRWIDTH-1:0] column
       );

genvar bi;
generate
  for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
    begin:B
      memtimingwrp #(.WIDTH(DEVICE_WIDTH),
                     .ROWS(ROWS),
                     .COLS(COLS),
                     .BL(BL)) mtmgi (
                     .clk(clk),
                     .rst(rst),
                     .halt(halt),
                     .commands((ba==bi)? commands : {19{1'b0}}),
                     .dq(dq),
                     .dqs_c(dqs_c),
                     .dqs_t(dqs_t),
                     .row(row),
                     .column(column)
                   );
    end
endgenerate

endmodule
