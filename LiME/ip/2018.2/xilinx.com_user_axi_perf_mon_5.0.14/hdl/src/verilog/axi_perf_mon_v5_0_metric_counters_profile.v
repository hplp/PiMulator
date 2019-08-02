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
// Filename     : axi_perf_mon_v5_0_metric_counters_profile.v
// Version      : v5.0
// Description  : Metric counter module instantiates the accumulators
//                and calculates the metric counts
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
//  axi_perf_mon.v
//      \--
//      \-- axi_perf_mon_v5_0_metric_counters_profile.v
//
//-----------------------------------------------------------------------------
// Author:    NLR 
// History: 
// NLR 02/10/2013      First Version  
// ~~~~~~
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_metric_counters_profile 
#(
   parameter                       C_FAMILY                   = "virtex7",
   parameter                       C_NUM_MONITOR_SLOTS        = 8,
   parameter                       C_NUM_OF_COUNTERS          = 10,
   parameter                       C_METRIC_COUNT_WIDTH       = 32,
   parameter                       C_HAVE_SAMPLED_METRIC_CNT  = 1
)
(
   input                            clk,
   input                            rst_n,
   input                            Sample_rst_n,

   input                            Sample_En,
   input [7:0]                      Lat_Addr_11downto4,
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

   //-- Cnt Enable and Reset
   input                            Metrics_Cnt_En,
   input                            Metrics_Cnt_Reset,

   // Metric Counters - in core clk domain
   output reg [31:0]                Metric_Ram_Data_In    
);


//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;

//-------------------------------------------------------------------
// Signal Declarations
//------------------------------------------------------------------
 wire [C_METRIC_COUNT_WIDTH-1:0] accum_in [C_NUM_OF_COUNTERS-1:0];
 wire [C_NUM_OF_COUNTERS-1:0]    accum_in_valid;
 wire [C_METRIC_COUNT_WIDTH-1:0] Metric_Cnt [47:0];
 wire [C_METRIC_COUNT_WIDTH-1:0] Sample_Metric_Cnt [47:0];

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

   assign accum_in[0] = S0_Write_Byte_Cnt;
   assign accum_in[1] = 1'b1;
   assign accum_in[2] = S0_Write_Latency;
   assign accum_in[3] = S0_Read_Byte_Cnt;
   assign accum_in[4] = 1'b1;
   assign accum_in[5] = S0_Read_Latency;
   assign accum_in_valid[0] = Write_Beat_Cnt_En[0];
   assign accum_in_valid[1] = Wtrans_Cnt_En[0];
   assign accum_in_valid[2] = Write_Latency_En[0];
   assign accum_in_valid[3] = Read_Beat_Cnt_En[0];
   assign accum_in_valid[4] = Rtrans_Cnt_En[0];
   assign accum_in_valid[5] = Read_Latency_En[0];

generate if(C_NUM_OF_COUNTERS > 6) begin
   assign accum_in[6] = S1_Write_Byte_Cnt;
   assign accum_in[7] = 1'b1;
   assign accum_in[8] = S1_Write_Latency;
   assign accum_in[9] = S1_Read_Byte_Cnt;
   assign accum_in[10] = 1'b1;
   assign accum_in[11] = S1_Read_Latency;

   assign accum_in_valid[6] = Write_Beat_Cnt_En[1];
   assign accum_in_valid[7] = Wtrans_Cnt_En[1];
   assign accum_in_valid[8] = Write_Latency_En[1];
   assign accum_in_valid[9] = Read_Beat_Cnt_En[1];
   assign accum_in_valid[10] = Rtrans_Cnt_En[1];
   assign accum_in_valid[11] = Read_Latency_En[1];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 12) begin
   assign accum_in[12] = S2_Write_Byte_Cnt;
   assign accum_in[13] = 1'b1;
   assign accum_in[14] = S2_Write_Latency;
   assign accum_in[15] = S2_Read_Byte_Cnt;
   assign accum_in[16] = 1'b1;
   assign accum_in[17] = S2_Read_Latency;

   assign accum_in_valid[12] = Write_Beat_Cnt_En[2];
   assign accum_in_valid[13] = Wtrans_Cnt_En[2];
   assign accum_in_valid[14] = Write_Latency_En[2];
   assign accum_in_valid[15] = Read_Beat_Cnt_En[2];
   assign accum_in_valid[16] = Rtrans_Cnt_En[2];
   assign accum_in_valid[17] = Read_Latency_En[2];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 18) begin
  assign accum_in[18] = S3_Write_Byte_Cnt;
  assign accum_in[19] = 1'b1;
  assign accum_in[20] = S3_Write_Latency;
  assign accum_in[21] = S3_Read_Byte_Cnt;
  assign accum_in[22] = 1'b1;
  assign accum_in[23] = S3_Read_Latency;

  assign accum_in_valid[18] = Write_Beat_Cnt_En[3];
  assign accum_in_valid[19] = Wtrans_Cnt_En[3];
  assign accum_in_valid[20] = Write_Latency_En[3];
  assign accum_in_valid[21] = Read_Beat_Cnt_En[3];
  assign accum_in_valid[22] = Rtrans_Cnt_En[3];
  assign accum_in_valid[23] = Read_Latency_En[3];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 24) begin
  assign accum_in[24] = S4_Write_Byte_Cnt;
  assign accum_in[25] = 1'b1;
  assign accum_in[26] = S4_Write_Latency;
  assign accum_in[27] = S4_Read_Byte_Cnt;
  assign accum_in[28] = 1'b1;
  assign accum_in[29] = S4_Read_Latency;

  assign accum_in_valid[24] = Write_Beat_Cnt_En[4];
  assign accum_in_valid[25] = Wtrans_Cnt_En[4];
  assign accum_in_valid[26] = Write_Latency_En[4];
  assign accum_in_valid[27] = Read_Beat_Cnt_En[4];
  assign accum_in_valid[28] = Rtrans_Cnt_En[4];
  assign accum_in_valid[29] = Read_Latency_En[4];

