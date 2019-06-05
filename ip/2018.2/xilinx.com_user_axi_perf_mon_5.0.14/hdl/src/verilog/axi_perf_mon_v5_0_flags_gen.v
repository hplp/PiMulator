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
// Filename   : axi_perf_mon_v5_0_flags_gen.v
// Version    : v5.0
// Description: This module detects the events over AXI interface and generates
//              the flags
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon.v
//       \-- axi_perf_mon_v5_0_flags_gen.v
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
// NLR       03/20/2012      Added external trigger start and stop
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_flags_gen 
#(
   parameter C_FAMILY                 = "nofamily",
   parameter C_MON_FIFO_DATA_WIDTH    = 64,
   parameter C_LOG_WIDTH              = 71,
   parameter C_FLAG_WIDTH             = 7,  //-- 7: for AXI4   2: for AXI4S
   //AXI Slot Interface parameters
   parameter C_AXI_ADDR_WIDTH         = 32,
   parameter C_AXI_DATA_WIDTH         = 32,
   parameter C_AXI_ID_WIDTH           = 1,
   parameter C_AXI_PROTOCOL           = "AXI4",
   parameter C_AXIS_TDATA_WIDTH       = 32,
   parameter C_AXIS_TID_WIDTH         = 1,
   parameter C_AXIS_TDEST_WIDTH       = 1,
   parameter C_AXIS_TUSER_WIDTH       = 1,
   parameter C_SHOW_AXI_IDS           = 1,
   parameter C_SHOW_AXI_LEN           = 1,
   parameter C_SHOW_AXIS_TID          = 1,
   parameter C_SHOW_AXIS_TDEST        = 1,
   parameter C_SHOW_AXIS_TUSER        = 1
)
(
   input                                  clk,
   input                                  rst_n,

   input [C_MON_FIFO_DATA_WIDTH-1:0]      Data_In,
   input                                  Data_Valid,
   input [6:0]                            Flag_Enable_Reg,    
   input                                  Ext_Trig,
   input                                  Ext_Trig_Stop,
   input                                  Use_Ext_Trig_Log,
   output [C_LOG_WIDTH-1:0]               Log_Data,
   output                                 Log_En,
   input [2:0]                            Ext_Data_in,
   input                                  Ext_Data_Valid,
   input [2:0]                            Ext_Event_Flag_En,
   output reg [2:0]                       Ext_Event_Flags
    

);



//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;
localparam LOG_DATA_WIDTH = (C_AXI_PROTOCOL == "AXI4")?  
                            (2*C_AXI_ADDR_WIDTH + 4*C_AXI_ID_WIDTH + 16):
                            (C_AXIS_TID_WIDTH +C_AXIS_TDEST_WIDTH + C_AXIS_TUSER_WIDTH);


//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------

 reg                                Write_going_on;    
 reg                                Read_going_on;    
 reg [LOG_DATA_WIDTH-1:0]           Log_Data_int; 
 reg [C_FLAG_WIDTH-1:0]             Flags;  
 reg                                Ext_Trig_log_en;
 reg [1:0]                          Ext_Triggers_Sync_d1;

 wire [1:0] Ext_Triggers = {Ext_Trig_Stop,Ext_Trig}; 
 wire [1:0] Ext_Triggers_Sync;
 wire Ext_Trig_Sync_Out;
 wire Ext_Trig_Stop_Sync_Out;

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

