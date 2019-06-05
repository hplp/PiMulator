----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2017 11:52:00 AM
-- Design Name: 
-- Module Name: axis_probe_cmd - behavioral
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
use ieee.numeric_std.all;
-- use ieee.std_logic_arith.ext;

library axis_probe_lib;
use axis_probe_lib.all;

entity axis_probe_cmd is
generic (
	C_CTL_IS_ASYNC      : integer range 0 to 1 := 0;

	-- Stream Control
	C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
	C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	-- Vector Register Port
	C_DATA_WIDTH : integer := 32;
	C_ADDR_WIDTH : integer := 3;
	C_NREG : integer := 8;

	-- Stream Data
	C_AXIS_DAT_TDATA_WIDTH : integer range 8 to 1024 := 64;
	C_AXIS_DAT_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_DAT_TDEST_WIDTH : integer range 2 to 8 := 4
	);

port (
	-- associated with control streams
	ctl_aclk    : in  std_logic;
	ctl_aresetn : in  std_logic;

	-- associated with data streams
	data_aclk    : in  std_logic;
	data_aresetn : in  std_logic;

	-----------------------
	-- Command Interface --
	-----------------------

	-- Command Header
	command_tid   : in std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	command_tdest : in std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	command_tuser : in std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Command Sync
	command_valid : in  std_logic;
	command_ready : out std_logic;

	------------------------
	-- Register Interface --
	------------------------

	-- Vector Register Port
	vcmd : in  std_logic_vector(C_DATA_WIDTH*C_NREG-1 downto 0);
	vrsp : out std_logic_vector(C_DATA_WIDTH*C_NREG-1 downto 0);
	vwe  : out std_logic_vector(C_NREG-1 downto 0);

	------------------------
	-- Response Interface --
	------------------------

	-- Response Registers
	response_sel : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	response_len : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);

	-- Response Header
	response_tid   : out std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	response_tdest : out std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	response_tuser : out std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Response Sync
	response_valid : out std_logic;
	response_ready : in  std_logic;

	-----------------
	-- Data Port 1 --
	-----------------

	-- Stream Data In
	s_axis_dat1_tdata  : in  std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	s_axis_dat1_tid    : in  std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	s_axis_dat1_tdest  : in  std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	s_axis_dat1_tkeep  : in  std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	s_axis_dat1_tlast  : in  std_logic;
	s_axis_dat1_tvalid : in  std_logic;
	s_axis_dat1_tready : out std_logic;

	-- Stream Data Out
	m_axis_dat1_tdata  : out std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	m_axis_dat1_tid    : out std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	m_axis_dat1_tdest  : out std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	m_axis_dat1_tkeep  : out std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	m_axis_dat1_tlast  : out std_logic;
	m_axis_dat1_tvalid : out std_logic;
	m_axis_dat1_tready : in  std_logic;

	-----------------
	-- Data Port 2 --
	-----------------

	-- Stream Data In
	s_axis_dat2_tdata  : in  std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	s_axis_dat2_tid    : in  std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	s_axis_dat2_tdest  : in  std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	s_axis_dat2_tkeep  : in  std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	s_axis_dat2_tlast  : in  std_logic;
	s_axis_dat2_tvalid : in  std_logic;
	s_axis_dat2_tready : out std_logic;

	-- Stream Data Out
	m_axis_dat2_tdata  : out std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	m_axis_dat2_tid    : out std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	m_axis_dat2_tdest  : out std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	m_axis_dat2_tkeep  : out std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	m_axis_dat2_tlast  : out std_logic;
	m_axis_dat2_tvalid : out std_logic;
	m_axis_dat2_tready : in  std_logic
	);

end axis_probe_cmd;

architecture rtl of axis_probe_cmd is

--      probe unit
--      register map
-- reg   31 bits  0
--     |------------|
--   0 | status:32  |
--   1 | plen:10    | minus 1
--   2 | ignore:32  |
--   3 | ignore:32  |
--   4 | ignore:32  |
--   5 | ignore:32  |
--   6 | ignore:32  |
--   7 | ignore:32  |
--     |------------|

