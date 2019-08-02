----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2014 02:30:00 PM
-- Design Name: 
-- Module Name: axi_lsu_tb - behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library axi_bram_ctrl_v4_0;
use axi_bram_ctrl_v4_0.axi_bram_ctrl;

library axi_lsu_lib;
use axi_lsu_lib.axi_lsu;

entity axi_lsu_tb is
end axi_lsu_tb;

architecture behavioral of axi_lsu_tb is

	constant period : time := 10 ns;
	constant offset : time := 10 ns;
	constant duty_cycle : real := 0.5;
	constant hold : time := 0.5 ns;

	signal clock : std_logic;
	signal reset : std_logic;

	signal count : integer;

	procedure wait_sig (
		signal clock : in std_logic;
		signal sig : in std_logic;
		constant val : in std_logic
	) is
	begin
		wait until (rising_edge(clock) and sig = val);
		wait for hold;
	end wait_sig;

	procedure wait_cycles (
		signal clock : in std_logic;
		constant cycles : in integer
	) is
	begin
		for i in 1 to cycles loop
			wait until (rising_edge(clock));
		end loop;
		wait for hold;
	end wait_cycles;

	-- return the log base 2 of the argument x rounded to plus infinity
	function log2rp (x : natural) return natural is
		variable i : natural;
	begin
		i := 0;
		while (x > 2**i) loop
			i := i + 1;
		end loop;
		return i;
	end log2rp;

-- #################### --

constant C_CTL_IS_ASYNC      : integer range 0 to 1 := 0;
constant C_CTL_FIFO_DEPTH    : integer range 1 to 16 := 4;
constant C_MAX_BURST_LEN     : integer range 2 to 256 := 16;
constant C_BTT_USED          : integer range 8 to 23 := 23;
constant C_R_ADDR_PIPE_DEPTH : integer range 1 to 30 := 4;
constant C_R_INCLUDE_SF      : integer range 0 to 1 := 1;
constant C_W_ADDR_PIPE_DEPTH : integer range 1 to 30 := 4;
constant C_W_INCLUDE_SF      : integer range 0 to 1 := 0;
constant C_FAMILY            : string := "zynq";

	-- Stream Control
constant C_AXIS_CTL_TDATA_WIDTH : integer range 8 to 1024 := 32;
constant C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
constant C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
constant C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	-- Stream Data
constant C_AXIS_DAT_TDATA_WIDTH : integer range 8 to 1024 := 64;
constant C_AXIS_DAT_TID_WIDTH   : integer range 2 to 8 := 4;
constant C_AXIS_DAT_TDEST_WIDTH : integer range 2 to 8 := 4;

	-- Memory Mapped
constant C_AXI_MAP_ID_WIDTH   : integer range  1 to 8 := 1;
constant C_AXI_MAP_ADDR_WIDTH : integer range 32 to 64 := 40;
constant C_AXI_MAP_DATA_WIDTH : integer range 32 to 1024 := 64;

	-- associated with control streams
alias  ctl_aclk    : std_logic is clock;
signal ctl_aresetn : std_logic;

	-- associated with data streams and master AXI
alias  data_aclk    : std_logic is clock;
signal data_aresetn : std_logic;

	------------------
	-- Control Port --
	------------------

	-- Stream Control In
signal s_axis_ctl_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal s_axis_ctl_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal s_axis_ctl_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal s_axis_ctl_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal s_axis_ctl_tlast  : std_logic;
signal s_axis_ctl_tvalid : std_logic;
signal s_axis_ctl_tready : std_logic;

	-- Stream Control Out
signal m_axis_ctl_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal m_axis_ctl_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal m_axis_ctl_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal m_axis_ctl_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal m_axis_ctl_tlast  : std_logic;
signal m_axis_ctl_tvalid : std_logic;
signal m_axis_ctl_tready : std_logic;

	---------------
	-- Data Port --
	---------------

	-- Stream Data In
signal s_axis_dat_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
signal s_axis_dat_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
signal s_axis_dat_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
signal s_axis_dat_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
signal s_axis_dat_tlast  : std_logic;
signal s_axis_dat_tvalid : std_logic;
signal s_axis_dat_tready : std_logic;

	-- Stream Data Out
