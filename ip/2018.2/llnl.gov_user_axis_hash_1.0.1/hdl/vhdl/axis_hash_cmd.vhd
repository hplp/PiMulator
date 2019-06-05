----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2016 06:17:00 AM
-- Design Name: 
-- Module Name: axis_hash_cmd - behavioral
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
use ieee.std_logic_arith.ext;

library axis_hash_lib;
use axis_hash_lib.short_hash;

entity axis_hash_cmd is
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
	m_axis_dat_tready : in  std_logic
	);

end axis_hash_cmd;

architecture behavioral of axis_hash_cmd is

constant C_AXIS_KEY_TDATA_WIDTH : integer := 128;
constant C_AXIS_KEY_TUSER_WIDTH : integer := 8;
constant C_AXIS_TAP_TDATA_WIDTH : integer := 256;

constant C_INIT : std_logic_vector := X"DEADBEEFDEADBEEF";

--      register map
-- reg   31 bits  0
--     |------------|
--   0 | status:32  |
--   1 | tlen_lo:32 |
--   2 | tlen_hi:32 |
--   3 | command:30 | seldi:1 seldo:1 seed:4 tdest:4 tid:4 hlen:8 klen:8
--   4 | data_lo:32 |
--   5 | data_hi:32 |
--   6 | hash_lo:32 |
--   7 | hash_hi:32 |
--     |------------|

-- status reg out, count of keys in hash function pipeline
alias status_c: std_logic_vector(C_DATA_WIDTH-1 downto 0) is vcmd(C_DATA_WIDTH*0+C_DATA_WIDTH-1 downto C_DATA_WIDTH*0);
alias status_r: std_logic_vector(C_DATA_WIDTH-1 downto 0) is vrsp(C_DATA_WIDTH*0+C_DATA_WIDTH-1 downto C_DATA_WIDTH*0);
-- table length in, used to mod resulting hash to form index
alias tlen    : std_logic_vector(63 downto 0) is vcmd(C_DATA_WIDTH*1+63 downto C_DATA_WIDTH*1+ 0);
-- command reg in
alias keylen  : std_logic_vector(7 downto 0) is vcmd(C_DATA_WIDTH*3+ 7 downto C_DATA_WIDTH*3+ 0);
alias hashlen : std_logic_vector(7 downto 0) is vcmd(C_DATA_WIDTH*3+15 downto C_DATA_WIDTH*3+ 8);
alias tid     : std_logic_vector(3 downto 0) is vcmd(C_DATA_WIDTH*3+19 downto C_DATA_WIDTH*3+16);
alias tdest   : std_logic_vector(3 downto 0) is vcmd(C_DATA_WIDTH*3+23 downto C_DATA_WIDTH*3+20);
alias seed    : std_logic_vector(3 downto 0) is vcmd(C_DATA_WIDTH*3+27 downto C_DATA_WIDTH*3+24);
alias seldo   : std_logic is vcmd(C_DATA_WIDTH*3+28); -- select data port for hash output
alias seldi   : std_logic is vcmd(C_DATA_WIDTH*3+29); -- select data port for key input
-- data reg in
alias data    : std_logic_vector(63 downto 0) is vcmd(C_DATA_WIDTH*4+63 downto C_DATA_WIDTH*4+ 0);
-- hash/index out
constant hreg : integer := 6;
alias hash    : std_logic_vector(63 downto 0) is vrsp(C_DATA_WIDTH*hreg+63 downto C_DATA_WIDTH*hreg+ 0);

signal index : std_logic_vector(63 downto 0);
signal rlen  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);

signal m_axis_key_tdata  : std_logic_vector(C_AXIS_KEY_TDATA_WIDTH-1 downto 0);
signal m_axis_key_tuser  : std_logic_vector(C_AXIS_KEY_TUSER_WIDTH-1 downto 0);
signal m_axis_key_tvalid : std_logic;
signal m_axis_key_tready : std_logic;

signal m_axis_tap_tdata  : std_logic_vector(C_AXIS_TAP_TDATA_WIDTH-1 downto 0);
signal m_axis_tap_tvalid : std_logic;
signal m_axis_tap_tready : std_logic;

signal s_axis_tap_tdata  : std_logic_vector(C_AXIS_TAP_TDATA_WIDTH-1 downto 0);
signal s_axis_tap_tvalid : std_logic;
signal s_axis_tap_tready : std_logic;

