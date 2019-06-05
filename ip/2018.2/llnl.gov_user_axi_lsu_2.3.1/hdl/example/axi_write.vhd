
-- *************************************************************************
--
--  (c) Copyright 2010-2011, 2013 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
-- *************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity axi_write is
    generic(
        MEM_ADDR_WIDTH         : integer range 32 to 64    := 32;
        MEM_DATA_WIDTH         : integer range 32 to 1024  := 64;
        BURST_LENGTH           : integer range 1  to 256   := 16; -- No. of Transfers
        C_NUM_BURST            : integer range 1  to 1024  := 2   -- Total transfers = C_NUM_BURST*BURST_LENGTH

  );
    port (

        clock           : in  std_logic           		:= '0' ;        --
        resetn          : in  std_logic          		:= '1' ;        --
        -----------------------------------------------------------------------                 --
        -- AXI Write Channel                                                                     --
        -----------------------------------------------------------------------                 --
        -- Write Address Channel                                           --
        awaddr           : out std_logic_vector                                      --
                             (MEM_ADDR_WIDTH-1 downto 0);                   --
        awlen            : out std_logic_vector(7 downto 0)      ;                   --
        awsize           : out std_logic_vector(2 downto 0)      ;                   --

        awburst          : out std_logic_vector(1 downto 0)      ;                   --
        awprot           : out std_logic_vector(2 downto 0)      ;                   --
        awcache          : out std_logic_vector(3 downto 0)      ;                   --

        awvalid          : out std_logic                         ;                   --
        awready          : in  std_logic                         := '1';                   --
                                                                                                --
        -- Write Data Channel                                              --
        wdata            : out std_logic_vector                                      --
                             (MEM_DATA_WIDTH-1 downto 0);                   --
        wstrb            : out std_logic_vector                                      --
                             ((MEM_DATA_WIDTH/8)-1 downto 0);               --
        wlast            : out std_logic                         ;                   --

        wvalid           : out std_logic                         ;                   --
        wready           : in  std_logic                         := '1';                   --
                                                                                                --
        -- Write Response Channel                                          --
        bresp            : in  std_logic_vector(1 downto 0)       := (others => '0');                   --
        bvalid           : in  std_logic                         := '0';                   --
        bready           : out std_logic                         ;                   --
                                                                                                --
        -- Stream to Memory Map Steam Interface                                                 --
        done_write_success     : out std_logic                                            --
    );
end entity axi_write;

architecture implementation of axi_write is

  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";



constant total_transfers_count           : integer := C_NUM_BURST * BURST_LENGTH;
constant per_burst_byte_transfers        : integer := MEM_DATA_WIDTH/8 * BURST_LENGTH;		-- no 4K check


signal running_burst_down_count   	         : integer := C_NUM_BURST;
signal running_transfer_down_count   		 : integer := BURST_LENGTH;




signal data_counter : std_logic_vector (7 downto 0):= (others => '0');


signal data_phase_completed      : std_logic := '0';
signal data_phase_completed_d1   : std_logic := '0';
signal data_phase_completed_re_pulse   : std_logic := '0';

signal start_data_phase      : std_logic := '0';
signal start_data_phase_d1   : std_logic := '0';
signal start_data_phase_re_pulse   : std_logic := '0';


signal done_all_addr_write     : std_logic := '0';
signal wvalid_i     : std_logic := '0';
signal awvalid_i     : std_logic := '0';
signal awaddr_i           : std_logic_vector                                      --
                             (MEM_ADDR_WIDTH-1 downto 0):= (others => '0');                   --
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

done_write_success <= done_all_addr_write and data_phase_completed; 

wvalid <= wvalid_i;
awvalid <= awvalid_i;
awaddr <= awaddr_i;
wstrb   <= (others => '1');

bready  <= '1';

awburst <= "01"; 		-- incremental
awcache <= "0011";
awprot  <= "010";


awlen	<= std_logic_vector(TO_UNSIGNED(BURST_LENGTH, 8) - 1);		 





