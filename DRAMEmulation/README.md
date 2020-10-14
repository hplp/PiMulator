# DRAM Emulation

## SystemVerilog Model
The SystemVerilog model is located in the *DDRFSM* directory. It includes finite state machines for timing and emulation memory cache, a ddr interface, hierarchy, command decoding and testbenches.

## HLS DRAM Emulation Code: 

### Bank_Hardware_Design:                               
Bank-CPU Vivado Project and also Xilinx SDK Zynq Software Projects. 
Zynq CPU issues commands to Bank Hardware Module. 
Both Bank Hardware Module and Bank Software Module tested with same benchmark.
Timing result are reported. 

### Bank_HLS: 
HLS project for DRAM Bank. 

### Rank_Software: 
Software Project of DRAM Rank, where DRAM Rank is modeled in Software and 
tested in Software. 

### Reading_Information:
Reference Literature and also information on DDR3 / Command Timing
