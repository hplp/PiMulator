----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/15/2014 11:30:00 AM
-- Design Name: 
-- Module Name: axi_tcd_tb - behavioral
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
-- use std.textio.all;
-- use ieee.std_logic_textio.all; -- I/O for logic types

library axi_tcd_lib;
use axi_tcd_lib.axi_tcd;

entity axi_tcd_tb is
end axi_tcd_tb;

architecture behavioral of axi_tcd_tb is

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

-- #################### --

constant C_MEM_ADDR_WIDTH : integer := 11; -- 12;
constant C_FIFO_DEPTH     : integer := 32; -- 1024;
constant C_BURST_LEN      : integer := 16;
constant C_FAMILY         : string := "zynq";

-- AXI4-Lite Slave Bus Interface S_AXI
constant C_S_AXI_DATA_WIDTH : integer := 32;
constant C_S_AXI_ADDR_WIDTH : integer := 20;

-- AXI4-Stream Slave Bus Interface S_AXIS
constant C_S_AXIS_TDATA_WIDTH : integer := 256;

-- AXI4-Full Master Bus Interface M_AXI
constant C_M_AXI_ID_WIDTH     : integer := 1;
constant C_M_AXI_ADDR_WIDTH   : integer := 32;
constant C_M_AXI_DATA_WIDTH   : integer := 256;
constant C_M_AXI_AWUSER_WIDTH : integer := 0; -- AXI4
constant C_M_AXI_ARUSER_WIDTH : integer := 0; -- AXI4
constant C_M_AXI_WUSER_WIDTH  : integer := 0; -- AXI4
constant C_M_AXI_RUSER_WIDTH  : integer := 0; -- AXI4
constant C_M_AXI_BUSER_WIDTH  : integer := 0; -- AXI4

-- AXI4-Lite Slave Bus Interface S_AXI
alias  s_axi_aclk    : std_logic is clock;
signal s_axi_aresetn : std_logic;
--
signal s_axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal s_axi_awprot  : std_logic_vector(2 downto 0);
signal s_axi_awvalid : std_logic;
signal s_axi_awready : std_logic;
--
signal s_axi_wdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal s_axi_wstrb   : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
signal s_axi_wvalid  : std_logic;
signal s_axi_wready  : std_logic;
--
signal s_axi_bresp   : std_logic_vector(1 downto 0);
signal s_axi_bvalid  : std_logic;
signal s_axi_bready  : std_logic;
--
signal s_axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal s_axi_arprot  : std_logic_vector(2 downto 0);
signal s_axi_arvalid : std_logic;
signal s_axi_arready : std_logic;
--
signal s_axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal s_axi_rresp   : std_logic_vector(1 downto 0);
signal s_axi_rvalid  : std_logic;
signal s_axi_rready  : std_logic;

-- AXI4-Stream Slave Bus Interface S_AXIS
alias  s_axis_aclk    : std_logic is clock;
signal s_axis_aresetn : std_logic;
--
signal s_axis_tdata   : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
signal s_axis_tstrb   : std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
signal s_axis_tlast   : std_logic;
signal s_axis_tvalid  : std_logic;
signal s_axis_tready  : std_logic;