signal m_axis_dat_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
signal m_axis_dat_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
signal m_axis_dat_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
signal m_axis_dat_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
signal m_axis_dat_tlast  : std_logic;
signal m_axis_dat_tvalid : std_logic;
signal m_axis_dat_tready : std_logic;

	--------------------------
	-- Memory Map Interface --
	--------------------------

	-- AXI4 Write Address Channel
signal m_axi_awid    : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal m_axi_awaddr  : std_logic_vector(C_AXI_MAP_ADDR_WIDTH-1 downto 0);
signal m_axi_awlen   : std_logic_vector(7 downto 0);
signal m_axi_awsize  : std_logic_vector(2 downto 0);
signal m_axi_awburst : std_logic_vector(1 downto 0);
signal m_axi_awcache : std_logic_vector(3 downto 0);
signal m_axi_awprot  : std_logic_vector(2 downto 0);
signal m_axi_awvalid : std_logic;
signal m_axi_awready : std_logic;

	-- AXI4 Write Data Channel
signal m_axi_wdata   : std_logic_vector(C_AXI_MAP_DATA_WIDTH-1 downto 0);
signal m_axi_wstrb   : std_logic_vector((C_AXI_MAP_DATA_WIDTH/8)-1 downto 0);
signal m_axi_wlast   : std_logic;
signal m_axi_wvalid  : std_logic;
signal m_axi_wready  : std_logic;

	-- AXI4 Write Response Channel
signal m_axi_bid     : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal m_axi_bresp   : std_logic_vector(1 downto 0);
signal m_axi_bvalid  : std_logic;
signal m_axi_bready  : std_logic;

	-- AXI4 Read Address Channel
signal m_axi_arid    : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal m_axi_araddr  : std_logic_vector(C_AXI_MAP_ADDR_WIDTH-1 downto 0);
signal m_axi_arlen   : std_logic_vector(7 downto 0);
signal m_axi_arsize  : std_logic_vector(2 downto 0);
signal m_axi_arburst : std_logic_vector(1 downto 0);
signal m_axi_arcache : std_logic_vector(3 downto 0);
signal m_axi_arprot  : std_logic_vector(2 downto 0);
signal m_axi_arvalid : std_logic;
signal m_axi_arready : std_logic;

	-- AXI4 Read Data Channel
signal m_axi_rid     : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal m_axi_rdata   : std_logic_vector(C_AXI_MAP_DATA_WIDTH-1 downto 0);
signal m_axi_rresp   : std_logic_vector(1 downto 0);
signal m_axi_rlast   : std_logic;
signal m_axi_rvalid  : std_logic;
signal m_axi_rready  : std_logic;

--------------
-- For BRAM --
--------------

constant C_MEMORY_SIZE : integer := (8*1024); -- in bytes
constant C_MEMORY_DEPTH : integer := C_MEMORY_SIZE/(C_AXI_MAP_DATA_WIDTH/8); -- in words
constant C_BRAM_ADDR_WIDTH : integer := log2rp(C_MEMORY_DEPTH);
constant C_AXI_BRAM_ADDR_WIDTH : integer := C_AXI_MAP_ADDR_WIDTH;
constant C_BURST_LENGTH : integer := C_MAX_BURST_LEN;

-- MMap Write Address Channel
signal axi_awid    : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal axi_awaddr  : std_logic_vector(C_AXI_MAP_ADDR_WIDTH-1 downto 0);
signal axi_awlen   : std_logic_vector(7 downto 0);
signal axi_awsize  : std_logic_vector(2 downto 0);
signal axi_awburst : std_logic_vector(1 downto 0);
signal axi_awlock  : std_logic;
signal axi_awcache : std_logic_vector(3 downto 0);
signal axi_awprot  : std_logic_vector(2 downto 0);
signal axi_awvalid : std_logic;
signal axi_awready : std_logic;

-- MMap Write Data Channel
signal axi_wdata   : std_logic_vector(C_AXI_MAP_DATA_WIDTH-1 downto 0);
signal axi_wstrb   : std_logic_vector((C_AXI_MAP_DATA_WIDTH/8)-1 downto 0);
signal axi_wlast   : std_logic;
signal axi_wvalid  : std_logic;
signal axi_wready  : std_logic;

-- MMap Write Response Channel
signal axi_bid     : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal axi_bresp   : std_logic_vector(1 downto 0);
signal axi_bvalid  : std_logic;
signal axi_bready  : std_logic;

