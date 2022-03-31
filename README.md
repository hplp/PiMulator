# PiMulator: FPGA-based Processing-in-Memory Emulation Framework

This framework enables emulation of existing and emerging memories on FPGA boards and modeling of PiM architectures. A soft core parameterizable and FPGA synthesizable memory prototype is provided. The memory model implements the memory components and accurately models their function and behavior. PiM kernels can be injected throughout the memory hierarchy.

## SystemVerilog Model
The SystemVerilog model is located in the `SysVerilog_Model` directory. The SystemVerilog files implement the memory components and model their behavior, such as state and timing. The model is synthesizable and can be thought of as a memory soft core. The `testbnch_*` and `wtestbnch_*` files implement test benches and preformatted waveform configurations allowing for easy testing.

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

## Usage

At this stage the files can be simulated in Vivado or ModelSim, synthesized (out of context). The development for integration into a full system is in progress.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
Please see the license file