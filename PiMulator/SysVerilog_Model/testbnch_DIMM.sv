`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// `define RowClone

module testbnch_DIMM();
    
    parameter RANKS = 1;
    parameter CHIPS = 16;
    parameter BGWIDTH = 2;
    parameter BAWIDTH = 2;
    parameter ADDRWIDTH = 17;
    parameter COLWIDTH = 10;
    parameter DEVICE_WIDTH = 4; // x4, x8, x16 -> DQ width = Device_Width x BankGroups (Chips)
    parameter BL = 8; // Burst Length
    parameter CHWIDTH = 5; // Emulation Memory Cache Width
    
    localparam DQWIDTH = DEVICE_WIDTH*CHIPS; // 64 bits + 8 bits for ECC
    localparam BANKGROUPS = 2**BGWIDTH;
    localparam BANKSPERGROUP = 2**BAWIDTH;
    localparam ROWS = 2**ADDRWIDTH;
    localparam COLS = 2**COLWIDTH;
    
    localparam CHIPSIZE = (DEVICE_WIDTH*COLS*(ROWS/1024)*BANKSPERGROUP*BANKGROUPS)/(1024); // Mbit
    localparam DIMMSIZE = (CHIPSIZE*CHIPS)/(1024*8); // GB
    
    localparam tCK = 0.75;
    
    localparam T_CL   = 17;   // CAS is the Column-Address-Strobe, i.e., when the column address is presented on the lines. CL is the delay, in clock cycles, between the internal READ command and the availability of the first bit of output data.
    localparam T_RCD  = 17;   // Row to Column command delay, time interval between row access and data ready at sense amplifier
    localparam T_RP   = 17;   // Row precharge, time to precharge DRAM to access another row
    localparam T_RFC  = 34;   // Refresh cycle time, time b/w refresh and activation command
    localparam T_WR   = 14;   // Write recovery time, time b/w end of write data burst and start of a precharge command
    localparam T_RTP  = 7;    // Read to Precharge, time b/w read and precharge command (~t_cas(column access strobe latency)-t_cmd(command transport duration))
    localparam T_CWL  = 10;   //
    localparam T_ABA  = 24;   // 
    localparam T_ABAR = 24;   //
    localparam T_RAS  = 32;   // Row access strobe latency
    localparam T_REFI = 9360; // Time refresh Interval
    
    logic reset_n;
    logic ck2x;
    `ifdef DDR4
    logic ck_c;
    logic ck_t;
    `elsif DDR3
    logic ck_n;
    logic ck_p;
    `endif
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
    `ifdef DDR4
    logic [BGWIDTH-1:0]bg; // todo: explore adding one bit that is always ignored
    `endif
    wire [DQWIDTH-1:0]dq;
    logic [DQWIDTH-1:0]dq_reg;
    `ifdef DDR4
    wire [CHIPS-1:0]dqs_c;
    logic [CHIPS-1:0]dqs_c_reg;
    wire [CHIPS-1:0]dqs_t;
    logic [CHIPS-1:0]dqs_t_reg;
    `elsif DDR3
    wire [CHIPS-1:0]dqs_n;
    logic [CHIPS-1:0]dqs_n_reg;
    wire [CHIPS-1:0]dqs_p;
    logic [CHIPS-1:0]dqs_p_reg;
    `endif
    logic odt;
    `ifdef DDR4
    logic parity;
    `endif
    
    logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    
    logic writing;
    
    assign dq = (writing) ? dq_reg:{DQWIDTH{1'bZ}};
    assign dqs_c = (writing) ? dqs_c_reg:{CHIPS{1'bZ}};
    assign dqs_t = (writing) ? dqs_t_reg:{CHIPS{1'bZ}};
    
    DIMM #(.RANKS(RANKS),
    .CHIPS(CHIPS),
    .BGWIDTH(BGWIDTH),
    .BAWIDTH(BAWIDTH),
    .ADDRWIDTH(ADDRWIDTH),
    .COLWIDTH(COLWIDTH),
    .DEVICE_WIDTH(DEVICE_WIDTH),
    .BL(BL),
    .CHWIDTH(CHWIDTH)
    ) dut (
    .reset_n(reset_n),
    .ck2x(ck2x),
    `ifdef DDR4
    .ck_c(ck_c),
    .ck_t(ck_t),
    `elsif DDR3
    .ck_n(ck_n),
    .ck_p(ck_p),
    `endif
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
    `ifdef DDR4
    .bg(bg),
    `endif
    .dq(dq),
    `ifdef DDR4
    .dqs_c(dqs_c),
    .dqs_t(dqs_t),
    `elsif DDR3
    .dqs_n(dqs_n),
    .dqs_p(dqs_p),
    `endif
    .odt(odt),
    `ifdef DDR4
    .parity(parity),
    `endif
    .sync(sync)
    );
    
    always #(tCK) ck_t = ~ck_t;
    always #(tCK) ck_c = ~ck_c;
    always #(tCK*0.5) ck2x = ~ck2x;
    
    integer i, j; // loop variable
    
    initial
    begin
        // initialize all inputs
        reset_n = 0; // DRAM is active only when this signal is HIGH
        ck_t = 1;
        ck_c = 0;
        ck2x = 1;
        cke = 1;
        cs_n = {RANKS{1'b1}}; // LOW makes rank active
        act_n = 1; // no ACT
        A = {ADDRWIDTH{1'b0}};
        bg = 0;
        ba = 0;
        dq_reg = {DQWIDTH{1'b0}};
        dqs_t_reg = {CHIPS{1'b0}};
        dqs_c_reg = {CHIPS{1'b1}};
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
        bg = 1;
        ba = 1;
        sync[1][1] = 1;
        #tCK;
        act_n = 1;
        A = 17'b00000000000000000;
        bg = 0;
        ba = 0;
        #tCK;
        assert (dut.TimingFSMi.BankFSM[1][1] == 5'h01) $display("OK: activating"); else $display(dut.TimingFSMi.BankFSM[1][1]);
        #(tCK*(T_RCD-1)); // tRCD
        assert (dut.TimingFSMi.BankFSM[1][1] == 5'h03) $display("OK: bank active"); else $display(dut.TimingFSMi.BankFSM[1][1]);
        #(tCK*(T_CL-1)); // tCL
        assert (dut.TimingFSMi.BankFSM[1][1] == 5'h03) $display("OK: bank active"); else $display(dut.TimingFSMi.BankFSM[1][1]);
        
        // write test
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000000001 : 17'b00000000000000000;
            bg = (i==0)? 1:1;// todo: needs to change?
            ba = (i==0)? 1:1;// todo: needs to change?
            writing = 1;
            dq_reg = {$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom };
            dqs_t_reg = {CHIPS{1'b1}};
            dqs_c_reg = {CHIPS{1'b0}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[1][1] == 5'h12) || (i==0)) $display("OK: writing", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[1][1]);
        end
        dq_reg = {DQWIDTH{1'b0}};
        bg = 0;
        ba = 0;
        #(tCK*(T_ABA-BL));
        assert ((dut.TimingFSMi.BankFSM[1][1] == 5'h12) || (i==0)) $display("OK: writing", $time," dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[1][1]);
        writing = 0;
        #(tCK*4); // no actions
        
        `ifdef RowClone
        #(tCK*5); // activating again for RowClone
        act_n = 0;
        bg = 1;
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
            A = (i==0)? 17'b10100000000000001 : 17'b00000000000000000;
            bg = (i==0)? 1:1;// todo: needs to change?
            ba = (i==0)? 1:1;// todo: needs to change?
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[1][1] == 5'h0b) || (i==0)) $display("OK: reading", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[1][1]);
        end
        bg = 0;
        ba = 0;
        #(tCK*(T_ABAR-BL));
        assert ((dut.TimingFSMi.BankFSM[1][1] == 5'h0b) || (i==0)) $display("OK: reading", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[1][1]);
        #(tCK*4); // no actions
        
        // precharge and back to idle
        bg = 1;
        ba = 1;
        A = 17'b01000000000000000;
        #tCK;
        assert ((dut.TimingFSMi.BankFSM[1][1] == 5'h0a) || (i==0)) $display("OK: precharge"); else $display(dut.TimingFSMi.BankFSM[1][1]);
        bg = 0;
        ba = 0;
        A = 17'b00000000000000000;
        sync[1][1] = 0;
        #((T_RP-1)*tCK);
        assert (dut.TimingFSMi.BankFSM[1][1] == 5'h00) $display("OK: idle"); else $display(dut.TimingFSMi.BankFSM[1][1]);
        #(2*tCK);
        $finish();
    end;
    
endmodule
