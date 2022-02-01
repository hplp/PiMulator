`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module TimingFSM
    #(parameter BL = 8,
    parameter BGWIDTH = 2,
    parameter BAWIDTH = 2,
    localparam BANKGROUPS = 2**BGWIDTH,
    localparam BANKSPERGROUP = 2**BAWIDTH
)
    (
    input wire clk,
    input wire reset_n,
    `ifdef DDR4
    input [BGWIDTH-1:0]bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
    `endif
    input [BAWIDTH-1:0]ba, // bank address
    input ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA,
    output [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0]
);

    // TODO: make memory timings registers writeable by the memory controller
    logic [7:0] T_CL   = 17;
    logic [7:0] T_RCD  = 17;
    logic [7:0] T_RP   = 17;
    logic [7:0] T_RFC  = 34;
    logic [7:0] T_WR   = 14;
    logic [7:0] T_RTP  = 7;
    logic [7:0] T_CWL  = 10;
    logic [7:0] T_ABA  = 24;
    logic [7:0] T_ABAR = 24;
    logic [7:0] T_RAS  = 32;
    logic [15:0] T_REFI = 9360;

    genvar bgi, bi; // bank group and bank identifiers
    generate
        for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
        begin:BG
            for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
            begin:MT // todo: send latencies as inputs
                memtiming #(.BL(BL))  MTi (
                    .state(BankFSM[bgi][bi]),
                    .ACT( ((bg==bgi)&&(ba==bi))? ACT  : 1'b0),
                    .BST( ((bg==bgi)&&(ba==bi))? BST  : 1'b0),
                    .CFG( ((bg==bgi)&&(ba==bi))? CFG  : 1'b0),
                    .CKEH(((bg==bgi)&&(ba==bi))? CKEH : 1'b0),
                    .CKEL(((bg==bgi)&&(ba==bi))? CKEL : 1'b0),
                    .DPD( ((bg==bgi)&&(ba==bi))? DPD  : 1'b0),
                    .DPDX(((bg==bgi)&&(ba==bi))? DPDX : 1'b0),
                    .MRR( ((bg==bgi)&&(ba==bi))? MRR  : 1'b0),
                    .MRW( ((bg==bgi)&&(ba==bi))? MRW  : 1'b0),
                    .PD(  ((bg==bgi)&&(ba==bi))? PD   : 1'b0),
                    .PDX( ((bg==bgi)&&(ba==bi))? PDX  : 1'b0),
                    .PR(  ((bg==bgi)&&(ba==bi))? PR   : 1'b0),
                    .PRA( ((bg==bgi)&&(ba==bi))? PRA  : 1'b0),
                    .RD(  ((bg==bgi)&&(ba==bi))? RD   : 1'b0),
                    .RDA( ((bg==bgi)&&(ba==bi))? RDA  : 1'b0),
                    .REF( ((bg==bgi)&&(ba==bi))? REF  : 1'b0),
                    .SRF( ((bg==bgi)&&(ba==bi))? SRF  : 1'b0),
                    .WR(  ((bg==bgi)&&(ba==bi))? WR   : 1'b0),
                    .WRA( ((bg==bgi)&&(ba==bi))? WRA  : 1'b0),
                    .T_CL(T_CL),
                    .T_RCD(T_RCD),
                    .T_RP(T_RP),
                    .T_RFC(T_RFC),
                    .T_WR(T_WR),
                    .T_RTP(T_RTP),
                    .T_CWL(T_CWL),
                    .T_ABA(T_ABA),
                    .T_ABAR(T_ABAR),
                    .T_RAS(T_RAS),
                    .T_REFI(T_REFI),
                    .clk(clk), // TODO put eclk
                    .rst(!reset_n)
                );
            end
        end
    endgenerate

endmodule
