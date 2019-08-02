//-----------------------------------------------------------------------------
// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and 
//  international copyright and other intellectual property
//  laws.
//  
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//  
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//  
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
// Filename   : axi_perf_mon_v5_0_strm_fifo_wr_logic.v
// Version    : v5.0
// Description: Event log streaming fifo write logic module 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon.v
//      \--axi_perf_mon_v5_0_strm_fifo_wr_logic.v 
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
// NLR       03/20/2013      Updated Time stamp counter load value
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_strm_fifo_wr_logic 
#(
   parameter C_FAMILY                        = "nofamily",
   parameter C_NUM_MONITOR_SLOTS             = 8,
   parameter C_SW_SYNC_DATA_WIDTH            = 32,  //-- Width of SW data register
   parameter C_SLOT_0_LOG_WIDTH              = 64,
   parameter C_SLOT_1_LOG_WIDTH              = 64,
   parameter C_SLOT_2_LOG_WIDTH              = 64,
   parameter C_SLOT_3_LOG_WIDTH              = 64,
   parameter C_SLOT_4_LOG_WIDTH              = 64,
   parameter C_SLOT_5_LOG_WIDTH              = 64,
   parameter C_SLOT_6_LOG_WIDTH              = 64,
   parameter C_SLOT_7_LOG_WIDTH              = 64,
   parameter C_FIFO_AXIS_TDATA_WIDTH         = 258 // AXI Streaming FIFO width

)
(
   input                                    clk,
   input                                    rst_n,

   input                                    Event_Log_En,     //-- synchronized to core clk

   input  [C_SLOT_0_LOG_WIDTH-1:0]          Slot_0_Log,
   input                                    Slot_0_Log_En,
   input  [C_SLOT_1_LOG_WIDTH-1:0]          Slot_1_Log,
   input                                    Slot_1_Log_En,
   input  [C_SLOT_2_LOG_WIDTH-1:0]          Slot_2_Log,
   input                                    Slot_2_Log_En,
   input  [C_SLOT_3_LOG_WIDTH-1:0]          Slot_3_Log,
   input                                    Slot_3_Log_En,
   input  [C_SLOT_4_LOG_WIDTH-1:0]          Slot_4_Log,
   input                                    Slot_4_Log_En,
   input  [C_SLOT_5_LOG_WIDTH-1:0]          Slot_5_Log,
   input                                    Slot_5_Log_En,
   input  [C_SLOT_6_LOG_WIDTH-1:0]          Slot_6_Log,
   input                                    Slot_6_Log_En,
   input  [C_SLOT_7_LOG_WIDTH-1:0]          Slot_7_Log,
   input                                    Slot_7_Log_En,

   input                                    SW_Data_Log_En,    
   input  [C_SW_SYNC_DATA_WIDTH-1:0]        SW_Data,    
   input                                    SW_Data_Wr_En,    //-- synchronized to core clk
   
   input  [2:0]                             Ext_Event0_Flags,
   input  [2:0]                             Ext_Event1_Flags,
   input  [2:0]                             Ext_Event2_Flags,
   input  [2:0]                             Ext_Event3_Flags,
   input  [2:0]                             Ext_Event4_Flags,
   input  [2:0]                             Ext_Event5_Flags,
   input  [2:0]                             Ext_Event6_Flags,
   input  [2:0]                             Ext_Event7_Flags,

   input                                    Fifo_Full,
   input                                    Fifo_Empty,

   output reg                               Fifo_Wr_En,
   output reg [C_FIFO_AXIS_TDATA_WIDTH-1:0] Fifo_Wr_Data
);



//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;
localparam TIME_DIFF_COUNT_WIDTH = 30;
localparam [TIME_DIFF_COUNT_WIDTH-1:0]
  TIME_DIFF_ZERO = 0,
  TIME_DIFF_ONE = 1;

//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
//wire
wire [TIME_DIFF_COUNT_WIDTH-1:0]    Time_Diff;    
wire                                over_flow;    
//FIFO WIDTH-(timestamp + {1-bit loopevent} + {1-bit log id})
wire [C_FIFO_AXIS_TDATA_WIDTH-TIME_DIFF_COUNT_WIDTH-2-1:0] mon_wr_data_int;

