----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2014 11:04:00 AM
-- Design Name: 
-- Module Name: axi_delay_tb - behavioral
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

library axi_delay_lib;
use axi_delay_lib.axi_delay_pkg.all;
use axi_delay_lib.axi_delay;

entity axi_delay_tb is
end axi_delay_tb;

architecture behavioral of axi_delay_tb is

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

	function resize (arg: std_logic_vector; new_size: natural) return std_logic_vector is
		constant nau: std_logic_vector(0 downto 1) := (others => '0');
		constant arg_left: integer := arg'length-1;
		alias xarg: std_logic_vector(arg_left downto 0) is arg;
		variable result: std_logic_vector(new_size-1 downto 0) := (others => '0');
	begin
		if (new_size < 1) then return nau; end if;
		if (xarg'length = 0) then return result; end if;
		if (result'length < arg'length) then
			result(result'left downto 0) := xarg(result'left downto 0);
		else
			result(result'left downto xarg'left+1) := (others => '0');
			result(xarg'left downto 0) := xarg;
		end if;
		return result;
	end resize;

-- #################### --

constant C_BASE_ADDR : integer := 16#40000100#;

constant C_FAMILY         : string  := "zynq";
constant C_AXI_PROTOCOL   : integer := P_AXI4; -- 0:AXI4 1:AXI3 2:AXILITE
constant C_MEM_ADDR_WIDTH : integer := 12;
constant C_COUNTER_WIDTH  : integer := 6;
constant C_FIFO_DEPTH_AW  : integer := 4*8;    -- 4 engines * 8 requests
constant C_FIFO_DEPTH_W   : integer := 4*8*16; -- 4 engines * 8 requests * 16 data beats
constant C_FIFO_DEPTH_B   : integer := 4*8;    -- 4 engines * 8 requests
constant C_FIFO_DEPTH_AR  : integer := 4*8;    -- 4 engines * 8 requests
constant C_FIFO_DEPTH_R   : integer := 4*8*16; -- 4 engines * 8 requests * 16 data beats

-- AXI-Lite Bus Interface
constant C_AXI_LITE_ADDR_WIDTH : integer := 6;
constant C_AXI_LITE_DATA_WIDTH : integer := 32;

-- AXI-Full Bus Interface
constant C_AXI_ID_WIDTH     : integer := 1;
constant C_AXI_ADDR_WIDTH   : integer := 32;
constant C_AXI_DATA_WIDTH   : integer := 64;
-- constant C_AXI_AWUSER_WIDTH : integer := 0; -- AXI4
-- constant C_AXI_ARUSER_WIDTH : integer := 0; -- AXI4
-- constant C_AXI_WUSER_WIDTH  : integer := 0; -- AXI4
-- constant C_AXI_RUSER_WIDTH  : integer := 0; -- AXI4
-- constant C_AXI_BUSER_WIDTH  : integer := 0; -- AXI4

-- AXI-Lite Slave Bus Interface S_AXI
alias  s_axi_lite_aclk    : std_logic is clock;
signal s_axi_lite_aresetn : std_logic;
--
signal s_axi_lite_awaddr  : std_logic_vector(C_AXI_LITE_ADDR_WIDTH-1 downto 0);
signal s_axi_lite_awprot  : std_logic_vector(2 downto 0);
signal s_axi_lite_awvalid : std_logic;
signal s_axi_lite_awready : std_logic;
--
signal s_axi_lite_wdata   : std_logic_vector(C_AXI_LITE_DATA_WIDTH-1 downto 0);
signal s_axi_lite_wstrb   : std_logic_vector((C_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
signal s_axi_lite_wvalid  : std_logic;
signal s_axi_lite_wready  : std_logic;
--
signal s_axi_lite_bresp   : std_logic_vector(1 downto 0);
signal s_axi_lite_bvalid  : std_logic;
signal s_axi_lite_bready  : std_logic;
--
signal s_axi_lite_araddr  : std_logic_vector(C_AXI_LITE_ADDR_WIDTH-1 downto 0);
signal s_axi_lite_arprot  : std_logic_vector(2 downto 0);
signal s_axi_lite_arvalid : std_logic;
signal s_axi_lite_arready : std_logic;
--
signal s_axi_lite_rdata   : std_logic_vector(C_AXI_LITE_DATA_WIDTH-1 downto 0);
signal s_axi_lite_rresp   : std_logic_vector(1 downto 0);
signal s_axi_lite_rvalid  : std_logic;
signal s_axi_lite_rready  : std_logic;

-- AXI-Full Slave Bus Interface S_AXI
alias  s_axi_aclk     : std_logic is clock;
signal s_axi_aresetn  : std_logic;
--
signal s_axi_awid     : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_awaddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal s_axi_awlen    : std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
signal s_axi_awsize   : std_logic_vector(2 downto 0);
signal s_axi_awburst  : std_logic_vector(1 downto 0);
signal s_axi_awlock   : std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
signal s_axi_awcache  : std_logic_vector(3 downto 0);
signal s_axi_awprot   : std_logic_vector(2 downto 0);
signal s_axi_awqos    : std_logic_vector(3 downto 0); -- AXI4
signal s_axi_awregion : std_logic_vector(3 downto 0); -- AXI4
-- signal s_axi_awuser   : std_logic_vector(C_AXI_AWUSER_WIDTH-1 downto 0); -- AXI4
signal s_axi_awvalid  : std_logic;
signal s_axi_awready  : std_logic;
--
signal s_axi_wid      : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0); -- AXI3
signal s_axi_wdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal s_axi_wstrb    : std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);
signal s_axi_wlast    : std_logic;
-- signal s_axi_wuser    : std_logic_vector(C_AXI_WUSER_WIDTH-1 downto 0); -- AXI4
signal s_axi_wvalid   : std_logic;
signal s_axi_wready   : std_logic;
--
signal s_axi_bid      : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_bresp    : std_logic_vector(1 downto 0);
-- signal s_axi_buser    : std_logic_vector(C_AXI_BUSER_WIDTH-1 downto 0); -- AXI4
signal s_axi_bvalid   : std_logic;
signal s_axi_bready   : std_logic;
--
signal s_axi_arid     : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_araddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal s_axi_arlen    : std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
signal s_axi_arsize   : std_logic_vector(2 downto 0);
signal s_axi_arburst  : std_logic_vector(1 downto 0);
signal s_axi_arlock   : std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
signal s_axi_arcache  : std_logic_vector(3 downto 0);
signal s_axi_arprot   : std_logic_vector(2 downto 0);
signal s_axi_arqos    : std_logic_vector(3 downto 0); -- AXI4
signal s_axi_arregion : std_logic_vector(3 downto 0); -- AXI4
-- signal s_axi_aruser   : std_logic_vector(C_AXI_ARUSER_WIDTH-1 downto 0); -- AXI4
signal s_axi_arvalid  : std_logic;
signal s_axi_arready  : std_logic;
--
signal s_axi_rid      : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_rdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal s_axi_rresp    : std_logic_vector(1 downto 0);
signal s_axi_rlast    : std_logic;
-- signal s_axi_ruser    : std_logic_vector(C_AXI_RUSER_WIDTH-1 downto 0); -- AXI4
signal s_axi_rvalid   : std_logic;
signal s_axi_rready   : std_logic;

-- AXI-Full Master Bus Interface M_AXI
alias  m_axi_aclk     : std_logic is clock;
signal m_axi_aresetn  : std_logic;
--
signal m_axi_awid     : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal m_axi_awaddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal m_axi_awlen    : std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
signal m_axi_awsize   : std_logic_vector(2 downto 0);
signal m_axi_awburst  : std_logic_vector(1 downto 0);
signal m_axi_awlock   : std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
signal m_axi_awcache  : std_logic_vector(3 downto 0);
signal m_axi_awprot   : std_logic_vector(2 downto 0);
signal m_axi_awqos    : std_logic_vector(3 downto 0); -- AXI4
signal m_axi_awregion : std_logic_vector(3 downto 0); -- AXI4
-- signal m_axi_awuser   : std_logic_vector(C_AXI_AWUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_awvalid  : std_logic;
signal m_axi_awready  : std_logic;
--
signal m_axi_wid      : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0); -- AXI3
signal m_axi_wdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal m_axi_wstrb    : std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);
signal m_axi_wlast    : std_logic;
-- signal m_axi_wuser    : std_logic_vector(C_AXI_WUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_wvalid   : std_logic;
signal m_axi_wready   : std_logic;
--
signal m_axi_bid      : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal m_axi_bresp    : std_logic_vector(1 downto 0);
-- signal m_axi_buser    : std_logic_vector(C_AXI_BUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_bvalid   : std_logic;
signal m_axi_bready   : std_logic;
--
signal m_axi_arid     : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal m_axi_araddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal m_axi_arlen    : std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
signal m_axi_arsize   : std_logic_vector(2 downto 0);
signal m_axi_arburst  : std_logic_vector(1 downto 0);
signal m_axi_arlock   : std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
signal m_axi_arcache  : std_logic_vector(3 downto 0);
signal m_axi_arprot   : std_logic_vector(2 downto 0);
signal m_axi_arqos    : std_logic_vector(3 downto 0); -- AXI4
signal m_axi_arregion : std_logic_vector(3 downto 0); -- AXI4
-- signal m_axi_aruser   : std_logic_vector(C_AXI_ARUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_arvalid  : std_logic;
signal m_axi_arready  : std_logic;
--
signal m_axi_rid      : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal m_axi_rdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal m_axi_rresp    : std_logic_vector(1 downto 0);
signal m_axi_rlast    : std_logic;
-- signal m_axi_ruser    : std_logic_vector(C_AXI_RUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_rvalid   : std_logic;
signal m_axi_rready   : std_logic;

signal ctl_write_done : std_logic;
signal main_write_done : std_logic;

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
--	s_axi_lite_aclk <= clock;
--	s_axi_aclk <= clock;
--	m_axi_aclk <= clock;

	s_axi_lite_aresetn <= not reset;
	s_axi_aresetn <= not reset;
	m_axi_aresetn <= not reset;

	ctl_wa: process
	begin
		s_axi_lite_awaddr <= (others => '0');
		s_axi_lite_awprot <= (others => '0');
		s_axi_lite_awvalid <= '0';
		wait_sig(s_axi_lite_aclk, s_axi_lite_aresetn, '1');

		s_axi_lite_awprot <= "010"; -- Data, Non-secure, Unprivileged access
		s_axi_lite_awvalid <= '1';

		s_axi_lite_awaddr <= std_logic_vector(to_unsigned(16#00#, s_axi_lite_awaddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_awready, '1');
		s_axi_lite_awaddr <= std_logic_vector(to_unsigned(16#04#, s_axi_lite_awaddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_awready, '1');
		s_axi_lite_awaddr <= std_logic_vector(to_unsigned(16#08#, s_axi_lite_awaddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_awready, '1');
		s_axi_lite_awaddr <= std_logic_vector(to_unsigned(16#0C#, s_axi_lite_awaddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_awready, '1');
		s_axi_lite_awaddr <= std_logic_vector(to_unsigned(16#10#, s_axi_lite_awaddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_awready, '1');

		s_axi_lite_awaddr <= (others => '0');
		s_axi_lite_awprot <= (others => '0');
		s_axi_lite_awvalid <= '0';
		wait;
	end process;

	ctl_w: process
	begin
		s_axi_lite_wdata <= (others => '0');
		s_axi_lite_wstrb <= (others => '0');
		s_axi_lite_wvalid <= '0';
		wait_sig(s_axi_lite_aclk, s_axi_lite_aresetn, '1');

		s_axi_lite_wstrb <= (others => '1');
		s_axi_lite_wvalid <= '1';

		s_axi_lite_wdata <= std_logic_vector(to_unsigned(3, s_axi_lite_wdata'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_wready, '1');
		s_axi_lite_wdata <= std_logic_vector(to_unsigned(3, s_axi_lite_wdata'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_wready, '1');
		s_axi_lite_wdata <= std_logic_vector(to_unsigned(5, s_axi_lite_wdata'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_wready, '1');
		s_axi_lite_wdata <= std_logic_vector(to_unsigned(7, s_axi_lite_wdata'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_wready, '1');
		s_axi_lite_wdata <= std_logic_vector(to_unsigned(9, s_axi_lite_wdata'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_wready, '1');

		s_axi_lite_wdata <= (others => '0');
		s_axi_lite_wstrb <= (others => '0');
		s_axi_lite_wvalid <= '0';
		wait;
	end process;

	ctl_b: process
	begin
		ctl_write_done <= '0';
		s_axi_lite_bready <= '0';
		wait_sig(s_axi_lite_aclk, s_axi_lite_aresetn, '1');

		s_axi_lite_bready <= '1';
		for i in 1 to 5 loop
			wait_sig(s_axi_lite_aclk, s_axi_lite_bvalid, '1');
		end loop;

		s_axi_lite_bready <= '0';
		ctl_write_done <= '1';
		wait;
	end process;

	ctl_ra: process
	begin
		s_axi_lite_araddr <= (others => '0');
		s_axi_lite_arprot <= (others => '0');
		s_axi_lite_arvalid <= '0';
		wait_sig(s_axi_lite_aclk, s_axi_lite_aresetn, '1');
		wait_sig(s_axi_lite_aclk, ctl_write_done, '1');

		s_axi_lite_arprot <= "010"; -- Data, Non-secure, Unprivileged access
		s_axi_lite_arvalid <= '1';

		s_axi_lite_araddr <= std_logic_vector(to_unsigned(16#00#, s_axi_lite_araddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_arready, '1');
		s_axi_lite_araddr <= std_logic_vector(to_unsigned(16#04#, s_axi_lite_araddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_arready, '1');
		s_axi_lite_araddr <= std_logic_vector(to_unsigned(16#08#, s_axi_lite_araddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_arready, '1');
		s_axi_lite_araddr <= std_logic_vector(to_unsigned(16#0C#, s_axi_lite_araddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_arready, '1');
		s_axi_lite_araddr <= std_logic_vector(to_unsigned(16#10#, s_axi_lite_araddr'length));
		wait_sig(s_axi_lite_aclk, s_axi_lite_arready, '1');

		s_axi_lite_araddr <= (others => '0');
		s_axi_lite_arprot <= (others => '0');
		s_axi_lite_arvalid <= '0';
		wait;
	end process;

	ctl_r: process
	begin
		s_axi_lite_rready <= '0';
		wait_sig(s_axi_lite_aclk, s_axi_lite_aresetn, '1');

		s_axi_lite_rready <= '1';
		for i in 1 to 5 loop
			wait_sig(s_axi_lite_aclk, s_axi_lite_rvalid, '1');
		end loop;

		s_axi_lite_rready <= '0';
		wait;
	end process;

	main_wa: process
	begin
		s_axi_awid     <= (others => '0');
		s_axi_awaddr   <= (others => '0');
		s_axi_awlen    <= (others => '0');
		s_axi_awsize   <= (others => '0');
		s_axi_awburst  <= (others => '0');
		s_axi_awlock   <= (others => '0');
		s_axi_awcache  <= (others => '0');
		s_axi_awprot   <= (others => '0');
		s_axi_awqos    <= (others => '0');
		s_axi_awregion <= (others => '0');
--		s_axi_awuser   <= (others => '0');
		s_axi_awvalid  <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');
		wait_sig(s_axi_aclk, ctl_write_done, '1');

		s_axi_awlen    <= std_logic_vector(to_unsigned(ite(C_AXI_PROTOCOL /= P_AXILITE,4,1), s_axi_awlen'length) - 1);
		s_axi_awsize   <= std_logic_vector(to_unsigned(log2rp(C_AXI_DATA_WIDTH/8), s_axi_awsize'length));
		s_axi_awburst  <= "01"; -- Incrementing
		s_axi_awcache  <= "0011"; -- Normal Non-cacheable Bufferable
		s_axi_awprot   <= "010"; -- Data, Non-secure, Unprivileged access

		s_axi_awvalid  <= '1';
		s_axi_awaddr <= std_logic_vector(to_unsigned(C_BASE_ADDR-16#20#, s_axi_awaddr'length));
		wait_sig(s_axi_aclk, s_axi_awready, '1');
		s_axi_awvalid  <= '0';

		wait_cycles(s_axi_aclk, 2);

		s_axi_awvalid  <= '1';
		s_axi_awaddr <= std_logic_vector(to_unsigned(C_BASE_ADDR+16#00#, s_axi_awaddr'length));
		wait_sig(s_axi_aclk, s_axi_awready, '1');
		s_axi_awvalid  <= '0';

		wait until (rising_edge(clock) and count = 2**C_COUNTER_WIDTH-6);
		wait for hold;

		s_axi_awvalid  <= '1';
		s_axi_awaddr <= std_logic_vector(to_unsigned(C_BASE_ADDR+16#20#, s_axi_awaddr'length));
		wait_sig(s_axi_aclk, s_axi_awready, '1');
		s_axi_awvalid  <= '0';

		wait_cycles(s_axi_aclk, 1);

		s_axi_awvalid  <= '1';
		s_axi_awaddr <= std_logic_vector(to_unsigned(C_BASE_ADDR-16#40#, s_axi_awaddr'length));
		wait_sig(s_axi_aclk, s_axi_awready, '1');
		s_axi_awvalid  <= '0';

		s_axi_awaddr   <= (others => '0');
		s_axi_awlen    <= (others => '0');
		s_axi_awsize   <= (others => '0');
		s_axi_awburst  <= (others => '0');
		s_axi_awcache  <= (others => '0');
		s_axi_awprot   <= (others => '0');
		wait;
	end process;

	main_w: process
	begin
		s_axi_wid    <= (others => '0');
		s_axi_wdata  <= (others => '0');
		s_axi_wstrb  <= (others => '0');
		s_axi_wlast  <= '0';
--		s_axi_wuser  <= (others => '0');
		s_axi_wvalid <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');
		wait_sig(s_axi_aclk, ctl_write_done, '1');

		s_axi_wstrb <= (others => '1');
		s_axi_wvalid <= '1';

		for i in 1 to 4 loop
			if (C_AXI_PROTOCOL /= P_AXILITE) then
				s_axi_wdata <= std_logic_vector(to_unsigned(i, s_axi_wdata'length));
				wait_sig(s_axi_aclk, s_axi_wready, '1');
				s_axi_wdata <= std_logic_vector(to_unsigned(i, s_axi_wdata'length));
				wait_sig(s_axi_aclk, s_axi_wready, '1');
				s_axi_wdata <= std_logic_vector(to_unsigned(i, s_axi_wdata'length));
				wait_sig(s_axi_aclk, s_axi_wready, '1');
			end if;
			s_axi_wlast  <= '1';
			s_axi_wdata <= std_logic_vector(to_unsigned(i, s_axi_wdata'length));
			wait_sig(s_axi_aclk, s_axi_wready, '1');
			s_axi_wlast  <= '0';
		end loop;

		s_axi_wdata <= (others => '0');
		s_axi_wstrb <= (others => '0');
		s_axi_wvalid <= '0';
		wait;
	end process;

	main_b: process
	begin
		main_write_done <= '0';
		s_axi_bready <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');

		s_axi_bready <= '1';
		for i in 1 to 4 loop
			wait_sig(s_axi_aclk, s_axi_bvalid, '1');
		end loop;

		s_axi_bready <= '0';
		main_write_done <= '1';
		wait;
	end process;

	main_ra: process
	begin
		s_axi_arid     <= (others => '0');
		s_axi_araddr   <= (others => '0');
		s_axi_arlen    <= (others => '0');
		s_axi_arsize   <= (others => '0');
		s_axi_arburst  <= (others => '0');
		s_axi_arlock   <= (others => '0');
		s_axi_arcache  <= (others => '0');
		s_axi_arprot   <= (others => '0');
		s_axi_arqos    <= (others => '0');
		s_axi_arregion <= (others => '0');
--		s_axi_aruser   <= (others => '0');
		s_axi_arvalid  <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');
		wait_sig(s_axi_aclk, main_write_done, '1');

		s_axi_arlen    <= std_logic_vector(to_unsigned(ite(C_AXI_PROTOCOL /= P_AXILITE,4,1), s_axi_arlen'length) - 1);
		s_axi_arsize   <= std_logic_vector(to_unsigned(log2rp(C_AXI_DATA_WIDTH/8), s_axi_arsize'length));
		s_axi_arburst  <= "01"; -- Incrementing
		s_axi_arcache  <= "0011"; -- Normal Non-cacheable Bufferable
		s_axi_arprot   <= "010"; -- Data, Non-secure, Unprivileged access

		s_axi_arvalid  <= '1';
		s_axi_araddr <= std_logic_vector(to_unsigned(C_BASE_ADDR-16#20#, s_axi_araddr'length));
		wait_sig(s_axi_aclk, s_axi_arready, '1');
		s_axi_arvalid  <= '0';

		wait_cycles(s_axi_aclk, 2);

		s_axi_arvalid  <= '1';
		s_axi_araddr <= std_logic_vector(to_unsigned(C_BASE_ADDR+16#00#, s_axi_araddr'length));
		wait_sig(s_axi_aclk, s_axi_arready, '1');
		s_axi_arvalid  <= '0';

		wait_cycles(s_axi_aclk, 2);

		s_axi_arvalid  <= '1';
		s_axi_araddr <= std_logic_vector(to_unsigned(C_BASE_ADDR+16#20#, s_axi_araddr'length));
		wait_sig(s_axi_aclk, s_axi_arready, '1');
		s_axi_arvalid  <= '0';

		wait_cycles(s_axi_aclk, 2);

		s_axi_arvalid  <= '1';
		s_axi_araddr <= std_logic_vector(to_unsigned(C_BASE_ADDR-16#40#, s_axi_araddr'length));
		wait_sig(s_axi_aclk, s_axi_arready, '1');
		s_axi_arvalid  <= '0';

		s_axi_araddr   <= (others => '0');
		s_axi_arlen    <= (others => '0');
		s_axi_arsize   <= (others => '0');
		s_axi_arburst  <= (others => '0');
		s_axi_arcache  <= (others => '0');
		s_axi_arprot   <= (others => '0');
		wait;
	end process;

	main_r: process
	begin
		s_axi_rready <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');

		s_axi_rready <= '1';
		for i in 1 to 4 loop
			if (C_AXI_PROTOCOL /= P_AXILITE) then
				wait_sig(s_axi_aclk, s_axi_rvalid, '1');
				wait_sig(s_axi_aclk, s_axi_rvalid, '1');
				wait_sig(s_axi_aclk, s_axi_rvalid, '1');
			end if;
			wait_sig(s_axi_aclk, s_axi_rvalid, '1');
		end loop;

		s_axi_rready <= '0';
		-- ########## Done ########## --
		wait_cycles(s_axi_aclk, 10);
		assert (FALSE) report "done." severity FAILURE;
		wait;
	end process;

	-- #################### --

	uut: entity axi_delay
	generic map (
	C_FAMILY         => C_FAMILY,
	C_AXI_PROTOCOL   => C_AXI_PROTOCOL,
	C_MEM_ADDR_WIDTH => C_MEM_ADDR_WIDTH,
	C_COUNTER_WIDTH  => C_COUNTER_WIDTH,
	C_FIFO_DEPTH_AW  => C_FIFO_DEPTH_AW,
	C_FIFO_DEPTH_W   => C_FIFO_DEPTH_W,
	C_FIFO_DEPTH_B   => C_FIFO_DEPTH_B,
	C_FIFO_DEPTH_AR  => C_FIFO_DEPTH_AR,
	C_FIFO_DEPTH_R   => C_FIFO_DEPTH_R,

	-- AXI-Lite Bus Interface S_AXI_LITE
	C_AXI_LITE_ADDR_WIDTH => C_AXI_LITE_ADDR_WIDTH,
	C_AXI_LITE_DATA_WIDTH => C_AXI_LITE_DATA_WIDTH,

	-- AXI-Full Bus Interface
	C_AXI_ID_WIDTH     => C_AXI_ID_WIDTH,
	C_AXI_ADDR_WIDTH   => C_AXI_ADDR_WIDTH,
	C_AXI_DATA_WIDTH   => C_AXI_DATA_WIDTH
--	C_AXI_AWUSER_WIDTH => C_AXI_AWUSER_WIDTH,
--	C_AXI_ARUSER_WIDTH => C_AXI_ARUSER_WIDTH,
--	C_AXI_WUSER_WIDTH  => C_AXI_WUSER_WIDTH,
--	C_AXI_RUSER_WIDTH  => C_AXI_RUSER_WIDTH,
--	C_AXI_BUSER_WIDTH  => C_AXI_BUSER_WIDTH
	)
	port map (
	-- AXI-Lite Slave Bus Interface S_AXI_LITE
	s_axi_lite_aclk    => s_axi_lite_aclk,
	s_axi_lite_aresetn => s_axi_lite_aresetn,
	--
	s_axi_lite_awaddr  => s_axi_lite_awaddr,
	s_axi_lite_awprot  => s_axi_lite_awprot,
	s_axi_lite_awvalid => s_axi_lite_awvalid,
	s_axi_lite_awready => s_axi_lite_awready,
	--
	s_axi_lite_wdata   => s_axi_lite_wdata,
	s_axi_lite_wstrb   => s_axi_lite_wstrb,
	s_axi_lite_wvalid  => s_axi_lite_wvalid,
	s_axi_lite_wready  => s_axi_lite_wready,
	--
	s_axi_lite_bresp   => s_axi_lite_bresp,
	s_axi_lite_bvalid  => s_axi_lite_bvalid,
	s_axi_lite_bready  => s_axi_lite_bready,
	--
	s_axi_lite_araddr  => s_axi_lite_araddr,
	s_axi_lite_arprot  => s_axi_lite_arprot,
	s_axi_lite_arvalid => s_axi_lite_arvalid,
	s_axi_lite_arready => s_axi_lite_arready,
	--
	s_axi_lite_rdata   => s_axi_lite_rdata,
	s_axi_lite_rresp   => s_axi_lite_rresp,
	s_axi_lite_rvalid  => s_axi_lite_rvalid,
	s_axi_lite_rready  => s_axi_lite_rready,

	-- AXI-Full Slave Bus Interface S_AXI
	s_axi_aclk     => s_axi_aclk,
	s_axi_aresetn  => s_axi_aresetn,
	--
	s_axi_awid     => s_axi_awid,
	s_axi_awaddr   => s_axi_awaddr,
	s_axi_awlen    => s_axi_awlen,
	s_axi_awsize   => s_axi_awsize,
	s_axi_awburst  => s_axi_awburst,
	s_axi_awlock   => s_axi_awlock,
	s_axi_awcache  => s_axi_awcache,
	s_axi_awprot   => s_axi_awprot,
	s_axi_awqos    => s_axi_awqos,
	s_axi_awregion => s_axi_awregion,
--	s_axi_awuser   => s_axi_awuser,
	s_axi_awvalid  => s_axi_awvalid,
	s_axi_awready  => s_axi_awready,
	--
	s_axi_wid      => s_axi_wid,
	s_axi_wdata    => s_axi_wdata,
	s_axi_wstrb    => s_axi_wstrb,
	s_axi_wlast    => s_axi_wlast,
--	s_axi_wuser    => s_axi_wuser,
	s_axi_wvalid   => s_axi_wvalid,
	s_axi_wready   => s_axi_wready,
	--
	s_axi_bid      => s_axi_bid,
	s_axi_bresp    => s_axi_bresp,
--	s_axi_buser    => s_axi_buser,
	s_axi_bvalid   => s_axi_bvalid,
	s_axi_bready   => s_axi_bready,
	--
	s_axi_arid     => s_axi_arid,
	s_axi_araddr   => s_axi_araddr,
	s_axi_arlen    => s_axi_arlen,
	s_axi_arsize   => s_axi_arsize,
	s_axi_arburst  => s_axi_arburst,
	s_axi_arlock   => s_axi_arlock,
	s_axi_arcache  => s_axi_arcache,
	s_axi_arprot   => s_axi_arprot,
	s_axi_arqos    => s_axi_arqos,
	s_axi_arregion => s_axi_arregion,
--	s_axi_aruser   => s_axi_aruser,
	s_axi_arvalid  => s_axi_arvalid,
	s_axi_arready  => s_axi_arready,
	--
	s_axi_rid      => s_axi_rid,
	s_axi_rdata    => s_axi_rdata,
	s_axi_rresp    => s_axi_rresp,
	s_axi_rlast    => s_axi_rlast,
--	s_axi_ruser    => s_axi_ruser,
	s_axi_rvalid   => s_axi_rvalid,
	s_axi_rready   => s_axi_rready,

	-- AXI-Full Master Bus Interface M_AXI
	m_axi_aclk     => m_axi_aclk,
	m_axi_aresetn  => m_axi_aresetn,
	--
	m_axi_awid     => m_axi_awid,
	m_axi_awaddr   => m_axi_awaddr,
	m_axi_awlen    => m_axi_awlen,
	m_axi_awsize   => m_axi_awsize,
	m_axi_awburst  => m_axi_awburst,
	m_axi_awlock   => m_axi_awlock,
	m_axi_awcache  => m_axi_awcache,
	m_axi_awprot   => m_axi_awprot,
	m_axi_awqos    => m_axi_awqos,
	m_axi_awregion => m_axi_awregion,
--	m_axi_awuser   => m_axi_awuser,
	m_axi_awvalid  => m_axi_awvalid,
	m_axi_awready  => m_axi_awready,
	--
	m_axi_wid      => m_axi_wid,
	m_axi_wdata    => m_axi_wdata,
	m_axi_wstrb    => m_axi_wstrb,
	m_axi_wlast    => m_axi_wlast,
--	m_axi_wuser    => m_axi_wuser,
	m_axi_wvalid   => m_axi_wvalid,
	m_axi_wready   => m_axi_wready,
	--
	m_axi_bid      => m_axi_bid,
	m_axi_bresp    => m_axi_bresp,
--	m_axi_buser    => m_axi_buser,
	m_axi_bvalid   => m_axi_bvalid,
	m_axi_bready   => m_axi_bready,
	--
	m_axi_arid     => m_axi_arid,
	m_axi_araddr   => m_axi_araddr,
	m_axi_arlen    => m_axi_arlen,
	m_axi_arsize   => m_axi_arsize,
	m_axi_arburst  => m_axi_arburst,
	m_axi_arlock   => m_axi_arlock,
	m_axi_arcache  => m_axi_arcache,
	m_axi_arprot   => m_axi_arprot,
	m_axi_arqos    => m_axi_arqos,
	m_axi_arregion => m_axi_arregion,
--	m_axi_aruser   => m_axi_aruser,
	m_axi_arvalid  => m_axi_arvalid,
	m_axi_arready  => m_axi_arready,
	--
	m_axi_rid      => m_axi_rid,
	m_axi_rdata    => m_axi_rdata,
	m_axi_rresp    => m_axi_rresp,
	m_axi_rlast    => m_axi_rlast,
--	m_axi_ruser    => m_axi_ruser,
	m_axi_rvalid   => m_axi_rvalid,
	m_axi_rready   => m_axi_rready
	);

	adapt: block -- Adapt from various AXI protocols to AXI4 block memory

	signal i_axi_awid     : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
	signal i_axi_awlen    : std_logic_vector(AXI_LEN_WIDTH(P_AXI4)-1 downto 0); -- AXI4
	signal i_axi_awsize   : std_logic_vector(2 downto 0);
	signal i_axi_awburst  : std_logic_vector(1 downto 0);
	--
	signal i_axi_wlast    : std_logic;
	--
	signal i_axi_arid     : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
	signal i_axi_arlen    : std_logic_vector(AXI_LEN_WIDTH(P_AXI4)-1 downto 0); -- AXI4
	signal i_axi_arsize   : std_logic_vector(2 downto 0);
	signal i_axi_arburst  : std_logic_vector(1 downto 0);

	begin

		lite: if (C_AXI_PROTOCOL = P_AXILITE) generate
			i_axi_awid    <= (others => '0');
			i_axi_awlen   <= std_logic_vector(to_unsigned(1, i_axi_awlen'length) - 1);
			i_axi_awsize  <= std_logic_vector(to_unsigned(log2rp(C_AXI_DATA_WIDTH/8), i_axi_awsize'length));
			i_axi_awburst <= "01"; -- Incrementing
			--
			i_axi_wlast   <= '1';
			--
			i_axi_arid    <= (others => '0');
			i_axi_arlen   <= std_logic_vector(to_unsigned(1, i_axi_arlen'length) - 1);
			i_axi_arsize  <= std_logic_vector(to_unsigned(log2rp(C_AXI_DATA_WIDTH/8), i_axi_arsize'length));
			i_axi_arburst <= "01"; -- Incrementing
		end generate lite;

		full: if (C_AXI_PROTOCOL /= P_AXILITE) generate
			i_axi_awid    <= m_axi_awid;
			i_axi_awlen   <= resize(m_axi_awlen,i_axi_awlen'length);
			i_axi_awsize  <= m_axi_awsize;
			i_axi_awburst <= m_axi_awburst;
			--
			i_axi_wlast   <= m_axi_wlast;
			--
			i_axi_arid    <= m_axi_arid;
			i_axi_arlen   <= resize(m_axi_arlen,i_axi_arlen'length);
			i_axi_arsize  <= m_axi_arsize;
			i_axi_arburst <= m_axi_arburst;
		end generate full;

		mem: entity work.axi_blk_mem
		generic map (
		C_FAMILY => "zynq",

		C_MEM_DEPTH      => 2**C_MEM_ADDR_WIDTH,
		C_MEM_ADDR_WIDTH => C_MEM_ADDR_WIDTH,

		C_AXI_ID_WIDTH   => C_AXI_ID_WIDTH,
		C_AXI_ADDR_WIDTH => C_AXI_ADDR_WIDTH,
		C_AXI_DATA_WIDTH => C_AXI_DATA_WIDTH
		)
		port map (
		s_aclk        => m_axi_aclk,
		s_aresetn     => m_axi_aresetn,
		--
		s_axi_awid    => i_axi_awid,
		s_axi_awaddr  => m_axi_awaddr,
		s_axi_awlen   => i_axi_awlen,
		s_axi_awsize  => i_axi_awsize,
		s_axi_awburst => i_axi_awburst,
		s_axi_awvalid => m_axi_awvalid,
		s_axi_awready => m_axi_awready,
		--
		s_axi_wdata   => m_axi_wdata,
		s_axi_wstrb   => m_axi_wstrb,
		s_axi_wlast   => i_axi_wlast,
		s_axi_wvalid  => m_axi_wvalid,
		s_axi_wready  => m_axi_wready,
		--
		s_axi_bid     => m_axi_bid,
		s_axi_bresp   => m_axi_bresp,
		s_axi_bvalid  => m_axi_bvalid,
		s_axi_bready  => m_axi_bready,
		--
		s_axi_arid    => i_axi_arid,
		s_axi_araddr  => m_axi_araddr,
		s_axi_arlen   => i_axi_arlen,
		s_axi_arsize  => i_axi_arsize,
		s_axi_arburst => i_axi_arburst,
		s_axi_arvalid => m_axi_arvalid,
		s_axi_arready => m_axi_arready,
		--
		s_axi_rid     => m_axi_rid,
		s_axi_rdata   => m_axi_rdata,
		s_axi_rresp   => m_axi_rresp,
		s_axi_rlast   => m_axi_rlast,
		s_axi_rvalid  => m_axi_rvalid,
		s_axi_rready  => m_axi_rready
		);

	end block adapt;

end behavioral;
