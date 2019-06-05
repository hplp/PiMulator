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
// Filename     : axi_perf_mon_v5_0_metric_counters.v
// Version      : v5.0
// Description  : Metric counter module instantiates the metric selection
//                and accumulator and incrementor modules based on the
//                number of metric counts required 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
//  axi_perf_mon.v
//      \--
//      \-- axi_perf_mon_v5_0_metric_counters.v
//
//-----------------------------------------------------------------------------
// Author:    Kalpanath
// History: 
// Kalpanath 07/25/2012      First Version  
// ~~~~~~
// NLR       10/10/2012      Updated to have eight monitor slots metric selection
// ~~~~~~
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_metric_counters 
#(
   parameter                       C_FAMILY             = "virtex7",
   parameter                       C_NUM_MONITOR_SLOTS  = 8,
   parameter                       C_ENABLE_EVENT_COUNT = 1,  //-- enables/disables perf mon counting logic
   parameter                       C_NUM_OF_COUNTERS    = 10,
   parameter                       C_METRIC_COUNT_WIDTH = 32,  //-- enables/disables perf mon counting logic
   parameter                       C_METRIC_COUNT_SCALE = 1,
   parameter                       COUNTER_LOAD_VALUE   = 32'h00000000  

)
(
   input                            clk,
   input                            rst_n,

    //-- AXI4 metrics
   input [C_NUM_MONITOR_SLOTS-1:0]  Wtrans_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  Rtrans_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Read_Byte_Cnt,
   input [C_NUM_MONITOR_SLOTS-1:0]  Write_Beat_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  Read_Beat_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Latency,
   input [C_NUM_MONITOR_SLOTS-1:0]  Read_Latency_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Write_Latency_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Slv_Wr_Idle_Cnt_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Mst_Rd_Idle_Cnt_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Num_BValids_En,       
   input [C_NUM_MONITOR_SLOTS-1:0]  Num_WLasts_En,             
   input [C_NUM_MONITOR_SLOTS-1:0]  Num_RLasts_En,      

   //-- AXI Streaming metrics
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Transfer_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Packet_Cnt_En,  
   input [C_METRIC_COUNT_WIDTH-1:0] S0_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_S_Null_Byte_Cnt,
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Slv_Idle_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Mst_Idle_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Max_Write_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Max_Write_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Max_Read_Latency,     
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Min_Read_Latency,           
   //-- External Events
   input [C_NUM_MONITOR_SLOTS-1:0]  External_Event_Cnt_En,

   //-- Cnt Enable and Reset
   input                            Metrics_Cnt_En,
   input                            Metrics_Cnt_Reset,

   // Metric Selector Registers - in axi clk domain
   input  [7:0]                     Metric_Sel_0,    
   input  [7:0]                     Metric_Sel_1,    
   input  [7:0]                     Metric_Sel_2,    
   input  [7:0]                     Metric_Sel_3,    
   input  [7:0]                     Metric_Sel_4,    
   input  [7:0]                     Metric_Sel_5,    
   input  [7:0]                     Metric_Sel_6,    
   input  [7:0]                     Metric_Sel_7,    
   input  [7:0]                     Metric_Sel_8,    
   input  [7:0]                     Metric_Sel_9,    

   // Range Registers - in axi clk domain
   input  [31:0]                    Range_Reg_0,    
   input  [31:0]                    Range_Reg_1,    
   input  [31:0]                    Range_Reg_2,    
   input  [31:0]                    Range_Reg_3,    
   input  [31:0]                    Range_Reg_4,    
   input  [31:0]                    Range_Reg_5,    
   input  [31:0]                    Range_Reg_6,    
   input  [31:0]                    Range_Reg_7,    
   input  [31:0]                    Range_Reg_8,    
   input  [31:0]                    Range_Reg_9,    

   // Metric Counters - in core clk domain
   output [31:0]                    Metric_Cnt_0,    
   output [31:0]                    Metric_Cnt_1,    
   output [31:0]                    Metric_Cnt_2,    
   output [31:0]                    Metric_Cnt_3,    
   output [31:0]                    Metric_Cnt_4,    
   output [31:0]                    Metric_Cnt_5,    
   output [31:0]                    Metric_Cnt_6,    
   output [31:0]                    Metric_Cnt_7,    
   output [31:0]                    Metric_Cnt_8,    
   output [31:0]                    Metric_Cnt_9,    

   // Incrementers in core clk domain
   output [31:0]                    Incrementer_0,    
   output [31:0]                    Incrementer_1,    
   output [31:0]                    Incrementer_2,    
   output [31:0]                    Incrementer_3,    
   output [31:0]                    Incrementer_4,    
   output [31:0]                    Incrementer_5,    
   output [31:0]                    Incrementer_6,    
   output [31:0]                    Incrementer_7,    
   output [31:0]                    Incrementer_8,    
   output [31:0]                    Incrementer_9,    

   // OverFlows
   output                           Acc_OF_0,    
   output                           Acc_OF_1,    
   output                           Acc_OF_2,    
   output                           Acc_OF_3,    
   output                           Acc_OF_4,    
   output                           Acc_OF_5,    
   output                           Acc_OF_6,    
   output                           Acc_OF_7,    
   output                           Acc_OF_8,    
   output                           Acc_OF_9,    

   output                           Incr_OF_0,    
   output                           Incr_OF_1,    
   output                           Incr_OF_2,    
   output                           Incr_OF_3,    
   output                           Incr_OF_4,    
   output                           Incr_OF_5,    
   output                           Incr_OF_6,    
   output                           Incr_OF_7,    
   output                           Incr_OF_8,    
   output                           Incr_OF_9    
);


