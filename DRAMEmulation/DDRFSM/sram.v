`timescale 1ns / 1ps

// https://timetoexplore.net/blog/block-ram-in-verilog-with-vivado
module sram #(parameter WIDTH = 8, DEPTH = 2048) (
         input wire clk,
         input wire [$clog2(DEPTH)-1:0] addr,
         input wire rd_o_wr,
         input wire [WIDTH-1:0] i_data,
         output reg [WIDTH-1:0] o_data
       );

(* ram_style = "block" *) reg [WIDTH-1:0] memory_array [0:DEPTH-1];

always @ (posedge clk)
  begin
    if(rd_o_wr)
      begin
        memory_array[addr] <= i_data;
      end
    else
      begin
        o_data <= memory_array[addr];
      end
  end
endmodule