-- MMap Read Address Channel
signal axi_arid    : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal axi_araddr  : std_logic_vector(C_AXI_MAP_ADDR_WIDTH-1 downto 0);
signal axi_arlen   : std_logic_vector(7 downto 0);
signal axi_arsize  : std_logic_vector(2 downto 0);
signal axi_arburst : std_logic_vector(1 downto 0);
signal axi_arlock  : std_logic;
signal axi_arcache : std_logic_vector(3 downto 0);
signal axi_arprot  : std_logic_vector(2 downto 0);
signal axi_arvalid : std_logic;
signal axi_arready : std_logic;

-- MMap Read Data Channel
signal axi_rid     : std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
signal axi_rdata   : std_logic_vector(C_AXI_MAP_DATA_WIDTH-1 downto 0);
signal axi_rresp   : std_logic_vector(1 downto 0);
signal axi_rlast   : std_logic;
signal axi_rvalid  : std_logic;
signal axi_rready  : std_logic;

-- Support
signal init_done : std_logic;
signal rsp_cnt : integer;

begin

	process -- clock
	begin
		clock <= '0';
		wait for offset;
		loop
			clock <= '1';
			wait for (period * duty_cycle);
			clock <= '0';
			wait for (period - (period * duty_cycle));
		end loop;
	end process;

	process -- reset
	begin
		reset <= '1';
		wait_cycles(clock, 4);
		reset <= '0';
		wait; -- will wait forever
	end process;

	process (clock) -- counter
	begin
		if (rising_edge(clock)) then
			if (reset = '1') then -- synchronous reset
				count <= 0;
			else
				count <= count + 1 after hold;
			end if;
		end if;
	end process;

	-- #################### --

