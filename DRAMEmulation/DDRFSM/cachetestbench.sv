`timescale 1ns / 1ps

module cachetestbench(
       );
       
       parameter CHWIDTH = 5;
       parameter ADDRWIDTH = 17;
       // parameter COLWIDTH = 10;
       // parameter DEVICE_WIDTH = 4; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)
       // parameter BL = 8; // Burst Length
       
       localparam CHROWS = 2**CHWIDTH;
       localparam ROWS = 2**ADDRWIDTH;
       // localparam COLS = 2**COLWIDTH;
       
       localparam tCK = 0.75;
       
       reg [CHWIDTH-1:0] cRowId;
       reg hold;
       reg RD;
       reg [ADDRWIDTH-1:0] RowId;
       reg WR;
       reg clk;
       reg rst;
       reg sync;
       
       cache #(
       .CHWIDTH(CHWIDTH),
       .ADDRWIDTH(ADDRWIDTH)
       ) 
       dut (
       .cRowId(cRowId),
       .hold(hold),
       .RD(RD),
       .RowId(RowId),
       .WR(WR),
       .clk(clk),
       .rst(rst),
       .sync(sync)
       );
       
       always #(tCK*0.5) clk = ~clk;
       
       integer i; // loop variable
       
       initial
       begin
              rst = 1;
              clk = 1;
              sync = 0;
              RD = 0;
              WR=0;
              RowId=0;
              #tCK
              
              rst = 0;
              #tCK
              
              // write
              WR=1;
              RowId=150;
              #tCK
              #tCK
              #tCK
              
              WR=0;
              RowId=0;
              #tCK

              // write
              WR=1;
              RowId=590;
              #tCK
              #tCK
              #tCK

              WR=0;
              RowId=0;
              #tCK
              
              #(4*tCK)
              $stop;
       end;
       
endmodule
