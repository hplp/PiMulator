`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// `define RowClone

module testbnch_DIMM();
    
    parameter RANKS = 1;
    parameter CHIPS = 16;
    parameter BGWIDTH = 2;
    parameter BANKGROUPS = 2**BGWIDTH;
    parameter BAWIDTH = 2;
    parameter ADDRWIDTH = 17;
    parameter COLWIDTH = 10;
    parameter DEVICE_WIDTH = 4; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)
    parameter BL = 8; // Burst Length
    parameter CHWIDTH = 5; // Emulation Memory Cache Width
    
    localparam DQWIDTH = DEVICE_WIDTH*CHIPS; // 64 bits + 8 bits for ECC
    localparam BANKSPERGROUP = 2**BAWIDTH;
    localparam ROWS = 2**ADDRWIDTH;
    localparam COLS = 2**COLWIDTH;
    
    localparam CHIPSIZE = (DEVICE_WIDTH*COLS*(ROWS/1024)*BANKSPERGROUP*BANKGROUPS)/(1024); // Mbit
    localparam DIMMSIZE = (CHIPSIZE*CHIPS)/(1024*8); // GB
    
    localparam tCK = 0.75;
    
    localparam T_CL   = 17;
    localparam T_RCD  = 17;
    localparam T_RP   = 17;
    localparam T_RFC  = 34;
    localparam T_WR   = 14;
    localparam T_RTP  = 7;
    localparam T_CWL  = 10;
    localparam T_ABA  = 24;
    localparam T_ABAR = 24;
    localparam T_RAS  = 32;
    localparam T_REFI = 9360;
    
    logic reset_n;
    logic ck2x;
    logic ck_cn;
    logic ck_tp;
    logic cke;
    logic [RANKS-1:0]cs_n;
    `ifdef DDR4
    logic act_n;
    `endif
    `ifdef DDR3
    logic ras_n;
    logic cas_n;
    logic we_n;
    `endif
    logic [ADDRWIDTH-1:0]A;
    logic [BAWIDTH-1:0]ba;
    logic [BGWIDTH-1:0]bg;
    wire [DQWIDTH-1:0]dq;
    logic [DQWIDTH-1:0]dq_reg;
    wire [CHIPS-1:0]dqs_cn;
    logic [CHIPS-1:0]dqs_cn_reg;
    wire [CHIPS-1:0]dqs_tp;
    logic [CHIPS-1:0]dqs_tp_reg;
    logic odt;
    `ifdef DDR4
    logic parity;
    `endif
    
    logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    
    logic writing;
    
    assign dq = (writing) ? dq_reg:{DQWIDTH{1'bZ}};
    assign dqs_cn = (writing) ? dqs_cn_reg:{CHIPS{1'bZ}};
    assign dqs_tp = (writing) ? dqs_tp_reg:{CHIPS{1'bZ}};
    
    DIMM #(.RANKS(RANKS),
    .CHIPS(CHIPS),
    .BGWIDTH(BGWIDTH),
    .BANKGROUPS(BANKGROUPS),
    .BAWIDTH(BAWIDTH),
    .ADDRWIDTH(ADDRWIDTH),
    .COLWIDTH(COLWIDTH),
    .DEVICE_WIDTH(DEVICE_WIDTH),
    .BL(BL),
    .CHWIDTH(CHWIDTH)
    ) dut (
    .reset_n(reset_n),
    .ck2x(ck2x),
    .ck_cn(ck_cn),
    .ck_tp(ck_tp),
    .cke(cke),
    .cs_n(cs_n),
    `ifdef DDR4
    .act_n(act_n),
    `endif
    `ifdef DDR3
    .ras_n(ras_n),
    .cas_n(cas_n),
    .we_n(we_n),
    `endif
    .A(A),
    .ba(ba),
    .bg(bg),
    .dq(dq),
    .dqs_cn(dqs_cn),
    .dqs_tp(dqs_tp),
    .odt(odt),
    `ifdef DDR4
    .parity(parity),
    `endif
    .sync(sync)
    );
    
    always #(tCK) ck_tp = ~ck_tp;
    always #(tCK) ck_cn = ~ck_cn;
    always #(tCK*0.5) ck2x = ~ck2x;
    
    integer i, j; // loop variable
    
    initial
    begin
        // initialize all inputs
        reset_n = 0; // DRAM is active only when this signal is HIGH
        ck_tp = 1;
        ck_cn = 0;
        ck2x = 1;
        cke = 1;
        cs_n = {RANKS{1'b1}}; // LOW makes rank active
        act_n = 1; // no ACT
        A = {ADDRWIDTH{1'b0}};
        bg = 0;
        ba = 0;
        dq_reg = {DQWIDTH{1'b0}};
        dqs_tp_reg = {CHIPS{1'b0}};
        dqs_cn_reg = {CHIPS{1'b1}};
        odt = 0;
        parity = 0;
        writing = 0;
        for (i = 0; i < BANKGROUPS; i = i + 1)
        begin
            for (j = 0; j < BANKSPERGROUP; j = j + 1)
            begin
                sync[i][j] = 0;
            end
        end
        #(tCK*0.99) // use a propagation delay because of (suspected) bug in Vivado Simulator
        
        // reset high
        reset_n = 1;
        cs_n = 1'b0; // LOW makes rank active
        #tCK;
        for (i = 0; i < BANKGROUPS; i = i + 1)
        begin
            for (j = 0; j < BANKSPERGROUP; j = j + 1)
            begin
                assert (dut.TimingFSMi.BankFSM[i][j] == 5'h00) $display("OK: StateTimingIdle"); else $display(dut.TimingFSMi.BankFSM[i][j]);
            end
        end
        #tCK;
        
        // activating
        act_n = 0;
        A = 17'b00000000000000001;
        ba = 1;
        sync[0][1] = 1;
        #tCK;
        act_n = 1;
        A = 17'b00000000000000000;
        ba = 0;
        #tCK;
        assert (dut.TimingFSMi.BankFSM[0][1] == 5'h01) $display("OK: activating"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        #(tCK*(T_RCD-1)); // tRCD
        assert (dut.TimingFSMi.BankFSM[0][1] == 5'h03) $display("OK: bank active"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        #(tCK*(T_CL-1)); // tCL
        assert (dut.TimingFSMi.BankFSM[0][1] == 5'h03) $display("OK: bank active"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        
        // write test
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000000010 : 17'b00000000000000000;
            ba = (i==0)? 1:1;// todo: needs to change?
            writing = 1;
            dq_reg = {$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom };
            dqs_tp_reg = {CHIPS{1'b1}};
            dqs_cn_reg = {CHIPS{1'b0}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h12) || (i==0)) $display("OK: writing"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        end
        dq_reg = {DQWIDTH{1'b0}};
        ba = 0;
        #(tCK*(T_ABA-BL));
        assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h12) || (i==0)) $display("OK: writing"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        writing = 0;
        #(tCK*4); // no actions
        
        `ifdef RowClone
        #(tCK*5); // activating again for RowClone
        act_n = 0;
        ba = 1;
        A = 17'b00000000000000100;
        #tCK;
        act_n = 1;
        A = 17'b00000000000000000;
        #(tCK*15); // tRCD
        `endif
        
        // read
        #tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10100000000000010 : 17'b00000000000000000;
            ba = (i==0)? 1:1;// todo: needs to change?
            dqs_tp_reg = {CHIPS{1'b0}};
            dqs_cn_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h0b) || (i==0)) $display("OK: reading"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        end
        ba = 0;
        #(tCK*(T_ABAR-BL));
        assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h0b) || (i==0)) $display("OK: reading"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        #(tCK*4); // no actions
        
        // precharge and back to idle
        ba = 1;
        A = 17'b01000000000000000;
        #tCK;
        assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h0a) || (i==0)) $display("OK: precharge"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        ba = 0;
        A = 17'b00000000000000000;
        sync[0][1] = 0;
        #((T_RP-1)*tCK);
        assert (dut.TimingFSMi.BankFSM[0][1] == 5'h00) $display("OK: idle"); else $display(dut.TimingFSMi.BankFSM[0][1]);
        #(2*tCK);
        $finish();
    end;
    
endmodule
