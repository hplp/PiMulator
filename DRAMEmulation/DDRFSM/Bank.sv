`timescale 1ns / 1ps

module Bank
  #(parameter DEVICE_WIDTH = 4,
  parameter COLS = 1024,
  parameter BL = 8,
  parameter CHWIDTH = 5,
  localparam ROWSinSRAM = 2**CHWIDTH,
  localparam BankBRAM = COLS*ROWSinSRAM) // amount of BRAM per bank as full rows (pages)
  (
  input  wire clk,
  input  wire [0:0]              rd_o_wr,
  input  wire [DEVICE_WIDTH-1:0] dqin,
  output wire [DEVICE_WIDTH-1:0] dqout,
  input  wire [CHWIDTH-1:0]      row,
  input  wire [$clog2(COLS)-1:0] column
  );
  
  sram #(.WIDTH(DEVICE_WIDTH), .DEPTH(BankBRAM)) array (
  .clk(clk),
  .addr({row, column}),
  .rd_o_wr(rd_o_wr), // 0->rd, 1->wr
  .i_data(dqin),
  .o_data(dqout)
  );
  
endmodule

// CAS = Column Address Strobe plus BL column address increment
// reg [$clog2(COLS)-1:0]colBL=0;
// always@(posedge clk)
//   begin
//     if((FSMstate==5'b01011) || (FSMstate==5'b01100))
//       colBL <= column;
//     else
//       if ((FSMstate==5'b10010) || (FSMstate==5'b10011) || (FSMstate==5'b01011) || (FSMstate==5'b01100))
//         colBL <= colBL + 1;
//       else
//         colBL <= {$clog2(COLS){1'b0}};
//   end

//
// reg [CADDRWIDTH-1:0] column = {CADDRWIDTH{1'b0}};
// always@(posedge clk)
//   begin
//     if(RD || RDA || WR || WRA)
//       column <= A[CADDRWIDTH-1:0];
//     else
//       column <= {CADDRWIDTH{1'b0}};
//   end