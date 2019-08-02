----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/19/2013 04:51:15 PM
-- Design Name: 
-- Module Name: axi_lsu_ctl - structural
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

library axi_lsu_lib;
use axi_lsu_lib.axis_port;
use axi_lsu_lib.axi_lsu_cmd;

entity axi_lsu_ctl is
generic (
	-- Stream Control
	C_AXIS_CTL_TDATA_WIDTH : integer range 8 to 1024 := 32;
	C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
	C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	-- Stream Data
	C_AXIS_DAT_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_DAT_TDEST_WIDTH : integer range 2 to 8 := 4;

	-- Memory Mapped
	C_AXI_MAP_ADDR_WIDTH : integer range 32 to 64 := 32;

	-- Stream Command and Status
	C_AXIS_CMD_TDATA_WIDTH : integer := 72; 
	C_AXIS_STS_TDATA_WIDTH : integer := 8
	);

port (
	aclk    : in  std_logic;
	aresetn : in  std_logic;

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

	---------------------------
	-- Stream Data Interface --
	---------------------------

	-- Stream Data Out
	m_axis_dat_tid    : out std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	m_axis_dat_tdest  : out std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);

	-- Stream Data In
	s_axis_dat_tid    : in  std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	s_axis_dat_tdest  : in  std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);

	------------------------------
	-- Stream Command Interface --
	------------------------------

	-- Stream Command Out
	m_axis_cmd_tdata  : out std_logic_vector(C_AXIS_CMD_TDATA_WIDTH-1 downto 0);
	m_axis_cmd_tvalid : out std_logic;
	m_axis_cmd_tready : in  std_logic;

	-- Stream Status In
	s_axis_sts_tdata  : in  std_logic_vector(C_AXIS_STS_TDATA_WIDTH-1 downto 0);
	s_axis_sts_tkeep  : in  std_logic_vector((C_AXIS_STS_TDATA_WIDTH/8)-1 downto 0);
	s_axis_sts_tlast  : in  std_logic;
	s_axis_sts_tvalid : in  std_logic;
	s_axis_sts_tready : out std_logic
	);

end axi_lsu_ctl;


architecture structural of axi_lsu_ctl is

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

	m_axis_dat_tid   <= vcmd(C_DATA_WIDTH*1+16+C_AXIS_DAT_TID_WIDTH-1 downto C_DATA_WIDTH*1+16);
	m_axis_dat_tdest <= vcmd(C_DATA_WIDTH*1+24+C_AXIS_DAT_TDEST_WIDTH-1 downto C_DATA_WIDTH*1+24);

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
		aclk => aclk,
		aresetn => aresetn,

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

	i_cmd : entity axi_lsu_cmd
	generic map (
		C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
		C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
		C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

		C_DATA_WIDTH => C_DATA_WIDTH,
		C_ADDR_WIDTH => C_ADDR_WIDTH,
		C_NREG       => C_NREG,

		C_AXI_MAP_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH,

		C_AXIS_CMD_TDATA_WIDTH => C_AXIS_CMD_TDATA_WIDTH,
		C_AXIS_STS_TDATA_WIDTH => C_AXIS_STS_TDATA_WIDTH
	)
	port map (
		aclk => aclk,
		aresetn => aresetn,

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

		m_axis_cmd_tdata  => m_axis_cmd_tdata,
		m_axis_cmd_tvalid => m_axis_cmd_tvalid,
		m_axis_cmd_tready => m_axis_cmd_tready,

		s_axis_sts_tdata  => s_axis_sts_tdata,
		s_axis_sts_tkeep  => s_axis_sts_tkeep,
		s_axis_sts_tlast  => s_axis_sts_tlast,
		s_axis_sts_tvalid => s_axis_sts_tvalid,
		s_axis_sts_tready => s_axis_sts_tready
	);

end structural;
