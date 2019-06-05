----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2017 11:52:00 AM
-- Design Name: 
-- Module Name: axis_flow - structural
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

library axis_flow_lib;
use axis_flow_lib.all;

entity axis_flow is
generic (
	C_CTL_IS_ASYNC      : integer range 0 to 1 := 0;
	C_FAMILY            : string := "zynq";

	-- Stream Control
	C_AXIS_CTL_TDATA_WIDTH : integer range 8 to 1024 := 32;
	C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
	C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

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

	------------------
	-- Control Port --
	------------------

	-- Stream Control In
	s_axis_ctl_tdata  : in  std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
	s_axis_ctl_tid    : in  std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	s_axis_ctl_tdest  : in  std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	s_axis_ctl_tuser  : in  std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
	s_axis_ctl_tlast  : in  std_logic;
	s_axis_ctl_tvalid : in  std_logic;
	s_axis_ctl_tready : out std_logic;

	-- Stream Control Out
	m_axis_ctl_tdata  : out std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
	m_axis_ctl_tid    : out std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	m_axis_ctl_tdest  : out std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	m_axis_ctl_tuser  : out std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
	m_axis_ctl_tlast  : out std_logic;
	m_axis_ctl_tvalid : out std_logic;
	m_axis_ctl_tready : in  std_logic;

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

end axis_flow;

architecture structural of axis_flow is

constant C_DATA_WIDTH : integer := C_AXIS_CTL_TDATA_WIDTH;
constant C_ADDR_WIDTH : integer := 3;
constant C_NREG : integer := 8;

-----------------------
-- Command Interface --
-----------------------

-- Command Header
signal command_tid   : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal command_tdest : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal command_tuser : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

-- Command Sync
signal command_valid : std_logic;
signal command_ready : std_logic;

------------------------
-- Register Interface --
------------------------

-- Vector Register Port
signal vcmd : std_logic_vector(C_DATA_WIDTH*C_NREG-1 downto 0);
signal vrsp : std_logic_vector(C_DATA_WIDTH*C_NREG-1 downto 0);
signal vwe  : std_logic_vector(C_NREG-1 downto 0);

------------------------
-- Response Interface --
------------------------

-- Response Registers
signal response_sel : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
signal response_len : std_logic_vector(C_ADDR_WIDTH-1 downto 0);

-- Response Header
signal response_tid   : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal response_tdest : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal response_tuser : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

-- Response Sync
signal response_valid : std_logic;
signal response_ready : std_logic;

begin

	i_port : entity axis_port
	generic map (
		C_AXIS_CTL_TDATA_WIDTH => C_AXIS_CTL_TDATA_WIDTH,
		C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
		C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
		C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

		C_DATA_WIDTH => C_DATA_WIDTH,
		C_ADDR_WIDTH => C_ADDR_WIDTH,
		C_NREG       => C_NREG
	)
	port map (
		aclk => ctl_aclk,
		aresetn => ctl_aresetn,

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

		command_tid   => command_tid,
		command_tdest => command_tdest,
		command_tuser => command_tuser,
		command_valid => command_valid,
		command_ready => command_ready,

		vcmd => vcmd,
		vrsp => vrsp,
		vwe  => vwe,

		response_sel   => response_sel,
		response_len   => response_len,
		response_tid   => response_tid,
		response_tdest => response_tdest,
		response_tuser => response_tuser,
		response_valid => response_valid,
		response_ready => response_ready
	);

	i_cmd : entity axis_flow_cmd
	generic map (
		C_CTL_IS_ASYNC => C_CTL_IS_ASYNC,

		C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
		C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
		C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

		C_DATA_WIDTH => C_DATA_WIDTH,
		C_ADDR_WIDTH => C_ADDR_WIDTH,
		C_NREG       => C_NREG,

		C_AXIS_DAT_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,
		C_AXIS_DAT_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
		C_AXIS_DAT_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH
	)
	port map (
		ctl_aclk => ctl_aclk,
		ctl_aresetn => ctl_aresetn,

		data_aclk => data_aclk,
		data_aresetn => data_aresetn,

		command_tid   => command_tid,
		command_tdest => command_tdest,
		command_tuser => command_tuser,
		command_valid => command_valid,
		command_ready => command_ready,

		vcmd => vcmd,
		vrsp => vrsp,
		vwe  => vwe,

		response_sel   => response_sel,
		response_len   => response_len,
		response_tid   => response_tid,
		response_tdest => response_tdest,
		response_tuser => response_tuser,
		response_valid => response_valid,
		response_ready => response_ready,

		s_axis_dat1_tdata  => s_axis_dat1_tdata,
		s_axis_dat1_tid    => s_axis_dat1_tid,
		s_axis_dat1_tdest  => s_axis_dat1_tdest,
		s_axis_dat1_tkeep  => s_axis_dat1_tkeep,
		s_axis_dat1_tlast  => s_axis_dat1_tlast,
		s_axis_dat1_tvalid => s_axis_dat1_tvalid,
		s_axis_dat1_tready => s_axis_dat1_tready,

		m_axis_dat1_tdata  => m_axis_dat1_tdata,
		m_axis_dat1_tid    => m_axis_dat1_tid,
		m_axis_dat1_tdest  => m_axis_dat1_tdest,
		m_axis_dat1_tkeep  => m_axis_dat1_tkeep,
		m_axis_dat1_tlast  => m_axis_dat1_tlast,
		m_axis_dat1_tvalid => m_axis_dat1_tvalid,
		m_axis_dat1_tready => m_axis_dat1_tready,

		s_axis_dat2_tdata  => s_axis_dat2_tdata,
		s_axis_dat2_tid    => s_axis_dat2_tid,
		s_axis_dat2_tdest  => s_axis_dat2_tdest,
		s_axis_dat2_tkeep  => s_axis_dat2_tkeep,
		s_axis_dat2_tlast  => s_axis_dat2_tlast,
		s_axis_dat2_tvalid => s_axis_dat2_tvalid,
		s_axis_dat2_tready => s_axis_dat2_tready,

		m_axis_dat2_tdata  => m_axis_dat2_tdata,
		m_axis_dat2_tid    => m_axis_dat2_tid,
		m_axis_dat2_tdest  => m_axis_dat2_tdest,
		m_axis_dat2_tkeep  => m_axis_dat2_tkeep,
		m_axis_dat2_tlast  => m_axis_dat2_tlast,
		m_axis_dat2_tvalid => m_axis_dat2_tvalid,
		m_axis_dat2_tready => m_axis_dat2_tready
	);

end structural;
