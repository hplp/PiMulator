`timescale 1ns / 1ps

// this array module is based on widely used Verilog designs for 2D memory array
// parameter WIDTH sets the word width (how many bits are written/read in 1 clk)
// parameter DEPTH sets the number of words
module array #(parameter WIDTH = 8, DEPTH = 2048) (
  input logic clk, // clock
  input logic [$clog2(DEPTH)-1:0] addr, // which word is read/written
  input logic rd_o_wr, // is the data read or written (0=read, 1=write)
  input logic [WIDTH-1:0] i_data, // data being written
  output logic [WIDTH-1:0] o_data // data being read, wire
  );
  
  (* ram_style = "block" *) logic [WIDTH-1:0] memory_array [0:DEPTH-1];
  // ram_style is an FPGA synthesis directive to map the memory array to BRAM
  // System Verilog style array of DEPTH elements of WIDTH bits logic
  
  `ifndef SYNTHESIS
  // initialize the memory array to values 0 for simulation runs
  integer i;
  initial
  begin
    for (i=0;i<=DEPTH;i=i+1)
    memory_array[i] = {WIDTH{1'b0}};
  end
  `endif
  
  always @ (posedge clk)
  begin
    if(rd_o_wr) // rd_o_wr=1 write i_data to memory_array[addr]
    begin
      memory_array[addr] <= i_data;
    end
    else // rd_o_wr=1 read memory_array[addr] to o_data
    begin
      o_data <= memory_array[addr];
    end
  end
  
endmodule

// Reference(s)
// https://timetoexplore.net/blog/block-ram-in-verilog-with-vivado