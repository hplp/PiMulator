----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2017 08:23:00 PM
-- Design Name: 
-- Module Name: axis_fifo_cc - structural
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

entity axis_fifo_cc is
generic (
	C_FAMILY : string := "zynq";
	C_DEPTH  : integer := 2; -- depth of FIFO

	C_AXIS_TDATA_WIDTH : integer range 8 to 1024 := 64;
	C_AXIS_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_TDEST_WIDTH : integer range 2 to 8 := 4
);

port (
	aclk    : in  std_logic;
	aresetn : in  std_logic;

	-- Stream In
	s_axis_tdata  : in  std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	s_axis_tid    : in  std_logic_vector(C_AXIS_TID_WIDTH-1 downto 0);
	s_axis_tdest  : in  std_logic_vector(C_AXIS_TDEST_WIDTH-1 downto 0);
	s_axis_tkeep  : in  std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0);
	s_axis_tlast  : in  std_logic;
	s_axis_tvalid : in  std_logic;
	s_axis_tready : out std_logic;

	-- Stream Out
	m_axis_tdata  : out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	m_axis_tid    : out std_logic_vector(C_AXIS_TID_WIDTH-1 downto 0);
	m_axis_tdest  : out std_logic_vector(C_AXIS_TDEST_WIDTH-1 downto 0);
	m_axis_tkeep  : out std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0);
	m_axis_tlast  : out std_logic;
	m_axis_tvalid : out std_logic;
	m_axis_tready : in  std_logic
);

end axis_fifo_cc;

architecture structural of axis_fifo_cc is

	constant FWFT : integer := 1; -- first word fall through
	constant FIFO_WIDTH : integer :=
		C_AXIS_TDATA_WIDTH +
		C_AXIS_TID_WIDTH +
		C_AXIS_TDEST_WIDTH +
		(C_AXIS_TDATA_WIDTH/8) + 1;

	signal fifo_din   : std_logic_vector(FIFO_WIDTH-1 downto 0);
	signal fifo_dout  : std_logic_vector(FIFO_WIDTH-1 downto 0);
	signal fifo_rd_en : std_logic;
	signal fifo_wr_en : std_logic;
	signal fifo_empty : std_logic;
	signal fifo_full  : std_logic;
	signal fifo_srst  : std_logic;

begin

	fifo_srst <= not aresetn;

	fifo_din <=
		s_axis_tlast  &
		s_axis_tkeep  &
		s_axis_tdest  &
		s_axis_tid    &
		s_axis_tdata;
	fifo_wr_en <= s_axis_tvalid;
	s_axis_tready <= not fifo_full;

	m_axis_tdata <= fifo_dout(C_AXIS_TDATA_WIDTH-1 downto 0);
	m_axis_tid <= fifo_dout(C_AXIS_TID_WIDTH+C_AXIS_TDATA_WIDTH-1 downto C_AXIS_TDATA_WIDTH);
	m_axis_tdest <= fifo_dout(C_AXIS_TDEST_WIDTH+C_AXIS_TID_WIDTH+C_AXIS_TDATA_WIDTH-1 downto C_AXIS_TID_WIDTH+C_AXIS_TDATA_WIDTH);
	m_axis_tkeep <= fifo_dout((C_AXIS_TDATA_WIDTH/8)+C_AXIS_TDEST_WIDTH+C_AXIS_TID_WIDTH+C_AXIS_TDATA_WIDTH-1 downto C_AXIS_TDEST_WIDTH+C_AXIS_TID_WIDTH+C_AXIS_TDATA_WIDTH);
	m_axis_tlast <= fifo_dout(FIFO_WIDTH-1);
	m_axis_tvalid <= not fifo_empty;
	fifo_rd_en <= m_axis_tready;

	i_fifo: entity fifo_cc
	generic map (
		C_WIDTH => FIFO_WIDTH,
		C_DEPTH => C_DEPTH,
		C_FWFT => FWFT
	)
	port map (
		clk => aclk,
		din => fifo_din,
		rd_en => fifo_rd_en,
		srst => fifo_srst,
		wr_en => fifo_wr_en,
		dout => fifo_dout,
		empty => fifo_empty,
		full => fifo_full
	);

end structural;