//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------


//-- Mux n Metric Counter_0
axi_perf_mon_v5_0_metric_sel_n_cnt 
  #(
       .C_FAMILY             (C_FAMILY),
       .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
       .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
       .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
       .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
       .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

   ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_0 
   (
       .clk                    (clk),
       .rst_n                  (rst_n),
       .Wtrans_Cnt_En          (Wtrans_Cnt_En),
       .Rtrans_Cnt_En          (Rtrans_Cnt_En),
       .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
       .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
       .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
       .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
       .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
       .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
       .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
       .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
       .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
       .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
       .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
       .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
       .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
       .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
       .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
       .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
       .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
       .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
       .S0_Read_Latency        (S0_Read_Latency),
       .S1_Read_Latency        (S1_Read_Latency),
       .S2_Read_Latency        (S2_Read_Latency),
       .S3_Read_Latency        (S3_Read_Latency),
       .S4_Read_Latency        (S4_Read_Latency),
       .S5_Read_Latency        (S5_Read_Latency),
       .S6_Read_Latency        (S6_Read_Latency),
       .S7_Read_Latency        (S7_Read_Latency),
       .S0_Write_Latency       (S0_Write_Latency),
       .S1_Write_Latency       (S1_Write_Latency),
       .S2_Write_Latency       (S2_Write_Latency),
       .S3_Write_Latency       (S3_Write_Latency),
       .S4_Write_Latency       (S4_Write_Latency),
       .S5_Write_Latency       (S5_Write_Latency),
       .S6_Write_Latency       (S6_Write_Latency),
       .S7_Write_Latency       (S7_Write_Latency),
       .Read_Latency_En        (Read_Latency_En),    
       .Write_Latency_En       (Write_Latency_En),   
       .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
       .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
       .Num_BValids_En         (Num_BValids_En),     
       .Num_WLasts_En          (Num_WLasts_En),      
       .Num_RLasts_En          (Num_RLasts_En),      
       .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
       .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
       .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
       .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
       .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
       .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
       .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
       .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
       .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
       .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
       .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
       .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
       .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
       .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
       .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
       .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
       .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
       .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
       .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
       .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
       .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
       .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
       .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
       .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
       .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
       .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
       .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
       .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
      .S0_Max_Write_Latency     (S0_Max_Write_Latency),         
      .S1_Max_Write_Latency     (S1_Max_Write_Latency),         
      .S2_Max_Write_Latency     (S2_Max_Write_Latency),         
      .S3_Max_Write_Latency     (S3_Max_Write_Latency),         
      .S4_Max_Write_Latency     (S4_Max_Write_Latency),         
      .S5_Max_Write_Latency     (S5_Max_Write_Latency),         
      .S6_Max_Write_Latency     (S6_Max_Write_Latency),         
      .S7_Max_Write_Latency     (S7_Max_Write_Latency),         
      .S0_Min_Write_Latency     (S0_Min_Write_Latency),       
      .S1_Min_Write_Latency     (S1_Min_Write_Latency),       
      .S2_Min_Write_Latency     (S2_Min_Write_Latency),       
      .S3_Min_Write_Latency     (S3_Min_Write_Latency),       
      .S4_Min_Write_Latency     (S4_Min_Write_Latency),       
      .S5_Min_Write_Latency     (S5_Min_Write_Latency),       
      .S6_Min_Write_Latency     (S6_Min_Write_Latency),       
      .S7_Min_Write_Latency     (S7_Min_Write_Latency),       
      .S0_Max_Read_Latency      (S0_Max_Read_Latency),                  
      .S1_Max_Read_Latency      (S1_Max_Read_Latency),                  
      .S2_Max_Read_Latency      (S2_Max_Read_Latency),                  
      .S3_Max_Read_Latency      (S3_Max_Read_Latency),                  
      .S4_Max_Read_Latency      (S4_Max_Read_Latency),                  
      .S5_Max_Read_Latency      (S5_Max_Read_Latency),                  
      .S6_Max_Read_Latency      (S6_Max_Read_Latency),                  
      .S7_Max_Read_Latency      (S7_Max_Read_Latency),                  
      .S0_Min_Read_Latency      (S0_Min_Read_Latency), 
      .S1_Min_Read_Latency      (S1_Min_Read_Latency), 
      .S2_Min_Read_Latency      (S2_Min_Read_Latency), 
      .S3_Min_Read_Latency      (S3_Min_Read_Latency), 
      .S4_Min_Read_Latency      (S4_Min_Read_Latency), 
      .S5_Min_Read_Latency      (S5_Min_Read_Latency), 
      .S6_Min_Read_Latency      (S6_Min_Read_Latency), 
      .S7_Min_Read_Latency      (S7_Min_Read_Latency), 
      .External_Event_Cnt_En    (External_Event_Cnt_En),
      .Metrics_Cnt_En           (Metrics_Cnt_En),
      .Metrics_Cnt_Reset        (Metrics_Cnt_Reset),
      .Metric_Sel               (Metric_Sel_0),
      .Range_Reg                (Range_Reg_0),
      .Metric_Cnt               (Metric_Cnt_0),
      .Incrementer              (Incrementer_0),
      .Acc_OF                   (Acc_OF_0),
      .Incr_OF                  (Incr_OF_0)
   );


