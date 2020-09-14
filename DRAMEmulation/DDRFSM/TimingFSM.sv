`timescale 1ns / 1ps

module TimingFSM
    #(  parameter BGWIDTH = 2,
    parameter BAWIDTH = 2
    )
    (
    input wire clk,
    .ba(ba),
    `ifdef DDR4
    .bg(bg),
    `endif
    input ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA
    );
    
    wire [4:0] MFSM [BANKGROUPS*BANKSPERGROUP-1:0];
    genvar bi; // bank identifier
    generate
        for (bi = 0; bi < BANKGROUPS*BANKSPERGROUP; bi=bi+1)
        begin:MT
            memtiming MTi (
            .tCLct(),
            .tRCDct(),
            .tRFCct(),
            .tRPct(),
            .state(MFSM[bi]),
            .ACT( ({bg,ba}==bi)? ACT  : 1'b0),
            .BST( ({bg,ba}==bi)? BST  : 1'b0),
            .CFG( ({bg,ba}==bi)? CFG  : 1'b0),
            .CKEH(({bg,ba}==bi)? CKEH : 1'b0),
            .CKEL(({bg,ba}==bi)? CKEL : 1'b0),
            .DPD( ({bg,ba}==bi)? DPD  : 1'b0),
            .DPDX(({bg,ba}==bi)? DPDX : 1'b0),
            .MRR( ({bg,ba}==bi)? MRR  : 1'b0),
            .MRW( ({bg,ba}==bi)? MRW  : 1'b0),
            .PD(  ({bg,ba}==bi)? PD   : 1'b0),
            .PDX( ({bg,ba}==bi)? PDX  : 1'b0),
            .PR(  ({bg,ba}==bi)? PR   : 1'b0),
            .PRA( ({bg,ba}==bi)? PRA  : 1'b0),
            .RD(  ({bg,ba}==bi)? RD   : 1'b0),
            .RDA( ({bg,ba}==bi)? RDA  : 1'b0),
            .REF( ({bg,ba}==bi)? REF  : 1'b0),
            .SRF( ({bg,ba}==bi)? SRF  : 1'b0),
            .WR(  ({bg,ba}==bi)? WR   : 1'b0),
            .WRA( ({bg,ba}==bi)? WRA  : 1'b0),
            .clk(clk), // TODO put eclk
            .rst(!reset_n)
            );
        end
    endgenerate
    
endmodule
