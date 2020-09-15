`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// references: www.systemverilog.io

module CMD
  #(parameter ADDRWIDTH = 17
  )
  (
  `ifdef DDR4
  input act_n, // Activate command input
  `endif
  `ifdef DDR3
  input ras_n,
  input cas_n,
  input we_n,
  `endif
  input cke, // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
  input [ADDRWIDTH-1:0]A,
  // ras_n -> A16, cas_n -> A15, we_n -> A14
  // Dual function inputs:
  // - when act_n & cs_n are LOW, these are interpreted as *Row* Address Bits (RAS Row Address Strobe)
  // - when act_n is HIGH, these are interpreted as command pins to indicate READ, WRITE or other commands
  // - - and CAS - Column Address Strobe (A0-A9 used for column at this times)
  // A10 which is an unused bit during CAS is overloaded to indicate Auto-Precharge
  output ACT, BST, CFG, CKEH, CKEL, DPD, DPDX, MRR, MRW, PD, PDX, PR, PRA, RD, RDA, REF, SRF, WR, WRA
  //  output WRA
  );
  
  wire A16 = A[ADDRWIDTH-1]; // RAS_n
  wire A15 = A[ADDRWIDTH-2]; // CAS_n
  wire A14 = A[ADDRWIDTH-3]; // WE_n
  wire A10 = A[ADDRWIDTH-4]; // AP // todo: check how this needs to relate to COL WIDTH
  
  // implement ddr logic // todo implement all commands not just a few
  assign ACT = (!act_n); // entire A is the Row Address at this time
  assign BST = (act_n && A[ADDRWIDTH-2]); // todo
  assign CFG = 0;
  assign CKEH = 0;//cke;
  assign CKEL = 0;//!cke;
  assign DPD = 0;
  assign DPDX = 0;
  assign MRR = 0;
  assign MRW = 0;
  assign PD = 0;
  assign PDX = 0;
  assign PR  = (act_n && !A16 &&  A15 && !A14 && !A10); // PRE
  assign PRA = (act_n && !A16 &&  A15 && !A14 &&  A10);
  assign RD  = (act_n &&  A16 && !A15 &&  A14 && !A10);
  assign RDA = (act_n &&  A16 && !A15 &&  A14 &&  A10);
  assign REF = (act_n && !A16 && !A15 &&  A14         &&  cke);
  assign SRF = (act_n && !A16 && !A15 &&  A14         && !cke); // SRE
  assign WR  = (act_n &&  A16 && !A15 && !A14 && !A10);
  assign WRA = (act_n &&  A16 && !A15 && !A14 &&  A10);
  
endmodule
