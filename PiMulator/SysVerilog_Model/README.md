# Processing in Memory Emulation Model in SystemVerilog

The RTL code in this directory implements a parameterizable model for the DDR family of memories, enabling prototyping of PiM architectures.

## Description

See the `sigasi-doc` directory for sigasi-generated documentation. The SystemVerilog files implement the memory components and model their behavior, such as state and timing. The model is synthesizable and can be thought of as a memory soft core. The `testbnch_*` and `wtestbnch_*` files implement test benches and preformatted waveform configurations allowing for easy testing. PiM kernels can be inserted throughout the memory hierarchy.

### Migen wrapper

See [m-labs/migen](https://github.com/m-labs/migen) for how to use and install Migen. The Python script `WrappedDIMM.py` reads a memory specification from a configuration file and generates the SystemVerilog wrapper `WrappedDIMM.sv`.

### FizZim

See [FizZim](https://fizzim.com/) for how to use FizZim to generate elegant, complex and efficient Finite State Machines (FSM). The `*.fzm` files implement state machine modules utilized in the memory model. To generate the SystemVerilog code run:

`fizzimperl -language SystemVerilog memtiming.fzm > memtiming.sv`

## Usage

At this stage the files can be simulated in Vivado or ModelSim, synthesized (out of context). The development for integration into a full system is in progress.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.