`timescale 1ns / 1ps

`define DDR4
// `define DDR3

module testbnch_BankInterleaving(
);

    parameter RANKS = 1;
    parameter CHIPS = 8;
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
    localparam T_CL   = 17; //CAS is the Column-Address-Strobe, i.e., when the column address is presented on the lines. CL is the delay, in clock cycles, between the internal READ command and the availability of the first bit of output data.
    localparam T_RCD  = 17; //Row to Column command delay, time interval between row access and data ready at sense amplifier
    localparam T_ABA  = 24; // 
    localparam T_RRDs = 4; //row to row delay in same bank group
    localparam T_RRDl = 6; // row to row delay in banks of different groups
    localparam T_ABAR = 24;
    localparam T_RP   = 17; //Row precharge, time to precharge DRAM to access another row
    localparam T_RFC  = 34; //Refresh cycle time, time b/w refresh and activation command
    
    logic reset_n;
    logic ck2x;
       `ifdef DDR4
       logic ck_c;
    logic ck_t;
       `elsif DDR3
       reg ck_n;
       reg ck_p;
       `endif
       logic cke;
    logic [RANKS-1:0]cs_n;
       `ifdef DDR4
       logic act_n;
       `endif
       `ifdef DDR3
       reg ras_n;
       reg cas_n;
       reg we_n;
       `endif
       logic [ADDRWIDTH-1:0]A;
       logic [BAWIDTH-1:0]ba;
       `ifdef DDR4
       logic [BGWIDTH-1:0]bg;
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
       reg [CHIPS-1:0]dqs_n_reg;
       wire [CHIPS-1:0]dqs_p;
       reg [CHIPS-1:0]dqs_p_reg;
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
        reset_n = 0;
        ck2x = 1;
        ck_t = 1;
        ck_c = 0;
        cke = 1;
        cs_n = {RANKS{1'b1}};
        act_n = 1;
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
        #tCK;

        // reset high
        reset_n = 1;  //reset release 
        cs_n = 1'b0;  //chip select for the Rank 0
        #(tCK*5);

        for (i = 0; i < BANKGROUPS; i = i + 1)
        begin
            for (j = 0; j < BANKSPERGROUP; j = j + 1)
            begin
                assert (dut.TimingFSMi.BankFSM[i][j] == 5'h00) $display("OK: StateTimingIdle"); else $display(dut.TimingFSMi.BankFSM[i][j]);
            end
        end
        #tCK;


            act_n = 0;  /// Act = cs_n = 0, act_n = 0, A16:0 = row_addr
            A = 17'b00000000000000001;
            bg = 0;
            ba = 0;
            sync[0][0] = 1;
            #(tCK*4); //t_RRD_s
            bg = 0;
            ba = 1;
            sync[0][1] = 1;
            #(tCK*4);
            bg = 0;
            ba = 2;
            sync[0][2] = 1;
            #(tCK*4);
            bg = 0;
            ba = 3;
            sync[0][3] = 1;
            #tCK;
            act_n = 1;  // the command should now be DES ( deselect)
            
            //#(tCK*(T_RCD-1+T_CL-1)); ( wait till the bank is active)
            //write sequence
        
        //from testbnch_DIMM
        A = 17'b00000000000000000;
        bg = 0;
        ba = 0;
        #tCK;
        assert (dut.TimingFSMi.BankFSM[0][0] == 5'h01) $display("OK: activating"); else $display(dut.TimingFSMi.BankFSM[0][0]);
        #(tCK*(T_RCD-1)); // tRCD
        assert (dut.TimingFSMi.BankFSM[0][0] == 5'h03) $display("OK: bank active"); else $display(dut.TimingFSMi.BankFSM[0][0]);
        #(tCK*(T_CL-1)); // tCL
        assert (dut.TimingFSMi.BankFSM[0][0] == 5'h03) $display("OK: bank active"); else $display(dut.TimingFSMi.BankFSM[0][0]);            
         
        //writing
        #tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 0:0;// todo: needs to change?
            writing = 1;
            dq_reg = {$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom };
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][0] == 5'h012) || (i==0)) $display("OK: writing", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][0]);
        end
        writing = 0;   
        //#tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 1:1;// todo: needs to change?
            writing = 1;
            dq_reg = {$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom };
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h012) || (i==0)) $display("OK: writing", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][0]);
        end
        writing =0;        
        //#tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 2:2;// todo: needs to change?
            writing = 1;
            dq_reg = {$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom };
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][2] == 5'h012) || (i==0)) $display("OK: writing", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][0]);
        end        
        writing = 0;
        //#tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 3:3;// todo: needs to change?
            writing = 1;
            dq_reg = {$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom };
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][3] == 5'h012) || (i==0)) $display("OK: writing", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][0]);
        end       
        writing = 0;
        //from testbnch_DIMM ( Z is gettign written to the memory)
//        #(tCK*(T_ABA-BL));
//        assert ((dut.TimingFSMi.BankFSM[1][1] == 5'h12) || (i==0)) $display("OK: writing", $time," dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[1][1]);
//        writing = 0;
        //reading with Auto precharge  
        //#tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            //A = (i==0)? 17'b10100000000000010 : 17'b00000000000000000;
            A = (i==0)? 17'b10100010000000001 : 17'b00000000000000000; //change made by kk for addr and RDA
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 0:0;// todo: needs to change?
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][0] == 5'h0c) || (i==0)) $display("OK: reading with autoprecharge", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][0]);
        end

         
        //reading with Auto precharge  
        #tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10100010000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 1:1;// todo: needs to change?
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h0c) || (i==0)) $display("OK: reading with autoprecharge", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][1]);
        end
         
        //reading with Auto precharge  
        #tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10100010000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 2:2;// todo: needs to change?
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][2] == 5'h0c) || (i==0)) $display("OK: reading with autoprecharge", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][2]);
        end

         
        //reading with Auto precharge  
        #tCK;
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10100010000000001 : 17'b00000000000000000;
            bg = (i==0)? 0:0;// todo: needs to change?
            ba = (i==0)? 3:3;// todo: needs to change?
            dqs_t_reg = {CHIPS{1'b0}};
            dqs_c_reg = {CHIPS{1'b1}};
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][3] == 5'h0c) || (i==0)) $display("OK: reading with autoprecharge", $time, " dq= h%x ", dq); else $display(dut.TimingFSMi.BankFSM[0][3]);
        end

// refresh 
        #(tCK*(T_RP-1));
            A = 17'b00100000000000000;
            bg = 0;
            ba = 0;
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][0] == 5'h0d) || (i==0)) $display("OK: refreshing", $time); else $display(dut.TimingFSMi.BankFSM[0][0]);
            bg = 0;
            ba = 1;
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][1] == 5'h0d) || (i==0)) $display("OK: refreshing", $time); else $display(dut.TimingFSMi.BankFSM[0][1]);
            bg = 0;
            ba = 2;
            #tCK;
            assert ((dut.TimingFSMi.BankFSM[0][2] == 5'h0d) || (i==0)) $display("OK: refreshing", $time); else $display(dut.TimingFSMi.BankFSM[0][2]);
            bg = 0;
            ba = 3;
        #(tCK*(T_RFC -1));
            assert ((dut.TimingFSMi.BankFSM[0][3] == 5'h0d) || (i==0)) $display("OK: refreshing", $time); else $display(dut.TimingFSMi.BankFSM[0][3]);    
          A = 17'b00000000000000000;  
        #(20*tCK);
        $finish();
    end;

endmodule
