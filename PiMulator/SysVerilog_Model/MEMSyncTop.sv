`timescale 1ns / 1ps

// This module instatiates a MEMSync module for each memory Bank.
module MEMSyncTop #(
    parameter BGWIDTH = 2,
    parameter BANKGROUPS = 2**BGWIDTH,
    parameter BAWIDTH = 2,
    parameter CHWIDTH = 5,
    parameter ADDRWIDTH = 17,

    localparam BANKSPERGROUP = 2**BAWIDTH,
    localparam CHROWS = 2**CHWIDTH,
    localparam ROWS = 2**ADDRWIDTH
    )
    (
    input logic clk,
    input logic reset_n,
    input logic [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input logic [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic [CHWIDTH-1:0] cRowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic stall
    );
    
    logic [BANKGROUPS-1:0][BANKSPERGROUP-1:0] ready;
    logic [BANKGROUPS-1:0][BANKSPERGROUP-1:0] stalls;
    
    genvar bgi, bi; // bank identifier
    assign stall = |stalls;
    
    generate
        for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1)
        begin:BG
            for (bi=0; bi< BANKSPERGROUP; bi=bi+1)
            begin:B
                MEMSync #(
                .CHWIDTH(CHWIDTH),
                .ADDRWIDTH(ADDRWIDTH)
                ) Mi (
                .cRowId(cRowId[bgi][bi]),
                .ready(ready[bgi][bi]),
                .stall(stalls[bgi][bi]),
                .ACT(BankFSM[bgi][bi]==5'b00001), // Activating from memtiming FSM
                .PR(BankFSM[bgi][bi]==5'b01010), // Precharging from memtiming FSM
                .RD((BankFSM[bgi][bi]==5'b01011)||(BankFSM[bgi][bi]==5'b01100)), // Read from memtiming FSM
                .RowId(RowId[bgi][bi]),
                .WR((BankFSM[bgi][bi]==5'b10010)||(BankFSM[bgi][bi]==5'b10011)), // Write from memtiming FSM
                .clk(clk),
                .rst(!reset_n),
                .sync(sync[bgi][bi])
                );
            end
        end
    endgenerate
    
endmodule
