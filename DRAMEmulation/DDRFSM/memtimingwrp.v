`timescale 1ns / 1ps

module memtimingwrp // bank timing plus n rows of BRAM space
       #(parameter WIDTH = 4,
         parameter ROWS = 131072,
         parameter COLS = 1024,
         parameter BL = 8,
         localparam BankBRAM = COLS*16) // amount of BRAM per bank
       (
         input wire clk,
         input wire rst,
         input wire halt,
         input wire [18:0]commands,
         inout [WIDTH-1:0]dq,
         inout dqs_c,
         inout dqs_t,
         input wire [$clog2(ROWS)-1:0]row,
         input wire [$clog2(COLS)-1:0]column
       );

wire ACT  = commands[18];//1
wire BST  = commands[17];//2
wire CFG  = commands[16];//3
wire CKEH = commands[15];//4
wire CKEL = commands[14];//5
wire DPD  = commands[13];//6
wire DPDX = commands[12];//7
wire MRR  = commands[11];//8
wire MRW  = commands[10];//9
wire PD   = commands[9];//10
wire PDX  = commands[8];//11
wire PR   = commands[7];//12
wire PRA  = commands[6];//13
wire RD   = commands[5];//14
wire RDA  = commands[4];//15
wire REF  = commands[3];//16
wire SRF  = commands[2];//17
wire WR   = commands[1];//18
wire WRA  = commands[0];//19

wire [WIDTH-1 : 0] o_data;
assign dq = (RD || RDA || PR || PRA)? o_data : {WIDTH{1'bZ}};
assign dqs_t = (RD || RDA || PR || PRA)? 1'b1 : 1'bZ;
assign dqs_c = (RD || RDA || PR || PRA)? 1'b0: 1'bZ;

wire [4:0] FSMstate;

localparam ROWADDR = $clog2(BankBRAM) - $clog2(COLS);
sram #(.WIDTH(WIDTH), .DEPTH(BankBRAM)) array (
       .clk(clk),
       .addr({row[ROWADDR-1:0], column}),
       .rd_o_wr(WR||WRA||(FSMstate==5'b10010)),
       .i_data(dq),
       .o_data(o_data)
     );

wire eclk = clk && ~halt;

memtiming memtimingi (
            .tCLct(),
            .tRCDct(),
            .tRFCct(),
            .tRPct(),
            .state(FSMstate),
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
