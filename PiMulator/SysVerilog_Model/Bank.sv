`timescale 1ns / 1ps

// this Bank module models the basics in terms of structure and data storage of a memory Bank
// parameter DEVICE_WIDTH corresponds with the width of the memory Chip, Bank Group, Bank
//     sets the number of bits addressed by one row-column address location
// parameter COLWIDTH determines the number of columns in one row
// parameter CHWIDTH determines the number of full rows to be modeled
//     the number of full rows modeled will be much smaller than the real number of rows
//     because of the limited BRAM available on the FPGA chip
//     the small number of full rows modeled are then mapped to any rows in use
module Bank
  #(parameter DEVICE_WIDTH = 4,
    parameter COLWIDTH = 10,
    parameter CHWIDTH = 5,
    localparam COLS = 2**COLWIDTH, // number of columns
    localparam CHROWS = 2**CHWIDTH, // number of full rows allocated to a Bank model
    localparam DEPTH = COLS*CHROWS) // amount of BRAM per Bank as full rows
  (
    input  wire clk,
    input  wire [0:0]              rd_o_wr,
    input  wire [DEVICE_WIDTH-1:0] dqin,
    output wire [DEVICE_WIDTH-1:0] dqout,
    input  wire [CHWIDTH-1:0]      row,
    input  wire [COLWIDTH-1:0]     column
);

    bank_array #(.WIDTH(DEVICE_WIDTH), .DEPTH(DEPTH)) arrayi (
        .clk(clk),
        .addr({row, column}),
        .rd_o_wr(rd_o_wr), // 0->rd, 1->wr
        .i_data(dqin),
        .o_data(dqout)
    );

endmodule

// old code that used to manage RAS and CAS for bursts

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