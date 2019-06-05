----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2013 04:16:35 PM
-- Design Name: 
-- Module Name: axi_lsu - structural
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

library axi_datamover_v5_1_19;
use axi_datamover_v5_1_19.axi_datamover;

library axi_lsu_lib;
use axi_lsu_lib.axi_lsu_ctl;

entity axi_lsu is
generic (
	C_CTL_IS_ASYNC      : integer range 0 to 1 := 0;
	C_CTL_FIFO_DEPTH    : integer range 1 to 16 := 4;
	C_MAX_BURST_LEN     : integer range 2 to 256 := 16;
	C_BTT_USED          : integer range 8 to 23 := 23;
	C_R_ADDR_PIPE_DEPTH : integer range 1 to 30 := 16;
	C_R_INCLUDE_SF      : integer range 0 to 1 := 0;
	C_W_ADDR_PIPE_DEPTH : integer range 1 to 30 := 16;
	C_W_INCLUDE_SF      : integer range 0 to 1 := 0;
	C_FAMILY            : string := "zynq";

	-- Stream Control
	C_AXIS_CTL_TDATA_WIDTH : integer range 8 to 1024 := 32;
	C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
	C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	-- Stream Data
	C_AXIS_DAT_TDATA_WIDTH : integer range 8 to 1024 := 64;
	C_AXIS_DAT_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_DAT_TDEST_WIDTH : integer range 2 to 8 := 4;

	-- Memory Mapped
	C_AXI_MAP_ID_WIDTH   : integer range  1 to 8 := 1;
	C_AXI_MAP_ADDR_WIDTH : integer range 32 to 64 := 32;
	C_AXI_MAP_DATA_WIDTH : integer range 32 to 1024 := 64
);

port (
	-- associated with control streams
	ctl_aclk    : in  std_logic;
	ctl_aresetn : in  std_logic;

	-- associated with data streams and master AXI
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

	---------------
	-- Data Port --
	---------------

	-- Stream Data In
	s_axis_dat_tdata  : in  std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	s_axis_dat_tid    : in  std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	s_axis_dat_tdest  : in  std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	s_axis_dat_tkeep  : in  std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	s_axis_dat_tlast  : in  std_logic;
	s_axis_dat_tvalid : in  std_logic;
	s_axis_dat_tready : out std_logic;

	-- Stream Data Out
	m_axis_dat_tdata  : out std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	m_axis_dat_tid    : out std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
	m_axis_dat_tdest  : out std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
	m_axis_dat_tkeep  : out std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
	m_axis_dat_tlast  : out std_logic;
	m_axis_dat_tvalid : out std_logic;
	m_axis_dat_tready : in  std_logic;

	--------------------------
	-- Memory Map Interface --
	--------------------------

	-- AXI4 Write Address Channel
	m_axi_awid    : out std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
	m_axi_awaddr  : out std_logic_vector(C_AXI_MAP_ADDR_WIDTH-1 downto 0);
	m_axi_awlen   : out std_logic_vector(7 downto 0);
	m_axi_awsize  : out std_logic_vector(2 downto 0);
	m_axi_awburst : out std_logic_vector(1 downto 0);
	m_axi_awcache : out std_logic_vector(3 downto 0);
	m_axi_awprot  : out std_logic_vector(2 downto 0);
	m_axi_awvalid : out std_logic;
	m_axi_awready : in  std_logic;

	-- AXI4 Write Data Channel
	m_axi_wdata   : out std_logic_vector(C_AXI_MAP_DATA_WIDTH-1 downto 0);
	m_axi_wstrb   : out std_logic_vector((C_AXI_MAP_DATA_WIDTH/8)-1 downto 0);
	m_axi_wlast   : out std_logic;
	m_axi_wvalid  : out std_logic;
	m_axi_wready  : in  std_logic;

	-- AXI4 Write Response Channel
	m_axi_bid     : in  std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
	m_axi_bresp   : in  std_logic_vector(1 downto 0);
	m_axi_bvalid  : in  std_logic;
	m_axi_bready  : out std_logic;

	-- AXI4 Read Address Channel
	m_axi_arid    : out std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
	m_axi_araddr  : out std_logic_vector(C_AXI_MAP_ADDR_WIDTH-1 downto 0);
	m_axi_arlen   : out std_logic_vector(7 downto 0);
	m_axi_arsize  : out std_logic_vector(2 downto 0);
	m_axi_arburst : out std_logic_vector(1 downto 0);
	m_axi_arcache : out std_logic_vector(3 downto 0);
	m_axi_arprot  : out std_logic_vector(2 downto 0);
	m_axi_arvalid : out std_logic;
	m_axi_arready : in  std_logic;

	-- AXI4 Read Data Channel
	m_axi_rid     : in  std_logic_vector(C_AXI_MAP_ID_WIDTH-1 downto 0);
	m_axi_rdata   : in  std_logic_vector(C_AXI_MAP_DATA_WIDTH-1 downto 0);
	m_axi_rresp   : in  std_logic_vector(1 downto 0);
	m_axi_rlast   : in  std_logic;
	m_axi_rvalid  : in  std_logic;
	m_axi_rready  : out std_logic
);

