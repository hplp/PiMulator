----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2017 12:57:00 PM
-- Design Name: 
-- Module Name: axis_probe_tb - behavioral
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

library axis_probe_lib;
use axis_probe_lib.axis_probe;

entity axis_probe_tb is
end axis_probe_tb;

architecture behavioral of axis_probe_tb is

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

	-- return the log base 2 of the argument x rounded to plus infinity
	function log2rp (x : natural) return natural is
		variable i : natural;
	begin
		i := 0;
		while (x > 2**i) loop
			i := i + 1;
		end loop;
		return i;
	end log2rp;

	function to_slv (arg, size : natural) return std_logic_vector is
		variable result: std_logic_vector(size-1 downto 0);
		variable tmp: natural := arg;
	begin
		for i in 0 to result'left loop
			if (tmp mod 2) = 0 then result(i) := '0';
			else result(i) := '1';
			end if;
			tmp := tmp/2;
		end loop;
		if not(tmp = 0) then
			assert (false)
				report "to_slv: vector truncated"
				severity warning;
		end if;
		return result;
	end to_slv;

	function to_slv (s : string; size: natural) return std_logic_vector is
		variable result: std_logic_vector(size-1 downto 0);
	begin
		result := (others => '0');
		for i in s'range loop
			if (i*8-1 < size) then
				result(i*8-1 downto (i-1)*8) := to_slv(character'pos(s(i)), 8);
			else
				assert (false)
					report "to_slv: vector truncated"
					severity warning;
				return result;
			end if;
		end loop;
		return result;
	end to_slv;

-- #################### --

constant C_CTL_IS_ASYNC      : integer range 0 to 1 := 0;
constant C_FAMILY            : string := "zynq";

	-- Stream Control
constant C_AXIS_CTL_TDATA_WIDTH : integer range 8 to 1024 := 32;
constant C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
constant C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
constant C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	-- Stream Data
constant C_AXIS_DAT_TDATA_WIDTH : integer range 8 to 1024 := 64;
constant C_AXIS_DAT_TID_WIDTH   : integer range 2 to 8 := 4;
constant C_AXIS_DAT_TDEST_WIDTH : integer range 2 to 8 := 4;

	-- associated with control streams
alias  ctl_aclk    : std_logic is clock;
signal ctl_aresetn : std_logic;

	-- associated with data streams and master AXI
alias  data_aclk    : std_logic is clock;
signal data_aresetn : std_logic;

	------------------
	-- Control Port --
	------------------

	-- Stream Control In
signal s_axis_ctl_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal s_axis_ctl_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal s_axis_ctl_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal s_axis_ctl_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal s_axis_ctl_tlast  : std_logic;
signal s_axis_ctl_tvalid : std_logic;
signal s_axis_ctl_tready : std_logic;

	-- Stream Control Out
signal m_axis_ctl_tdata  : std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
signal m_axis_ctl_tid    : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
signal m_axis_ctl_tdest  : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
signal m_axis_ctl_tuser  : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
signal m_axis_ctl_tlast  : std_logic;
signal m_axis_ctl_tvalid : std_logic;
signal m_axis_ctl_tready : std_logic;

	-----------------
	-- Data Port 1 --
	-----------------

	-- Stream Data In
signal s_axis_dat1_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
signal s_axis_dat1_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
signal s_axis_dat1_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
signal s_axis_dat1_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
signal s_axis_dat1_tlast  : std_logic;
signal s_axis_dat1_tvalid : std_logic;
signal s_axis_dat1_tready : std_logic;

	-- Stream Data Out
signal m_axis_dat1_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
signal m_axis_dat1_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
signal m_axis_dat1_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
signal m_axis_dat1_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
signal m_axis_dat1_tlast  : std_logic;
signal m_axis_dat1_tvalid : std_logic;
signal m_axis_dat1_tready : std_logic;

	-----------------
	-- Data Port 2 --
	-----------------

	-- Stream Data In
signal s_axis_dat2_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
signal s_axis_dat2_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
signal s_axis_dat2_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
signal s_axis_dat2_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
signal s_axis_dat2_tlast  : std_logic;
signal s_axis_dat2_tvalid : std_logic;
signal s_axis_dat2_tready : std_logic;

	-- Stream Data Out
signal m_axis_dat2_tdata  : std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
signal m_axis_dat2_tid    : std_logic_vector(C_AXIS_DAT_TID_WIDTH-1 downto 0);
signal m_axis_dat2_tdest  : std_logic_vector(C_AXIS_DAT_TDEST_WIDTH-1 downto 0);
signal m_axis_dat2_tkeep  : std_logic_vector((C_AXIS_DAT_TDATA_WIDTH/8)-1 downto 0);
signal m_axis_dat2_tlast  : std_logic;
signal m_axis_dat2_tvalid : std_logic;
signal m_axis_dat2_tready : std_logic;

-- Support
signal init_done : std_logic;
signal rsp_cnt : integer;

procedure send_probe (
	signal tdata : out std_logic_vector;
	constant key : in string;
	constant idx : in natural
) is
begin
	for i in 0 to 15 loop
		if (i = idx) then
			tdata <= to_slv(key, tdata'length); -- slot to be found
			wait_sig(data_aclk, s_axis_dat2_tready, '1');
			tdata <= to_slv(1, 32) & to_slv(16#20000000# + i, 32); -- used
			wait_sig(data_aclk, s_axis_dat2_tready, '1');
		else
			tdata <= to_slv(i+1, tdata'length); -- made-up key not to be found
			wait_sig(data_aclk, s_axis_dat2_tready, '1');
			if (i mod 2 = 0) then
				tdata <= to_slv(1, 32) & to_slv(16#20000000# + i, 32); -- used
			else
				tdata <= to_slv(0, 32) & to_slv(16#20000000# + i, 32); -- not used
			end if;
			wait_sig(data_aclk, s_axis_dat2_tready, '1');
		end if;
	end loop;
end send_probe;

procedure check_axis (
	constant tdata : in std_logic_vector;
	constant tid : in std_logic_vector;
	constant tdest : in std_logic_vector
) is
begin
	wait until (rising_edge(data_aclk) and m_axis_dat1_tvalid = '1' and m_axis_dat1_tlast = '1');
	assert (m_axis_dat1_tdata = tdata) report "error." severity FAILURE;
	assert (m_axis_dat1_tid = tid) report "error." severity FAILURE;
	assert (m_axis_dat1_tdest = tdest) report "error." severity FAILURE;
	wait for hold;
end check_axis;

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

--	ctl_aclk <= clock; -- declared as alias
--	data_aclk <= clock; -- declared as alias

	ctl_aresetn <= not reset;
	data_aresetn <= not reset;

	control_rsp: process
	begin
		m_axis_ctl_tready <= '0';
		wait_sig(ctl_aclk, ctl_aresetn, '1');
		wait_sig(ctl_aclk, m_axis_ctl_tvalid, '1');
		wait_cycles(ctl_aclk, 1);
		m_axis_ctl_tready <= '1';

		wait; -- will wait forever
	end process;

	control_cmd: process
	begin
		init_done <= '0';
		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';
		wait_sig(ctl_aclk, ctl_aresetn, '1');

		-- ########## Setup ########## --
		s_axis_ctl_tid   <= X"1"; -- source id
		s_axis_ctl_tdest <= X"6"; -- destination id
		s_axis_ctl_tuser <= '0' & '1' & "000" & "010"; -- go, wr, reg, len
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '1';
		s_axis_ctl_tdata <= X"00000000"; -- clear status
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');
		s_axis_ctl_tlast <= '1';
		s_axis_ctl_tdata <= X"0000000F"; -- plen=16 (minus 1)
		wait_sig(ctl_aclk, s_axis_ctl_tready, '1');

		s_axis_ctl_tdata <= (others => '0');
		s_axis_ctl_tid <= (others => '0');
		s_axis_ctl_tdest <= (others => '0');
		s_axis_ctl_tuser <= (others => '0');
		s_axis_ctl_tlast <= '0';
		s_axis_ctl_tvalid <= '0';

		init_done <= '1';

		wait; -- will wait forever
	end process;

	data1_prod: process
	begin
		s_axis_dat1_tdata <= (others => '0');
		s_axis_dat1_tid <= (others => '0');
		s_axis_dat1_tdest <= (others => '0');
		s_axis_dat1_tkeep <= (others => '0');
		s_axis_dat1_tlast <= '0';
		s_axis_dat1_tvalid <= '0';
		wait_sig(data_aclk, data_aresetn, '1');
		wait_sig(data_aclk, init_done, '1');

		s_axis_dat1_tid   <= X"1"; -- source id
		s_axis_dat1_tdest <= X"2"; -- destination id
		s_axis_dat1_tkeep <= (others => '1');
		s_axis_dat1_tlast <= '1';
		s_axis_dat1_tvalid <= '1';

		s_axis_dat1_tdata <= to_slv("5B_01", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
		s_axis_dat1_tdata <= to_slv("5B_02", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
		s_axis_dat1_tdata <= to_slv("5B_03", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
		s_axis_dat1_tdata <= to_slv("5B_04", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
		s_axis_dat1_tdata <= to_slv("5B_05", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
		s_axis_dat1_tdata <= to_slv("5B_06", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
			s_axis_dat1_tvalid <= '0'; -- test idle
			wait_cycles(data_aclk, 33);
			s_axis_dat1_tvalid <= '1';
		s_axis_dat1_tdata <= to_slv("5B_07", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');
		s_axis_dat1_tdata <= to_slv("5B_08", s_axis_dat1_tdata'length);
		wait_sig(data_aclk, s_axis_dat1_tready, '1');

		s_axis_dat1_tdata <= (others => '0');
		s_axis_dat1_tid <= (others => '0');
		s_axis_dat1_tdest <= (others => '0');
		s_axis_dat1_tkeep <= (others => '0');
		s_axis_dat1_tlast <= '0';
		s_axis_dat1_tvalid <= '0';

		wait; -- will wait forever
	end process;

	data1_cons: process
	begin
		m_axis_dat1_tready <= '0';
		wait_sig(data_aclk, data_aresetn, '1');
		m_axis_dat1_tready <= '1';

		check_axis(X"0000000020000000", X"0", X"0");
		check_axis(X"0000000020000004", X"0", X"0");
			m_axis_dat1_tready <= '0'; -- test back pressure
			wait_cycles(data_aclk, 55);
			m_axis_dat1_tready <= '1';
		check_axis(X"000000002000000F", X"0", X"0");
		check_axis(X"0000000020000007", X"0", X"0");
		check_axis(X"000000002000000B", X"0", X"0");
		check_axis(X"0000000000000000", X"0", X"0");
		check_axis(X"0000000020000003", X"0", X"0");
		check_axis(X"0000000020000002", X"0", X"0");

		wait_cycles(data_aclk, 32);

		-- ########## Done ########## --
		assert (FALSE) report "done." severity FAILURE;
		wait; -- will wait forever
	end process;

	data2_prod: process
	begin
		s_axis_dat2_tdata <= (others => '0');
		s_axis_dat2_tid <= (others => '0');
		s_axis_dat2_tdest <= (others => '0');
		s_axis_dat2_tkeep <= (others => '0');
		s_axis_dat2_tlast <= '0';
		s_axis_dat2_tvalid <= '0';
		wait_sig(data_aclk, data_aresetn, '1');
		wait_sig(data_aclk, init_done, '1');

		s_axis_dat2_tid   <= X"3"; -- source id
		s_axis_dat2_tdest <= X"4"; -- destination id
		s_axis_dat2_tkeep <= (others => '1');
		s_axis_dat2_tlast <= '1';
		s_axis_dat2_tvalid <= '1';

		send_probe(s_axis_dat2_tdata, "5B_01",  0);
		send_probe(s_axis_dat2_tdata, "5B_02",  4);
		send_probe(s_axis_dat2_tdata, "5B_03", 15);
		send_probe(s_axis_dat2_tdata, "5B_04",  7);
			s_axis_dat2_tvalid <= '0'; -- test idle
			wait_cycles(data_aclk, 4);
			s_axis_dat2_tvalid <= '1';
		send_probe(s_axis_dat2_tdata, "5B_05", 11);
		send_probe(s_axis_dat2_tdata, "5B_0A",  1);
		send_probe(s_axis_dat2_tdata, "5B_07",  3);
		send_probe(s_axis_dat2_tdata, "5B_08",  2);

		s_axis_dat2_tdata <= (others => '0');
		s_axis_dat2_tid <= (others => '0');
		s_axis_dat2_tdest <= (others => '0');
		s_axis_dat2_tkeep <= (others => '0');
		s_axis_dat2_tlast <= '0';
		s_axis_dat2_tvalid <= '0';

		wait; -- will wait forever
	end process;

	data2_cons: process
	begin
		m_axis_dat2_tready <= '0';
		wait_sig(data_aclk, data_aresetn, '1');
		m_axis_dat2_tready <= '1';

		wait; -- will wait forever
	end process;

	-- #################### --

	uut: entity axis_probe
	generic map (

	C_CTL_IS_ASYNC         => C_CTL_IS_ASYNC,
	C_FAMILY               => C_FAMILY,

	C_AXIS_CTL_TDATA_WIDTH => C_AXIS_CTL_TDATA_WIDTH,
	C_AXIS_CTL_TID_WIDTH   => C_AXIS_CTL_TID_WIDTH,
	C_AXIS_CTL_TDEST_WIDTH => C_AXIS_CTL_TDEST_WIDTH,
	C_AXIS_CTL_TUSER_WIDTH => C_AXIS_CTL_TUSER_WIDTH,

	C_AXIS_DAT_TDATA_WIDTH => C_AXIS_DAT_TDATA_WIDTH,
	C_AXIS_DAT_TID_WIDTH   => C_AXIS_DAT_TID_WIDTH,
	C_AXIS_DAT_TDEST_WIDTH => C_AXIS_DAT_TDEST_WIDTH

	)
	port map (

	ctl_aclk    => ctl_aclk,
	ctl_aresetn => ctl_aresetn,

	data_aclk    => data_aclk,
	data_aresetn => data_aresetn,

	-- Control Interface
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

	-- Data Interface 1
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

	-- Data Interface 2
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

end behavioral;
