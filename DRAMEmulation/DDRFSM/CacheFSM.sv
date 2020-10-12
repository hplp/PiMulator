`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module CacheFSM
    #(parameter BGWIDTH = 2,
    parameter BAWIDTH = 2,
    parameter CHWIDTH = 5,
    parameter ADDRWIDTH = 17,
    
    localparam BANKGROUPS = 2**BGWIDTH,
    localparam BANKSPERGROUP = 2**BAWIDTH,
    localparam CHROWS = 2**CHWIDTH,
    localparam ROWS = 2**ADDRWIDTH
    )
    (
    input wire clk,
    input wire reset_n,
    input [BAWIDTH-1:0]ba, // bank address
    `ifdef DDR4
    input [BGWIDTH-1:0]bg, // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
    `endif
    input [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output [CHWIDTH-1:0] cRowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output hold
    );
    
    wire holds [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    wire holdsORs [BANKGROUPS*BANKSPERGROUP:0];
    
    genvar bgi, bi; // bank identifier
    generate
        assign holdsORs[0] = 0;
        for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1)
        begin
            for (bi=0; bi<BANKSPERGROUP; bi=bi+1)
            begin
                assign holdsORs[bgi*BANKSPERGROUP+bi+1] = holds[bgi][bi] || holdsORs[bgi*BANKSPERGROUP+bi];
            end
        end
    endgenerate
    assign hold = holdsORs[BANKGROUPS*BANKSPERGROUP];
    
    generate
        for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1)
        begin:BG
            for (bi=0; bi< BANKSPERGROUP; bi=bi+1)
            begin:BC
                cache #(
                .CHWIDTH(CHWIDTH),
                .ADDRWIDTH(ADDRWIDTH)
                ) Ci (
                .cRowId(cRowId[bgi][bi]),
                .hold(holds[bgi][bi]),
                .RD((BankFSM[bgi][bi]==5'b01011)||(BankFSM[bgi][bi]==5'b01100)),
                .RowId(RowId[bgi][bi]),
                .WR((BankFSM[bgi][bi]==5'b10010)||(BankFSM[bgi][bi]==5'b10011)),
                .clk(clk),
                .rst(!reset_n),
                .sync(sync[bgi][bi])
                );
            end
        end
    endgenerate
    
endmodule
