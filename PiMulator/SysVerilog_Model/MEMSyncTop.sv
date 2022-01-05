`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module MEMSyncTop #(
    parameter BGWIDTH = 2,
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
    output stall
    );
    
    wire [BANKGROUPS-1:0][BANKSPERGROUP-1:0] ready; // or wire ready [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    
    // wire stalls [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    wire [BANKGROUPS-1:0][BANKSPERGROUP-1:0] stalls;
    // wire stallsORs [BANKGROUPS*BANKSPERGROUP:0];
    
    genvar bgi, bi; // bank identifier
    // generate
    //     assign stallsORs[0] = 0;
    //     for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1)
    //     begin
    //         for (bi=0; bi<BANKSPERGROUP; bi=bi+1)
    //         begin
    //             assign stallsORs[bgi*BANKSPERGROUP+bi+1] = stalls[bgi][bi] || stallsORs[bgi*BANKSPERGROUP+bi];
    //         end
    //     end
    // endgenerate
    // assign stall = stallsORs[BANKGROUPS*BANKSPERGROUP];
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
