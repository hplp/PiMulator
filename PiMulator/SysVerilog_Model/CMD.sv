`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// references: www.systemverilog.io

// the native DIMM channel interface signals are passed to this module to be decoded into memory commands
// additionally, RAS and CAS controls are implemented

module CMD
  #(parameter ADDRWIDTH = 17,
    parameter COLWIDTH = 10,
    parameter BGWIDTH = 2,
    parameter BAWIDTH = 2,

    localparam BANKGROUPS = 2**BGWIDTH,
    localparam BANKSPERGROUP = 2**BAWIDTH
)
  (
  `ifdef DDR4
  input act_n,
  `endif
  `ifdef DDR3
  input ras_n,
  input cas_n,
  input we_n,
  `endif
  input cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
    input cs_n, // Chip select; The memory looks at all the other inputs only if this is LOW todo: scale to more than 1 rank
    input clk,
    input [BGWIDTH-1:0] bg,
    input [BAWIDTH-1:0] ba,
    input [ADDRWIDTH-1:0] A,
    // ras_n -> A16, cas_n -> A15, we_n -> A14
    // Dual function inputs:
    // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
    // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
    // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
    // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
    output logic [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic [COLWIDTH-1:0] ColId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA
);

    wire A16 = A[ADDRWIDTH-1]; // RAS_n
    wire A15 = A[ADDRWIDTH-2]; // CAS_n
    wire A14 = A[ADDRWIDTH-3]; // WE_n
    wire A10 = A[ADDRWIDTH-4]; // AP

    // implement ddr command decoding logic using truth table // todo: implement all commands not just a few
    assign ACT  = (!cs_n && !act_n); // entire A is the Row Address at this time
    assign BST  = 0; //(act_n && A[ADDRWIDTH-2]); // todo:
    assign CFG  = 0;
    assign CKEH = 0; //cke;
    assign CKEL = 0; //!cke;
    assign DPD  = 0;
    assign DPDX = 0;
    assign MRR  = 0;
    assign MRW  = 0;
    assign PD   = 0;
    assign PDX  = 0;
    assign PR   = (!cs_n && act_n && !A16 &&  A15 && !A14 && !A10); // PRE
    assign PRA  = (!cs_n && act_n && !A16 &&  A15 && !A14 &&  A10); // PREA Precharge all Banks
    assign RD   = (!cs_n && act_n &&  A16 && !A15 &&  A14 && !A10);
    assign RDA  = (!cs_n && act_n &&  A16 && !A15 &&  A14 &&  A10);
    assign REF  = (!cs_n && act_n && !A16 && !A15 &&  A14         &&  cke);
    assign SRF  = (!cs_n && act_n && !A16 && !A15 &&  A14         && !cke); // SRE
    assign WR   = (!cs_n && act_n &&  A16 && !A15 && !A14 && !A10);
    assign WRA  = (!cs_n && act_n &&  A16 && !A15 && !A14 &&  A10);

    // RAS = Row Address Strobe
    // the idea here is to store the address A during an activate command
    // thus keep track of which row is active at each Bank
    always@(posedge clk)
    begin
        if(!cs_n && !act_n) begin // if ACT
            RowId[bg][ba] <= A;
        end
    end

    // CAS = Column Address Strobe
    // 
    logic Burst [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    always@(posedge clk)
    begin
        if(WR || WRA || RD || RDA) begin
            ColId[bg][ba] <= A[COLWIDTH-1:0];
            Burst[bg][ba] <= 1;
        end
        else if (PR) begin
            //ColId[bg][ba] <= {COLWIDTH{1'b0}};
            Burst[bg][ba] <= 0;
        end
        else begin
            for (int i = 0; i < BANKGROUPS; i++) begin
                for (int j = 0; j < BANKGROUPS; j++) begin
                    if(Burst[i][j]) ColId[i][j] <= ColId[i][j] + 1;
                end
            end
        end
    end

    // Write Enable bit
    // will determine the read or write (in or out state of the inout data pins)
    always@(posedge clk)
    begin
        if(WR || WRA) rd_o_wr[bg][ba] <= 1;
        else if (PR || RD || RDA) rd_o_wr[bg][ba] <= 0;
        else rd_o_wr[bg][ba] <= 0;
    end

`ifndef SYNTHESIS
// initialize RowId, Column, Burst to values 0 for simulation runs
    initial
    begin
        for (integer i=0;i<=BANKGROUPS;i=i+1) begin
            for (integer j=0;j<=BANKSPERGROUP;j=j+1) begin
                RowId[i][j] = {ADDRWIDTH{1'b0}};
                ColId[i][j] = {COLWIDTH{1'b0}};
                Burst[i][j] = 0;
                rd_o_wr[i][j] = 0;
            end
        end
    end
`endif

endmodule

// // RAS = Row Address Strobe
// reg [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
// always@(posedge clk)
// begin
//   if(ACT) RowId[bg][ba] <= A;
//   else if (PR) RowId[bg][ba] <= {ADDRWIDTH{1'b0}};
// end

// CAS = Column Address Strobe plus BL column address increment
// reg [$clog2(COLS)-1:0]colBL=0;
// always@(posedge clk)
//   begin
//     if((FSMstate==5'b01011) || (FSMstate==5'b01100))
//       colBL <= column;
//     else
//       if ((FSMstate==5'b10010) || (FSMstate==5'b10011) || (FSMstate==5'b01011) || (FSMstate==5'b01100))
//         colBL <= colBL + 1;
//       else
//         colBL <= {$clog2(COLS){1'b0}};
//   end

//
// reg [CADDRWIDTH-1:0] column = {CADDRWIDTH{1'b0}};
// always@(posedge clk)
//   begin
//     if(RD || RDA || WR || WRA)
//       column <= A[CADDRWIDTH-1:0];
//     else
//       column <= {CADDRWIDTH{1'b0}};
//   end

// Address demultiplexing
// wire [ADDRWIDTH-1:0] addresses [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
// generate
//   for (bgi = 0; bgi < BANKGROUPS; bgi=bgi+1)
//   begin
//     for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
//     begin
//       assign addresses[bgi][bi] = ((bg==bgi)&&(ba==bi))? A : {ADDRWIDTH{1'b0}};
//     end
//   end
// endgenerate
