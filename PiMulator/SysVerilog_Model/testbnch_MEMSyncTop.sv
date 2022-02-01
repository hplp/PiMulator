`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module testbnch_MEMSyncTop(
);

    parameter BGWIDTH = 2;
    parameter BAWIDTH = 2;
    parameter CHWIDTH = 6;
    parameter ADDRWIDTH = 17;

    localparam BANKGROUPS = 2**BGWIDTH;
    localparam BANKSPERGROUP = 2**BAWIDTH;
    localparam CHROWS = 2**CHWIDTH;
    localparam ROWS = 2**ADDRWIDTH;

    localparam tCK = 0.75;

    logic clk;
    logic reset_n;

    logic [BAWIDTH-1:0]ba; // bank address
       `ifdef DDR4
       logic [BGWIDTH-1:0]bg; // bankgroup address, BG0-BG1 in x4/8 and BG0 in x16
       `endif
       logic [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    logic [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    logic [CHWIDTH-1:0] cRowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    logic stall; // test the stall signal

    MEMSyncTop #(
    .BGWIDTH(BGWIDTH),
    .BAWIDTH(BAWIDTH),
    .CHWIDTH(CHWIDTH),
    .ADDRWIDTH(ADDRWIDTH)
    )
    dut (
        .clk(clk),
        .reset_n(reset_n),
        .ba(ba),
       `ifdef DDR4
       .bg(bg),
       `endif
       .RowId(RowId),
        .BankFSM(BankFSM),
        .sync(sync),
        .cRowId(cRowId),
        .stall(stall)
    );

    always #(tCK*0.5) clk = ~clk;

    integer i=0, bgi=0, bi=0; // loop variables

    initial
    begin
        // initialize all values
        reset_n = 0;
        clk = 1;
        bg = 0; // bank group 0
        ba = 0; // bank 0 MEMSync will be tested
        for (bgi=0; bgi<BANKGROUPS; bgi=bgi+1) begin
            for (bi=0; bi<BANKGROUPS; bi=bi+1) begin
                sync[bgi][bi] = 0;
                BankFSM[bgi][bi] = 0;
                RowId[bgi][bi]=0;
                sync[bgi][bi]=0;
            end
        end
        #tCK

        reset_n = 1;
        #tCK

        // write then read to/from each MEMSync
        for (bgi=0; bgi<BANKSPERGROUP; bgi=bgi+1) begin
            for (bi=0; bi<BANKSPERGROUP; bi=bi+1) begin
                BankFSM[bgi][bi] = 5'b10010; // write
                RowId[bgi][bi]=$urandom;
                #(4*tCK)

                sync[bgi][bi]=1; // leave Allocate
                #tCK;
                sync[bgi][bi]=0;
                #(3*tCK)

                BankFSM[bgi][bi] = 0; // done writing
                #tCK;

                BankFSM[bgi][bi] = 5'b01011; // read
                #(3*tCK)

                BankFSM[bgi][bi] = 0; // done reading
                #tCK;
                $display(i);
            end
        end

        // write then read
        for (i=1; i<CHROWS; i=i+1) begin
            BankFSM[bg][ba] = 5'b10010; // write
            RowId[bg][ba]=$urandom;
            #(4*tCK)

            sync[bg][ba]=1; // leave Allocate
            #tCK;
            sync[bg][ba]=0;
            #(3*tCK)

            BankFSM[bg][ba] = 0; // done writing
            #tCK;

            BankFSM[bg][ba] = 5'b01011; // read
            #(3*tCK)

            BankFSM[bg][ba] = 0; // done reading
            #tCK;
            $display(i);
        end

        #(4*tCK)
        $finish();
    end;

endmodule
