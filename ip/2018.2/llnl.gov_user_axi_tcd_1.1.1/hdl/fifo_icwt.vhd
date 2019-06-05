----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/07/2018 11:38:00 PM
-- Design Name:
-- Module Name: fifo_icwt - rtl
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

library xpm;
use xpm.vcomponents.all;

entity fifo_icwt is
  generic (
    C_FAMILY     : string  := "rtl";
    C_DEPTH      : integer := 1024;
    C_DIN_WIDTH  : integer := 32;
    C_DOUT_WIDTH : integer := 32;
    C_THRESH     : integer := 16
  );
  port (
    rst        : in  std_logic;
    wr_clk     : in  std_logic;
    rd_clk     : in  std_logic;
    din        : in  std_logic_vector(C_DIN_WIDTH-1 downto 0);
    wr_en      : in  std_logic;
    rd_en      : in  std_logic;
    dout       : out std_logic_vector(C_DOUT_WIDTH-1 downto 0);
    full       : out std_logic;
    empty      : out std_logic;
    prog_full  : out std_logic;
    prog_empty : out std_logic
  );
end fifo_icwt;

architecture rtl of fifo_icwt is

	-- return the number of bits needed to represent argument x
	function nbits (x : natural) return natural is
		variable i : natural;
	begin
		i := 0;
		while (x >= 2**i) loop
			i := i + 1;
		end loop;
		return i;
	end nbits;

	function factor (a, b : positive) return positive is
	begin
	   if (b < a) then return a/b; else return 1; end if;
	end factor;

	constant C_RD_DEPTH : integer := C_DEPTH*factor(C_DIN_WIDTH,C_DOUT_WIDTH);
	constant C_RD_DATA_COUNT_WIDTH : integer := nbits(C_RD_DEPTH);
	constant C_WR_DEPTH : integer := C_DEPTH*factor(C_DOUT_WIDTH,C_DIN_WIDTH);
	constant C_WR_DATA_COUNT_WIDTH : integer := nbits(C_WR_DEPTH);
	constant C_PROG_EMPTY_THRESH_ASSERT_VAL : integer := C_THRESH-1;
	constant C_PROG_FULL_THRESH_ASSERT_VAL : integer := C_WR_DEPTH-C_THRESH;

	signal wr_rst_busy  : std_logic;
	signal rd_rst_busy  : std_logic;

	signal wr_en_i      : std_logic;
	signal rd_en_i      : std_logic;
	signal full_i       : std_logic;
	signal empty_i      : std_logic;
	signal prog_full_i  : std_logic;
	signal prog_empty_i : std_logic;

begin

	-- qualify with wr_rst_busy or rd_rst_busy
	wr_en_i <= wr_en and not (full_i or wr_rst_busy);
	rd_en_i <= rd_en and not (empty_i or rd_rst_busy);
	full <= full_i or wr_rst_busy;
	empty <= empty_i or rd_rst_busy;
	prog_full <= prog_full_i or wr_rst_busy;
	prog_empty <= prog_empty_i or rd_rst_busy;

	i_fifo : xpm_fifo_async
	generic map (
	FIFO_MEMORY_TYPE    => "auto",   --string; "auto", "block", or "distributed";
	ECC_MODE            => "no_ecc", --string; "no_ecc" or "en_ecc";
	RELATED_CLOCKS      => 0,
	FIFO_WRITE_DEPTH    => C_WR_DEPTH,
	WRITE_DATA_WIDTH    => C_DIN_WIDTH,
	WR_DATA_COUNT_WIDTH => 1, -- C_WR_DATA_COUNT_WIDTH,
	PROG_FULL_THRESH    => C_PROG_FULL_THRESH_ASSERT_VAL,
	FULL_RESET_VALUE    => 0,
	USE_ADV_FEATURES    => "0202",   --string; "0000" to "1F1F";
	READ_MODE           => "fwft",   --string; "std" or "fwft";
	FIFO_READ_LATENCY   => 0,
	READ_DATA_WIDTH     => C_DOUT_WIDTH,
	RD_DATA_COUNT_WIDTH => 1, -- C_RD_DATA_COUNT_WIDTH,
	PROG_EMPTY_THRESH   => C_PROG_EMPTY_THRESH_ASSERT_VAL,
	DOUT_RESET_VALUE    => "0",
	CDC_SYNC_STAGES     => 2,
	WAKEUP_TIME         => 0
	)
	port map (
	rst              => rst,
	wr_clk           => wr_clk,
	wr_en            => wr_en_i,
	din              => din,
	full             => full_i,
	overflow         => open,
	wr_rst_busy      => wr_rst_busy,
	prog_full        => prog_full_i,
	wr_data_count    => open,
	almost_full      => open,
	wr_ack           => open,
	rd_clk           => rd_clk,
	rd_en            => rd_en_i,
	dout             => dout,
	empty            => empty_i,
	underflow        => open,
	rd_rst_busy      => rd_rst_busy,
	prog_empty       => prog_empty_i,
	rd_data_count    => open,
	almost_empty     => open,
	data_valid       => open,
	sleep            => '0',
	injectsbiterr    => '0',
	injectdbiterr    => '0',
	sbiterr          => open,
	dbiterr          => open
	);

end rtl;