--	ctl_aclk <= clock; -- declared as alias
--	data_aclk <= clock; -- declared as alias

	ctl_aresetn <= not reset;
	data_aresetn <= not reset;

	control_rsp: process
	begin
		m_axis_ctl_tready <= '0';
		wait_sig(ctl_aclk, ctl_aresetn, '1');
		m_axis_ctl_tready <= '1';

		rsp_cnt <= 0;
		loop
			wait until (rising_edge(ctl_aclk) and m_axis_ctl_tvalid = '1' and m_axis_ctl_tlast = '1');
			wait for hold;
			rsp_cnt <= rsp_cnt + 1;
			if (rsp_cnt = 1) then
				m_axis_ctl_tready <= '0';
				wait until (rising_edge(ctl_aclk) and m_axis_ctl_tvalid = '1');
				m_axis_ctl_tready <= '1';
			end if;
		end loop;
	end process;

	control_cmd: process
	begin
		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait_sig(ctl_aclk, ctl_aresetn, '1');
		wait_sig(ctl_aclk, init_done, '1');

		-- ########## Contiguous Move ########## --
		s_axis_ctl_tdest <= X"2"; -- destination id
		s_axis_ctl_tid   <= X"1"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "000" & "100"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000001"; -- move command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000010"; -- src address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000400"; -- bytes to transfer
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdest <= X"3"; -- destination id
		s_axis_ctl_tid   <= X"1"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "000" & "100"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000081"; -- move command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000020"; -- dst address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000400"; -- bytes to transfer
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait_sig(ctl_aclk, m_axis_ctl_tvalid, '1'); wait_sig(ctl_aclk, m_axis_ctl_tvalid, '0');

		-- ########## Strided Read, Contiguous Write (with strided write) ########## --
		s_axis_ctl_tdest <= X"4"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "000" & "110"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"04060002"; -- smove command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000000"; -- src address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000004"; -- size
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000020"; -- increment
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000100"; -- repetitions
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdest <= X"5"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "000" & "110"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000082"; -- smove command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000020"; -- dst address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000004"; -- size
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000004"; -- increment
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000100"; -- repetitions
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait_sig(ctl_aclk, m_axis_ctl_tvalid, '1'); wait_sig(ctl_aclk, m_axis_ctl_tvalid, '0');

		-- ########## Indexed Store, Contiguous Read (with strided read) ########## --
		s_axis_ctl_tdest <= X"7"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '0' & '1' & "000" & "100"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000003"; -- index command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000080"; -- dst base address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000008"; -- size
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdest <= X"6"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "000" & "110"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000002"; -- smove command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000020"; -- src address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000008"; -- size
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000008"; -- increment
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000010"; -- repetitions
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdest <= X"7"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "100" & "001"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tvalid <= '1';

		s_axis_ctl_tdata <= X"0000000A"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000009"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000007"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000001"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"0000000F"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000003"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000000"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"0000000D"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000002"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000005"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000008"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000004"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"0000000C"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"0000000E"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000006"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tuser <= '0' & '1' & "001" & "001"; -- go, wr, reg, len
		s_axis_ctl_tdata <= X"00000083"; -- index command, request response
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tuser <= '1' & '1' & "100" & "001"; -- go, wr, reg, len
		s_axis_ctl_tdata <= X"0000000B"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait_sig(ctl_aclk, m_axis_ctl_tvalid, '1'); wait_sig(ctl_aclk, m_axis_ctl_tvalid, '0');

		-- ########## Index2 Read, Contiguous Write (with strided write) ########## --
		s_axis_ctl_tdest <= X"7"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "000" & "110"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000082"; -- smove command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000200"; -- dst address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000100"; -- size
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000100"; -- increment
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000004"; -- repetitions
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdest <= X"6"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '0' & '1' & "000" & "110"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000004"; -- index2 command
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000100"; -- src base address
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000010"; -- size
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000000"; -- index (spacer)
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"00000100"; -- trans
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdest <= X"6"; -- destination id
		s_axis_ctl_tid   <= X"2"; -- source id
		s_axis_ctl_tuser <= '1' & '1' & "100" & "001"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tvalid <= '1';

		s_axis_ctl_tdata <= X"00000004"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000003"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000006"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tdata <= X"00000005"; -- index
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait_sig(ctl_aclk, m_axis_ctl_tvalid, '1'); wait_sig(ctl_aclk, m_axis_ctl_tvalid, '0');

		-- ########## Register Read ########## --
		s_axis_ctl_tdest <= X"7"; -- destination id
		s_axis_ctl_tid   <= X"1"; -- source id
		s_axis_ctl_tuser <= '0' & '0' & "000" & "001"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- zero
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tuser <= '0' & '0' & "001" & "011"; -- go, wr, reg, len
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tuser <= '0' & '0' & "010" & "001"; -- go, wr, reg, len
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait until rsp_cnt = 7; wait for hold;

		-- ########## Done ########## --
		assert (FALSE) report "done." severity FAILURE;
		wait; -- will wait forever
	end process;

	-- #################### --

	s_axis_dat_tdata  <= m_axis_dat_tdata;
	s_axis_dat_tid    <= m_axis_dat_tid;
	s_axis_dat_tdest  <= m_axis_dat_tdest;
	s_axis_dat_tkeep  <= m_axis_dat_tkeep;
	s_axis_dat_tlast  <= m_axis_dat_tlast;
	s_axis_dat_tvalid <= m_axis_dat_tvalid;
	m_axis_dat_tready <= s_axis_dat_tready;

	uut: entity axi_lsu
	generic map (

	C_CTL_IS_ASYNC         => C_CTL_IS_ASYNC,
	C_CTL_FIFO_DEPTH       => C_CTL_FIFO_DEPTH,
	C_MAX_BURST_LEN        => C_MAX_BURST_LEN,
	C_BTT_USED             => C_BTT_USED,
	C_R_ADDR_PIPE_DEPTH    => C_R_ADDR_PIPE_DEPTH,
	C_R_INCLUDE_SF         => C_R_INCLUDE_SF,
	C_W_ADDR_PIPE_DEPTH    => C_W_ADDR_PIPE_DEPTH,
	C_W_INCLUDE_SF         => C_W_INCLUDE_SF,
	C_FAMILY               => C_FAMILY,

	C_AXIS_CTL_TDATA_WIDTH => C_AXIS_CTL_TDATA_WIDTH,
	C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
	C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
	C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

	C_AXIS_DAT_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,
	C_AXIS_DAT_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
	C_AXIS_DAT_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH,

	C_AXI_MAP_ID_WIDTH   => C_AXI_MAP_ID_WIDTH,
	C_AXI_MAP_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH,
	C_AXI_MAP_DATA_WIDTH => C_AXI_MAP_DATA_WIDTH

	)
	port map (

	ctl_aclk    => ctl_aclk,
	ctl_aresetn => ctl_aresetn,

	data_aclk    => data_aclk,
	data_aresetn => data_aresetn,

	-- Control Interface
	s_axis_ctl_tdata  => s_axis_ctl_tdata,
	s_axis_ctl_tid    => s_axis_ctl_tid,
	s_axis_ctl_tdest  => s_axis_ctl_tdest,
	s_axis_ctl_tuser  => s_axis_ctl_tuser,
	s_axis_ctl_tlast  => s_axis_ctl_tlast,
	s_axis_ctl_tvalid => s_axis_ctl_tvalid,
	s_axis_ctl_tready => s_axis_ctl_tready,

	m_axis_ctl_tdata  => m_axis_ctl_tdata,
	m_axis_ctl_tid    => m_axis_ctl_tid,
	m_axis_ctl_tdest  => m_axis_ctl_tdest,
	m_axis_ctl_tuser  => m_axis_ctl_tuser,
	m_axis_ctl_tlast  => m_axis_ctl_tlast,
	m_axis_ctl_tvalid => m_axis_ctl_tvalid,
	m_axis_ctl_tready => m_axis_ctl_tready,

	-- Data Interface
	s_axis_dat_tdata  => s_axis_dat_tdata,
	s_axis_dat_tid    => s_axis_dat_tid,
	s_axis_dat_tdest  => s_axis_dat_tdest,
	s_axis_dat_tkeep  => s_axis_dat_tkeep,
	s_axis_dat_tlast  => s_axis_dat_tlast,
	s_axis_dat_tvalid => s_axis_dat_tvalid,
	s_axis_dat_tready => s_axis_dat_tready,

	m_axis_dat_tdata  => m_axis_dat_tdata,
	m_axis_dat_tid    => m_axis_dat_tid,
	m_axis_dat_tdest  => m_axis_dat_tdest,
	m_axis_dat_tkeep  => m_axis_dat_tkeep,
	m_axis_dat_tlast  => m_axis_dat_tlast,
	m_axis_dat_tvalid => m_axis_dat_tvalid,
	m_axis_dat_tready => m_axis_dat_tready,

	-- Memory Map
	m_axi_awid    => m_axi_awid,
	m_axi_awaddr  => m_axi_awaddr,
	m_axi_awlen   => m_axi_awlen,
	m_axi_awsize  => m_axi_awsize,
	m_axi_awburst => m_axi_awburst,
	m_axi_awcache => m_axi_awcache,
	m_axi_awprot  => m_axi_awprot,
	m_axi_awvalid => m_axi_awvalid,
	m_axi_awready => m_axi_awready,
	--
	m_axi_wdata   => m_axi_wdata,
	m_axi_wstrb   => m_axi_wstrb,
	m_axi_wlast   => m_axi_wlast,
	m_axi_wvalid  => m_axi_wvalid,
	m_axi_wready  => m_axi_wready,
	--
	m_axi_bid     => m_axi_bid,
	m_axi_bresp   => m_axi_bresp,
	m_axi_bvalid  => m_axi_bvalid,
	m_axi_bready  => m_axi_bready,

	m_axi_arid    => m_axi_arid,
	m_axi_araddr  => m_axi_araddr, 
	m_axi_arlen   => m_axi_arlen,
	m_axi_arsize  => m_axi_arsize,
	m_axi_arburst => m_axi_arburst,
	m_axi_arcache => m_axi_arcache,
	m_axi_arprot  => m_axi_arprot,
	m_axi_arvalid => m_axi_arvalid,
	m_axi_arready => m_axi_arready,
	--
	m_axi_rid     => m_axi_rid,
	m_axi_rdata   => m_axi_rdata,
	m_axi_rresp   => m_axi_rresp,
	m_axi_rlast   => m_axi_rlast,
	m_axi_rvalid  => m_axi_rvalid,
	m_axi_rready  => m_axi_rready

	);

	mm2s_bram: entity axi_bram_ctrl
	generic map (

	C_MEMORY_DEPTH => C_MEMORY_DEPTH,
	C_FAMILY => C_FAMILY,
	C_BRAM_INST_MODE => "INTERNAL",
	C_BRAM_ADDR_WIDTH => C_BRAM_ADDR_WIDTH,
	C_S_AXI_ADDR_WIDTH => C_AXI_BRAM_ADDR_WIDTH,
	C_S_AXI_DATA_WIDTH => C_AXI_MAP_DATA_WIDTH,
	C_S_AXI_ID_WIDTH => C_AXI_MAP_ID_WIDTH,
	C_S_AXI_PROTOCOL => "AXI4",
	C_S_AXI_SUPPORTS_NARROW_BURST => 1,
	C_SINGLE_PORT_BRAM => 0,
	C_S_AXI_CTRL_ADDR_WIDTH => 32,
	C_S_AXI_CTRL_DATA_WIDTH => 32,
	C_ECC => 0,
	C_ECC_TYPE => 0,
	C_FAULT_INJECT => 0,
	C_ECC_ONOFF_RESET_VALUE => 0

	)
	port map (

	s_axi_aclk    => data_aclk,
	s_axi_aresetn => data_aresetn,

	-- connect with BRAM initialization logic to write
	s_axi_awid    => axi_awid,
	s_axi_awaddr  => axi_awaddr(C_AXI_BRAM_ADDR_WIDTH-1 downto 0),
	s_axi_awlen   => axi_awlen,
	s_axi_awsize  => axi_awsize,
	s_axi_awburst => axi_awburst,
	s_axi_awlock  => axi_awlock,
	s_axi_awcache => axi_awcache,
	s_axi_awprot  => axi_awprot,
	s_axi_awvalid => axi_awvalid,
	s_axi_awready => axi_awready,
	--
	s_axi_wdata   => axi_wdata,
	s_axi_wstrb   => axi_wstrb,
	s_axi_wlast   => axi_wlast,
	s_axi_wvalid  => axi_wvalid,
	s_axi_wready  => axi_wready,
	--
	s_axi_bid     => axi_bid,
	s_axi_bresp   => axi_bresp,
	s_axi_bvalid  => axi_bvalid,
	s_axi_bready  => axi_bready,

	-- connect with axi_lsu to read
	s_axi_arid    => m_axi_arid,
	s_axi_araddr  => m_axi_araddr(C_AXI_BRAM_ADDR_WIDTH-1 downto 0),
	s_axi_arlen   => m_axi_arlen,
	s_axi_arsize  => m_axi_arsize,
	s_axi_arburst => m_axi_arburst,
	s_axi_arlock  => '0',
	s_axi_arcache => m_axi_arcache,
	s_axi_arprot  => m_axi_arprot,
	s_axi_arvalid => m_axi_arvalid,
	s_axi_arready => m_axi_arready,
	--
	s_axi_rid     => m_axi_rid,
	s_axi_rdata   => m_axi_rdata,
	s_axi_rresp   => m_axi_rresp,
	s_axi_rlast   => m_axi_rlast,
	s_axi_rvalid  => m_axi_rvalid,
	s_axi_rready  => m_axi_rready,

	-- auxiliary
	s_axi_ctrl_awaddr => (others => '0'),
	s_axi_ctrl_awvalid => '0',
	s_axi_ctrl_wdata => (others => '0'),
	s_axi_ctrl_wvalid => '0',
	s_axi_ctrl_bready => '0',
	s_axi_ctrl_araddr => (others => '0'),
	s_axi_ctrl_arvalid => '0',
	s_axi_ctrl_rready => '0',
	bram_rddata_a => (others => '0'),
	bram_rddata_b => (others => '0')

	);

	s2mm_bram: entity axi_bram_ctrl
	generic map (

	C_MEMORY_DEPTH => C_MEMORY_DEPTH,
	C_FAMILY => C_FAMILY,
	C_BRAM_INST_MODE => "INTERNAL",
	C_BRAM_ADDR_WIDTH => C_BRAM_ADDR_WIDTH,
	C_S_AXI_ADDR_WIDTH => C_AXI_BRAM_ADDR_WIDTH,
	C_S_AXI_DATA_WIDTH => C_AXI_MAP_DATA_WIDTH,
	C_S_AXI_ID_WIDTH => C_AXI_MAP_ID_WIDTH,
	C_S_AXI_PROTOCOL => "AXI4",
	C_S_AXI_SUPPORTS_NARROW_BURST => 1,
	C_SINGLE_PORT_BRAM => 0,
	C_S_AXI_CTRL_ADDR_WIDTH => 32,
	C_S_AXI_CTRL_DATA_WIDTH => 32,
	C_ECC => 0,
	C_ECC_TYPE => 0,
	C_FAULT_INJECT => 0,
	C_ECC_ONOFF_RESET_VALUE => 0

	)
	port map (

	s_axi_aclk    => data_aclk,
	s_axi_aresetn => data_aresetn,

	-- connect with axi_lsu to write
	s_axi_awid    => m_axi_awid,
	s_axi_awaddr  => m_axi_awaddr(C_AXI_BRAM_ADDR_WIDTH-1 downto 0),
	s_axi_awlen   => m_axi_awlen,
	s_axi_awsize  => m_axi_awsize,
	s_axi_awburst => m_axi_awburst,
	s_axi_awlock  => '0',
	s_axi_awcache => m_axi_awcache,
	s_axi_awprot  => m_axi_awprot,
	s_axi_awvalid => m_axi_awvalid,
	s_axi_awready => m_axi_awready,
	--
	s_axi_wdata   => m_axi_wdata,
	s_axi_wstrb   => m_axi_wstrb,
	s_axi_wlast   => m_axi_wlast,
	s_axi_wvalid  => m_axi_wvalid,
	s_axi_wready  => m_axi_wready,
	--
	s_axi_bid     => m_axi_bid,
	s_axi_bresp   => m_axi_bresp,
	s_axi_bvalid  => m_axi_bvalid,
	s_axi_bready  => m_axi_bready,

	-- connect with BRAM check logic to read
	s_axi_arid    => axi_arid,
	s_axi_araddr  => axi_araddr(C_AXI_BRAM_ADDR_WIDTH-1 downto 0),
	s_axi_arlen   => axi_arlen,
	s_axi_arsize  => axi_arsize,
	s_axi_arburst => axi_arburst,
	s_axi_arlock  => axi_arlock,
	s_axi_arcache => axi_arcache,
	s_axi_arprot  => axi_arprot,
	s_axi_arvalid => axi_arvalid,
	s_axi_arready => axi_arready,
	--
	s_axi_rid     => axi_rid,
	s_axi_rdata   => axi_rdata,
	s_axi_rresp   => axi_rresp,
	s_axi_rlast   => axi_rlast,
	s_axi_rvalid  => axi_rvalid,
	s_axi_rready  => axi_rready,

	-- auxiliary
	s_axi_ctrl_awaddr  => (others => '0'),
	s_axi_ctrl_awvalid => '0',
	s_axi_ctrl_wdata   => (others => '0'),
	s_axi_ctrl_wvalid  => '0',
	s_axi_ctrl_bready  => '0',
	s_axi_ctrl_araddr  => (others => '0'),
	s_axi_ctrl_arvalid => '0',
	s_axi_ctrl_rready  => '0',
	bram_rddata_a      => (others => '0'),
	bram_rddata_b      => (others => '0')

	);

	-- no BRAM check logic
	axi_arid    <= (others => '0');
	axi_araddr  <= (others => '0');
	axi_arlen   <= (others => '0');
	axi_arsize  <= (others => '0');
	axi_arburst <= (others => '0');
	axi_arlock  <= '0';
	axi_arcache <= (others => '0');
	axi_arprot  <= (others => '0');
	axi_arvalid <= '0';

	axi_rready <= '0';

	mm2s_bram_fill: entity work.axi_write
	generic map(
	MEM_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH, 
	MEM_DATA_WIDTH => C_AXI_MAP_DATA_WIDTH, 
	BURST_LENGTH   => C_BURST_LENGTH,
	C_NUM_BURST    => C_MEMORY_DEPTH/C_BURST_LENGTH
	)
	port map (
	clock  => data_aclk,
	resetn => data_aresetn,
	-- Write Address Channel
	awaddr  => axi_awaddr,
	awlen   => axi_awlen,
	awsize  => axi_awsize,
	awburst => axi_awburst,
	awprot  => axi_awprot, 
	awcache => axi_awcache,
	awvalid => axi_awvalid,
	awready => axi_awready, 
	-- Write Data Channel
	wdata   => axi_wdata, 
	wstrb   => axi_wstrb, 
	wlast   => axi_wlast,  
	wvalid  => axi_wvalid, 
	wready  => axi_wready, 
	-- Write Response Channel
	bresp   => axi_bresp, 
	bvalid  => axi_bvalid,
	bready  => axi_bready,

	done_write_success => init_done
	);

	axi_awid   <= (others => '0');
	axi_awlock <= '0';

end behavioral;
