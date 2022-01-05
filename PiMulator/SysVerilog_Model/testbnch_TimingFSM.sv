`timescale 1ns / 1ps

//`define RowClone

module testbnch_TimingFSM(
       );
       
       parameter BGWIDTH = 2; // set to 0 for DDR3
       parameter BAWIDTH = 2;
       parameter BL = 8; // Burst Length
       parameter T_WR = 14;
       parameter T_ABA = 24;
       parameter T_ABAR = 24;
       parameter T_RTP = 7;
       localparam BANKGROUPS = 2**BGWIDTH;
       localparam BANKSPERGROUP = 2**BAWIDTH;
       
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

              // activating a row in bank 1 in bank group 1
              ACT = 1;
              bg = 1;
              ba = 1;
              #tCK;
              ACT = 0;
              #(tCK*15); // tRCD
              #(tCK*18); // tCL
              
              // write
              #tCK;

             // WRA = 1;
              //#tCK;
             // WRA = 0;
              //#(tCK*BL-1);


              for (i = 0; i <T_WR ; i = i + 1)
              begin
                     WR = (i==0)? 1 : 0;
                     #tCK;
              end
               #tCK;
               
             // precharge and back to idle
               #tCK;
               PR = 1;
               #tCK;
               PR = 0;
               #(16*tCK)

               // refresh
              REF = 1;
              #tCK;
              REF = 0;
              #(34*tCK);

              bg = 0;
              ba = 0;
              #(4*tCK);

              
              // activating a row in bank 1 in bank group 1
               ACT = 1;
               bg = 1;
               ba = 1;
               #tCK;
               ACT = 0;
               #(tCK*15); // tRCD
               #(tCK*18); // tCL


// write
               #tCK;

               // WRA = 1;
                //#tCK;
               // WRA = 0;
                //#(tCK*BL-1);
  
  
                for (i = 0; i <T_WR ; i = i + 1)
                begin
                       WR = (i==0)? 1 : 0;
                       #tCK;
                end
                 #tCK;
                 

             // read
               for (i = 0; i < BL; i = i + 1)
               begin
                      #tCK;
                      RD = (i==0)? 1 : 0;
               end

               // write
               #tCK;
                      for (i = 0; i <T_WR ; i = i + 1)
                begin
                       WR = (i==0)? 1 : 0;
                       #tCK;
                end
                 #tCK;
                 
             // precharge and back to idle
               #tCK;
               PR = 1;
               #tCK;
               PR = 0;
               #(16*tCK);

              // activating a row in bank 1 in bank group 1
               ACT = 1;
               bg = 1;
               ba = 1;
               #tCK;
               ACT = 0;
               #(tCK*15); // tRCD
               #(tCK*18); // tCL
               
               // write Auto-Precharge
               #tCK;
               for (i = 0; i < T_WR; i = i + 1)
               begin
                      WRA = (i==0)? 1 : 0;
                      #tCK;
               end
            
              //`ifdef RowClone
              //#(tCK*5); // activating again for RowClone
              //ACT = 1;
              //#tCK;
              //ACT = 0;
              //#(tCK*15); // tRCD
              //`endif
              
              #(18*tCK)
              // activating a row in bank 1 in bank group 1
              ACT = 1;
              bg = 1;
              ba = 1;
              #tCK;
              ACT = 0;
              #(tCK*15); // tRCD
              #(tCK*18); // tCL

             // read
             for (i = 0; i < BL; i = i + 1)
             begin
                    #tCK;
                    RD = (i==0)? 1 : 0;
             end
          

             // precharge and back to idle
             #tCK;
             PR = 1;
             #tCK;
             PR = 0;
             #(16*tCK)
              // activating a row in bank 1 in bank group 1
              ACT = 1;
              bg = 1;
              ba = 1;
              #tCK;
              ACT = 0;
              #(tCK*15); // tRCD
              #(tCK*18); // tCL
              // read Auto-Precharge
              for (i = 0; i < BL; i = i + 1)
              begin
                     #tCK;
                     RDA = (i==0)? 1 : 0;
              end

              #(18*tCK) // need to wait for the precharge time period before attempting any command
             // refresh
              REF = 1;
              #tCK;
              REF = 0;
              #(34*tCK);

              bg = 0;
              ba = 0;
              #(4*tCK);

              // precharge and back to idle
              #tCK;
              PR = 1;
              #tCK;
              PR = 0;
              #(16*tCK)
 	               
              $stop;
       end;
       
endmodule