begin

	assert C_CTL_IS_ASYNC = 0
		report "TODO: handle async control clock"
			severity FAILURE;

	-- registers only used for input, tie off to zero
	vrsp(C_DATA_WIDTH*1+C_DATA_WIDTH-1 downto C_DATA_WIDTH*1) <= (others => '0');
	vwe(1) <= '0';
	vrsp(C_DATA_WIDTH*2+C_DATA_WIDTH-1 downto C_DATA_WIDTH*2) <= (others => '0');
	vwe(2) <= '0';
	vrsp(C_DATA_WIDTH*3+C_DATA_WIDTH-1 downto C_DATA_WIDTH*3) <= (others => '0');
	vwe(3) <= '0';
	vrsp(C_DATA_WIDTH*4+C_DATA_WIDTH-1 downto C_DATA_WIDTH*4) <= (others => '0');
	vwe(4) <= '0';
	vrsp(C_DATA_WIDTH*5+C_DATA_WIDTH-1 downto C_DATA_WIDTH*5) <= (others => '0');
	vwe(5) <= '0';

	-- count of keys in hash function pipeline
	stat: process(status_c,
		m_axis_key_tvalid, m_axis_key_tready,
		s_axis_tap_tvalid, s_axis_tap_tready)
		subtype rng is natural range 4 downto 0;
		variable incv : boolean; -- input to hash module
		variable decv : boolean; -- output from hash module
	begin
		incv := m_axis_key_tvalid = '1' and m_axis_key_tready = '1';
		decv := s_axis_tap_tvalid = '1' and s_axis_tap_tready = '1';
		status_r <= (others => '0');
		vwe(0) <= '0';
		if (incv and not decv) then
			status_r(rng) <= std_logic_vector(unsigned(status_c(rng)) + 1);
			vwe(0) <= '1';
		elsif (decv and not incv) then
			status_r(rng) <= std_logic_vector(unsigned(status_c(rng)) - 1);
			vwe(0) <= '1';
		end if;
	end process;

	-- key in
	m_axis_key_tdata <=
		ext(s_axis_dat_tdata, C_AXIS_KEY_TDATA_WIDTH) when seldi = '1' else
		ext(data, C_AXIS_KEY_TDATA_WIDTH);
	m_axis_key_tuser <= keylen;
	m_axis_key_tvalid <=
		s_axis_dat_tvalid when seldi = '1' else
		command_valid;
	s_axis_dat_tready <= m_axis_key_tready when seldi = '1' else '0';
	command_ready     <= m_axis_key_tready when seldi = '0' else '0';

	-- tap in
	m_axis_tap_tdata <= C_INIT & C_INIT & ext(seed,64) & ext(seed,64);
	m_axis_tap_tvalid <= '1';

	-- hash/index out
	-- index <= s_axis_tap_tdata(63 downto 0); -- 909 LUTS total
	-- index <= std_logic_vector(unsigned(s_axis_tap_tdata(63 downto 0)) mod unsigned(tlen)); -- 4,353 LUTS for 64-bit by 64-bit mod.
	-- index <= ext(std_logic_vector(unsigned(s_axis_tap_tdata(63 downto 0)) mod unsigned(tlen(28 downto 0))),index'length); -- 1,994 LUTS for 64-bit by 29-bit mod.
	-- index <= ext(std_logic_vector(unsigned(s_axis_tap_tdata(40 downto 0)) mod unsigned(tlen(28 downto 0))),index'length); -- 1,281 LUTS for 40-bit by 29-bit mod.
	-- index <=
		-- s_axis_tap_tdata(63 downto 0) when unsigned(tlen(28 downto 0)) = 0 else -- 909 LUTS total
		-- ext(std_logic_vector(unsigned(s_axis_tap_tdata(31 downto 0)) mod unsigned(tlen(28 downto 0))),index'length); -- 1,002 LUTS for 32-bit by 29-bit mod.
	index <= s_axis_tap_tdata(63 downto 0) and tlen;
	rlen <= ext(std_logic_vector((unsigned(hashlen) + 3) srl 2), rlen'length);

	m_axis_dat_tdata  <= ext(index,m_axis_dat_tdata'length);
	m_axis_dat_tid    <= tid;
	m_axis_dat_tdest  <= ext(tdest,m_axis_dat_tdest'length);
	m_axis_dat_tkeep  <= (others => '1');
	m_axis_dat_tlast  <= '1';
	m_axis_dat_tvalid <= s_axis_tap_tvalid when seldo = '1' else '0';

	hash <= ext(index,hash'length);
	vwe(hreg+1 downto hreg) <= "11" when s_axis_tap_tvalid = '1' and response_ready = '1' and seldo = '0' else "00";
	response_sel   <= std_logic_vector(to_unsigned(hreg, response_sel'length));
	response_len   <= rlen;
	response_tid   <= tid;
	response_tdest <= ext(tdest,response_tdest'length);
	response_tuser <= '1' & '1' & "100" & rlen; -- go, write, sel, len
	response_valid <= s_axis_tap_tvalid when seldo = '0' else '0';

	s_axis_tap_tready <=
		m_axis_dat_tready when seldo = '1' else
		response_ready;

	i_hash: entity short_hash
	generic map (
		C_AXIS_DAT_TDATA_WIDTH => C_AXIS_KEY_TDATA_WIDTH,
		C_AXIS_DAT_TUSER_WIDTH => C_AXIS_KEY_TUSER_WIDTH,
		C_AXIS_TAP_TDATA_WIDTH => C_AXIS_TAP_TDATA_WIDTH
	)
	port map (
		aclk    => data_aclk,
		aresetn => data_aresetn,

		s_axis_dat_tdata  => m_axis_key_tdata,
		s_axis_dat_tuser  => m_axis_key_tuser,
		s_axis_dat_tvalid => m_axis_key_tvalid,
		s_axis_dat_tready => m_axis_key_tready,

		s_axis_tap_tdata  => m_axis_tap_tdata,
		s_axis_tap_tvalid => m_axis_tap_tvalid,
		s_axis_tap_tready => m_axis_tap_tready,

		m_axis_tap_tdata  => s_axis_tap_tdata,
		m_axis_tap_tvalid => s_axis_tap_tvalid,
		m_axis_tap_tready => s_axis_tap_tready
	);

end behavioral;
