`timescale 1ns / 1ps

module CacheFSM
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
    input [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input [17-1:0] Row [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output [5-1:0] CacheRow [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output halt
    );

    reg [64-1:0] RowAddr [32-1:0];
reg [64-1:0] ValDirt [32-1:0];
reg [64-1:0] BnkAddr [32-1:0];
reg [64-1:0] MemAddr [32-1:0];

    genvar bgi, bi; // bank identifier
    generate
        for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
        begin:BG
            for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
            begin:BC
                cache Ci (
                .state(BankFSM[bgi][bi]),
                .clk(clk), // TODO put eclk
                .rst(!reset_n)
                );
            end
        end
    endgenerate
    
endmodule
