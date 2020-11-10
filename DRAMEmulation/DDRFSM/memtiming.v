// Created by fizzim.pl version 5.20 on 2020:11:10 at 18:00:46 (www.fizzim.com)

module memtiming
       #(parameter T_CL = 17,
         parameter T_RCD = 17,
         parameter T_RP = 17,
         parameter T_RFC = 347
        )
       (
         output reg [4:0] state,
         output reg [7:0] tCLct,
         output reg [7:0] tRCDct,
         output reg [7:0] tRFCct,
         output reg [7:0] tRPct,
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
         input wire rst
       );

// state bits
parameter
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
  ZRowClone      = 5'b10100;

reg [4:0] state;
reg [4:0] nextstate;

// comb always block
always @*
  begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      Idle          :
        begin
          if (ACT)
            begin
              nextstate = Activating;
            end
          else if (REF)
            begin
              nextstate = Refreshing;
            end
          else if (SRF)
            begin
              nextstate = SelfRefreshing;
            end
          else if (rst)
            begin
              nextstate = Resetting;
            end
          else if (PD)
            begin
              nextstate = IdlePD;
            end
          else if (DPD)
            begin
              nextstate = DeepPD;
            end
          else if (MRW)
            begin
              nextstate = IdleMRW;
            end
          else if (MRR)
            begin
              nextstate = IdleMRR;
            end
          else
            begin
              nextstate = Idle;
            end
        end
      Activating    :
        begin
          if (tRCDct==8'd1)
            begin
              nextstate = BankActive;
            end
          else if (CKEL)
            begin
              nextstate = ActivePD;
            end
          else
            begin
              nextstate = Activating;
            end
        end
      ActivePD      :
        begin
          if (CKEH)
            begin
              nextstate = BankActive;
            end
          else if (CKEL)
            begin
              nextstate = ActivePD;
            end
        end
      BankActive    :
        begin
          if (WR&&(tCLct==8'd1))
            begin
              nextstate = Writing;
            end
          else if (WRA&&(tCLct==8'd1))
            begin
              nextstate = WritingAPR;
            end
          else if (RD&&(tCLct==8'd1))
            begin
              nextstate = Reading;
            end
          else if (RDA&&(tCLct==8'd1))
            begin
              nextstate = ReadingAPR;
            end
          else if (PR||PRA)
            begin
              nextstate = Precharging;
            end
          else if (CKEL)
            begin
              nextstate = ActivePD;
            end
          else if (ACT)
            begin
              nextstate = ZRowClone;
            end
          else
            begin
              nextstate = BankActive;
            end
        end
      Config        :
        begin
          begin
            nextstate = Resetting;
          end
        end
      DeepPD        :
        begin
          if (DPDX)
            begin
              nextstate = PowerOn;
            end
        end
      IdleMRR       :
        begin
          begin
            nextstate = Idle;
          end
        end
      IdleMRW       :
        begin
          begin
            nextstate = Idle;
          end
        end
      IdlePD        :
        begin
          if (PDX)
            begin
              nextstate = Idle;
            end
        end
      PowerOn       :
        begin
          if (rst)
            begin
              nextstate = Resetting;
            end
        end
      Precharging   :
        begin
          if (tRPct==8'd1)
            begin
              nextstate = Idle;
            end
        end
      Reading       :
        begin
          if (RDA)
            begin
              nextstate = ReadingAPR;
            end
          else if (PR||PRA)
            begin
              nextstate = Precharging;
            end
          else if (WR)
            begin
              nextstate = Writing;
            end
          else if (BST)
            begin
              nextstate = BankActive;
            end
          else if (RD)
            begin
              nextstate = Reading;
            end
        end
      ReadingAPR    :
        begin
          begin
            nextstate = Precharging;
          end
        end
      Refreshing    :
        begin
          if (tRFCct==8'd1)
            begin
              nextstate = Idle;
            end
          else
            begin
              nextstate = Refreshing;
            end
        end
      Resetting     :
        begin
          if (MRR)
            begin
              nextstate = ResettingMRR;
            end
          else if (PD)
            begin
              nextstate = ResettingPD;
            end
          else if (CFG)
            begin
              nextstate = Config;
            end
          else
            begin
              nextstate = Idle;
            end
        end
      ResettingMRR  :
        begin
          begin
            nextstate = Resetting;
          end
        end
      ResettingPD   :
        begin
          if (PDX)
            begin
              nextstate = Resetting;
            end
        end
      SelfRefreshing:
        begin
          if (CKEH)
            begin
              nextstate = Idle;
            end
          else if (CKEL)
            begin
              nextstate = SelfRefreshing;
            end
        end
      Writing       :
        begin
          if (WRA)
            begin
              nextstate = WritingAPR;
            end
          else if (PR||PRA)
            begin
              nextstate = Precharging;
            end
          else if (RD)
            begin
              nextstate = Reading;
            end
          else if (BST)
            begin
              nextstate = BankActive;
            end
          else if (WR)
            begin
              nextstate = Writing;
            end
        end
      WritingAPR    :
        begin
          begin
            nextstate = Precharging;
          end
        end
      ZRowClone     :
        begin
          if (tRCDct==8'd1)
            begin
              nextstate = BankActive;
            end
          else
            begin
              nextstate = ZRowClone;
            end
        end
    endcase
  end

// Assign reg'd outputs to state bits

// sequential always block
always @(posedge clk)
  begin
    if (rst)
      state <= Idle;
    else
      state <= nextstate;
  end

// datapath sequential always block
always @(posedge clk)
  begin
    if (rst)
      begin
        state[4:0] <= Idle;
        tCLct[7:0] <= T_CL;
        tRCDct[7:0] <= T_RCD;
        tRFCct[7:0] <= T_RFC;
        tRPct[7:0] <= T_RP;
      end
    else
      begin
        state[4:0] <= Idle; // default
        tCLct[7:0] <= T_CL; // default
        tRCDct[7:0] <= T_RCD; // default
        tRFCct[7:0] <= T_RFC; // default
        tRPct[7:0] <= T_RP; // default
        case (nextstate)
          Activating    :
            begin
              tRCDct[7:0] <= tRCDct-1;
            end
          BankActive    :
            begin
              tCLct[7:0] <= (tCLct>1)?tCLct-1:tCLct;
            end
          Precharging   :
            begin
              tRPct[7:0] <= tRPct-8'd1;
            end
          Refreshing    :
            begin
              tRFCct[7:0] <= tRFCct-1;
            end
          ZRowClone     :
            begin
              tRCDct[7:0] <= tRCDct-1;
            end
        endcase
      end
  end

// This code allows you to see state names in simulation
`ifndef SYNTHESIS
reg [111:0] statename;
always @*
  begin
    case (state)
      Idle          :
        statename = "Idle";
      Activating    :
        statename = "Activating";
      ActivePD      :
        statename = "ActivePD";
      BankActive    :
        statename = "BankActive";
      Config        :
        statename = "Config";
      DeepPD        :
        statename = "DeepPD";
      IdleMRR       :
        statename = "IdleMRR";
      IdleMRW       :
        statename = "IdleMRW";
      IdlePD        :
        statename = "IdlePD";
      PowerOn       :
        statename = "PowerOn";
      Precharging   :
        statename = "Precharging";
      Reading       :
        statename = "Reading";
      ReadingAPR    :
        statename = "ReadingAPR";
      Refreshing    :
        statename = "Refreshing";
      Resetting     :
        statename = "Resetting";
      ResettingMRR  :
        statename = "ResettingMRR";
      ResettingPD   :
        statename = "ResettingPD";
      SelfRefreshing:
        statename = "SelfRefreshing";
      Writing       :
        statename = "Writing";
      WritingAPR    :
        statename = "WritingAPR";
      ZRowClone     :
        statename = "ZRowClone";
      default       :
        statename = "XXXXXXXXXXXXXX";
    endcase
  end
`endif

endmodule