end axi_lsu;

architecture structural of axi_lsu is

constant C_AXIS_CMD_TDATA_WIDTH : integer := (C_AXI_MAP_ADDR_WIDTH+7)/8*8+40;
constant C_AXIS_STS_TDATA_WIDTH : integer := 8;

-- Memory Map to Stream
signal axis_mm2s_ctli_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal axis_mm2s_ctli_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal axis_mm2s_ctli_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal axis_mm2s_ctli_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal axis_mm2s_ctli_tlast  : std_logic;
signal axis_mm2s_ctli_tvalid : std_logic;
signal axis_mm2s_ctli_tready : std_logic;

signal axis_mm2s_ctlo_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal axis_mm2s_ctlo_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal axis_mm2s_ctlo_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal axis_mm2s_ctlo_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal axis_mm2s_ctlo_tlast  : std_logic;
signal axis_mm2s_ctlo_tvalid : std_logic;
signal axis_mm2s_ctlo_tready : std_logic;

signal axis_mm2s_cmd_tdata  : std_logic_vector (C_AXIS_CMD_TDATA_WIDTH-1 downto 0);
signal axis_mm2s_cmd_tvalid : std_logic;
signal axis_mm2s_cmd_tready : std_logic;

signal axis_mm2s_sts_tdata  : std_logic_vector (C_AXIS_STS_TDATA_WIDTH-1 downto 0);
signal axis_mm2s_sts_tkeep  : std_logic_vector (C_AXIS_STS_TDATA_WIDTH/8 -1 downto 0);
signal axis_mm2s_sts_tlast  : std_logic;
signal axis_mm2s_sts_tvalid : std_logic;
signal axis_mm2s_sts_tready : std_logic;

-- Stream to Memory Map
signal axis_s2mm_ctli_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal axis_s2mm_ctli_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal axis_s2mm_ctli_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal axis_s2mm_ctli_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal axis_s2mm_ctli_tlast  : std_logic;
signal axis_s2mm_ctli_tvalid : std_logic;
signal axis_s2mm_ctli_tready : std_logic;

signal axis_s2mm_ctlo_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal axis_s2mm_ctlo_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal axis_s2mm_ctlo_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal axis_s2mm_ctlo_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal axis_s2mm_ctlo_tlast  : std_logic;
signal axis_s2mm_ctlo_tvalid : std_logic;
signal axis_s2mm_ctlo_tready : std_logic;

signal axis_s2mm_cmd_tdata  : std_logic_vector (C_AXIS_CMD_TDATA_WIDTH-1 downto 0);
signal axis_s2mm_cmd_tvalid : std_logic;
signal axis_s2mm_cmd_tready : std_logic;

signal axis_s2mm_sts_tdata  : std_logic_vector (C_AXIS_STS_TDATA_WIDTH-1 downto 0);
signal axis_s2mm_sts_tkeep  : std_logic_vector (C_AXIS_STS_TDATA_WIDTH/8 -1 downto 0);
signal axis_s2mm_sts_tlast  : std_logic;
signal axis_s2mm_sts_tvalid : std_logic;
signal axis_s2mm_sts_tready : std_logic;