end
endgenerate

generate if(C_NUM_OF_COUNTERS > 30) begin
  assign accum_in[30] = S5_Write_Byte_Cnt;
  assign accum_in[31] = 1'b1;
  assign accum_in[32] = S5_Write_Latency;
  assign accum_in[33] = S5_Read_Byte_Cnt;
  assign accum_in[34] = 1'b1;
  assign accum_in[35] = S5_Read_Latency;

  assign accum_in_valid[30] = Write_Beat_Cnt_En[5];
  assign accum_in_valid[31] = Wtrans_Cnt_En[5];
  assign accum_in_valid[32] = Write_Latency_En[5];
  assign accum_in_valid[33] = Read_Beat_Cnt_En[5];
  assign accum_in_valid[34] = Rtrans_Cnt_En[5];
  assign accum_in_valid[35] = Read_Latency_En[5];

end
endgenerate

generate if(C_NUM_OF_COUNTERS > 36) begin
  assign accum_in[36] = S6_Write_Byte_Cnt;
  assign accum_in[37] = 1'b1;
  assign accum_in[38] = S6_Write_Latency;
  assign accum_in[39] = S6_Read_Byte_Cnt;
  assign accum_in[40] = 1'b1;
  assign accum_in[41] = S6_Read_Latency;

  assign accum_in_valid[36] = Write_Beat_Cnt_En[6];
  assign accum_in_valid[37] = Wtrans_Cnt_En[6];
  assign accum_in_valid[38] = Write_Latency_En[6];
  assign accum_in_valid[39] = Read_Beat_Cnt_En[6];
  assign accum_in_valid[40] = Rtrans_Cnt_En[6];
  assign accum_in_valid[41] = Read_Latency_En[6];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 42) begin
  assign accum_in[42] = S7_Write_Byte_Cnt;
  assign accum_in[43] = 1'b1;
  assign accum_in[44] = S7_Write_Latency;
  assign accum_in[45] = S7_Read_Byte_Cnt;
  assign accum_in[46] = 1'b1;
  assign accum_in[47] = S7_Read_Latency;

  assign accum_in_valid[42] = Write_Beat_Cnt_En[7];
  assign accum_in_valid[43] = Wtrans_Cnt_En[7];
  assign accum_in_valid[44] = Write_Latency_En[7];
  assign accum_in_valid[45] = Read_Beat_Cnt_En[7];
  assign accum_in_valid[46] = Rtrans_Cnt_En[7];
  assign accum_in_valid[47] = Read_Latency_En[7];

end
endgenerate

