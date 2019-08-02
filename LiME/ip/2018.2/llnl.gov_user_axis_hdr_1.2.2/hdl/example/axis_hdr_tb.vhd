----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2013 01:07:56 PM
-- Design Name: 
-- Module Name: axis_hdr_tb - behavioral
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

library axis_hdr_lib;
use axis_hdr_lib.axis_hdr;

entity axis_hdr_tb is
end axis_hdr_tb;

architecture behavioral of axis_hdr_tb is

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

-- #################### --

	constant C_AXIS_TDATA_WIDTH : integer := 32;
	constant C_AXIS_TUSER_WIDTH : integer := 8;
	constant C_AXIS_TID_WIDTH   : integer := 4;
	constant C_AXIS_TDEST_WIDTH : integer := 4;

	alias  h2s_aclk    : std_logic is clock;
	signal h2s_aresetn : std_logic;

	signal m_axis_hdr_tvalid  : std_logic;
	signal m_axis_hdr_tready  : std_logic;
	signal m_axis_hdr_tdata   : std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	signal m_axis_hdr_tlast   : std_logic;

	alias  s2h_aclk    : std_logic is clock;
	signal s2h_aresetn : std_logic;

	signal s_axis_hdr_tvalid  : std_logic;
	signal s_axis_hdr_tready  : std_logic;
	signal s_axis_hdr_tdata   : std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_axis_hdr_tlast   : std_logic;

	signal loop_sig_tvalid  : std_logic;
	signal loop_sig_tready  : std_logic;
	signal loop_sig_tdata   : std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	signal loop_sig_tlast   : std_logic;
	signal loop_sig_tid     : std_logic_vector(C_AXIS_TID_WIDTH-1 downto 0);
	signal loop_sig_tdest   : std_logic_vector(C_AXIS_TDEST_WIDTH-1 downto 0);
	signal loop_sig_tuser   : std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);

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

	-- declared as alias
	-- h2s_aclk <= clock;
	-- s2h_aclk <= clock;

	h2s_aresetn <= not reset;
	s2h_aresetn <= not reset;

	slave: process
	begin
		s_axis_hdr_tready <= '0';
		wait_sig(s2h_aclk, s2h_aresetn, '1');
		s_axis_hdr_tready <= '1';

		wait until (rising_edge(s2h_aclk) and s_axis_hdr_tvalid = '1' and s_axis_hdr_tlast = '1');
		wait for hold;

		wait_sig(s2h_aclk, s_axis_hdr_tvalid, '1');
		wait_cycles(s2h_aclk, 1);
		s_axis_hdr_tready <= '0';
		wait_cycles(s2h_aclk, 1);
		s_axis_hdr_tready <= '1';

		wait; -- will wait forever
	end process;

	master: process
	begin
		m_axis_hdr_tvalid <= '0';
		m_axis_hdr_tdata <= (others => '0');
		m_axis_hdr_tlast <= '0';
		wait_sig(h2s_aclk, h2s_aresetn, '1');

		m_axis_hdr_tvalid <= '1';
		m_axis_hdr_tdata <= X"33332211";
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tdata <= X"AAAAAAAA";
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tdata <= X"BBBBBBBB";
		m_axis_hdr_tlast <= '1';
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tvalid <= '0';
		m_axis_hdr_tdata <= (others => '0');
		m_axis_hdr_tlast <= '0';
		wait_cycles(h2s_aclk, 4);

		m_axis_hdr_tvalid <= '1';
		m_axis_hdr_tdata <= X"66665544";
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tdata <= X"CCCCCCCC";
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tdata <= X"DDDDDDDD";
		m_axis_hdr_tlast <= '1';
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tvalid <= '0';
		m_axis_hdr_tdata <= (others => '0');
		m_axis_hdr_tlast <= '0';
		wait_cycles(h2s_aclk, 4);

		m_axis_hdr_tvalid <= '1';
		m_axis_hdr_tdata <= X"99998877";
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tdata <= X"EEEEEEEE";
		m_axis_hdr_tlast <= '1';
		wait_sig(h2s_aclk, m_axis_hdr_tready, '1');
		m_axis_hdr_tvalid <= '0';
		m_axis_hdr_tdata <= (others => '0');
		m_axis_hdr_tlast <= '0';
		wait_cycles(h2s_aclk, 4);

		assert (FALSE) report "done." severity FAILURE;
		wait; -- will wait forever
	end process;

	uut: entity axis_hdr
	generic map (
		C_AXIS_TDATA_WIDTH => C_AXIS_TDATA_WIDTH,
		C_AXIS_TUSER_WIDTH => C_AXIS_TUSER_WIDTH,
		C_AXIS_TID_WIDTH => C_AXIS_TID_WIDTH,
		C_AXIS_TDEST_WIDTH => C_AXIS_TDEST_WIDTH
	)
	port map (
		-- header to signals
		h2s_aclk => h2s_aclk,
		h2s_aresetn => h2s_aresetn,

		s_axis_hdr_tvalid => m_axis_hdr_tvalid,
		s_axis_hdr_tready => m_axis_hdr_tready,
		s_axis_hdr_tdata => m_axis_hdr_tdata,
		s_axis_hdr_tlast => m_axis_hdr_tlast,

		m_axis_sig_tvalid => loop_sig_tvalid,
		m_axis_sig_tready => loop_sig_tready,
		m_axis_sig_tdata => loop_sig_tdata,
		m_axis_sig_tlast => loop_sig_tlast,
		m_axis_sig_tid => loop_sig_tid,
		m_axis_sig_tdest => loop_sig_tdest,
		m_axis_sig_tuser => loop_sig_tuser,

		-- signals to header
		s2h_aclk => s2h_aclk,
		s2h_aresetn => s2h_aresetn,

		s_axis_sig_tvalid => loop_sig_tvalid,
		s_axis_sig_tready => loop_sig_tready,
		s_axis_sig_tdata => loop_sig_tdata,
		s_axis_sig_tlast => loop_sig_tlast,
		s_axis_sig_tid => loop_sig_tid,
		s_axis_sig_tdest => loop_sig_tdest,
		s_axis_sig_tuser => loop_sig_tuser,

		m_axis_hdr_tvalid => s_axis_hdr_tvalid,
		m_axis_hdr_tready => s_axis_hdr_tready,
		m_axis_hdr_tdata => s_axis_hdr_tdata,
		m_axis_hdr_tlast => s_axis_hdr_tlast
	);

end behavioral;
