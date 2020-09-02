`timescale 1ns / 1ps

module Chiptestbench(
       );

parameter BGWIDTH = 2;
parameter BAWIDTH = 2;
parameter ADDRWIDTH = 17;
parameter COLWIDTH = 10;
parameter DEVICE_WIDTH = 4;
parameter BL = 8;

localparam BANKGROUPS = 2**BGWIDTH;
localparam BANKSPERGROUP = 2**BAWIDTH;
localparam ROWS = 2**ADDRWIDTH;
localparam COLS = 2**COLWIDTH;

localparam tCK = 0.75;
reg clk;

reg [BANKGROUPS-1:0][BANKSPERGROUP-1:0]rd_o_wr;
reg [BANKGROUPS-1:0][BANKSPERGROUP-1:0][DEVICE_WIDTH-1:0]dqin;
wire [BANKGROUPS-1:0][BANKSPERGROUP-1:0][DEVICE_WIDTH-1:0]dqout;
reg [BANKGROUPS-1:0][BANKSPERGROUP-1:0][ADDRWIDTH-1:0]row;
reg [BANKGROUPS-1:0][BANKSPERGROUP-1:0][COLWIDTH-1:0]column;

integer i, j; // loop variable

Chip #(.BGWIDTH(BGWIDTH),
       .BAWIDTH(BAWIDTH),
       .ADDRWIDTH(ADDRWIDTH),
       .COLWIDTH(COLWIDTH),
       .DEVICE_WIDTH(DEVICE_WIDTH),
       .BL(BL)) dut (
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
    clk = 0;

    // init
    for (i = 0; i < BANKGROUPS; i = i + 1)
      begin
        for (j = 0; j < BANKSPERGROUP; j = j + 1)
          begin
            rd_o_wr[i] = 0;
            row[i]=0;
            column[i]=0;
            dqin[i]=0;
          end
      end
    #tCK
     #tCK


     // write
     for (i = 0; i < BL; i = i + 1)
       begin
         #tCK
          rd_o_wr[1] = 4'b0001;
         row[1].=17'h1;
         column[1][1]=i;
         dqin[1][1]=$random;
       end

     #tCK
      rd_o_wr[1][1] = 1'b0;
    row[1][1]=17'h0;
    column[1][1]=0;
    dqin[1][1]=0;

    // read
    for (i = 0; i < BL; i = i + 1)
      begin
        #tCK
         rd_o_wr[1][1] = 1'b0;
        row[1][1]=17'h1;
        column[1][1]=i;
      end
    #tCK

     #tCK
     row[1][1]=17'h0;
    column[1][1]=0;

    #(4*tCK)
     $stop;
  end;

endmodule

  // reg [DEVICE_WIDTH-1:0]dq_reg;
  // assign dq = (commands[0] || commands[1]) ? dq_reg : {DEVICE_WIDTH{1'bZ}};
  // assign dqs_t = (commands[0] || commands[1]) ? 1'b1 : 1'bZ;
  // assign dqs_c = (commands[0] || commands[1]) ? 1'b0 : 1'bZ;
