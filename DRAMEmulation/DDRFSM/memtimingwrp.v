`timescale 1ns / 1ps

module memtimingwrp
       #(parameter WIDTH = 8,
         parameter ROWS = 131072,
         parameter COLS = 1024,
         parameter BankBRAM = COLS*2) // amount of BRAM per bank in bytes)
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
         inout [WIDTH-1 : 0]dq,
         input [$clog2(ROWS)-1 : 0] row,
         input [$clog2(COLS)-1 : 0] column
       );

wire [WIDTH-1 : 0] o_data;
assign dq = (RD || RDA || PR || PRA) ? o_data : {WIDTH{1'bZ}};

localparam ROWADDR = 1; // $clog2(BankBRAM)/2;
localparam COLADDR = $clog2(BankBRAM)-ROWADDR;
sram #(.WIDTH(WIDTH), .DEPTH(BankBRAM)) array (
       .clk(clk),
       .addr({row[ROWADDR-1:0], column[COLADDR-1:0]}),
       .rd_o_wr(WR||WRA),
       .i_data(dq),
       .o_data(o_data)
     );

wire eclk = clk && ~halt;

memtiming memtimingi (
            .tCLct(),
            .tRCDct(),
            .tRFCct(),
            .tRPct(),
            .ACT(ACT),
            .BST(BST),
            .CFG(CFG),
            .CKEH(CKEH),
            .CKEL(CKEL),
            .DPD(DPD),
            .DPDX(DPDX),
            .MRR(MRR),
            .MRW(MRW),
            .PD(PD),
            .PDX(PDX),
            .PR(PR),
            .PRA(PRA),
            .RD(RD),
            .RDA(RDA),
            .REF(REF),
            .SRF(SRF),
            .WR(WR),
            .WRA(WRA),
            .clk(eclk),
            .rst(rst)
          );

endmodule
