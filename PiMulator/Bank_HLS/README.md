How to generate the Vivado HLS Project:

Run *make Bank_HLS* to generate the Bank_HLS IP for the desired *TARGET* and *make clean* to clean.

Or,
1) run *vivado_hls -f Bank_HLS.tcl TARGET* command to generate the HLS project, as well as go over C simulation and C synthesis, where TARGET is your FPGA device
2) to open the project in vivado_hls run *vivado_hls -p Bank_HLS*
