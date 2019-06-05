----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2017 11:52:00 AM
-- Design Name: 
-- Module Name: axis_flow_cmd - behavioral
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
-- use ieee.numeric_std.all;
-- use ieee.std_logic_arith.ext;

library axis_flow_lib;
use axis_flow_lib.all;

entity axis_flow_cmd is
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

end axis_flow_cmd;

architecture behavioral of axis_flow_cmd is

--      register map
-- reg   31 bits  0
--     |------------|
--   0 | status:32  |
--   1 | ?:32 |
--   2 | ?:32 |
--   3 | ?:32 |
--   4 | ?:32 |
--   5 | ?:32 |
--   6 | ?:32 |
--   7 | ?:32 |
--     |------------|

-- The control port is not used for configuration in this implementation.
-- Functionality is hard wired to duplicate the input stream (dat1) on
-- the output streams (dat1 and dat2).

signal s_axis_dat1_tvalid_s : std_logic;
signal s_axis_dat1_tready_s : std_logic;

signal s_axis_dat2_tvalid_s : std_logic;
signal s_axis_dat2_tready_s : std_logic;

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

	s_axis_dat1_tvalid_s <= s_axis_dat1_tvalid and s_axis_dat2_tready_s;
	s_axis_dat2_tvalid_s <= s_axis_dat1_tvalid and s_axis_dat1_tready_s;
	s_axis_dat1_tready <= s_axis_dat1_tready_s and s_axis_dat2_tready_s;
	s_axis_dat2_tready <= '0';

	i_reg1 : entity axis_fifo_cc
	generic map (
		C_DEPTH            => 2,

		C_AXIS_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,
		C_AXIS_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
		C_AXIS_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH
	)
	port map (
		aclk => data_aclk,
		aresetn => data_aresetn,

		s_axis_tdata  => s_axis_dat1_tdata,
		s_axis_tid    => s_axis_dat1_tid,
		s_axis_tdest  => s_axis_dat1_tdest,
		s_axis_tkeep  => s_axis_dat1_tkeep,
		s_axis_tlast  => s_axis_dat1_tlast,
		s_axis_tvalid => s_axis_dat1_tvalid_s,
		s_axis_tready => s_axis_dat1_tready_s,

		m_axis_tdata  => m_axis_dat1_tdata,
		m_axis_tid    => m_axis_dat1_tid,
		m_axis_tdest  => m_axis_dat1_tdest,
		m_axis_tkeep  => m_axis_dat1_tkeep,
		m_axis_tlast  => m_axis_dat1_tlast,
		m_axis_tvalid => m_axis_dat1_tvalid,
		m_axis_tready => m_axis_dat1_tready
	);

	i_reg2 : entity axis_fifo_cc
	generic map (
		C_DEPTH            => 2,

		C_AXIS_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,
		C_AXIS_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
		C_AXIS_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH
	)
	port map (
		aclk => data_aclk,
		aresetn => data_aresetn,

		s_axis_tdata  => s_axis_dat1_tdata,
		s_axis_tid    => s_axis_dat1_tid,
		s_axis_tdest  => s_axis_dat1_tdest,
		s_axis_tkeep  => s_axis_dat1_tkeep,
		s_axis_tlast  => s_axis_dat1_tlast,
		s_axis_tvalid => s_axis_dat2_tvalid_s,
		s_axis_tready => s_axis_dat2_tready_s,

		m_axis_tdata  => m_axis_dat2_tdata,
		m_axis_tid    => m_axis_dat2_tid,
		m_axis_tdest  => m_axis_dat2_tdest,
		m_axis_tkeep  => m_axis_dat2_tkeep,
		m_axis_tlast  => m_axis_dat2_tlast,
		m_axis_tvalid => m_axis_dat2_tvalid,
		m_axis_tready => m_axis_dat2_tready
	);

end behavioral;
