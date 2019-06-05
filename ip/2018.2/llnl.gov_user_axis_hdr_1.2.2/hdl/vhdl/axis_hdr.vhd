----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2013 10:23:06 AM
-- Design Name: 
-- Module Name: axis_hdr - RTL
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

entity axis_hdr is
generic (
	C_AXIS_TDATA_WIDTH    : integer range 8 to 1024 := 32;
	C_AXIS_TUSER_WIDTH    : integer range 4 to 16 := 8;
	C_AXIS_TID_WIDTH      : integer range 2 to 8 := 4;
	C_AXIS_TDEST_WIDTH    : integer range 2 to 8 := 4);

port (
	-- header to signals
	h2s_aclk    : in  std_logic;
	h2s_aresetn : in  std_logic;

	s_axis_hdr_tvalid  : in  std_logic;
	s_axis_hdr_tready  : out std_logic;
	s_axis_hdr_tdata   : in  std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	s_axis_hdr_tlast   : in  std_logic;

	m_axis_sig_tvalid  : out std_logic;
	m_axis_sig_tready  : in  std_logic;
	m_axis_sig_tdata   : out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	m_axis_sig_tlast   : out std_logic;
	m_axis_sig_tid     : out std_logic_vector(C_AXIS_TID_WIDTH-1 downto 0);
	m_axis_sig_tdest   : out std_logic_vector(C_AXIS_TDEST_WIDTH-1 downto 0);
	m_axis_sig_tuser   : out std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);

	-- signals to header
	s2h_aclk    : in  std_logic;
	s2h_aresetn : in  std_logic;

	s_axis_sig_tvalid  : in  std_logic;
	s_axis_sig_tready  : out std_logic;
	s_axis_sig_tdata   : in  std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	s_axis_sig_tlast   : in  std_logic;
	s_axis_sig_tid     : in  std_logic_vector(C_AXIS_TID_WIDTH-1 downto 0);
	s_axis_sig_tdest   : in  std_logic_vector(C_AXIS_TDEST_WIDTH-1 downto 0);
	s_axis_sig_tuser   : in  std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);

	m_axis_hdr_tvalid  : out std_logic;
	m_axis_hdr_tready  : in  std_logic;
	m_axis_hdr_tdata   : out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	m_axis_hdr_tlast   : out std_logic);

end axis_hdr;

architecture rtl of axis_hdr is

	constant TDEST_pos : natural := 0;
	constant TID_pos   : natural := 8;
	constant TUSER_pos : natural := 16;

	type state_type is (S_HDR, S_PAY); -- machine states
	signal h2s_ns : state_type; -- next state
	signal h2s_cs : state_type; -- current state
	signal s2h_ns : state_type; -- next state
	signal s2h_cs : state_type; -- current state

	signal m_axis_sig_tid_r   : std_logic_vector(C_AXIS_TID_WIDTH-1 downto 0);
	signal m_axis_sig_tdest_r : std_logic_vector(C_AXIS_TDEST_WIDTH-1 downto 0);
	signal m_axis_sig_tuser_r : std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);

	function conv_hdr(signal tid, tdest, tuser : std_logic_vector)
		return std_logic_vector is
		variable result : std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	begin
		result := (others => '0');
		result(TID_pos+tid'high downto TID_pos) := tid;
		result(TDEST_pos+tdest'high downto TDEST_pos) := tdest;
		result(TUSER_pos+tuser'high downto TUSER_pos) := tuser;
		return result;
	end conv_hdr;

begin

	-- header to signal

	s_axis_hdr_tready <= m_axis_sig_tready when (h2s_cs = S_PAY) else '1';

	m_axis_sig_tvalid <= s_axis_hdr_tvalid when (h2s_cs = S_PAY) else '0';
	m_axis_sig_tdata <= s_axis_hdr_tdata;
	m_axis_sig_tlast <= s_axis_hdr_tlast;
	m_axis_sig_tid <= m_axis_sig_tid_r;
	m_axis_sig_tdest <= m_axis_sig_tdest_r;
	m_axis_sig_tuser <= m_axis_sig_tuser_r;

	h2s_seq: process(h2s_aclk)
	begin
		if (rising_edge(h2s_aclk)) then
			if (h2s_aresetn = '0') then -- synchronous reset
				h2s_cs <= S_HDR;
				m_axis_sig_tid_r <= (others => '0');
				m_axis_sig_tdest_r <= (others => '0');
				m_axis_sig_tuser_r <= (others => '0');
			else
				if (h2s_cs = S_HDR and s_axis_hdr_tvalid = '1') then
					m_axis_sig_tid_r <= s_axis_hdr_tdata(TID_pos+C_AXIS_TID_WIDTH-1 downto TID_pos);
					m_axis_sig_tdest_r <= s_axis_hdr_tdata(TDEST_pos+C_AXIS_TDEST_WIDTH-1 downto TDEST_pos);
					m_axis_sig_tuser_r <= s_axis_hdr_tdata(TUSER_pos+C_AXIS_TUSER_WIDTH-1 downto TUSER_pos);
				end if;
				h2s_cs <= h2s_ns;
			end if;
		end if;
	end process;

	h2s_comb: process(h2s_cs, s_axis_hdr_tvalid, m_axis_sig_tready, s_axis_hdr_tlast)
	begin
		h2s_ns <= h2s_cs; -- set default
		case h2s_cs is
			when S_HDR =>
				if (s_axis_hdr_tvalid = '1' and s_axis_hdr_tlast = '0') then
					h2s_ns <= S_PAY;
				end if;
			when S_PAY =>
				if (s_axis_hdr_tvalid = '1' and m_axis_sig_tready = '1' and s_axis_hdr_tlast = '1') then
					h2s_ns <= S_HDR;
				end if;
			when others => null;
		end case;
	end process;

	-- signal to header

	s_axis_sig_tready <= m_axis_hdr_tready when (s2h_cs = S_PAY) else '0';

	m_axis_hdr_tvalid <= s_axis_sig_tvalid;
	m_axis_hdr_tdata <= s_axis_sig_tdata when (s2h_cs = S_PAY)
		else conv_hdr(s_axis_sig_tid, s_axis_sig_tdest, s_axis_sig_tuser);
	m_axis_hdr_tlast <= s_axis_sig_tlast when (s2h_cs = S_PAY) else '0';

	s2h_seq: process(s2h_aclk)
	begin
		if (rising_edge(s2h_aclk)) then
			if (s2h_aresetn = '0') then -- synchronous reset
				s2h_cs <= S_HDR;
			else
				s2h_cs <= s2h_ns;
			end if;
		end if;
	end process;

	s2h_comb: process(s2h_cs, s_axis_sig_tvalid, m_axis_hdr_tready, s_axis_sig_tlast)
	begin
		s2h_ns <= s2h_cs; -- set default
		case s2h_cs is
			when S_HDR =>
				if (s_axis_sig_tvalid = '1' and m_axis_hdr_tready = '1') then
					s2h_ns <= S_PAY;
				end if;
			when S_PAY =>
				if (s_axis_sig_tvalid = '1' and m_axis_hdr_tready = '1' and s_axis_sig_tlast = '1') then
					s2h_ns <= S_HDR;
				end if;
			when others => null;
		end case;
	end process;

end rtl;