-- The control port is only used for configuration of the probe length.
-- The rest of the functionality is hard wired to compare a stream of keys
-- from dat1 with a stream of probes from dat2 and output a value when a
-- key matches in a probe.

-- Command
constant PLEN_WIDTH : integer := 10;
alias plen   : std_logic_vector(PLEN_WIDTH-1 downto 0) is vcmd(C_DATA_WIDTH*1+PLEN_WIDTH-1 downto C_DATA_WIDTH*1);

-- Status
alias status : std_logic_vector(8-1 downto 0) is vcmd(8-1 downto 0);

	-------------------------------------------
	-- Stream Data Port 1 Internal Interface --
	-------------------------------------------

	signal dat1_key   : std_logic_vector(63 downto 0);
	signal dat1_valid : std_logic;
	signal dat1_ready : std_logic;

	-------------------------------------------
	-- Stream Data Port 2 Internal Interface --
	-------------------------------------------

--  typedef struct {
--      key_type key; /* 64-bits */
--      mapped_type value; /* 32-bits */
--      psl_t probes; /* 32-bits */
--  } slot_s;

	type dat2_state_type is range 0 to 1; -- machine states
	signal dat2_cs     : dat2_state_type; -- current state
	signal dat2_key    : std_logic_vector(63 downto 0);
	signal dat2_probes : std_logic_vector(31 downto 0);
	signal dat2_value  : std_logic_vector(31 downto 0);
	signal dat2_valid  : std_logic;
	signal dat2_ready  : std_logic;

	--------------------------------
	-- Compare and Select Support --
	--------------------------------

	subtype cmp_state_type is unsigned(PLEN_WIDTH-1 downto 0); -- machine states
	signal cmp_cs   : cmp_state_type; -- compare current state
	signal cmp_ns   : cmp_state_type; -- compare next state
	signal found_cs : boolean; -- key found current state
	signal found_ns : boolean; -- key found next state

	----------------------------
	-- Stream Output Register --
	----------------------------

	signal s_axis_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	signal s_axis_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	signal s_axis_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	signal s_axis_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	signal s_axis_tlast  : std_logic;
	signal s_axis_tvalid : std_logic;
	signal s_axis_tready : std_logic;

