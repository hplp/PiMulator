`timescale 1ns / 1ps

module Bank
       #(parameter DEVICE_WIDTH = 4,
         parameter ROWS = 131072,
         parameter COLS = 1024,
         parameter BL = 8,
         localparam ROWSinSRAM = 32,
         localparam BankBRAM = COLS*ROWSinSRAM) // amount of BRAM per bank as full rows (pages)
       (
         input wire clk,
         input wire rd_o_wr,
         input [DEVICE_WIDTH-1:0]dqin,
         output [DEVICE_WIDTH-1:0]dqout,
         input wire [$clog2(ROWS)-1:0]row,
         input wire [$clog2(COLS)-1:0]column
       );

localparam ROWADDR = $clog2(BankBRAM) - $clog2(COLS);
sram #(.WIDTH(DEVICE_WIDTH), .DEPTH(BankBRAM)) array (
       .clk(clk),
       .addr({row[ROWADDR-1:0], column}),
       .rd_o_wr(rd_o_wr), // 0->rd, 1->wr
       .i_data(dqin),
       .o_data(dqout)
     );

endmodule

  //.addr({row[ROWADDR-1:0], colBL}),
  // wire ACT  = commands[18];//1
  // wire BST  = commands[17];//2
  // wire CFG  = commands[16];//3
  // wire CKEH = commands[15];//4
  // wire CKEL = commands[14];//5
  // wire DPD  = commands[13];//6
  // wire DPDX = commands[12];//7
  // wire MRR  = commands[11];//8
  // wire MRW  = commands[10];//9
  // wire PD   = commands[9];//10
  // wire PDX  = commands[8];//11
  // wire PR   = commands[7];//12
  // wire PRA  = commands[6];//13
  // wire RD   = commands[5];//14
  // wire RDA  = commands[4];//15
  // wire REF  = commands[3];//16
  // wire SRF  = commands[2];//17
  // wire WR   = commands[1];//18
  // wire WRA  = commands[0];//19

  // wire [4:0] FSMstate;
  // wire [DEVICE_WIDTH-1 : 0] o_data;
  // assign dq = ((FSMstate==5'b01011) || (FSMstate==5'b01100))? o_data : {DEVICE_WIDTH{1'bZ}};
  // assign dqs_t = ((FSMstate==5'b01011) || (FSMstate==5'b01100))? 1'b1 : 1'bZ;
  // assign dqs_c = ((FSMstate==5'b01011) || (FSMstate==5'b01100))? 1'b0: 1'bZ;

  // // CAS = Column Address Strobe plus BL column address increment
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

  // wire eclk = clk && ~halt;

  // memtiming memtimingi (
  //             .tCLct(),
  //             .tRCDct(),
  //             .tRFCct(),
  //             .tRPct(),
  //             .state(FSMstate),
  //             .ACT(ACT),
  //             .BST(BST),
  //             .CFG(CFG),
  //             .CKEH(CKEH),
  //             .CKEL(CKEL),
  //             .DPD(DPD),
  //             .DPDX(DPDX),
  //             .MRR(MRR),
  //             .MRW(MRW),
  //             .PD(PD),
  //             .PDX(PDX),
  //             .PR(PR),
  //             .PRA(PRA),
  //             .RD(RD),
  //             .RDA(RDA),
  //             .REF(REF),
  //             .SRF(SRF),
  //             .WR(WR),
  //             .WRA(WRA),
  //             .clk(eclk),
  //             .rst(!reset_n)
  //           );
