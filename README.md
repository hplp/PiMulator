# PiMulator: FPGA-based Processing-in-Memory Emulation Framework
PiMulator is a modular, parameterizable, FPGA synthesizable soft PiM model suitable for prototyping and rapid evaluation of Processing-in-Memory architectures. The PiM model is implemented in System Verilog and allows users to generate any desired memory configuration on the FPGA fabric with complete control over the structure and distribution of the PiM logic units. Moreover, the model is compatible with the LiteX framework, which provides a high degree of usability and compatibility with the FPGA and RISC-V ecosystem. Thus, the framework enables architects to easily prototype, emulate and evaluate a wide range of emerging PiM architectures and designs.

PiMulator consists of a memory model that emulates *components* such as the shared data bus, row buffer, and subarrays, *behaviors* such as latencies and bank states, and thus *operations* such as burst write/read, refresh, bank interleaving. Accounting for both memory structure and behavior facilitates deployment of the desired PiM logic at any desired location.

We demonstrate strategies to model several pioneering bitwise-PiM architectures and provide detailed benchmark performance results that demonstrate the platform's ability to facilitate design space exploration. We observe an emulation vs. simulation weighted-average speedup of 28x when running a memory benchmark workload.

## SystemVerilog Model
The SystemVerilog model is located in the `SysVerilog_Model` directory. The SystemVerilog files implement the memory components and model their behavior, such as state and timing. The model is synthesizable and can be thought of as a memory soft core. The `testbnch_*` and `wtestbnch_*` files implement test benches and preformatted waveform configurations allowing for easy testing.

## Usage
Please see the [wiki](../../wiki) for detailed instructions and documentation.

At this stage the files can be simulated in Vivado, ModelSim, or Verilator, and synthesized (out of context). The development for integration into a full system is in progress.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Publications
* DATE 2022 paper 23.2.3
    * [Presentation Video](https://youtu.be/rLoetLFsD2w)
    * [Full-text on ResearchGate](https://www.researchgate.net/publication/360226899_PiMulator_a_Fast_and_Flexible_Processing-in-Memory_Emulation_Platform)

## License
Please see the license file