process (clock)
   begin
        if (clock'event and clock = '1') then
           if (resetn = '0') then
		data_phase_completed_d1 <= '0';
	   else
		data_phase_completed_d1 <= data_phase_completed;
	   end if;	
      end if;
   end process;
  
		
data_phase_completed_re_pulse <= data_phase_completed and not data_phase_completed_d1;




process (clock)
   begin
        if (clock'event and clock = '1') then
           if (resetn = '0') then
		start_data_phase_d1 <= '0';
	   else
		start_data_phase_d1 <= start_data_phase;
	   end if;	
      end if;
   end process;
  
		
start_data_phase_re_pulse <= start_data_phase and not start_data_phase_d1;




 process (clock)
   begin
        if (clock'event and clock = '1') then
           if (resetn = '0') then
               awaddr_i 	<= (others => '0');
               awvalid_i 	<= '0';
               running_burst_down_count 	<= C_NUM_BURST;
               start_data_phase <= '0';
               done_all_addr_write <= '0';

           --elsif (running_burst_down_count = 0 ) then     
           elsif (running_burst_down_count = 0 and bvalid = '1') then     
               done_all_addr_write <= '1';

           --elsif (awvalid_i = '0' and running_burst_down_count /= C_NUM_BURST and running_burst_down_count /= 0 and data_phase_completed_re_pulse = '1') then     
           elsif (awvalid_i = '0' and running_burst_down_count /= C_NUM_BURST and running_burst_down_count /= 0 and bvalid = '1') then     
               awaddr_i <= std_logic_vector(unsigned(awaddr_i) + TO_UNSIGNED(per_burst_byte_transfers, MEM_ADDR_WIDTH));		
               awvalid_i <= '1';
               start_data_phase <= '0';
               done_all_addr_write <= '0';


           elsif (awvalid_i = '0' and running_burst_down_count = C_NUM_BURST) then    				-- First burst address 
               awaddr_i 	<= (others => '0');
               awvalid_i <= '1';
               start_data_phase <= '0';
               done_all_addr_write <= '0';



           elsif (awvalid_i = '1' and awready = '1') then
               awvalid_i <= '0';
               running_burst_down_count <= running_burst_down_count - 1;
               start_data_phase <= '1';
               done_all_addr_write <= '0';



           end if;
        end if;
   end process;
  



 process (clock)
   begin
        if (clock'event and clock = '1') then
           if (resetn = '0') then
               wvalid_i 	<= '0';
               running_transfer_down_count 	<= BURST_LENGTH;
               data_counter <= (others => '0');
               data_phase_completed <= '0';
               wlast <= '0';

           elsif (start_data_phase_re_pulse = '1') then     
               wvalid_i <= '1';
               running_transfer_down_count 	<= BURST_LENGTH;
               data_phase_completed <= '0';
               wlast <= '0';

           elsif (wvalid_i = '1' and wready = '1' and running_transfer_down_count = 2) then
               wvalid_i <= '1';
               data_counter   <= std_logic_vector(unsigned(data_counter) + 1);
               running_transfer_down_count 	<= running_transfer_down_count -1;
               data_phase_completed <= '0';
               wlast <= '1';



           elsif (wvalid_i = '1' and wready = '1' and running_transfer_down_count = 1) then
               wvalid_i <= '0';
               data_counter   <= std_logic_vector(unsigned(data_counter) + 1);
               running_transfer_down_count 	<= running_transfer_down_count -1;
               data_phase_completed <= '1';
               wlast <= '0';

           elsif (wvalid_i = '1' and wready = '1' and running_transfer_down_count /= 0) then
               wvalid_i <= '1';
               data_counter   <= std_logic_vector(unsigned(data_counter) + 1);
               running_transfer_down_count 	<= running_transfer_down_count -1;
               data_phase_completed <= '0';
               wlast <= '0';



           end if;
        end if;
   end process;
  

WDATA_32 : if MEM_DATA_WIDTH = 32 generate
 
  begin

wdata  <= data_counter & data_counter & data_counter & data_counter;
awsize <= "010";

  end generate WDATA_32;


WDATA_64 : if MEM_DATA_WIDTH = 64 generate
 
  begin

wdata  <= data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter;
awsize <= "011";

  end generate WDATA_64;


WDATA_128 : if MEM_DATA_WIDTH = 128 generate
 
  begin

wdata  <= data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter 
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter;
awsize <= "100";

  end generate WDATA_128;



WDATA_256 : if MEM_DATA_WIDTH = 256 generate
 
  begin

wdata  <= data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter 
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter;
awsize <= "101";

  end generate WDATA_256;


WDATA_512 : if MEM_DATA_WIDTH = 512 generate
 
  begin

wdata  <= data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter 
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter;
awsize <= "110";

  end generate WDATA_512;


WDATA_1024 : if MEM_DATA_WIDTH = 1024 generate
 
  begin

wdata  <= data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter 
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter
       &  data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter & data_counter;

awsize <= "111";

  end generate WDATA_1024;

end implementation;