//reg
reg                                 Mon_Wr_En;    
reg [C_FIFO_AXIS_TDATA_WIDTH-TIME_DIFF_COUNT_WIDTH-2-1:0]  Mon_Wr_Data;
reg                                 Event_Log_En_D1;    
reg                                 over_flow_cap;   
reg [C_FIFO_AXIS_TDATA_WIDTH-1:0]   Fifo_Reg_Data; 
reg                                 Fifo_Reg_Wr_En;


wire [7:0] Slot_Log_En = {Slot_0_Log_En,Slot_1_Log_En,Slot_2_Log_En,Slot_3_Log_En,Slot_4_Log_En,
                          Slot_5_Log_En,Slot_6_Log_En,Slot_7_Log_En};

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

//--Monitor write data assignment based on number of monitor slots

  generate 
  if(C_NUM_MONITOR_SLOTS == 1) begin:GEN_ONE_LOG
    assign mon_wr_data_int = {Slot_0_Log, Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 2) begin:GEN_TWO_LOG
    assign mon_wr_data_int = {Slot_1_Log, Ext_Event1_Flags, Slot_0_Log, Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 3) begin:GEN_THREE_LOG
    assign mon_wr_data_int = {Slot_2_Log, Ext_Event2_Flags,Slot_1_Log, Ext_Event1_Flags, Slot_0_Log, 
                              Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 4) begin:GEN_FOUR_LOG
    assign mon_wr_data_int = {Slot_3_Log, Ext_Event3_Flags, Slot_2_Log, Ext_Event2_Flags,Slot_1_Log, 
                              Ext_Event1_Flags, Slot_0_Log, Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 5) begin:GEN_FIVE_LOG
    assign mon_wr_data_int = {Slot_4_Log, Ext_Event4_Flags, Slot_3_Log, Ext_Event3_Flags, Slot_2_Log, 
                              Ext_Event2_Flags,Slot_1_Log, Ext_Event1_Flags, Slot_0_Log, Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 6) begin:GEN_SIX_LOG
    assign mon_wr_data_int = {Slot_5_Log, Ext_Event5_Flags, Slot_4_Log, Ext_Event4_Flags, Slot_3_Log, 
                              Ext_Event3_Flags, Slot_2_Log, Ext_Event2_Flags,Slot_1_Log, Ext_Event1_Flags, 
                              Slot_0_Log, Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 7) begin:GEN_SEVEN_LOG
    assign mon_wr_data_int = {Slot_6_Log, Ext_Event6_Flags, Slot_5_Log, Ext_Event5_Flags, Slot_4_Log, 
                              Ext_Event4_Flags, Slot_3_Log, Ext_Event3_Flags, Slot_2_Log, Ext_Event2_Flags,
                              Slot_1_Log, Ext_Event1_Flags, Slot_0_Log, Ext_Event0_Flags};
  end
  else if(C_NUM_MONITOR_SLOTS == 8) begin:GEN_EIGHT_LOG
    assign mon_wr_data_int = {Slot_7_Log, Ext_Event7_Flags, Slot_6_Log, Ext_Event6_Flags, Slot_5_Log, 
                              Ext_Event5_Flags, Slot_4_Log, Ext_Event4_Flags, Slot_3_Log, Ext_Event3_Flags, 
                              Slot_2_Log, Ext_Event2_Flags,Slot_1_Log, Ext_Event1_Flags, Slot_0_Log, 
                              Ext_Event0_Flags};
  end
  endgenerate

//-- Flag generation
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Mon_Wr_En   <= 1'b0;
       Mon_Wr_Data <= 0;
   end
   else begin
       Mon_Wr_En   <=  | (Slot_Log_En | Ext_Event0_Flags | Ext_Event1_Flags | Ext_Event2_Flags | Ext_Event3_Flags | Ext_Event4_Flags | Ext_Event5_Flags | Ext_Event6_Flags | Ext_Event7_Flags);
       Mon_Wr_Data <= mon_wr_data_int;
   end
end 

//--Event Log enable registering 
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Event_Log_En_D1 <= 1'b0;
   end
   else begin
       Event_Log_En_D1 <= Event_Log_En;
   end
end 

