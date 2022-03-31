`timescale 1ns / 1ps

`define TestWrite
`define TestWriteReadWrite // needs TestWrite
`define TestRefresh
`define WRAutoPrecharge
`define RDAutoPrecharge
`define RowClone // needs RDAutoPrecharge

module testbnch_TimingFSM(
    );
    
    parameter BGWIDTH = 2; // set to 0 for DDR3
    parameter BAWIDTH = 2;
    parameter BL = 8; // Burst Length
    
    localparam BANKGROUPS = 2**BGWIDTH;
    localparam BANKSPERGROUP = 2**BAWIDTH;
    
    localparam T_CL = 17;
    localparam T_RCD = 17;
    localparam T_WR = 14;
    localparam T_RP = 17;
    localparam T_RFC  = 34;
    // parameter T_ABA = 24;
    // parameter T_ABAR = 24;
    // parameter T_RTP = 7;
    
    localparam tCK = 0.75;
    
    // logic signals for the testbench
    logic clk;
    logic reset_n;
    logic [BGWIDTH-1:0]bg; // bankgroup address
    logic [BAWIDTH-1:0]ba; // bank address
    logic ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA;
    logic [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    
    logic [18:0] commands;
    assign commands = {ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA};
    
    // Bank Timing FSMs instance dut
    TimingFSM #(.BGWIDTH(BGWIDTH),
    .BAWIDTH(BAWIDTH))
    dut(
    .clk(clk),
    .reset_n(reset_n),
    .bg(bg),
    .ba(ba),
    .commands(commands),
    .BankFSM(BankFSM)
    );
    
    // define clk behavior
    always #(tCK*0.5) clk = ~clk;
    
    integer i, j; // loop variable
    
    initial
    begin
        // initialize all inputs
        clk = 1;
        reset_n = 0;
        bg = 0;
        ba = 0;
        ACT = 0;
        BST = 0;
        CFG = 0;
        CKEH = 0;
        CKEL = 0;
        DPD = 0;
        DPDX = 0;
        MRR = 0;
        MRW = 0;
        PD = 0;
        PDX = 0;
        PR = 0;
        PRA = 0;
        RD = 0;
        RDA = 0;
        REF = 0;
        SRF = 0;
        WR = 0;
        WRA = 0;
        #tCK;
        
        // reset
        reset_n = 1;
        #(tCK*3);
        assert (BankFSM[1][1] == 5'h00) $display("Idle"); else $display(BankFSM[1][1]); // activating
        
        `ifdef TestWrite
        // activating a row in bank 1 in bank group 1
        ACT = 1;
        bg = 1;
        ba = 1;
        #tCK;
        ACT = 0;
        bg = 0;
        ba = 0;
        #tCK;
        assert (BankFSM[1][1] == 5'h01) $display("activating"); else $display(BankFSM[1][1]); // activating
        #(tCK*(T_RCD-1)); // tRCD
        assert (BankFSM[1][1] == 5'h03) $display("bank active"); else $display(BankFSM[1][1]); // bank active
        #(tCK*(T_CL-1)); // tCL
        assert (BankFSM[1][1] == 5'h03) $display("bank active"); else $display(BankFSM[1][1]); // bank active
        
        // write
        for (i = 0; i <T_WR ; i = i + 1)
        begin
            WR = (i==0)? 1 : 0;
            bg = (i==0)? 1 : 0;
            ba = (i==0)? 1 : 0;
            #tCK;
            assert ((BankFSM[1][1] == 5'h12) || (i==0)) $display("writing"); else $display(BankFSM[1][1]); // writing
        end
        #tCK;
        assert (BankFSM[1][1] == 5'h12) $display("writing"); else $display(BankFSM[1][1]); // writing
        
        `ifdef TestWriteReadWrite
        // read
        for (i = 0; i < BL; i = i + 1)
        begin
            RD = (i==0)? 1 : 0;
            bg = (i==0)? 1 : 0;
            ba = (i==0)? 1 : 0;
            #tCK;
            assert ((BankFSM[1][1] == 5'h0b) || (i==0)) $display("reading"); else $display(BankFSM[1][1]); // reading
        end
        #tCK;
        assert ((BankFSM[1][1] == 5'h0b) || (i==0)) $display("reading"); else $display(BankFSM[1][1]); // reading
        
        // write
        for (i = 0; i <T_WR ; i = i + 1)
        begin
            WR = (i==0)? 1 : 0;
            bg = (i==0)? 1 : 0;
            ba = (i==0)? 1 : 0;
            #tCK;
            assert ((BankFSM[1][1] == 5'h12) || (i==0)) $display("writing"); else $display(BankFSM[1][1]); // writing
        end
        #tCK;
        assert (BankFSM[1][1] == 5'h12) $display("writing"); else $display(BankFSM[1][1]); // writing
        `endif
        
        // precharge and back to idle
        PR = 1;
        bg = 1;
        ba = 1;
        #tCK;
        PR = 0;
        bg = 0;
        ba = 0;
        #tCK;
        assert (BankFSM[1][1] == 5'h0a) $display("precharge"); else $display(BankFSM[1][1]); // precharge
        #((T_RP-1)*tCK)
        assert (BankFSM[1][1] == 5'h00) $display("idle"); else $display(BankFSM[1][1]); // idle
        #(2*tCK);
        `endif
        
        `ifdef TestRefresh
        // refresh
        bg = 1;
        ba = 1;
        REF = 1;
        #tCK;
        REF = 0;
        bg = 0;
        ba = 0;
        #tCK;
        assert (BankFSM[1][1] == 5'h0d) $display("refreshing"); else $display(BankFSM[1][1]); // refreshing
        #((T_RFC-1)*tCK);
        assert (BankFSM[1][1] == 5'h00) $display("idle"); else $display(BankFSM[1][1]); // idle
        #(2*tCK);
        `endif
        
        `ifdef WRAutoPrecharge
        // activating a row in bank 1 in bank group 1
        ACT = 1;
        bg = 1;
        ba = 1;
        #tCK;
        ACT = 0;
        bg = 0;
        ba = 0;
        #tCK;
        assert (BankFSM[1][1] == 5'h01) $display("activating"); else $display(BankFSM[1][1]); // activating
        #(tCK*(T_RCD-1)); // tRCD
        assert (BankFSM[1][1] == 5'h03) $display("bank active"); else $display(BankFSM[1][1]); // bank active
        #(tCK*(T_CL-1)); // tCL
        assert (BankFSM[1][1] == 5'h03) $display("bank active"); else $display(BankFSM[1][1]); // bank active
        
        // write Auto-Precharge
        for (i = 0; i <T_WR ; i = i + 1)
        begin
            WRA = (i==0)? 1 : 0;
            bg = (i==0)? 1 : 0;
            ba = (i==0)? 1 : 0;
            #tCK;
            assert ((BankFSM[1][1] == 5'h13) || (i==0)) $display("writingAP"); else $display(BankFSM[1][1]); // writingAP
        end
        #tCK;
        assert (BankFSM[1][1] == 5'h13) $display("writingAP"); else $display(BankFSM[1][1]); // writingAP
        
        // precharge and back to idle
        #tCK;
        assert (BankFSM[1][1] == 5'h0a) $display("precharge"); else $display(BankFSM[1][1]); // precharge
        #((T_RP-1)*tCK)
        assert (BankFSM[1][1] == 5'h00) $display("idle"); else $display(BankFSM[1][1]); // idle
        #(2*tCK);
        `endif
        
        `ifdef RDAutoPrecharge
        // activating a row in bank 1 in bank group 1
        ACT = 1;
        bg = 1;
        ba = 1;
        #tCK;
        ACT = 0;
        bg = 0;
        ba = 0;
        #tCK;
        assert (BankFSM[1][1] == 5'h01) $display("activating"); else $display(BankFSM[1][1]); // activating
        #(tCK*(T_RCD-1)); // tRCD
        assert (BankFSM[1][1] == 5'h03) $display("bank active"); else $display(BankFSM[1][1]); // bank active
        #(tCK*(T_CL-1)); // tCL
        assert (BankFSM[1][1] == 5'h03) $display("bank active"); else $display(BankFSM[1][1]); // bank active
        
        `ifdef RowClone
        ACT = 1; // activating again for RowClone
        #tCK;
        ACT = 0;
        #tCK;
        $display("RowClone");
        assert (BankFSM[bg][bg] == 5'h14) else $display(BankFSM[bg][bg]); // RowClone
        #(tCK*(T_RCD-1)); // tRCD
        $display("bank active");
        assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
        `endif
        
        // read Auto-Precharge
        for (i = 0; i <BL ; i = i + 1)
        begin
            RDA = (i==0)? 1 : 0;
            bg = (i==0)? 1 : 0;
            ba = (i==0)? 1 : 0;
            #tCK;
            assert ((BankFSM[1][1] == 5'h0c) || (i==0)) $display("readingAP"); else $display(BankFSM[1][1]); // readingAP
        end
        #tCK;
        assert (BankFSM[1][1] == 5'h0c) $display("readingAP"); else $display(BankFSM[1][1]); // readingAP
        
        // precharge and back to idle
        #tCK;
        assert (BankFSM[1][1] == 5'h0a) $display("precharge"); else $display(BankFSM[1][1]); // precharge
        #((T_RP-1)*tCK)
        assert (BankFSM[1][1] == 5'h00) $display("idle"); else $display(BankFSM[1][1]); // idle
        #(2*tCK);
        `endif
        
        $finish();
    end;
    
endmodule