begin

	assert C_CTL_IS_ASYNC = 0
		report "TODO: handle async control clock"
			severity FAILURE;

	command_ready <= '0';

	vwe <= (others => '0');

	response_sel   <= (others => '0');
	response_len   <= (others => '0');
	response_tid   <= (others => '0');
	response_tdest <= (others => '0');
	response_tuser <= (others => '0');
	response_valid <= '0';

	m_axis_dat2_tdata  <= (others => '0');
	m_axis_dat2_tid    <= (others => '0');
	m_axis_dat2_tdest  <= (others => '0');
	m_axis_dat2_tkeep  <= (others => '0');
	m_axis_dat2_tlast  <= '0';
	m_axis_dat2_tvalid <= '0';

	-------------------------------------------
	-- Stream Data Port 1 Internal Interface --
	-------------------------------------------

	s_axis_dat1_tready <= dat1_ready or not dat1_valid;

	d1s: process(data_aclk)
	begin
		if (rising_edge(data_aclk)) then
			if (data_aresetn = '0') then -- synchronous reset
				dat1_key <= (others => '0');
				dat1_valid <= '0';
			else
				if (dat1_ready = '1' or dat1_valid = '0') then
					dat1_key <= s_axis_dat1_tdata;
					dat1_valid <= s_axis_dat1_tvalid;
				end if;
			end if;
		end if;
	end process;

	-------------------------------------------
	-- Stream Data Port 2 Internal Interface --
	-------------------------------------------

	s_axis_dat2_tready <= dat2_ready or not dat2_valid;

	d2s: process(data_aclk)
	begin
		if (rising_edge(data_aclk)) then
			if (data_aresetn = '0') then -- synchronous reset
				dat2_cs <= 0;
				dat2_key <= (others => '0');
				dat2_value <= (others => '0');
				dat2_probes <= (others => '0');
				dat2_valid <= '0';
			else
				if (dat2_ready = '1' or dat2_valid = '0') then
					if (dat2_cs mod 2 = 0) then
						dat2_key <= s_axis_dat2_tdata;
						dat2_valid <= '0';
					else
						dat2_value  <= s_axis_dat2_tdata(31 downto  0);
						dat2_probes <= s_axis_dat2_tdata(63 downto 32);
						dat2_valid <= s_axis_dat2_tvalid;
					end if;
					if (s_axis_dat2_tvalid = '1') then
						if (dat2_cs = dat2_state_type'high) then dat2_cs <= 0;
						else dat2_cs <= dat2_cs + 1; end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	--------------------------------
	-- Compare and Select Support --
	--------------------------------

	s_axis_tid   <= (others => '0');
	s_axis_tdest <= (others => '0');
	s_axis_tkeep <= (3 => '1', 2 => '1', 1 => '1', 0 => '1', others => '0');
	s_axis_tlast <= '1';

	sequ: process(data_aclk)
	begin
		if (rising_edge(data_aclk)) then
			if (data_aresetn = '0') then -- synchronous reset
				cmp_cs <= to_unsigned(0,PLEN_WIDTH);
				found_cs <= false;
			else
				cmp_cs <= cmp_ns;
				found_cs <= found_ns;
			end if;
		end if;
	end process;

	comb: process(
		cmp_cs, found_cs,
		dat1_valid, dat2_valid, s_axis_tready,
		dat1_key, dat2_key, dat2_probes, dat2_value, plen)
	begin
		cmp_ns <= cmp_cs; -- set default
		found_ns <= found_cs;
		s_axis_tdata <= (others => '0');
		s_axis_tvalid <= '0';
		if (dat1_valid = '1' and dat2_valid = '1' and s_axis_tready = '1') then
			if (dat2_key = dat1_key and dat2_probes /= X"00000000") then
				found_ns <= true;
				s_axis_tdata <= X"00000000" & dat2_value;
				s_axis_tvalid <= '1';
			elsif (cmp_cs = unsigned(plen) and not found_cs) then
				s_axis_tdata <= (others => '0'); -- send null
				s_axis_tvalid <= '1';
			end if;
			if (cmp_cs = unsigned(plen)) then
				cmp_ns <= to_unsigned(0,PLEN_WIDTH);
				found_ns <= false;
			else cmp_ns <= cmp_cs + to_unsigned(1,PLEN_WIDTH); end if;
		end if;
		if (cmp_cs = unsigned(plen)) then
			dat1_ready <= dat2_valid and s_axis_tready;
			dat2_ready <= dat1_valid and s_axis_tready;
		else
			dat1_ready <= '0';
			dat2_ready <= dat1_valid and s_axis_tready;
		end if;
	end process;

	----------------------------
	-- Stream Output Register --
	----------------------------

	i_reg1 : entity axis_fifo_cc
	generic map (
		C_DEPTH => 2,

		C_AXIS_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,
		C_AXIS_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
		C_AXIS_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH
	)
	port map (
		aclk => data_aclk,
		aresetn => data_aresetn,

		s_axis_tdata  => s_axis_tdata,
		s_axis_tid    => s_axis_tid,
		s_axis_tdest  => s_axis_tdest,
		s_axis_tkeep  => s_axis_tkeep,
		s_axis_tlast  => s_axis_tlast,
		s_axis_tvalid => s_axis_tvalid,
		s_axis_tready => s_axis_tready,

		m_axis_tdata  => m_axis_dat1_tdata,
		m_axis_tid    => m_axis_dat1_tid,
		m_axis_tdest  => m_axis_dat1_tdest,
		m_axis_tkeep  => m_axis_dat1_tkeep,
		m_axis_tlast  => m_axis_dat1_tlast,
		m_axis_tvalid => m_axis_dat1_tvalid,
		m_axis_tready => m_axis_dat1_tready
	);

end rtl;