//-- Event Log Enable edge detection
wire Event_Log_En_Edge = Event_Log_En && (!Event_Log_En_D1);

wire SW_Data_Log_n_Wr_En = SW_Data_Log_En && SW_Data_Wr_En;

wire Count_Reset = Event_Log_En_Edge || Mon_Wr_En || SW_Data_Log_n_Wr_En;

//-- Time difference Counter Instantiation
axi_perf_mon_v5_0_counter 
  #(
       .C_FAMILY             (C_FAMILY),
       .C_NUM_BITS           (TIME_DIFF_COUNT_WIDTH),
       .COUNTER_LOAD_VALUE   (32'h00000000)
   ) counter_inst 
   (
       .clk                  (clk),
       .rst_n                (rst_n),
       .Load_In              (TIME_DIFF_ONE),
       .Count_Enable         (Event_Log_En),
       .Count_Load           (Count_Reset),
       .Count_Down           (1'b0),
       .Count_Out            (Time_Diff),
       .Carry_Out            (over_flow)
   );

//-- Capturing Overflow
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       over_flow_cap <= 1'b0;
   end
   else begin
       if ((Fifo_Wr_En == 1'b1)) begin
          over_flow_cap <= 1'b0;
       end
       else if ((over_flow == 1'b1)) begin
          over_flow_cap <= 1'b1;
       end
       else begin
          over_flow_cap <= over_flow_cap;
       end
   end
end 

//-- FIFO Write Enable and Write Data generation
//-- This logic sends either software written data register value or
//-- the AXI/external events log.
//-- This logic is written to handle the concurrent software written data register
//-- write and axi/external events occurance
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Fifo_Wr_En     <= 1'b0;    //write enable to FIFO
       Fifo_Wr_Data   <= 0;       //write data to FIFO
       Fifo_Reg_Data  <= 0;       //Registered Monitor slot write data 
       Fifo_Reg_Wr_En <= 1'b0;    //Registered write enable to FIFO
   end
   else begin
       if ((Fifo_Full == 1'b0) && (Event_Log_En == 1'b1)) begin
           if (SW_Data_Log_n_Wr_En == 1'b1) begin          //SW data
               Fifo_Wr_En     <= 1'b1;
               Fifo_Wr_Data   <= { 8'b0, SW_Data, over_flow_cap, Time_Diff, 1'b1};
               if(Mon_Wr_En == 1'b1) begin
                 Fifo_Reg_Data  <= { Mon_Wr_Data, over_flow_cap, TIME_DIFF_ZERO, 1'b0};
                 Fifo_Reg_Wr_En <= 1'b1;
               end
               else begin
                 Fifo_Reg_Data  <= 0;
                 Fifo_Reg_Wr_En <= 1'b0;
               end
           end
           else if (Fifo_Reg_Wr_En == 1'b1) begin           
               Fifo_Wr_Data <= Fifo_Reg_Data;
               Fifo_Wr_En   <= 1'b1; 
               if(Mon_Wr_En == 1'b1) begin
                 Fifo_Reg_Data  <= { Mon_Wr_Data, over_flow_cap, TIME_DIFF_ZERO, 1'b0};
                 Fifo_Reg_Wr_En <= 1'b1;
               end
               else begin
                 Fifo_Reg_Data  <= 0;
                 Fifo_Reg_Wr_En <= 1'b0;
               end
           end
           else if (Mon_Wr_En == 1'b1) begin
               Fifo_Wr_En     <= 1'b1;
               Fifo_Wr_Data   <= { Mon_Wr_Data, over_flow_cap, Time_Diff, 1'b0};
               Fifo_Reg_Data  <= 0;
               Fifo_Reg_Wr_En <= 1'b0;
           end
           else begin
               Fifo_Wr_En     <= 1'b0;
               Fifo_Wr_Data   <= 0;
               Fifo_Reg_Data  <= 0;
               Fifo_Reg_Wr_En <= 1'b0;
           end
       end
       else begin
           Fifo_Wr_En   <= 1'b0;
           Fifo_Wr_Data <= 0;
           Fifo_Reg_Data  <= 0;
           Fifo_Reg_Wr_En <= 1'b0;
       end
   end
end 


endmodule








