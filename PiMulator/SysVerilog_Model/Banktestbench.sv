`timescale 1ns / 1ps

module Banktestbench(
  );
  
  parameter DEVICE_WIDTH = 4;
  parameter COLS = 1024;
  parameter BL = 8;
  parameter CHWIDTH = 5;
  
  localparam tCK = 0.75;
  
  reg clk;
  reg  [0:0]             rd_o_wr;
  reg  [DEVICE_WIDTH-1:0]dqin;
  wire [DEVICE_WIDTH-1:0]dqout;
  reg  [CHWIDTH-1:0]row;
  reg  [$clog2(COLS)-1:0]column;
  
  integer i; // loop variable
  
  Bank #(.DEVICE_WIDTH(DEVICE_WIDTH),
  .COLS(COLS),
  .BL(BL),
  .CHWIDTH(CHWIDTH)) dut (
  .clk(clk),
  .rd_o_wr(rd_o_wr),
  .dqin(dqin),
  .dqout(dqout),
  .row(row),
  .column(column)
  );
  
  always #(tCK*0.5) clk = ~clk;
  
  initial
  begin
    clk = 1;
    rd_o_wr = 0;
    row = 0;
    column = 0;
    dqin = 0;
    
    // write
    for (i = 0; i < BL; i = i + 1)
    begin
      #tCK
      rd_o_wr = 1;
      row = 1;
      column = i;
      dqin = $random;
    end
    
    #tCK
    rd_o_wr = 0;
    row = 0;
    dqin = 0;
    
    // read
    for (i = 0; i < BL; i = i + 1)
    begin
      #tCK
      rd_o_wr = 0;
      row = 1;
      column = i;
    end
    #tCK
    
    #tCK
    row = 0;
    column = 0;
    
    #(4*tCK)
    $stop;
  end;
  
endmodule
