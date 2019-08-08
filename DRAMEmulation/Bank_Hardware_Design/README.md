Project that Interfaces Bank with CPU

I. How to Generate:
   1. Open Vivado (version has to be >=2018.3)
   2. In the Vivado TCL shell, make sure that your current directory is set to the Bank_Hardware_Design directory  
   3. Tools -> Run Tcl Script..  
   4. Choose Bank_Hardware.tcl 

   Alternatively: in Vivado TCL shell, run:   
   source Bank_Hardware.tcl

   5. Project Bank_Hardware is generated with a board design that includes   
      Zynq CPU, AXI, and Bank Hardware Module
   
   Note: Make sure that you have run the .tcl script provided in the DRAMEmulation/Bank_HLS directory, so    
	 that the Bank IP block is generated prior to attempting to build the project.    
	 Also, the generated project is only compatible with the PYNQ FPGA.   
    
II. How to Run Bank Software Tests:                  
    1. Once having the project generated, open Xilinx SDK and create a blank C++ project  
    (IMPORTANT: make sure that the created project is specifically for C++)       
    2. Delete the default main.cc file generated in the src directory        
    3. Add All C++ files from the Bank_Hardware_Design/software_src directory to your Xilinx SDK project src directory      
    4. Now Run the software on the PYNQ board: documentation on how to run/understand the code is provided in the code itself     

