SOFTWARE Visual Studio code for DRAM Rank

The following code base models a DRAM Rank, which interfaces with DRAM Banks and   
can also receive commands for different DRAM Transactions

It is both (i) Timing Accurate and (ii) Hardware Accurate (on the bank level)

The main function performs a DRAM Rank Test: Writing all Rank locations and reading all Rank locations, checking whether the read 
data is correct. Simulation timing results are also reported. 
