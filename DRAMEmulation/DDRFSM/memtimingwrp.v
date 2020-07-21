
module memtimingwrp
       #(parameter width = 8,
         parameter rows = 128,
         parameter columns = 64)
       (
         input wire clk,
         input wire rst,
         input halt,
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
         inout [width-1 : 0]dq,
         input [$clog2(rows)-1 : 0] row,
         input [$clog2(columns)-1 : 0] column,
         input wr_req,
         input rd_req
       );

reg [width-1 : 0] o_data;
assign dq = rd_req ? o_data : {width{1'bZ}};

sram #(.WIDTH(8), .DEPTH(128)) array (
       .clk(clk),
       .addr({row, column}),
       .rd_o_wr(WR||WRA||wr_req),
       .i_data(dq),
       .o_data(o_data)
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