//-- Metric Counter_1
generate
if (C_NUM_OF_COUNTERS > 1) begin : GEN_METRIC_CNT_1

    //-- Mux n Metric Counter_1
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_1 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_1),
           .Range_Reg              (Range_Reg_1),
           .Metric_Cnt             (Metric_Cnt_1),
           .Incrementer            (Incrementer_1),
           .Acc_OF                 (Acc_OF_1),
           .Incr_OF                (Incr_OF_1)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_1
    assign Metric_Cnt_1  = 0;
    assign Incrementer_1 = 0;
    assign Acc_OF_1      = 1'b0;
    assign Incr_OF_1     = 1'b0;

end
endgenerate


//-- Metric Counter_2
generate
if (C_NUM_OF_COUNTERS > 2) begin : GEN_METRIC_CNT_2

    //-- Mux n Metric Counter_2
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_2 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_2),
           .Range_Reg              (Range_Reg_2),
           .Metric_Cnt             (Metric_Cnt_2),
           .Incrementer            (Incrementer_2),
           .Acc_OF                 (Acc_OF_2),
           .Incr_OF                (Incr_OF_2)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_2
    assign Metric_Cnt_2  = 0;
    assign Incrementer_2 = 0;
    assign Acc_OF_2      = 1'b0;
    assign Incr_OF_2     = 1'b0;

end
endgenerate




//-- Metric Counter_3
generate
if (C_NUM_OF_COUNTERS > 3) begin : GEN_METRIC_CNT_3

    //-- Mux n Metric Counter_3
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_3 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_3),
           .Range_Reg              (Range_Reg_3),
           .Metric_Cnt             (Metric_Cnt_3),
           .Incrementer            (Incrementer_3),
           .Acc_OF                 (Acc_OF_3),
           .Incr_OF                (Incr_OF_3)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_3
    assign Metric_Cnt_3  = 0;
    assign Incrementer_3 = 0;
    assign Acc_OF_3      = 1'b0;
    assign Incr_OF_3     = 1'b0;

