`timescale 1ns / 1ps

module sram #(parameter WIDTH = 8, DEPTH = 2048) (
  input logic clk,
  input logic [$clog2(DEPTH)-1:0] addr,
  input logic rd_o_wr,
  input logic [WIDTH-1:0] i_data,
  output logic [WIDTH-1:0] o_data
  );
  
  (* ram_style = "block" *) logic [WIDTH-1:0] memory_array [0:DEPTH-1];
  
  `ifndef SYNTHESIS
  integer i;
  initial
  begin
    for (i=0;i<=DEPTH;i=i+1)
    memory_array[i] = {WIDTH{1'b0}};
  end
  `endif
  
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

// Reference(s)
// https://timetoexplore.net/blog/block-ram-in-verilog-with-vivado