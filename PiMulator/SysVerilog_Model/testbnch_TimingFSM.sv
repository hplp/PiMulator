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
       
       // Bank Timing FSMs instance dut
       TimingFSM #(.BGWIDTH(BGWIDTH),
       .BAWIDTH(BAWIDTH))
       dut(
       .clk(clk),
       .reset_n(reset_n),
       .bg(bg),
       .ba(ba),
       .ACT(ACT), .BST(BST), .CFG(CFG), .CKEH(CKEH), .CKEL(CKEL), .DPD(DPD), .DPDX(DPDX), .MRR(MRR), .MRW(MRW), .PD(PD), .PDX(PDX), .PR(PR), .PRA(PRA), .RD(RD), .RDA(RDA), .REF(REF), .SRF(SRF), .WR(WR), .WRA(WRA),
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
              
              `ifdef TestWrite
              // activating a row in bank 1 in bank group 1
              ACT = 1;
              bg = 1;
              ba = 1;
              #tCK;
              ACT = 0;
              #tCK;
              $display("activating");
              assert (BankFSM[bg][bg] == 5'h01) else $display(BankFSM[bg][bg]); // activating
              #(tCK*(T_RCD-1)); // tRCD
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              #(tCK*(T_CL-1)); // tCL
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              
              // write
              for (i = 0; i <T_WR ; i = i + 1)
              begin
                     WR = (i==0)? 1 : 0;
                     #tCK;
                     $display("writing");
                     assert ((BankFSM[bg][bg] == 5'h12) || (i==0)) else $display(BankFSM[bg][bg]); // writing
              end
              #tCK;
              $display("writing");
              assert (BankFSM[bg][bg] == 5'h12) else $display(BankFSM[bg][bg]); // writing
              
              `ifdef TestWriteReadWrite
              // read
              for (i = 0; i < BL; i = i + 1)
              begin
                     RD = (i==0)? 1 : 0;
                     #tCK;
                     $display("reading");
                     assert ((BankFSM[bg][bg] == 5'h0b) || (i==0)) else $display(BankFSM[bg][bg]); // reading
              end
              #tCK;
              $display("reading");
              assert ((BankFSM[bg][bg] == 5'h0b) || (i==0)) else $display(BankFSM[bg][bg]); // reading
              
              // write
              for (i = 0; i <T_WR ; i = i + 1)
              begin
                     WR = (i==0)? 1 : 0;
                     #tCK;
                     $display("writing");
                     assert ((BankFSM[bg][bg] == 5'h12) || (i==0)) else $display(BankFSM[bg][bg]); // writing
              end
              #tCK;
              $display("writing");
              assert (BankFSM[bg][bg] == 5'h12) else $display(BankFSM[bg][bg]); // writing
              `endif
              
              // precharge and back to idle
              PR = 1;
              #tCK;
              PR = 0;
              #tCK;
              $display("precharge");
              assert (BankFSM[bg][bg] == 5'h0a) else $display(BankFSM[bg][bg]); // precharge
              #((T_RP-1)*tCK)
              $display("idle");
              assert (BankFSM[bg][bg] == 5'h00) else $display(BankFSM[bg][bg]); // idle
              bg = 0;
              ba = 0;
              #(2*tCK);
              `endif
              
              `ifdef TestRefresh
              // refresh
              bg = 1;
              ba = 1;
              REF = 1;
              #tCK;
              REF = 0;
              #tCK;
              $display("refreshing");
              assert (BankFSM[bg][bg] == 5'h0d) else $display(BankFSM[bg][bg]); // refreshing
              #((T_RFC-1)*tCK);
              $display("idle");
              assert (BankFSM[bg][bg] == 5'h00) else $display(BankFSM[bg][bg]); // idle
              bg = 0;
              ba = 0;
              #(2*tCK);
              `endif
              
              `ifdef WRAutoPrecharge
              // activating a row in bank 1 in bank group 1
              ACT = 1;
              bg = 1;
              ba = 1;
              #tCK;
              ACT = 0;
              #tCK;
              $display("activating");
              assert (BankFSM[bg][bg] == 5'h01) else $display(BankFSM[bg][bg]); // activating
              #(tCK*(T_RCD-1)); // tRCD
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              #(tCK*(T_CL-1)); // tCL
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              
              // write Auto-Precharge
              for (i = 0; i <T_WR ; i = i + 1)
              begin
                     WRA = (i==0)? 1 : 0;
                     #tCK;
                     $display("writingAP");
                     assert ((BankFSM[bg][bg] == 5'h13) || (i==0)) else $display(BankFSM[bg][bg]); // writingAP
              end
              #tCK;
              $display("writingAP");
              assert (BankFSM[bg][bg] == 5'h13) else $display(BankFSM[bg][bg]); // writingAP
              
              // precharge and back to idle
              #tCK;
              $display("precharge");
              assert (BankFSM[bg][bg] == 5'h0a) else $display(BankFSM[bg][bg]); // precharge
              #((T_RP-1)*tCK)
              $display("idle");
              assert (BankFSM[bg][bg] == 5'h00) else $display(BankFSM[bg][bg]); // idle
              bg = 0;
              ba = 0;
              #(2*tCK);
              `endif
              
              `ifdef RDAutoPrecharge
              // activating a row in bank 1 in bank group 1
              ACT = 1;
              bg = 1;
              ba = 1;
              #tCK;
              ACT = 0;
              #tCK;
              $display("activating");
              assert (BankFSM[bg][bg] == 5'h01) else $display(BankFSM[bg][bg]); // activating
              #(tCK*(T_RCD-1)); // tRCD
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              #(tCK*(T_CL-1)); // tCL
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              
              `ifdef RowClone
              ACT = 1; // activating again for RowClone
              #tCK;
              ACT = 0;
              #tCK;
              $display("RowClone");
              assert (BankFSM[bg][bg] == 5'h14) else $display(BankFSM[bg][bg]); // 10100
              #(tCK*(T_RCD-1)); // tRCD
              $display("bank active");
              assert (BankFSM[bg][bg] == 5'h03) else $display(BankFSM[bg][bg]); // bank active
              `endif
              
              // read Auto-Precharge
              for (i = 0; i <BL ; i = i + 1)
              begin
                     RDA = (i==0)? 1 : 0;
                     #tCK;
                     $display("readingAP");
                     assert ((BankFSM[bg][bg] == 5'h0c) || (i==0)) else $display(BankFSM[bg][bg]); // readingAP
              end
              #tCK;
              $display("readingAP");
              assert (BankFSM[bg][bg] == 5'h0c) else $display(BankFSM[bg][bg]); // readingAP
              
              // precharge and back to idle
              #tCK;
              $display("precharge");
              assert (BankFSM[bg][bg] == 5'h0a) else $display(BankFSM[bg][bg]); // precharge
              #((T_RP-1)*tCK)
              $display("idle");
              assert (BankFSM[bg][bg] == 5'h00) else $display(BankFSM[bg][bg]); // idle
              bg = 0;
              ba = 0;
              #(2*tCK);
              `endif
              
              $finish();
       end;
       
endmodule