end
endgenerate



//-- Metric Counter_4
generate
if (C_NUM_OF_COUNTERS > 4) begin : GEN_METRIC_CNT_4

    //-- Mux n Metric Counter_4
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_4 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_4),
           .Range_Reg              (Range_Reg_4),
           .Metric_Cnt             (Metric_Cnt_4),
           .Incrementer            (Incrementer_4),
           .Acc_OF                 (Acc_OF_4),
           .Incr_OF                (Incr_OF_4)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_4
    assign Metric_Cnt_4  = 0;
    assign Incrementer_4 = 0;
    assign Acc_OF_4      = 1'b0;
    assign Incr_OF_4     = 1'b0;

end
endgenerate



//-- Metric Counter_5
generate
if (C_NUM_OF_COUNTERS > 5) begin : GEN_METRIC_CNT_5

    //-- Mux n Metric Counter_5
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_5 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_5),
           .Range_Reg              (Range_Reg_5),
           .Metric_Cnt             (Metric_Cnt_5),
           .Incrementer            (Incrementer_5),
           .Acc_OF                 (Acc_OF_5),
           .Incr_OF                (Incr_OF_5)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_5
    assign Metric_Cnt_5  = 0;
    assign Incrementer_5 = 0;
    assign Acc_OF_5      = 1'b0;
    assign Incr_OF_5     = 1'b0;

end
endgenerate




//-- Metric Counter_6
generate
if (C_NUM_OF_COUNTERS > 6) begin : GEN_METRIC_CNT_6

    //-- Mux n Metric Counter_6
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_6 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_6),
           .Range_Reg              (Range_Reg_6),
           .Metric_Cnt             (Metric_Cnt_6),
           .Incrementer            (Incrementer_6),
           .Acc_OF                 (Acc_OF_6),
           .Incr_OF                (Incr_OF_6)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_6
    assign Metric_Cnt_6  = 0;
    assign Incrementer_6 = 0;
    assign Acc_OF_6      = 1'b0;
    assign Incr_OF_6     = 1'b0;

end
endgenerate




//-- Metric Counter_7
generate
if (C_NUM_OF_COUNTERS > 7) begin : GEN_METRIC_CNT_7

    //-- Mux n Metric Counter_7
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_7 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_7),
           .Range_Reg              (Range_Reg_7),
           .Metric_Cnt             (Metric_Cnt_7),
           .Incrementer            (Incrementer_7),
           .Acc_OF                 (Acc_OF_7),
           .Incr_OF                (Incr_OF_7)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_7
    assign Metric_Cnt_7  = 0;
    assign Incrementer_7 = 0;
    assign Acc_OF_7      = 1'b0;
    assign Incr_OF_7     = 1'b0;

end
endgenerate



//-- Metric Counter_8
generate
if (C_NUM_OF_COUNTERS > 8) begin : GEN_METRIC_CNT_8

    //-- Mux n Metric Counter_8
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_8 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_8),
           .Range_Reg              (Range_Reg_8),
           .Metric_Cnt             (Metric_Cnt_8),
           .Incrementer            (Incrementer_8),
           .Acc_OF                 (Acc_OF_8),
           .Incr_OF                (Incr_OF_8)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_8
    assign Metric_Cnt_8  = 0;
    assign Incrementer_8 = 0;
    assign Acc_OF_8      = 1'b0;
    assign Incr_OF_8     = 1'b0;

end
endgenerate




