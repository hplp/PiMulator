module memtimingwrp (
         input wire ACT,
         input wire BST,
         input wire CFG,
         input wire CKEH,
         input wire CKEL,
         input wire DPD,
         input wire DPDX,
         input wire MRR,
         input wire MRW,
         input wire PD,
         input wire PDX,
         input wire PR,
         input wire PRA,
         input wire RD,
         input wire RDA,
         input wire REF,
         input wire SRF,
         input wire WR,
         input wire WRA,
         input wire clk,
         input wire rst,
         input halt
       );

wire eclk = clk && ~halt;

memtiming memtimingi (
            .tCLct(),
            .tRCDct(),
            .tRFCct(),
            .tRPct(),
            .ACT(ACT),
            .BST(BST),
            .CFG(CFG),
            .CKEH(CKEH),
            .CKEL(CKEL),
            .DPD(DPD),
            .DPDX(DPDX),
            .MRR(MRR),
            .MRW(MRW),
            .PD(PD),
            .PDX(PDX),
            .PR(PR),
            .PRA(PRA),
            .RD(RD),
            .RDA(RDA),
            .REF(REF),
            .SRF(SRF),
            .WR(WR),
            .WRA(WRA),
            .clk(eclk),
            .rst(rst)
          );

endmodule
