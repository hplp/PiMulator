`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// references: www.systemverilog.io

// The native DIMM channel interface signals (addressing and controls) are passed to this
// module to be decoded into memory commands. Additionally, RAS and CAS controls are implemented.
module CMD
    #(parameter ADDRWIDTH = 17,
    parameter COLWIDTH = 10,
    parameter BGWIDTH = 2,
    parameter BANKGROUPS = 2**BGWIDTH,
    parameter BAWIDTH = 2,
    parameter BL = 8, // Burst Length
    
    localparam BANKSPERGROUP = 2**BAWIDTH
    )
    (
    input logic cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
    input logic cs_n, // Chip select; The memory looks at all the other inputs only if this is LOW todo: scale to more than 1 rank
    input logic clk,
    `ifdef DDR4
    input logic act_n,
    `endif
    `ifdef DDR3
    input logic ras_n,
    input logic cas_n,
    input logic we_n,
    `endif
    input logic [BGWIDTH-1:0] bg,
    input logic [BAWIDTH-1:0] ba,
    input logic [ADDRWIDTH-1:0] A,
    output logic [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic [COLWIDTH-1:0] ColId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic [18:0] commands
    );
    
    // ras_n -> A16, cas_n -> A15, we_n -> A14
    // Dual function inputs:
    // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
    // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
    // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
    // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
    logic A16, A15, A14, A10;
    assign A16 = A[ADDRWIDTH-1]; // RAS_n
    assign A15 = A[ADDRWIDTH-2]; // CAS_n
    assign A14 = A[ADDRWIDTH-3]; // WE_n
    assign A10 = A[ADDRWIDTH-4]; // AP
    
    logic ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA;
    
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
    
    assign commands = {ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA};
    
    // RAS = Row Address Strobe;
    // the idea here is to store the address A during an activate command
    // thus keep track of which row is active at each Bank
    always@(posedge clk)
    begin
        if(ACT) begin // store the active row
            RowId[bg][ba] <= A;
        end
    end
    
    logic Burst [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    // CAS = Column Address Strobe;
    // similarly, here we store the first column and iterate to implement a burst count
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
                for (int j = 0; j < BANKSPERGROUP; j++) begin
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
        // else rd_o_wr[bg][ba] <= 0;
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