assign Log_En = Use_Ext_Trig_Log? ((|Flags) && Ext_Trig_log_en): | Flags;  // Bit wise or of flags to generate fifo write enable

   // Synchronizing external trigger
   //-- Double Flop synchronization
    axi_perf_mon_v5_0_cdc_sync
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (0             ),  
       .c_reset_state   (1             ),  
       .c_single_bit    (0             ),  
       .c_vector_width  (2             ),  
       .c_mtbf_stages   (4             )  
     )ext_trig_cdc_sync 
     (
       .prmry_aclk      (1'b0                ),
       .prmry_rst_n     (1'b1                ),
       .prmry_in        (1'b0                ),
       .prmry_vect_in   (Ext_Triggers        ),
       .scndry_aclk     (clk                 ),
       .scndry_rst_n    (rst_n               ),
       .prmry_ack       (                    ),
       .scndry_out      (                    ),
       .scndry_vect_out (Ext_Triggers_Sync   ) 
      );

   always @(posedge clk) begin
      if (rst_n == RST_ACTIVE) begin
          Ext_Triggers_Sync_d1 <= 0;
      end
      else begin
          Ext_Triggers_Sync_d1 <= Ext_Triggers_Sync;
      end
   end
  
   // Positive edge detection for the trigger start and stop 
   assign Ext_Trig_Sync_Out = Ext_Triggers_Sync[0] & ~(Ext_Triggers_Sync_d1[0]); 
   assign Ext_Trig_Stop_Sync_Out = Ext_Triggers_Sync[1] & ~(Ext_Triggers_Sync_d1[1]); 

   always @(posedge clk) begin
      if (rst_n == RST_ACTIVE) begin
          Ext_Trig_log_en <= 0;
      end
      else begin
          if(Use_Ext_Trig_Log == 1'b0 || Ext_Trig_Stop_Sync_Out == 1'b1) begin
            Ext_Trig_log_en <=  1'b0;
          end
          else if(Ext_Trig_Sync_Out == 1'b1) begin
            Ext_Trig_log_en <=  1'b1;
          end
          else begin
            Ext_Trig_log_en <= Ext_Trig_log_en;
          end
      end
   end

 
generate 
if (C_AXI_PROTOCOL == "AXI4") begin : GEN_FLAGS_AXI4
    //-- Decoding individual signals from output of fifo
    wire RREADY                           = Data_In[0];
    wire RVALID                           = Data_In[1];
    wire RLAST                            = Data_In[2];
    wire [1:0] RRESP                      = Data_In[4:3];
    wire [C_AXI_ID_WIDTH-1:0] RID         = Data_In[C_AXI_ID_WIDTH+4:5];

    wire ARREADY                          = Data_In[C_AXI_ID_WIDTH+5];
    wire ARVALID                          = Data_In[C_AXI_ID_WIDTH+6];
    wire [1:0] ARBURST                    = Data_In[C_AXI_ID_WIDTH+8:C_AXI_ID_WIDTH+7];
    wire [2:0] ARSIZE                     = Data_In[C_AXI_ID_WIDTH+11:C_AXI_ID_WIDTH+9];
    wire [7:0] ARLEN                      = Data_In[C_AXI_ID_WIDTH+19:C_AXI_ID_WIDTH+12];
    wire [C_AXI_ADDR_WIDTH-1:0] ARADDR    = Data_In[C_AXI_ADDR_WIDTH+C_AXI_ID_WIDTH+19:C_AXI_ID_WIDTH+20];
    wire [C_AXI_ID_WIDTH-1:0] ARID        = Data_In[(C_AXI_ADDR_WIDTH+(2*C_AXI_ID_WIDTH)+19):(C_AXI_ADDR_WIDTH+C_AXI_ID_WIDTH+20)];

    wire BREADY        = Data_In[(C_AXI_ADDR_WIDTH+(2*C_AXI_ID_WIDTH)+20)];
    wire BVALID        = Data_In[(C_AXI_ADDR_WIDTH+(2*C_AXI_ID_WIDTH)+21)];
    wire [1:0] BRESP   = Data_In[(C_AXI_ADDR_WIDTH+(2*C_AXI_ID_WIDTH)+23):(C_AXI_ADDR_WIDTH+(2*C_AXI_ID_WIDTH)+22)];
    wire [C_AXI_ID_WIDTH-1:0] BID = Data_In[(C_AXI_ADDR_WIDTH+(3*C_AXI_ID_WIDTH)+23):(C_AXI_ADDR_WIDTH+(2*C_AXI_ID_WIDTH)+24)];

    wire WREADY                           = Data_In[(C_AXI_ADDR_WIDTH+(3*C_AXI_ID_WIDTH)+24)];
    wire WVALID                           = Data_In[(C_AXI_ADDR_WIDTH+(3*C_AXI_ID_WIDTH)+25)];
    wire WLAST                            = Data_In[(C_AXI_ADDR_WIDTH+(3*C_AXI_ID_WIDTH)+26)];
    wire [C_AXI_DATA_WIDTH/8 -1 :0] WSTRB = 
    Data_In[(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+26):(C_AXI_ADDR_WIDTH+(3*C_AXI_ID_WIDTH)+27)];

    wire AWREADY                          = Data_In[(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+27)];
    wire AWVALID                          = Data_In[(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+28)];
    wire [1:0] AWBURST = 
    Data_In[(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+30):(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+29)];
    wire [2:0] AWSIZE = 
    Data_In[(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+33):(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+31)];
    wire [7:0] AWLEN  = 
    Data_In[(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+41):(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+34)];
    wire [C_AXI_ADDR_WIDTH-1:0] AWADDR    
    = Data_In[((2*C_AXI_ADDR_WIDTH)+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+41):(C_AXI_ADDR_WIDTH+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+42)];
    wire [C_AXI_ID_WIDTH-1:0] AWID   
    = Data_In[((2*C_AXI_ADDR_WIDTH)+(C_AXI_DATA_WIDTH/8)+(4*C_AXI_ID_WIDTH)+41):((2*C_AXI_ADDR_WIDTH)+(C_AXI_DATA_WIDTH/8)+(3*C_AXI_ID_WIDTH)+42)];

    //-- Flags generation
    wire Wr_Addr_Lat_Flag = AWREADY && AWVALID && Data_Valid;
    wire First_Write_Flag = WVALID && WREADY && (!Write_going_on) && Data_Valid;
    wire Last_Write_Flag  = WLAST && WVALID && WREADY && Data_Valid;
    wire Response_Flag    = BVALID && BREADY && Data_Valid;
    wire Rd_Addr_Lat_Flag = ARREADY && ARVALID && Data_Valid;
    wire First_Read_Flag  = RVALID && RREADY && (!Read_going_on) && Data_Valid;
    wire Last_Read_Flag   = RLAST && RVALID && RREADY && Data_Valid;

    //-- Write_going_on for First_Write_Flag generation
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Write_going_on <= 1'b0;
       end
       else begin
           if (Last_Write_Flag == 1'b1) begin
               Write_going_on <= 1'b0;
           end
           else if (First_Write_Flag == 1'b1)  begin
               Write_going_on <= 1'b1;
           end
           else begin
               Write_going_on <= Write_going_on;
           end
       end
    end 

    //-- Read_going_on for First_Read_Flag generation
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Read_going_on <= 1'b0;
       end
       else begin
           if (Last_Read_Flag == 1'b1) begin
               Read_going_on <= 1'b0;
           end
           else if ((First_Read_Flag == 1'b1))  begin
               Read_going_on <= 1'b1;
           end
           else begin
               Read_going_on <= Read_going_on;
           end
       end
    end 

    //-- Flags
always @(posedge clk) begin
  if (rst_n == RST_ACTIVE) begin
    Flags <= 0;
  end
  else begin
    Flags <= Flag_Enable_Reg & {Last_Read_Flag,First_Read_Flag,Rd_Addr_Lat_Flag,Response_Flag,Last_Write_Flag,First_Write_Flag,Wr_Addr_Lat_Flag};
  end
end 

     
    //-- Data Log
    always @(posedge clk) begin
       if (rst_n == RST_ACTIVE) begin
           Log_Data_int <= 0;
       end
       else begin
           Log_Data_int <= {AWADDR, ARADDR, AWID, BID, ARID, RID, AWLEN, ARLEN};
       end
    end 

end
else if (C_AXI_PROTOCOL == "AXI4S") begin : GEN_FLAGS_AXI4S
  wire [C_AXIS_TUSER_WIDTH-1:0] TUSER     = Data_In[C_AXIS_TUSER_WIDTH-1:0];
  wire [C_AXIS_TDEST_WIDTH-1:0] TDEST     = Data_In[(C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH-1):(C_AXIS_TUSER_WIDTH)];
  wire [C_AXIS_TID_WIDTH-1:0] TID         = 
  Data_In[(C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH-1):(C_AXIS_TUSER_WIDTH+C_AXIS_TDEST_WIDTH)];
  wire  TLAST                             = Data_In[(C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH)];
  wire [(C_AXIS_TDATA_WIDTH/8)-1:0] TKEEP = 
  Data_In[((C_AXIS_TDATA_WIDTH/8)+C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH):(C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH+1)];
  wire [(C_AXIS_TDATA_WIDTH/8)-1:0] TSTRB = 
  Data_In[((2*(C_AXIS_TDATA_WIDTH/8))+C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH):((C_AXIS_TDATA_WIDTH/8)+C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH+1)];
  wire  TREADY   = Data_In[((2*(C_AXIS_TDATA_WIDTH/8))+C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH+1)];
  wire  TVALID   = Data_In[((2*(C_AXIS_TDATA_WIDTH/8))+C_AXIS_TID_WIDTH+C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH+2)];

  //-- Flags generation
  wire First_Write_Flag = TVALID && TREADY && (!Write_going_on) && Data_Valid;
  wire Last_Write_Flag  = TLAST && TVALID && TREADY && Data_Valid;

    //-- Write_going_on for First_Write_Flag generation
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Write_going_on <= 1'b0;
       end
       else begin
           if (Last_Write_Flag == 1'b1) begin
               Write_going_on <= 1'b0;
           end
           else if ((First_Write_Flag == 1'b1))  begin
               Write_going_on <= 1'b1;
           end
           else begin
               Write_going_on <= Write_going_on;
           end
       end
    end 

    //-- Flags
    always @(posedge clk) begin
       if (rst_n == RST_ACTIVE) begin
           Flags <= 0;
       end
       else begin
           Flags <= {(Flag_Enable_Reg[2] && Last_Write_Flag), (Flag_Enable_Reg[1] && First_Write_Flag)} ;
       end
    end 

    //-- Data Log
    always @(posedge clk) begin
       if (rst_n == RST_ACTIVE) begin
           Log_Data_int <= 0;
       end
       else begin
           Log_Data_int <= {TID, TDEST, TUSER};
       end
    end 

end
endgenerate

// Assigning log data out based on the control parameters
// This assignment is to reduce the log data width

generate 

if (C_AXI_PROTOCOL == "AXI4" && C_SHOW_AXI_IDS == 1 && C_SHOW_AXI_LEN == 1) begin : GEN_LOGS_AXI4
   assign Log_Data = {Log_Data_int,Flags};
end
else if(C_AXI_PROTOCOL == "AXI4" && C_SHOW_AXI_IDS == 1 && C_SHOW_AXI_LEN == 0) begin :GEN_SHOW_IDS
   assign Log_Data = {Log_Data_int[(LOG_DATA_WIDTH-1):(LOG_DATA_WIDTH-(2*C_AXI_ADDR_WIDTH))],Log_Data_int[(4*C_AXI_ID_WIDTH+16-1):16],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4" && C_SHOW_AXI_IDS == 0 && C_SHOW_AXI_LEN == 1) begin :GEN_SHOW_LEN
   assign Log_Data = {Log_Data_int[(LOG_DATA_WIDTH-1):(LOG_DATA_WIDTH-(2*C_AXI_ADDR_WIDTH))],Log_Data_int[15:0],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4" && C_SHOW_AXI_IDS == 0 && C_SHOW_AXI_LEN == 0) begin :GEN_NO_LOG_DATA
   assign Log_Data = Flags;
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 1 && C_SHOW_AXIS_TDEST == 1 && C_SHOW_AXIS_TUSER == 1) 
  begin : GEN_LOGS_AXI4S
   assign Log_Data = {Log_Data_int,Flags};
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 1 && C_SHOW_AXIS_TDEST == 1 && C_SHOW_AXIS_TUSER == 0) 
   begin : GEN_SHOW_IDS_DEST 
   assign Log_Data = {Log_Data_int[LOG_DATA_WIDTH-1:C_AXIS_TUSER_WIDTH],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 1 && C_SHOW_AXIS_TDEST == 0 && C_SHOW_AXIS_TUSER == 0)
   begin : GEN_SHOW_TID
   assign Log_Data = {Log_Data_int[LOG_DATA_WIDTH-1:(C_AXIS_TDEST_WIDTH+C_AXIS_TUSER_WIDTH)],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 0 && C_SHOW_AXIS_TDEST == 1 && C_SHOW_AXIS_TUSER == 1) 
   begin : GEN_SHOW_TDEST_TUSER
   assign Log_Data = {Log_Data_int[(LOG_DATA_WIDTH-C_AXIS_TID_WIDTH-1):0],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 0 && C_SHOW_AXIS_TDEST == 1 && C_SHOW_AXIS_TUSER == 0) 
   begin : GEN_SHOW_TDEST
   assign Log_Data = {Log_Data_int[(LOG_DATA_WIDTH-C_AXIS_TID_WIDTH-1):C_AXIS_TUSER_WIDTH],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 0 && C_SHOW_AXIS_TDEST == 0 && C_SHOW_AXIS_TUSER == 1) 
   begin : GEN_SHOW_TUSER
   assign Log_Data = {Log_Data_int[(C_AXIS_TUSER_WIDTH-1):0],Flags};
end
else if(C_AXI_PROTOCOL == "AXI4S" && C_SHOW_AXIS_TID == 0 && C_SHOW_AXIS_TDEST == 0 && C_SHOW_AXIS_TUSER == 0) 
   begin :GEN_SHOW_NO_AXI4S_LOG 
   assign Log_Data = Flags;
end 
else
   begin:GEN_NO_LOGS
   assign Log_Data = 0;
end

endgenerate

 // External event flags generation
 wire Ext_Event_Start_Flag = Ext_Data_in[2] && Ext_Data_Valid; 
 wire Ext_Event_Stop_Flag =  Ext_Data_in[1] && Ext_Data_Valid;
 wire Ext_Event_Flag  =  Ext_Data_in[0] && Ext_Data_Valid;


  // External event flags
always @(posedge clk) begin
 if (rst_n == RST_ACTIVE) begin
    Ext_Event_Flags <= 0;
 end
 else begin
   Ext_Event_Flags <= {(Ext_Event_Flag_En[2] && Ext_Event_Start_Flag),
                       (Ext_Event_Flag_En[1] && Ext_Event_Stop_Flag), (Ext_Event_Flag_En[0] && Ext_Event_Flag)} ;
 end
end 

endmodule





