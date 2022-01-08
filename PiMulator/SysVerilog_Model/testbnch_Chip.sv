`timescale 1ns / 1ps

module testbnch_Chip(
  );
  
  parameter BGWIDTH = 2;
  parameter BAWIDTH = 2;
  parameter COLWIDTH = 10;
  parameter DEVICE_WIDTH = 4;
  parameter BL = 8;
  parameter CHWIDTH = 5;
  
  localparam BANKGROUPS = 2**BGWIDTH;
  localparam BANKSPERGROUP = 2**BAWIDTH;
  localparam COLS = 2**COLWIDTH;
  
  localparam tCK = 0.75;
  reg clk;
  
  reg  [0:0]             rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  reg  [DEVICE_WIDTH-1:0]dqin    [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  wire [DEVICE_WIDTH-1:0]dqout   [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  reg  [CHWIDTH-1:0]     row     [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  reg  [COLWIDTH-1:0]    column  [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
  
  reg  [DEVICE_WIDTH-1:0]data[BL-1:0];
  
  integer i, j; // loop variable
  
  Chip #(.BGWIDTH(BGWIDTH),
  .BAWIDTH(BAWIDTH),
  .COLWIDTH(COLWIDTH),
  .DEVICE_WIDTH(DEVICE_WIDTH),
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
    
    // init
    for (i = 0; i < BANKGROUPS; i = i + 1)
    begin
      for (j = 0; j < BANKSPERGROUP; j = j + 1)
      begin
        rd_o_wr[i][j] = 0;
        row[i][j]=0;
        column[i][j]=0;
        dqin[i][j]=0;
      end
    end
    #tCK;
    
    // write
    for (i = 0; i < BL; i = i + 1)
    begin
      rd_o_wr[1][1] = 1;
      row[1][1]=1;
      column[1][1]=i;
      dqin[1][1]=$random;
      data[column[1][1]] = dqin[1][1];
      #tCK;
    end
    
    rd_o_wr[1][1] = 0;
    row[1][1]=0;
    column[1][1]=0;
    dqin[1][1]=0;
    #tCK;
    
    // read
    for (i = 0; i < BL; i = i + 1)
    begin
      row[1][1]=1;
      column[1][1]=i;
      #tCK;
      $display(dqout[1][1], data[column[1][1]]);
      assert (dqout[1][1] == data[column[1][1]]);
    end
    
    row[1][1]=0;
    column[1][1]=0;
    #(2*tCK);
    $finish();
  end;
  
endmodule