begin

	-- switch : 1 in x 2 out
	axis_mm2s_ctli_tdata  <= s_axis_ctl_tdata;
	axis_mm2s_ctli_tid    <= s_axis_ctl_tid;
	axis_mm2s_ctli_tdest  <= s_axis_ctl_tdest;
	axis_mm2s_ctli_tuser  <= s_axis_ctl_tuser;
	axis_mm2s_ctli_tlast  <= s_axis_ctl_tlast;
	axis_mm2s_ctli_tvalid <= s_axis_ctl_tvalid when (s_axis_ctl_tdest(0) = '0') else '0';

	axis_s2mm_ctli_tdata  <= s_axis_ctl_tdata;
	axis_s2mm_ctli_tid    <= s_axis_ctl_tid;
	axis_s2mm_ctli_tdest  <= s_axis_ctl_tdest;
	axis_s2mm_ctli_tuser  <= s_axis_ctl_tuser;
	axis_s2mm_ctli_tlast  <= s_axis_ctl_tlast;
	axis_s2mm_ctli_tvalid <= s_axis_ctl_tvalid when (s_axis_ctl_tdest(0) = '1') else '0';

	-- has to wait for both tready
	-- s_axis_ctl_tready <= axis_mm2s_ctli_tready and axis_s2mm_ctli_tready;

	-- has feedback loop through tvalid and makes tready dependent on tvalid
	s_axis_ctl_tready <=
		axis_mm2s_ctli_tready when (s_axis_ctl_tvalid = '1' and s_axis_ctl_tdest(0) = '0') else
		axis_s2mm_ctli_tready when (s_axis_ctl_tvalid = '1' and s_axis_ctl_tdest(0) = '1') else
		'0';

	-- FIXME: needs a latch or register to hold path
	-- switch : 2 in x 1 out
	m_axis_ctl_tdata  <= axis_mm2s_ctlo_tdata  when (axis_mm2s_ctlo_tvalid = '1') else axis_s2mm_ctlo_tdata;
	m_axis_ctl_tid    <= axis_mm2s_ctlo_tid    when (axis_mm2s_ctlo_tvalid = '1') else axis_s2mm_ctlo_tid;
	m_axis_ctl_tdest  <= axis_mm2s_ctlo_tdest  when (axis_mm2s_ctlo_tvalid = '1') else axis_s2mm_ctlo_tdest;
	m_axis_ctl_tuser  <= axis_mm2s_ctlo_tuser  when (axis_mm2s_ctlo_tvalid = '1') else axis_s2mm_ctlo_tuser;
	m_axis_ctl_tlast  <= axis_mm2s_ctlo_tlast  when (axis_mm2s_ctlo_tvalid = '1') else axis_s2mm_ctlo_tlast;
	m_axis_ctl_tvalid <= axis_mm2s_ctlo_tvalid or axis_s2mm_ctlo_tvalid;

	axis_mm2s_ctlo_tready <= m_axis_ctl_tready when (axis_mm2s_ctlo_tvalid = '1') else '0';
	axis_s2mm_ctlo_tready <= m_axis_ctl_tready when (axis_mm2s_ctlo_tvalid = '0') else '0';

	i_mm2s_ctl: entity axi_lsu_ctl
	generic map (

	C_AXIS_CTL_TDATA_WIDTH => C_AXIS_CTL_TDATA_WIDTH,
	C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
	C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
	C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

	C_AXIS_DAT_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
	C_AXIS_DAT_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH,

	C_AXI_MAP_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH,

	C_AXIS_CMD_TDATA_WIDTH => C_AXIS_CMD_TDATA_WIDTH,
	C_AXIS_STS_TDATA_WIDTH => C_AXIS_STS_TDATA_WIDTH

	)
	port map (

	aclk    => ctl_aclk,
	aresetn => ctl_aresetn,

	s_axis_ctl_tdata  => axis_mm2s_ctli_tdata,
	s_axis_ctl_tid    => axis_mm2s_ctli_tid,
	s_axis_ctl_tdest  => axis_mm2s_ctli_tdest,
	s_axis_ctl_tuser  => axis_mm2s_ctli_tuser,
	s_axis_ctl_tlast  => axis_mm2s_ctli_tlast,
	s_axis_ctl_tvalid => axis_mm2s_ctli_tvalid,
	s_axis_ctl_tready => axis_mm2s_ctli_tready,

	m_axis_ctl_tdata  => axis_mm2s_ctlo_tdata,
	m_axis_ctl_tid    => axis_mm2s_ctlo_tid,
	m_axis_ctl_tdest  => axis_mm2s_ctlo_tdest,
	m_axis_ctl_tuser  => axis_mm2s_ctlo_tuser,
	m_axis_ctl_tlast  => axis_mm2s_ctlo_tlast,
	m_axis_ctl_tvalid => axis_mm2s_ctlo_tvalid,
	m_axis_ctl_tready => axis_mm2s_ctlo_tready,

	m_axis_dat_tid    => m_axis_dat_tid,
	m_axis_dat_tdest  => m_axis_dat_tdest,

	s_axis_dat_tid    => (others => '0'),
	s_axis_dat_tdest  => (others => '0'),

	m_axis_cmd_tdata  => axis_mm2s_cmd_tdata,
	m_axis_cmd_tvalid => axis_mm2s_cmd_tvalid,
	m_axis_cmd_tready => axis_mm2s_cmd_tready,

	s_axis_sts_tdata  => axis_mm2s_sts_tdata,
	s_axis_sts_tkeep  => axis_mm2s_sts_tkeep,
	s_axis_sts_tlast  => axis_mm2s_sts_tlast,
	s_axis_sts_tvalid => axis_mm2s_sts_tvalid,
	s_axis_sts_tready => axis_mm2s_sts_tready

	);

	i_s2mm_ctl: entity axi_lsu_ctl
	generic map (

	C_AXIS_CTL_TDATA_WIDTH => C_AXIS_CTL_TDATA_WIDTH,
	C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
	C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
	C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

	C_AXIS_DAT_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
	C_AXIS_DAT_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH,

	C_AXI_MAP_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH,

	C_AXIS_CMD_TDATA_WIDTH => C_AXIS_CMD_TDATA_WIDTH,
	C_AXIS_STS_TDATA_WIDTH => C_AXIS_STS_TDATA_WIDTH

	)
	port map (

	aclk    => ctl_aclk,
	aresetn => ctl_aresetn,

	s_axis_ctl_tdata  => axis_s2mm_ctli_tdata,
	s_axis_ctl_tid    => axis_s2mm_ctli_tid,
	s_axis_ctl_tdest  => axis_s2mm_ctli_tdest,
	s_axis_ctl_tuser  => axis_s2mm_ctli_tuser,
	s_axis_ctl_tlast  => axis_s2mm_ctli_tlast,
	s_axis_ctl_tvalid => axis_s2mm_ctli_tvalid,
	s_axis_ctl_tready => axis_s2mm_ctli_tready,

	m_axis_ctl_tdata  => axis_s2mm_ctlo_tdata,
	m_axis_ctl_tid    => axis_s2mm_ctlo_tid,
	m_axis_ctl_tdest  => axis_s2mm_ctlo_tdest,
	m_axis_ctl_tuser  => axis_s2mm_ctlo_tuser,
	m_axis_ctl_tlast  => axis_s2mm_ctlo_tlast,
	m_axis_ctl_tvalid => axis_s2mm_ctlo_tvalid,
	m_axis_ctl_tready => axis_s2mm_ctlo_tready,

	m_axis_dat_tid    => open,
	m_axis_dat_tdest  => open,

	s_axis_dat_tid    => s_axis_dat_tid,
	s_axis_dat_tdest  => s_axis_dat_tdest,

	m_axis_cmd_tdata  => axis_s2mm_cmd_tdata,
	m_axis_cmd_tvalid => axis_s2mm_cmd_tvalid,
	m_axis_cmd_tready => axis_s2mm_cmd_tready,

	s_axis_sts_tdata  => axis_s2mm_sts_tdata,
	s_axis_sts_tkeep  => axis_s2mm_sts_tkeep,
	s_axis_sts_tlast  => axis_s2mm_sts_tlast,
	s_axis_sts_tvalid => axis_s2mm_sts_tvalid,
	s_axis_sts_tready => axis_s2mm_sts_tready

	);

	i_mover: entity axi_datamover
	generic map (

	--------------------------
	-- Memory Map to Stream --
	--------------------------

	-- Specifies the type of MM2S function to include
	-- 0 = Omit MM2S functionality
	-- 1 = Full MM2S Functionality
	-- 2 = Basic MM2S functionality
	C_INCLUDE_MM2S => 1,

	-- Specifies the constant value to output on 
	-- the ARID output port
	C_M_AXI_MM2S_ARID => 0,

	-- Specifies the width of the MM2S ID port 
	C_M_AXI_MM2S_ID_WIDTH => C_AXI_MAP_ID_WIDTH,

	-- Specifies the width of the MMap Read Address Channel 
	-- Address bus
	C_M_AXI_MM2S_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH,

	-- Specifies the width of the MMap Read Data Channel
	-- data bus
	C_M_AXI_MM2S_DATA_WIDTH => C_AXI_MAP_DATA_WIDTH,

	-- Specifies the width of the MM2S Master Stream Data 
	-- Channel data bus
	C_M_AXIS_MM2S_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,

	-- Specifies if a Status FIFO is to be implemented
	-- 0 = Omit MM2S Status FIFO
	-- 1 = Include MM2S Status FIFO
	C_INCLUDE_MM2S_STSFIFO => 1,

	-- Specifies the depth of the MM2S Command FIFO and the 
	-- optional Status FIFO
	-- Valid values are 1,4,8,16
	C_MM2S_STSCMD_FIFO_DEPTH => C_CTL_FIFO_DEPTH,

	-- Specifies if the Status and Command interfaces need to
	-- be asynchronous to the primary data path clocking
	-- 0 = Use same clocking as data path
	-- 1 = Use special Status/Command clock for the interfaces
	C_MM2S_STSCMD_IS_ASYNC => C_CTL_IS_ASYNC,

	-- Specifies if DRE is to be included in the MM2S function 
	-- 0 = Omit DRE
	-- 1 = Include DRE
	C_INCLUDE_MM2S_DRE => 1,

	-- Specifies the max number of databeats to use for MMap
	-- burst transfers by the MM2S function 
	C_MM2S_BURST_SIZE => C_MAX_BURST_LEN,

	-- Specifies the number of bits used from the BTT field
	-- of the input Command Word of the MM2S Command Interface 
	C_MM2S_BTT_USED => C_BTT_USED,

	-- This parameter specifies the depth of the MM2S internal 
	-- child command queues in the Read Address Controller and 
	-- the Read Data Controller. Increasing this value will 
	-- allow more Read Addresses to be issued to the AXI4 Read 
	-- Address Channel before receipt of the associated read 
	-- data on the Read Data Channel.
	C_MM2S_ADDR_PIPE_DEPTH => C_R_ADDR_PIPE_DEPTH,

	-- This parameter specifies the inclusion/omission of the
	-- MM2S (Read) Store and Forward function
	-- 0 = Omit MM2S Store and Forward
	-- 1 = Include MM2S Store and Forward
	C_MM2S_INCLUDE_SF => C_R_INCLUDE_SF,

	--------------------------
	-- Stream to Memory Map --
	--------------------------

	-- Specifies the type of S2MM function to include
	-- 0 = Omit S2MM functionality
	-- 1 = Full S2MM Functionality
	-- 2 = Basic S2MM functionality
	C_INCLUDE_S2MM => 1,

	-- Specifies the constant value to output on 
	-- the AWID output port
	C_M_AXI_S2MM_AWID => 1,

	-- Specifies the width of the S2MM ID port 
	C_M_AXI_S2MM_ID_WIDTH => C_AXI_MAP_ID_WIDTH,

	-- Specifies the width of the MMap Read Address Channel 
	-- Address bus
	C_M_AXI_S2MM_ADDR_WIDTH => C_AXI_MAP_ADDR_WIDTH,

	-- Specifies the width of the MMap Read Data Channel
	-- data bus
	C_M_AXI_S2MM_DATA_WIDTH => C_AXI_MAP_DATA_WIDTH,

	-- Specifies the width of the S2MM Master Stream Data 
	-- Channel data bus
	C_S_AXIS_S2MM_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,

	-- Specifies if a Status FIFO is to be implemented
	-- 0 = Omit S2MM Status FIFO
	-- 1 = Include S2MM Status FIFO
	C_INCLUDE_S2MM_STSFIFO => 1,

	-- Specifies the depth of the S2MM Command FIFO and the 
	-- optional Status FIFO
	-- Valid values are 1,4,8,16
	C_S2MM_STSCMD_FIFO_DEPTH => C_CTL_FIFO_DEPTH,

	-- Specifies if the Status and Command interfaces need to
	-- be asynchronous to the primary data path clocking
	-- 0 = Use same clocking as data path
	-- 1 = Use special Status/Command clock for the interfaces
	C_S2MM_STSCMD_IS_ASYNC => C_CTL_IS_ASYNC,

	-- Specifies if DRE is to be included in the S2MM function 
	-- 0 = Omit DRE
	-- 1 = Include DRE
	C_INCLUDE_S2MM_DRE => 1,

	-- Specifies the max number of databeats to use for MMap
	-- burst transfers by the S2MM function 
	C_S2MM_BURST_SIZE => C_MAX_BURST_LEN,

	-- Specifies the number of bits used from the BTT field
	-- of the input Command Word of the S2MM Command Interface 
	C_S2MM_BTT_USED => C_BTT_USED,

	-- Specifies if support for indeterminate packet lengths
	-- are to be received on the input Stream interface 
	-- 0 = Omit support (User MUST transfer the exact number of  
	--     bytes on the Stream interface as specified in the BTT 
	--     field of the Corresponding DataMover Command)
	-- 1 = Include support for indeterminate packet lengths
	--     This causes FIFOs to be added and "Store and Forward" 
	--     behavior of the S2MM function
	C_S2MM_SUPPORT_INDET_BTT => 0,

	-- This parameter specifies the depth of the S2MM internal 
	-- address pipeline queues in the Write Address Controller 
	-- and the Write Data Controller. Increasing this value will 
	-- allow more Write Addresses to be issued to the AXI4 Write 
	-- Address Channel before transmission of the associated  
	-- write data on the Write Data Channel.
	C_S2MM_ADDR_PIPE_DEPTH => C_W_ADDR_PIPE_DEPTH,

	-- This parameter specifies the inclusion/omission of the
	-- S2MM (Write) Store and Forward function
	-- 0 = Omit S2MM Store and Forward
	-- 1 = Include S2MM Store and Forward
	C_S2MM_INCLUDE_SF => C_W_INCLUDE_SF,

	---------------------------
	-- Additional Parameters --
	---------------------------

	C_ENABLE_CACHE_USER => 0,

	-- if C_ENABLE_SKID_BUF(2) = '1', not used
	-- if C_ENABLE_SKID_BUF(2) = '1', for better timing, isolate store and forward from write controller
	-- if C_ENABLE_SKID_BUF(3) = '1', for better timing when no realigner, between absorber and write controller
	-- if C_ENABLE_SKID_BUF(4) = '1', enable S2MM stream input buffer
	-- if C_ENABLE_SKID_BUF(5) = '1', enable MM2S stream output buffer
	C_ENABLE_SKID_BUF => "11111",

	-- TKEEP is used on stream data, otherwise set to 1
	C_ENABLE_MM2S_TKEEP => 1,
	C_ENABLE_S2MM_TKEEP => 1,

	-- Not used in v5.1
	C_ENABLE_MM2S_ADV_SIG => 0,
	C_ENABLE_S2MM_ADV_SIG => 0,

	-- Available only in basic functionality
	-- If 1, passes through the EOF bit in command
	-- otherwise EOF is always 1
	C_MICRO_DMA => 0,

	C_CMD_WIDTH => C_AXIS_CMD_TDATA_WIDTH,

	-- Specifies the target FPGA family type
	C_FAMILY => C_FAMILY

	)
	port map (

	-- Memory Map to Stream
	m_axi_mm2s_aclk    => data_aclk,
	m_axi_mm2s_aresetn => data_aresetn,

	m_axis_mm2s_cmdsts_aclk    => ctl_aclk,
	m_axis_mm2s_cmdsts_aresetn => ctl_aresetn,

	s_axis_mm2s_cmd_tdata  => axis_mm2s_cmd_tdata,
	s_axis_mm2s_cmd_tvalid => axis_mm2s_cmd_tvalid,
	s_axis_mm2s_cmd_tready => axis_mm2s_cmd_tready,

	m_axis_mm2s_sts_tdata  => axis_mm2s_sts_tdata,
	m_axis_mm2s_sts_tkeep  => axis_mm2s_sts_tkeep,
	m_axis_mm2s_sts_tlast  => axis_mm2s_sts_tlast,
	m_axis_mm2s_sts_tvalid => axis_mm2s_sts_tvalid,
	m_axis_mm2s_sts_tready => axis_mm2s_sts_tready,

	m_axi_mm2s_arid    => m_axi_arid,
	m_axi_mm2s_araddr  => m_axi_araddr, 
	m_axi_mm2s_arlen   => m_axi_arlen,
	m_axi_mm2s_arsize  => m_axi_arsize,
	m_axi_mm2s_arburst => m_axi_arburst,
	m_axi_mm2s_arcache => m_axi_arcache,
	m_axi_mm2s_arprot  => m_axi_arprot,
	m_axi_mm2s_aruser  => open,
	m_axi_mm2s_arvalid => m_axi_arvalid,
	m_axi_mm2s_arready => m_axi_arready,
	--
	m_axi_mm2s_rdata   => m_axi_rdata,
	m_axi_mm2s_rresp   => m_axi_rresp,
	m_axi_mm2s_rlast   => m_axi_rlast,
	m_axi_mm2s_rvalid  => m_axi_rvalid,
	m_axi_mm2s_rready  => m_axi_rready,

	m_axis_mm2s_tdata  => m_axis_dat_tdata,
	m_axis_mm2s_tkeep  => m_axis_dat_tkeep,
	m_axis_mm2s_tlast  => m_axis_dat_tlast,
	m_axis_mm2s_tvalid => m_axis_dat_tvalid,
	m_axis_mm2s_tready => m_axis_dat_tready,

	mm2s_halt => '0',
	mm2s_halt_cmplt => open,
	mm2s_allow_addr_req => '1',
	mm2s_addr_req_posted => open,
	mm2s_rd_xfer_cmplt => open,
	mm2s_dbg_sel => (others => '0'),
	mm2s_dbg_data => open,
	mm2s_err => open,

	-- Stream to Memory Map
	m_axi_s2mm_aclk    => data_aclk,
	m_axi_s2mm_aresetn => data_aresetn,

	m_axis_s2mm_cmdsts_awclk   => ctl_aclk,
	m_axis_s2mm_cmdsts_aresetn => ctl_aresetn,

	s_axis_s2mm_cmd_tdata  => axis_s2mm_cmd_tdata,
	s_axis_s2mm_cmd_tvalid => axis_s2mm_cmd_tvalid,
	s_axis_s2mm_cmd_tready => axis_s2mm_cmd_tready,

	m_axis_s2mm_sts_tdata  => axis_s2mm_sts_tdata,
	m_axis_s2mm_sts_tkeep  => axis_s2mm_sts_tkeep,
	m_axis_s2mm_sts_tlast  => axis_s2mm_sts_tlast,
	m_axis_s2mm_sts_tvalid => axis_s2mm_sts_tvalid,
	m_axis_s2mm_sts_tready => axis_s2mm_sts_tready,

	m_axi_s2mm_awid    => m_axi_awid,
	m_axi_s2mm_awaddr  => m_axi_awaddr, 
	m_axi_s2mm_awlen   => m_axi_awlen,
	m_axi_s2mm_awsize  => m_axi_awsize,
	m_axi_s2mm_awburst => m_axi_awburst,
	m_axi_s2mm_awcache => m_axi_awcache,
	m_axi_s2mm_awprot  => m_axi_awprot,
	m_axi_s2mm_awuser  => open,
	m_axi_s2mm_awvalid => m_axi_awvalid,
	m_axi_s2mm_awready => m_axi_awready,
	--
	m_axi_s2mm_wdata   => m_axi_wdata,
	m_axi_s2mm_wstrb   => m_axi_wstrb,
	m_axi_s2mm_wlast   => m_axi_wlast,
	m_axi_s2mm_wvalid  => m_axi_wvalid,
	m_axi_s2mm_wready  => m_axi_wready,
	--
	m_axi_s2mm_bresp   => m_axi_bresp,
	m_axi_s2mm_bvalid  => m_axi_bvalid,
	m_axi_s2mm_bready  => m_axi_bready,

	s_axis_s2mm_tdata  => s_axis_dat_tdata,
	s_axis_s2mm_tkeep  => s_axis_dat_tkeep,
	s_axis_s2mm_tlast  => s_axis_dat_tlast,
	s_axis_s2mm_tvalid => s_axis_dat_tvalid,
	s_axis_s2mm_tready => s_axis_dat_tready,

	s2mm_halt => '0',
	s2mm_halt_cmplt => open,
	s2mm_allow_addr_req => '1',
	s2mm_addr_req_posted => open,
	s2mm_wr_xfer_cmplt => open,
	s2mm_dbg_sel => (others => '0'),
	s2mm_dbg_data => open,
	s2mm_ld_nxt_len => open,
	s2mm_wr_len => open,
	s2mm_err => open

	);

end structural;