-- AXI4-Full Master Bus Interface M_AXI
alias  m_axi_aclk     : std_logic is clock;
signal m_axi_aresetn  : std_logic;
--
signal m_axi_awid     : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
signal m_axi_awaddr   : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
signal m_axi_awlen    : std_logic_vector(7 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
signal m_axi_awsize   : std_logic_vector(2 downto 0);
signal m_axi_awburst  : std_logic_vector(1 downto 0);
signal m_axi_awlock   : std_logic_vector(0 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
signal m_axi_awcache  : std_logic_vector(3 downto 0);
signal m_axi_awprot   : std_logic_vector(2 downto 0);
signal m_axi_awqos    : std_logic_vector(3 downto 0); -- AXI4
signal m_axi_awregion : std_logic_vector(3 downto 0); -- AXI4
signal m_axi_awuser   : std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_awvalid  : std_logic;
signal m_axi_awready  : std_logic;
--
--signal m_axi_wid      : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0); -- AXI3
signal m_axi_wdata    : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal m_axi_wstrb    : std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
signal m_axi_wlast    : std_logic;
signal m_axi_wuser    : std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_wvalid   : std_logic;
signal m_axi_wready   : std_logic;
--
signal m_axi_bid      : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
signal m_axi_bresp    : std_logic_vector(1 downto 0);
signal m_axi_buser    : std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_bvalid   : std_logic;
signal m_axi_bready   : std_logic;
--
signal m_axi_arid     : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
signal m_axi_araddr   : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
signal m_axi_arlen    : std_logic_vector(7 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
signal m_axi_arsize   : std_logic_vector(2 downto 0);
signal m_axi_arburst  : std_logic_vector(1 downto 0);
signal m_axi_arlock   : std_logic_vector(0 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
signal m_axi_arcache  : std_logic_vector(3 downto 0);
signal m_axi_arprot   : std_logic_vector(2 downto 0);
signal m_axi_arqos    : std_logic_vector(3 downto 0); -- AXI4
signal m_axi_arregion : std_logic_vector(3 downto 0); -- AXI4
signal m_axi_aruser   : std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_arvalid  : std_logic;
signal m_axi_arready  : std_logic;
--
signal m_axi_rid      : std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
signal m_axi_rdata    : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal m_axi_rresp    : std_logic_vector(1 downto 0);
signal m_axi_rlast    : std_logic;
signal m_axi_ruser    : std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0); -- AXI4
signal m_axi_rvalid   : std_logic;
signal m_axi_rready   : std_logic;

constant TRACE_CNT : integer := 112;
constant EW : integer := 8; -- element width (bits) in trace vector

signal trace_gen_done : std_logic;
signal set_forward_done : std_logic;

begin

	clk: process -- clock
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

	rst: process -- reset
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
	-- s_axi_aclk <= clock;
	-- s_axis_aclk <= clock;
	-- m_axi_aclk <= clock;

	s_axi_aresetn <= not reset;
	s_axis_aresetn <= not reset;
	m_axi_aresetn <= not reset;

	trace_gen: process
	begin
		trace_gen_done <= '0';
		s_axis_tdata <= (others => '0');
		s_axis_tstrb <= (others => '0');
		s_axis_tlast <= '0';
		s_axis_tvalid <= '0';
		wait_sig(s_axis_aclk, s_axis_aresetn, '1');

		for i in 0 to TRACE_CNT-1 loop
			--s_axis_tdata <= std_logic_vector(to_unsigned(i, C_S_AXIS_TDATA_WIDTH));
			for j in 0 to C_S_AXIS_TDATA_WIDTH/EW-1 loop
				if (j = 0) then
					s_axis_tdata((j+1)*EW-1 downto j*EW) <= std_logic_vector(to_unsigned(i, EW));
				else
					s_axis_tdata((j+1)*EW-1 downto j*EW) <= std_logic_vector(to_unsigned(j, EW));
				end if;
			end loop;
			s_axis_tstrb <= (others => '1');
			s_axis_tvalid <= '1';
			wait_sig(s_axis_aclk, s_axis_tready, '1');
			-- s_axis_tvalid <= '0';
			-- wait_cycles(s_axis_aclk, 10);
		end loop;
		s_axis_tdata <= (others => '0');
		s_axis_tstrb <= (others => '0');
		s_axis_tlast <= '0';
		s_axis_tvalid <= '0';
		wait_cycles(s_axis_aclk, 24);
		trace_gen_done <= '1';
		wait;
	end process;

	ctl_w: process
	begin
		set_forward_done <= '0';
		s_axi_awaddr <= (others => '0');
		s_axi_awprot <= (others => '0');
		s_axi_awvalid <= '0';
		s_axi_wdata <= (others => '0');
		s_axi_wstrb <= (others => '0');
		s_axi_wvalid <= '0';
		s_axi_bready <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');

		-- wait_sig(s_axi_aclk, trace_gen_done, '1');
		-- wait_cycles(s_axi_aclk, 50); -- let burst flow to TCD memory

		s_axi_awvalid <= '1'; -- set forward mode in TCD
		wait_sig(s_axi_aclk, s_axi_awready, '1');
		s_axi_awvalid <= '0';
		s_axi_wstrb <= (others => '1');
		s_axi_wvalid <= '1';
		wait_sig(s_axi_aclk, s_axi_wready, '1');
		s_axi_wstrb <= (others => '0');
		s_axi_wvalid <= '0';
		s_axi_bready <= '1';
		wait_sig(s_axi_aclk, s_axi_bvalid, '1');
		s_axi_bready <= '0';
		set_forward_done <= '1';

		wait;
	end process;

	ctl_r: process
		-- variable my_line : line; -- type 'line' comes from textio
	begin
		s_axi_araddr <= (others => '0');
		s_axi_arprot <= (others => '0');
		s_axi_arvalid <= '0';
		s_axi_rready <= '0';
		wait_sig(s_axi_aclk, s_axi_aresetn, '1');

		wait_sig(s_axi_aclk, trace_gen_done, '1');
		wait_sig(s_axi_aclk, set_forward_done, '1');

		for i in 0 to TRACE_CNT-1 loop
			for j in 0 to C_S_AXIS_TDATA_WIDTH/C_S_AXI_DATA_WIDTH-1 loop
				s_axi_araddr <= std_logic_vector(to_unsigned(j*(C_S_AXI_DATA_WIDTH/8), C_S_AXI_ADDR_WIDTH));
				s_axi_arprot <= (1 => '1', others => '0');
				s_axi_arvalid <= '1';
				wait_sig(s_axi_aclk, s_axi_arready, '1');
				s_axi_arvalid <= '0';

				s_axi_rready <= '1';
				-- wait_sig(s_axi_aclk, s_axi_rvalid, '1');
				wait until (rising_edge(s_axi_aclk) and s_axi_rvalid = '1');
				for k in 0 to C_S_AXI_DATA_WIDTH/EW-1 loop
					if (j = 0 and k = 0) then
						-- hwrite(my_line, s_axi_rdata((k+1)*EW-1 downto k*EW));
						-- writeline(output, my_line); -- write to display
						assert (s_axi_rdata((k+1)*EW-1 downto k*EW) = std_logic_vector(to_unsigned(i, EW)))
							report "error." severity FAILURE;
					else
						assert (s_axi_rdata((k+1)*EW-1 downto k*EW) = std_logic_vector(to_unsigned(j*(C_S_AXI_DATA_WIDTH/EW)+k, EW)))
							report "error." severity FAILURE;
					end if;
				end loop;
				wait for hold;
				s_axi_rready <= '0';

			end loop;
		end loop;
		s_axi_araddr <= (others => '0');
		s_axi_arprot <= (others => '0');

		-- ########## Done ########## --
		wait_cycles(s_axi_aclk, 2);
		assert (FALSE) report "done." severity FAILURE;
		wait; -- will wait forever
	end process;

	-- #################### --

	uut: entity axi_tcd
	generic map (

	C_MEM_ADDR_WIDTH => C_MEM_ADDR_WIDTH,
	C_FIFO_DEPTH     => C_FIFO_DEPTH,
	C_BURST_LEN      => C_BURST_LEN,
	C_FAMILY         => C_FAMILY,

	-- AXI4-Lite Slave Bus Interface S_AXI
	C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
	C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,

	-- AXI4-Stream Slave Bus Interface S_AXIS
	C_S_AXIS_TDATA_WIDTH => C_S_AXIS_TDATA_WIDTH,

	-- AXI4-Full Master Bus Interface M_AXI
	C_M_AXI_ID_WIDTH => C_M_AXI_ID_WIDTH,
	C_M_AXI_ADDR_WIDTH => C_M_AXI_ADDR_WIDTH,
	C_M_AXI_DATA_WIDTH => C_M_AXI_DATA_WIDTH,
	C_M_AXI_AWUSER_WIDTH => C_M_AXI_AWUSER_WIDTH,
	C_M_AXI_ARUSER_WIDTH => C_M_AXI_ARUSER_WIDTH,
	C_M_AXI_WUSER_WIDTH => C_M_AXI_WUSER_WIDTH,
	C_M_AXI_RUSER_WIDTH => C_M_AXI_RUSER_WIDTH,
	C_M_AXI_BUSER_WIDTH => C_M_AXI_BUSER_WIDTH

	)
	port map (

	-- AXI4-Lite Slave Bus Interface S_AXI
	s_axi_aclk => s_axi_aclk,
	s_axi_aresetn => s_axi_aresetn,
	--
	s_axi_awaddr => s_axi_awaddr,
	s_axi_awprot => s_axi_awprot,
	s_axi_awvalid => s_axi_awvalid,
	s_axi_awready => s_axi_awready,
	--
	s_axi_wdata => s_axi_wdata,
	s_axi_wstrb => s_axi_wstrb,
	s_axi_wvalid => s_axi_wvalid,
	s_axi_wready => s_axi_wready,
	--
	s_axi_bresp => s_axi_bresp,
	s_axi_bvalid => s_axi_bvalid,
	s_axi_bready => s_axi_bready,
	--
	s_axi_araddr => s_axi_araddr,
	s_axi_arprot => s_axi_arprot,
	s_axi_arvalid => s_axi_arvalid,
	s_axi_arready => s_axi_arready,
	--
	s_axi_rdata => s_axi_rdata,
	s_axi_rresp => s_axi_rresp,
	s_axi_rvalid => s_axi_rvalid,
	s_axi_rready => s_axi_rready,
	
	-- AXI4-Stream Slave Bus Interface S_AXIS
	s_axis_aclk => s_axis_aclk,
	s_axis_aresetn => s_axis_aresetn,
	--
	s_axis_tdata => s_axis_tdata,
	s_axis_tstrb => s_axis_tstrb,
--	s_axis_tlast => s_axis_tlast,
	s_axis_tvalid => s_axis_tvalid,
	s_axis_tready => s_axis_tready,
	
	-- AXI4-Full Master Bus Interface M_AXI
	m_axi_aclk => m_axi_aclk,
	m_axi_aresetn => m_axi_aresetn,
	--
	m_axi_awid => m_axi_awid,
	m_axi_awaddr => m_axi_awaddr,
	m_axi_awlen => m_axi_awlen,
	m_axi_awsize => m_axi_awsize,
	m_axi_awburst => m_axi_awburst,
	m_axi_awlock => m_axi_awlock,
	m_axi_awcache => m_axi_awcache,
	m_axi_awprot => m_axi_awprot,
	m_axi_awqos => m_axi_awqos,
	m_axi_awregion => m_axi_awregion,
	m_axi_awuser => m_axi_awuser,
	m_axi_awvalid => m_axi_awvalid,
	m_axi_awready => m_axi_awready,
	--
--	m_axi_wid => m_axi_wid,
	m_axi_wdata => m_axi_wdata,
	m_axi_wstrb => m_axi_wstrb,
	m_axi_wlast => m_axi_wlast,
	m_axi_wuser => m_axi_wuser,
	m_axi_wvalid => m_axi_wvalid,
	m_axi_wready => m_axi_wready,
	--
	m_axi_bid => m_axi_bid,
	m_axi_bresp => m_axi_bresp,
	m_axi_buser => m_axi_buser,
	m_axi_bvalid => m_axi_bvalid,
	m_axi_bready => m_axi_bready,
	--
	m_axi_arid => m_axi_arid,
	m_axi_araddr => m_axi_araddr,
	m_axi_arlen => m_axi_arlen,
	m_axi_arsize => m_axi_arsize,
	m_axi_arburst => m_axi_arburst,
	m_axi_arlock => m_axi_arlock,
	m_axi_arcache => m_axi_arcache,
	m_axi_arprot => m_axi_arprot,
	m_axi_arqos => m_axi_arqos,
	m_axi_arregion => m_axi_arregion,
	m_axi_aruser => m_axi_aruser,
	m_axi_arvalid => m_axi_arvalid,
	m_axi_arready => m_axi_arready,
	--
	m_axi_rid => m_axi_rid,
	m_axi_rdata => m_axi_rdata,
	m_axi_rresp => m_axi_rresp,
	m_axi_rlast => m_axi_rlast,
	m_axi_ruser => m_axi_ruser,
	m_axi_rvalid => m_axi_rvalid,
	m_axi_rready => m_axi_rready

	);

	mem: entity work.axi_blk_mem
	generic map (

	C_FAMILY => C_FAMILY,

	C_MEM_DEPTH => 2**C_MEM_ADDR_WIDTH,
	C_MEM_ADDR_WIDTH => C_MEM_ADDR_WIDTH,

	C_AXI_ID_WIDTH => C_M_AXI_ID_WIDTH,
	C_AXI_ADDR_WIDTH => C_M_AXI_ADDR_WIDTH,
	C_AXI_DATA_WIDTH => C_M_AXI_DATA_WIDTH

	)
	port map (
	s_aclk => m_axi_aclk,
	s_aresetn => m_axi_aresetn,
	--
	s_axi_awid => m_axi_awid,
	s_axi_awaddr => m_axi_awaddr,
	s_axi_awlen => m_axi_awlen,
	s_axi_awsize => m_axi_awsize,
	s_axi_awburst => m_axi_awburst,
	s_axi_awvalid => m_axi_awvalid,
	s_axi_awready => m_axi_awready,
	--
	s_axi_wdata => m_axi_wdata,
	s_axi_wstrb => m_axi_wstrb,
	s_axi_wlast => m_axi_wlast,
	s_axi_wvalid => m_axi_wvalid,
	s_axi_wready => m_axi_wready,
	--
	s_axi_bid => m_axi_bid,
	s_axi_bresp => m_axi_bresp,
	s_axi_bvalid => m_axi_bvalid,
	s_axi_bready => m_axi_bready,
	--
	s_axi_arid => m_axi_arid,
	s_axi_araddr => m_axi_araddr,
	s_axi_arlen => m_axi_arlen,
	s_axi_arsize => m_axi_arsize,
	s_axi_arburst => m_axi_arburst,
	s_axi_arvalid => m_axi_arvalid,
	s_axi_arready => m_axi_arready,
	--
	s_axi_rid => m_axi_rid,
	s_axi_rdata => m_axi_rdata,
	s_axi_rresp => m_axi_rresp,
	s_axi_rlast => m_axi_rlast,
	s_axi_rvalid => m_axi_rvalid,
	s_axi_rready => m_axi_rready
	);

end behavioral;