//-- Metric Counter
genvar i;
generate
for (i=0; i<C_NUM_OF_COUNTERS; i=i+1) begin : GEN_acc

   axi_perf_mon_v5_0_acc_sample_profile 
   #(
     .C_FAMILY                      (C_FAMILY            ),
     .DWIDTH                        (C_METRIC_COUNT_WIDTH),
     .C_HAVE_SAMPLED_METRIC_CNT     (C_HAVE_SAMPLED_METRIC_CNT)
   ) acc_inst_0
   (
      .clk                (clk                        ),
      .rst_n              (rst_n                      ),
      .Sample_rst_n       (Sample_rst_n               ),
      .Enable             (Metrics_Cnt_En             ),   
      .Reset              (Metrics_Cnt_Reset          ) ,   
      .Add_in             (accum_in[i]                ),  
      .Add_in_Valid       (accum_in_valid[i]          ), 
      .Sample_En          (Sample_En                  ), 
      .Accumulate         (1'b1                       ), 
      .Accumulator        (Metric_Cnt[i]              ),
      .Sample_Accumulator (Sample_Metric_Cnt[i]       )
   );
end
endgenerate  

genvar j;
generate for (j=C_NUM_OF_COUNTERS; j<48; j = j+1) begin :GEN_No_acc
  assign Metric_Cnt[j] = 0;
  assign Sample_Metric_Cnt[j] = 0;
end
endgenerate

always @(*) begin 
      case (Lat_Addr_11downto4)
        8'h10: Metric_Ram_Data_In<= Metric_Cnt[0];   
        8'h11: Metric_Ram_Data_In<= Metric_Cnt[1]; 
        8'h12: Metric_Ram_Data_In<= Metric_Cnt[2]; 
        8'h13: Metric_Ram_Data_In<= Metric_Cnt[3]; 
        8'h14: Metric_Ram_Data_In<= Metric_Cnt[4]; 
        8'h15: Metric_Ram_Data_In<= Metric_Cnt[5]; 
        8'h16: Metric_Ram_Data_In<= Metric_Cnt[6]; 
        8'h17: Metric_Ram_Data_In<= Metric_Cnt[7]; 
        8'h18: Metric_Ram_Data_In<= Metric_Cnt[8]; 
        8'h19: Metric_Ram_Data_In<= Metric_Cnt[9]; 
        8'h1A: Metric_Ram_Data_In<= Metric_Cnt[10];
        8'h1B: Metric_Ram_Data_In<= Metric_Cnt[11];
        8'h20: Metric_Ram_Data_In<= Sample_Metric_Cnt[0];   
        8'h21: Metric_Ram_Data_In<= Sample_Metric_Cnt[1]; 
        8'h22: Metric_Ram_Data_In<= Sample_Metric_Cnt[2]; 
        8'h23: Metric_Ram_Data_In<= Sample_Metric_Cnt[3]; 
        8'h24: Metric_Ram_Data_In<= Sample_Metric_Cnt[4]; 
        8'h25: Metric_Ram_Data_In<= Sample_Metric_Cnt[5]; 
        8'h26: Metric_Ram_Data_In<= Sample_Metric_Cnt[6]; 
        8'h27: Metric_Ram_Data_In<= Sample_Metric_Cnt[7]; 
        8'h28: Metric_Ram_Data_In<= Sample_Metric_Cnt[8]; 
        8'h29: Metric_Ram_Data_In<= Sample_Metric_Cnt[9]; 
        8'h2A: Metric_Ram_Data_In<= Sample_Metric_Cnt[10];
        8'h2B: Metric_Ram_Data_In<= Sample_Metric_Cnt[11];
        8'h50: Metric_Ram_Data_In<= Metric_Cnt[12];   
        8'h51: Metric_Ram_Data_In<= Metric_Cnt[13]; 
        8'h52: Metric_Ram_Data_In<= Metric_Cnt[14]; 
        8'h53: Metric_Ram_Data_In<= Metric_Cnt[15]; 
        8'h54: Metric_Ram_Data_In<= Metric_Cnt[16]; 
        8'h55: Metric_Ram_Data_In<= Metric_Cnt[17]; 
        8'h56: Metric_Ram_Data_In<= Metric_Cnt[18]; 
        8'h57: Metric_Ram_Data_In<= Metric_Cnt[19]; 
        8'h58: Metric_Ram_Data_In<= Metric_Cnt[20]; 
        8'h59: Metric_Ram_Data_In<= Metric_Cnt[21]; 
        8'h5A: Metric_Ram_Data_In<= Metric_Cnt[22];
        8'h5B: Metric_Ram_Data_In<= Metric_Cnt[23];
        8'h60: Metric_Ram_Data_In<= Sample_Metric_Cnt[12];   
        8'h61: Metric_Ram_Data_In<= Sample_Metric_Cnt[13]; 
        8'h62: Metric_Ram_Data_In<= Sample_Metric_Cnt[14]; 
        8'h63: Metric_Ram_Data_In<= Sample_Metric_Cnt[15]; 
        8'h64: Metric_Ram_Data_In<= Sample_Metric_Cnt[16]; 
        8'h65: Metric_Ram_Data_In<= Sample_Metric_Cnt[17]; 
        8'h66: Metric_Ram_Data_In<= Sample_Metric_Cnt[18]; 
        8'h67: Metric_Ram_Data_In<= Sample_Metric_Cnt[19]; 
        8'h68: Metric_Ram_Data_In<= Sample_Metric_Cnt[20]; 
        8'h69: Metric_Ram_Data_In<= Sample_Metric_Cnt[21]; 
        8'h6A: Metric_Ram_Data_In<= Sample_Metric_Cnt[22];
        8'h6B: Metric_Ram_Data_In<= Sample_Metric_Cnt[23];
        8'h70: Metric_Ram_Data_In<= Metric_Cnt[24];   
        8'h71: Metric_Ram_Data_In<= Metric_Cnt[25]; 
        8'h72: Metric_Ram_Data_In<= Metric_Cnt[26]; 
        8'h73: Metric_Ram_Data_In<= Metric_Cnt[27]; 
        8'h74: Metric_Ram_Data_In<= Metric_Cnt[28]; 
        8'h75: Metric_Ram_Data_In<= Metric_Cnt[29]; 
        8'h76: Metric_Ram_Data_In<= Metric_Cnt[30]; 
        8'h77: Metric_Ram_Data_In<= Metric_Cnt[31]; 
        8'h78: Metric_Ram_Data_In<= Metric_Cnt[32]; 
        8'h79: Metric_Ram_Data_In<= Metric_Cnt[33]; 
        8'h7A: Metric_Ram_Data_In<= Metric_Cnt[34];
        8'h7B: Metric_Ram_Data_In<= Metric_Cnt[35];
        8'h80: Metric_Ram_Data_In<= Sample_Metric_Cnt[24];   
        8'h81: Metric_Ram_Data_In<= Sample_Metric_Cnt[25]; 
        8'h82: Metric_Ram_Data_In<= Sample_Metric_Cnt[26]; 
        8'h83: Metric_Ram_Data_In<= Sample_Metric_Cnt[27]; 
        8'h84: Metric_Ram_Data_In<= Sample_Metric_Cnt[28]; 
        8'h85: Metric_Ram_Data_In<= Sample_Metric_Cnt[29]; 
        8'h86: Metric_Ram_Data_In<= Sample_Metric_Cnt[30]; 
        8'h87: Metric_Ram_Data_In<= Sample_Metric_Cnt[31]; 
        8'h88: Metric_Ram_Data_In<= Sample_Metric_Cnt[32]; 
        8'h89: Metric_Ram_Data_In<= Sample_Metric_Cnt[33]; 
        8'h8A: Metric_Ram_Data_In<= Sample_Metric_Cnt[34];
        8'h8B: Metric_Ram_Data_In<= Sample_Metric_Cnt[35];
        8'h90: Metric_Ram_Data_In<= Metric_Cnt[36];   
        8'h91: Metric_Ram_Data_In<= Metric_Cnt[37]; 
        8'h92: Metric_Ram_Data_In<= Metric_Cnt[38]; 
        8'h93: Metric_Ram_Data_In<= Metric_Cnt[39]; 
        8'h94: Metric_Ram_Data_In<= Metric_Cnt[40]; 
        8'h95: Metric_Ram_Data_In<= Metric_Cnt[41]; 
        8'h96: Metric_Ram_Data_In<= Metric_Cnt[42]; 
        8'h97: Metric_Ram_Data_In<= Metric_Cnt[43]; 
        8'h98: Metric_Ram_Data_In<= Metric_Cnt[44]; 
        8'h99: Metric_Ram_Data_In<= Metric_Cnt[45]; 
        8'h9A: Metric_Ram_Data_In<= Metric_Cnt[46];
        8'h9B: Metric_Ram_Data_In<= Metric_Cnt[47];
        8'hA0: Metric_Ram_Data_In<= Sample_Metric_Cnt[36];   
        8'hA1: Metric_Ram_Data_In<= Sample_Metric_Cnt[37]; 
        8'hA2: Metric_Ram_Data_In<= Sample_Metric_Cnt[38]; 
        8'hA3: Metric_Ram_Data_In<= Sample_Metric_Cnt[39]; 
        8'hA4: Metric_Ram_Data_In<= Sample_Metric_Cnt[40]; 
        8'hA5: Metric_Ram_Data_In<= Sample_Metric_Cnt[41]; 
        8'hA6: Metric_Ram_Data_In<= Sample_Metric_Cnt[42]; 
        8'hA7: Metric_Ram_Data_In<= Sample_Metric_Cnt[43]; 
        8'hA8: Metric_Ram_Data_In<= Sample_Metric_Cnt[44]; 
        8'hA9: Metric_Ram_Data_In<= Sample_Metric_Cnt[45]; 
        8'hAA: Metric_Ram_Data_In<= Sample_Metric_Cnt[46];
        8'hAB: Metric_Ram_Data_In<= Sample_Metric_Cnt[47];
        default:Metric_Ram_Data_In <= 0; 
      endcase
end 

endmodule       
