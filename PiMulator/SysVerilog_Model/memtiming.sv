// Created by fizzim.pl version 5.20 on 2022:01:17 at 19:04:56 (www.fizzim.com)

module memtiming
  #(parameter BL = 8
  )
  (
  output state,
  output logic [7:0] BSTct,    // Burst counter
  output logic [7:0] tABARct,
  output logic [7:0] tABAct,   // Automatic Bank Active latency counter
  output logic [7:0] tCLct,    // CAS latency counter
  output logic [7:0] tCWLct,   // CAS write latency counter
  output logic [7:0] tRASct,   // RAS latency counter
  output logic [7:0] tRCDct,   // RCD latency counter
  output logic [15:0] tREFIct, // Refresh Interval
  output logic [7:0] tRFCct,   // Refresh counter
  output logic [7:0] tRPct,    // Precharge counter
  output logic [7:0] tRTPct,   // Reead to Precharge Delay counter
  output logic [7:0] tWRct,    // Write to precharge delay counter
  input logic ACT,
  input logic BST,
  input logic CFG,
  input logic CKEH,
  input logic CKEL,
  input logic DPD,
  input logic DPDX,
  input logic MRR,
  input logic MRW,
  input logic PD,
  input logic PDX,
  input logic PR,
  input logic PRA,
  input logic RD,
  input logic RDA,
  input logic REF,
  input logic SRF,
  input logic [7:0] T_ABAR,
  input logic [7:0] T_ABA,
  input logic [7:0] T_CL,
  input logic [7:0] T_CWL,
  input logic [7:0] T_RAS,
  input logic [7:0] T_RCD,
  input logic [15:0] T_REFI,
  input logic [7:0] T_RFC,
  input logic [7:0] T_RP,
  input logic [7:0] T_RTP,
  input logic [7:0] T_WR,
  input logic WR,
  input logic WRA,
  input logic clk,
  input logic rst
);

  // state bits
  enum logic [4:0] {
    Idle           = 5'b00000, 
    Activating     = 5'b00001, 
    ActivePD       = 5'b00010, 
    BankActive     = 5'b00011, 
    Config         = 5'b00100, 
    DeepPD         = 5'b00101, 
    IdleMRR        = 5'b00110, 
    IdleMRW        = 5'b00111, 
    IdlePD         = 5'b01000, 
    PowerOn        = 5'b01001, 
    Precharging    = 5'b01010, 
    Reading        = 5'b01011, 
    ReadingAPR     = 5'b01100, 
    Refreshing     = 5'b01101, 
    Resetting      = 5'b01110, 
    ResettingMRR   = 5'b01111, 
    ResettingPD    = 5'b10000, 
    SelfRefreshing = 5'b10001, 
    Writing        = 5'b10010, 
    WritingAPR     = 5'b10011, 
    ZRowClone      = 5'b10100
  } state, nextstate;


  // comb always block
  always_comb begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      Idle          : begin
        if (ACT) begin
          nextstate = Activating;
        end
        else if (REF) begin
          nextstate = Refreshing;
        end
        else if (SRF) begin
          nextstate = SelfRefreshing;
        end
        else if (rst) begin
          nextstate = Resetting;
        end
        else if (PD) begin
          nextstate = IdlePD;
        end
        else if (DPD) begin
          nextstate = DeepPD;
        end
        else if (MRW) begin
          nextstate = IdleMRW;
        end
        else if (MRR) begin
          nextstate = IdleMRR;
        end
      end
      Activating    : begin
        if (tRCDct==8'd1) begin
          nextstate = BankActive;
        end
        else if (CKEL) begin
          nextstate = ActivePD;
        end
      end
      ActivePD      : begin
        if (CKEH) begin
          nextstate = BankActive;
        end
        else if (CKEL) begin
          nextstate = ActivePD;
        end
      end
      BankActive    : begin
        if (WR&&(tCWLct==8'd1)) begin
          nextstate = Writing;
        end
        else if (WRA&&(tCWLct==8'd1)) begin
          nextstate = WritingAPR;
        end
        else if (RD&&(tCLct==8'd1)) begin
          nextstate = Reading;
        end
        else if (RDA&&(tCLct==8'd1)) begin
          nextstate = ReadingAPR;
        end
        else if (PR&&(tRASct==0)) begin
          nextstate = Precharging;
        end
        else if (CKEL) begin
          nextstate = ActivePD;
        end
        else if (ACT) begin
          nextstate = ZRowClone;
        end
      end
      Config        : begin
        begin
          nextstate = Resetting;
        end
      end
      DeepPD        : begin
        if (DPDX) begin
          nextstate = PowerOn;
        end
      end
      IdleMRR       : begin
        begin
          nextstate = Idle;
        end
      end
      IdleMRW       : begin
        begin
          nextstate = Idle;
        end
      end
      IdlePD        : begin
        if (PDX) begin
          nextstate = Idle;
        end
      end
      PowerOn       : begin
        if (rst) begin
          nextstate = Resetting;
        end
      end
      Precharging   : begin
        if (tRPct==8'd1) begin
          nextstate = Idle;
        end
      end
      Reading       : begin
        if (RDA) begin
          nextstate = ReadingAPR;
        end
        else if (PR&&(tRTPct==0)&&(tRASct==0)) begin
          nextstate = Precharging;
        end
        else if (WR) begin
          nextstate = Writing;
        end
        else if ((tABARct==0)) begin
          nextstate = BankActive;
        end
        else if (WRA) begin
          nextstate = WritingAPR;
        end
      end
      ReadingAPR    : begin
        if ((BSTct==0)&&(tRTPct==0)&&(tRASct==0)) begin
          nextstate = Precharging;
        end
      end
      Refreshing    : begin
        if (tRFCct==8'd1) begin
          nextstate = Idle;
        end
      end
      Resetting     : begin
        if (MRR) begin
          nextstate = ResettingMRR;
        end
        else if (PD) begin
          nextstate = ResettingPD;
        end
        else if (CFG) begin
          nextstate = Config;
        end
        else begin
          nextstate = Idle;
        end
      end
      ResettingMRR  : begin
        begin
          nextstate = Resetting;
        end
      end
      ResettingPD   : begin
        if (PDX) begin
          nextstate = Resetting;
        end
      end
      SelfRefreshing: begin
        if (CKEH) begin
          nextstate = Idle;
        end
        else if (CKEL) begin
          nextstate = SelfRefreshing;
        end
      end
      Writing       : begin
        if (WRA) begin
          nextstate = WritingAPR;
        end
        else if (PR&&(tWRct==0)&&(tRASct==0)) begin
          nextstate = Precharging;
        end
        else if (RD) begin
          nextstate = Reading;
        end
        else if ((tABAct==0)) begin
          nextstate = BankActive;
        end
        else if (RDA) begin
          nextstate = ReadingAPR;
        end
      end
      WritingAPR    : begin
        if ((BSTct==0)&&(tWRct==0)&&(tRASct==0)) begin
          nextstate = Precharging;
        end
      end
      ZRowClone     : begin
        if (tRCDct==8'd1) begin
          nextstate = BankActive;
        end
        else begin
          nextstate = ZRowClone;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always_ff @(posedge clk) begin
    if (rst)
      state <= Idle;
    else
      state <= nextstate;
  end

  // datapath sequential always block
  always_ff @(posedge clk) begin
    if (rst) begin
      BSTct[7:0] <= BL;
      tABARct[7:0] <= T_ABAR;
      tABAct[7:0] <= T_ABA;
      tCLct[7:0] <= T_CL;
      tCWLct[7:0] <= T_CWL;
      tRASct[7:0] <= T_RAS;
      tRCDct[7:0] <= T_RCD;
      tREFIct[15:0] <= T_REFI;
      tRFCct[7:0] <= T_RFC;
      tRPct[7:0] <= T_RP;
      tRTPct[7:0] <= T_RTP;
      tWRct[7:0] <= T_WR;
    end
    else begin
      BSTct[7:0] <= BL; // default
      tABARct[7:0] <= T_ABAR; // default
      tABAct[7:0] <= T_ABA; // default
      tCLct[7:0] <= T_CL; // default
      tCWLct[7:0] <= T_CWL; // default
      tRASct[7:0] <= T_RAS; // default
      tRCDct[7:0] <= T_RCD; // default
      tREFIct[15:0] <= T_REFI; // default
      tRFCct[7:0] <= T_RFC; // default
      tRPct[7:0] <= T_RP; // default
      tRTPct[7:0] <= T_RTP; // default
      tWRct[7:0] <= T_WR; // default
      case (nextstate)
        Idle          : begin
          tREFIct[15:0] <= (tREFIct>1)?tREFIct-1:tREFIct;
        end
        Activating    : begin
          tRASct[7:0] <= tRASct-1;
          tRCDct[7:0] <= tRCDct-1;
        end
        BankActive    : begin
          tCLct[7:0] <= (tCLct>1)?tCLct-1:tCLct;
          tCWLct[7:0] <= (tCWLct>1)?tCWLct-1:tCWLct;
          tRASct[7:0] <= (tRASct>0)?tRASct-1:tRASct;
          tREFIct[15:0] <= (tREFIct>1)?tREFIct-1:tREFIct;
        end
        Precharging   : begin
          tRPct[7:0] <= tRPct-8'd1;
        end
        Reading       : begin
          BSTct[7:0] <= (BSTct>0)?BSTct-1:BSTct;
          tABARct[7:0] <= (tABARct>0)?tABARct-1:tABARct;
          tCLct[7:0] <= tCLct;
          tCWLct[7:0] <= tCWLct;
          tRASct[7:0] <= (tRASct>0)?tRASct-1:tRASct;
          tRTPct[7:0] <= (tRTPct>0)?tRTPct-1:tRTPct;
        end
        ReadingAPR    : begin
          BSTct[7:0] <= (BSTct>0)?BSTct-1:BSTct;
          tRASct[7:0] <= (tRASct>0)?tRASct-1:tRASct;
          tRTPct[7:0] <= (tRTPct>0)?tRTPct-1:tRTPct;
        end
        Refreshing    : begin
          tRFCct[7:0] <= tRFCct-1;
        end
        Writing       : begin
          BSTct[7:0] <= (BSTct>0)?BSTct-1:BSTct;
          tABAct[7:0] <= (tABAct>0)?tABAct-1:tABAct;
          tCLct[7:0] <= (tCLct>1)?tCLct-1:tCLct;
          tCWLct[7:0] <= tCWLct;
          tRASct[7:0] <= (tRASct>0)?tRASct-1:tRASct;
          tWRct[7:0] <= (tWRct>0)?tWRct-1:tWRct;
        end
        WritingAPR    : begin
          BSTct[7:0] <= (BSTct>0)?BSTct-1:BSTct;
          tCLct[7:0] <= tCLct;
          tRASct[7:0] <= (tRASct>0)?tRASct-1:tRASct;
          tWRct[7:0] <= (tWRct>0)?tWRct-1:tWRct;
        end
        ZRowClone     : begin
          tCLct[7:0] <= tCLct;
          tCWLct[7:0] <= tCWLct;
          tRASct[7:0] <= (tRASct>0)?tRASct-1:tRASct;
          tRCDct[7:0] <= tRCDct-1;
        end
      endcase
    end
  end
endmodule