//-- Metric Counter_9
generate
if (C_NUM_OF_COUNTERS > 9) begin : GEN_METRIC_CNT_9

    //-- Mux n Metric Counter_9
    axi_perf_mon_v5_0_metric_sel_n_cnt 
      #(
           .C_FAMILY             (C_FAMILY),
           .C_NUM_MONITOR_SLOTS  (C_NUM_MONITOR_SLOTS), 
           .C_ENABLE_EVENT_COUNT (C_ENABLE_EVENT_COUNT),
           .C_METRIC_COUNT_WIDTH (C_METRIC_COUNT_WIDTH),
           .C_METRIC_COUNT_SCALE (C_METRIC_COUNT_SCALE),
           .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)  

       ) axi_perf_mon_v5_0_metric_sel_n_cnt_inst_9 
       (
           .clk                    (clk),
           .rst_n                  (rst_n),
           .Wtrans_Cnt_En          (Wtrans_Cnt_En),
           .Rtrans_Cnt_En          (Rtrans_Cnt_En),
           .S0_Write_Byte_Cnt      (S0_Write_Byte_Cnt),
           .S1_Write_Byte_Cnt      (S1_Write_Byte_Cnt),
           .S2_Write_Byte_Cnt      (S2_Write_Byte_Cnt),
           .S3_Write_Byte_Cnt      (S3_Write_Byte_Cnt),
           .S4_Write_Byte_Cnt      (S4_Write_Byte_Cnt),
           .S5_Write_Byte_Cnt      (S5_Write_Byte_Cnt),
           .S6_Write_Byte_Cnt      (S6_Write_Byte_Cnt),
           .S7_Write_Byte_Cnt      (S7_Write_Byte_Cnt),
           .S0_Read_Byte_Cnt       (S0_Read_Byte_Cnt),
           .S1_Read_Byte_Cnt       (S1_Read_Byte_Cnt),
           .S2_Read_Byte_Cnt       (S2_Read_Byte_Cnt),
           .S3_Read_Byte_Cnt       (S3_Read_Byte_Cnt),
           .S4_Read_Byte_Cnt       (S4_Read_Byte_Cnt),
           .S5_Read_Byte_Cnt       (S5_Read_Byte_Cnt),
           .S6_Read_Byte_Cnt       (S6_Read_Byte_Cnt),
           .S7_Read_Byte_Cnt       (S7_Read_Byte_Cnt),
           .Write_Beat_Cnt_En      (Write_Beat_Cnt_En),
           .Read_Beat_Cnt_En       (Read_Beat_Cnt_En),
           .S0_Read_Latency        (S0_Read_Latency),
           .S1_Read_Latency        (S1_Read_Latency),
           .S2_Read_Latency        (S2_Read_Latency),
           .S3_Read_Latency        (S3_Read_Latency),
           .S4_Read_Latency        (S4_Read_Latency),
           .S5_Read_Latency        (S5_Read_Latency),
           .S6_Read_Latency        (S6_Read_Latency),
           .S7_Read_Latency        (S7_Read_Latency),
           .S0_Write_Latency       (S0_Write_Latency),
           .S1_Write_Latency       (S1_Write_Latency),
           .S2_Write_Latency       (S2_Write_Latency),
           .S3_Write_Latency       (S3_Write_Latency),
           .S4_Write_Latency       (S4_Write_Latency),
           .S5_Write_Latency       (S5_Write_Latency),
           .S6_Write_Latency       (S6_Write_Latency),
           .S7_Write_Latency       (S7_Write_Latency),
           .Read_Latency_En        (Read_Latency_En),    
           .Write_Latency_En       (Write_Latency_En),   
           .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En), 
           .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En), 
           .Num_BValids_En         (Num_BValids_En),     
           .Num_WLasts_En          (Num_WLasts_En),      
           .Num_RLasts_En          (Num_RLasts_En),      
           .S_Transfer_Cnt_En      (S_Transfer_Cnt_En),
           .S_Packet_Cnt_En        (S_Packet_Cnt_En),  
           .S0_S_Data_Byte_Cnt     (S0_S_Data_Byte_Cnt),
           .S1_S_Data_Byte_Cnt     (S1_S_Data_Byte_Cnt),
           .S2_S_Data_Byte_Cnt     (S2_S_Data_Byte_Cnt),
           .S3_S_Data_Byte_Cnt     (S3_S_Data_Byte_Cnt),
           .S4_S_Data_Byte_Cnt     (S4_S_Data_Byte_Cnt),
           .S5_S_Data_Byte_Cnt     (S5_S_Data_Byte_Cnt),
           .S6_S_Data_Byte_Cnt     (S6_S_Data_Byte_Cnt),
           .S7_S_Data_Byte_Cnt     (S7_S_Data_Byte_Cnt),
           .S0_S_Position_Byte_Cnt (S0_S_Position_Byte_Cnt),
           .S1_S_Position_Byte_Cnt (S1_S_Position_Byte_Cnt),
           .S2_S_Position_Byte_Cnt (S2_S_Position_Byte_Cnt),
           .S3_S_Position_Byte_Cnt (S3_S_Position_Byte_Cnt),
           .S4_S_Position_Byte_Cnt (S4_S_Position_Byte_Cnt),
           .S5_S_Position_Byte_Cnt (S5_S_Position_Byte_Cnt),
           .S6_S_Position_Byte_Cnt (S6_S_Position_Byte_Cnt),
           .S7_S_Position_Byte_Cnt (S7_S_Position_Byte_Cnt),
           .S0_S_Null_Byte_Cnt     (S0_S_Null_Byte_Cnt),
           .S1_S_Null_Byte_Cnt     (S1_S_Null_Byte_Cnt),
           .S2_S_Null_Byte_Cnt     (S2_S_Null_Byte_Cnt),
           .S3_S_Null_Byte_Cnt     (S3_S_Null_Byte_Cnt),
           .S4_S_Null_Byte_Cnt     (S4_S_Null_Byte_Cnt),
           .S5_S_Null_Byte_Cnt     (S5_S_Null_Byte_Cnt),
           .S6_S_Null_Byte_Cnt     (S6_S_Null_Byte_Cnt),
           .S7_S_Null_Byte_Cnt     (S7_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En),
           .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En),
           .S0_Max_Write_Latency   (S0_Max_Write_Latency),         
           .S1_Max_Write_Latency   (S1_Max_Write_Latency),         
           .S2_Max_Write_Latency   (S2_Max_Write_Latency),         
           .S3_Max_Write_Latency   (S3_Max_Write_Latency),         
           .S4_Max_Write_Latency   (S4_Max_Write_Latency),         
           .S5_Max_Write_Latency   (S5_Max_Write_Latency),         
           .S6_Max_Write_Latency   (S6_Max_Write_Latency),         
           .S7_Max_Write_Latency   (S7_Max_Write_Latency),         
           .S0_Min_Write_Latency   (S0_Min_Write_Latency),       
           .S1_Min_Write_Latency   (S1_Min_Write_Latency),       
           .S2_Min_Write_Latency   (S2_Min_Write_Latency),       
           .S3_Min_Write_Latency   (S3_Min_Write_Latency),       
           .S4_Min_Write_Latency   (S4_Min_Write_Latency),       
           .S5_Min_Write_Latency   (S5_Min_Write_Latency),       
           .S6_Min_Write_Latency   (S6_Min_Write_Latency),       
           .S7_Min_Write_Latency   (S7_Min_Write_Latency),       
           .S0_Max_Read_Latency    (S0_Max_Read_Latency),                  
           .S1_Max_Read_Latency    (S1_Max_Read_Latency),                  
           .S2_Max_Read_Latency    (S2_Max_Read_Latency),                  
           .S3_Max_Read_Latency    (S3_Max_Read_Latency),                  
           .S4_Max_Read_Latency    (S4_Max_Read_Latency),                  
           .S5_Max_Read_Latency    (S5_Max_Read_Latency),                  
           .S6_Max_Read_Latency    (S6_Max_Read_Latency),                  
           .S7_Max_Read_Latency    (S7_Max_Read_Latency),                  
           .S0_Min_Read_Latency    (S0_Min_Read_Latency), 
           .S1_Min_Read_Latency    (S1_Min_Read_Latency), 
           .S2_Min_Read_Latency    (S2_Min_Read_Latency), 
           .S3_Min_Read_Latency    (S3_Min_Read_Latency), 
           .S4_Min_Read_Latency    (S4_Min_Read_Latency), 
           .S5_Min_Read_Latency    (S5_Min_Read_Latency), 
           .S6_Min_Read_Latency    (S6_Min_Read_Latency), 
           .S7_Min_Read_Latency    (S7_Min_Read_Latency), 
           .External_Event_Cnt_En  (External_Event_Cnt_En),
           .Metrics_Cnt_En         (Metrics_Cnt_En),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset),
           .Metric_Sel             (Metric_Sel_9),
           .Range_Reg              (Range_Reg_9),
           .Metric_Cnt             (Metric_Cnt_9),
           .Incrementer            (Incrementer_9),
           .Acc_OF                 (Acc_OF_9),
           .Incr_OF                (Incr_OF_9)
       );
    
end    
else begin : GEN_NO_METRIC_CNT_9
    assign Metric_Cnt_9  = 0;
    assign Incrementer_9 = 0;
    assign Acc_OF_9      = 1'b0;
    assign Incr_OF_9     = 1'b0;

end
endgenerate


endmodule       
