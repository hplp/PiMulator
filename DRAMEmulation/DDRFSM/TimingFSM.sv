`timescale 1ns / 1ps

module TimingFSM
    #(parameter BGWIDTH = 2,
    parameter BAWIDTH = 2,
    localparam BANKGROUPS = 2**BGWIDTH,
    localparam BANKSPERGROUP = 2**BAWIDTH
    )
    (
    input wire clk,
    input wire reset_n,
    input [BAWIDTH-1:0]ba, // bank address
    `ifdef DDR4
    input [BGWIDTH-1:0]bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
    `endif
    input ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA,
    output [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0]
    );
    
    genvar bgi, bi; // bank identifier
    generate
        for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
        begin:BG
            for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
            begin:MT // todo: send latencies as inputs
                memtiming MTi (
                .tCLct(),
                .tRCDct(),
                .tRFCct(),
                .tRPct(),
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
                .clk(clk), // TODO put eclk
                .rst(!reset_n)
                );
            end
        end
    endgenerate
    
endmodule
