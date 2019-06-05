----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2014 01:04:30 PM
-- Design Name: 
-- Module Name: axi_tcd - behavioral
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

library xpm;
use xpm.vcomponents.all;

library axi_tcd_lib;
use axi_tcd_lib.fifo_icwt;

entity axi_tcd is

generic (

	C_MEM_ADDR_WIDTH : integer := 30;
	C_FIFO_DEPTH     : integer := 1024;
	C_BURST_LEN      : integer := 16;
	C_FAMILY         : string := "rtl";

	-- AXI4-Lite Slave Bus Interface S_AXI
	C_S_AXI_DATA_WIDTH : integer := 32;
	C_S_AXI_ADDR_WIDTH : integer := 20;

	-- AXI4-Stream Slave Bus Interface S_AXIS
	C_S_AXIS_TDATA_WIDTH : integer := 32;

	-- AXI4-Full Master Bus Interface M_AXI
	C_M_AXI_ID_WIDTH     : integer := 1;
	C_M_AXI_ADDR_WIDTH   : integer := 32;
	C_M_AXI_DATA_WIDTH   : integer := 32;
	C_M_AXI_AWUSER_WIDTH : integer := 0; -- AXI4
	C_M_AXI_ARUSER_WIDTH : integer := 0; -- AXI4
	C_M_AXI_WUSER_WIDTH  : integer := 0; -- AXI4
	C_M_AXI_RUSER_WIDTH  : integer := 0; -- AXI4
	C_M_AXI_BUSER_WIDTH  : integer := 0 -- AXI4
);

port (
	-- AXI4-Lite Slave Bus Interface S_AXI
	s_axi_aclk    : in  std_logic;
	s_axi_aresetn : in  std_logic;
	--
	s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	s_axi_awprot  : in  std_logic_vector(2 downto 0);
	s_axi_awvalid : in  std_logic;
	s_axi_awready : out std_logic;
	--
	s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
	s_axi_wvalid  : in  std_logic;
	s_axi_wready  : out std_logic;
	--
	s_axi_bresp   : out std_logic_vector(1 downto 0);
	s_axi_bvalid  : out std_logic;
	s_axi_bready  : in  std_logic;
	--
	s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	s_axi_arprot  : in  std_logic_vector(2 downto 0);
	s_axi_arvalid : in  std_logic;
	s_axi_arready : out std_logic;
	--
	s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	s_axi_rresp   : out std_logic_vector(1 downto 0);
	s_axi_rvalid  : out std_logic;
	s_axi_rready  : in  std_logic;

	-- AXI4-Stream Slave Bus Interface S_AXIS
	s_axis_aclk    : in  std_logic;
	s_axis_aresetn : in  std_logic;
	--
	s_axis_tdata   : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
	s_axis_tstrb   : in  std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
--	s_axis_tlast   : in  std_logic := '0';
	s_axis_tvalid  : in  std_logic;
	s_axis_tready  : out std_logic;

	-- AXI4-Full Master Bus Interface M_AXI
	m_axi_aclk     : in  std_logic;
	m_axi_aresetn  : in  std_logic;
	--
	m_axi_awid     : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
	m_axi_awaddr   : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
	m_axi_awlen    : out std_logic_vector(7 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
	m_axi_awsize   : out std_logic_vector(2 downto 0);
	m_axi_awburst  : out std_logic_vector(1 downto 0);
	m_axi_awlock   : out std_logic_vector(0 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
	m_axi_awcache  : out std_logic_vector(3 downto 0);
	m_axi_awprot   : out std_logic_vector(2 downto 0);
	m_axi_awqos    : out std_logic_vector(3 downto 0); -- AXI4
	m_axi_awregion : out std_logic_vector(3 downto 0); -- AXI4
	m_axi_awuser   : out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_awvalid  : out std_logic;
	m_axi_awready  : in  std_logic;
	--
--	m_axi_wid      : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0); -- AXI3
	m_axi_wdata    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	m_axi_wstrb    : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
	m_axi_wlast    : out std_logic;
	m_axi_wuser    : out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_wvalid   : out std_logic;
	m_axi_wready   : in  std_logic;
	--
	m_axi_bid      : in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
	m_axi_bresp    : in  std_logic_vector(1 downto 0);
	m_axi_buser    : in  std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_bvalid   : in  std_logic;
	m_axi_bready   : out std_logic;
	--
	m_axi_arid     : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
	m_axi_araddr   : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
	m_axi_arlen    : out std_logic_vector(7 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
	m_axi_arsize   : out std_logic_vector(2 downto 0);
	m_axi_arburst  : out std_logic_vector(1 downto 0);
	m_axi_arlock   : out std_logic_vector(0 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
	m_axi_arcache  : out std_logic_vector(3 downto 0);
	m_axi_arprot   : out std_logic_vector(2 downto 0);
	m_axi_arqos    : out std_logic_vector(3 downto 0); -- AXI4
	m_axi_arregion : out std_logic_vector(3 downto 0); -- AXI4
	m_axi_aruser   : out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_arvalid  : out std_logic;
	m_axi_arready  : in  std_logic;
	--
	m_axi_rid      : in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
	m_axi_rdata    : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	m_axi_rresp    : in  std_logic_vector(1 downto 0);
	m_axi_rlast    : in  std_logic;
	m_axi_ruser    : in  std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_rvalid   : in  std_logic;
	m_axi_rready   : out std_logic
);

end axi_tcd;

architecture behavioral of axi_tcd is

constant BURST_INCR : integer := 1;
constant BURST_SIZE : integer := C_M_AXI_DATA_WIDTH/8*C_BURST_LEN; -- bytes

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

signal had_aw : std_logic;
signal had_w  : std_logic;
signal had_ar : std_logic;

constant BURST_W : integer := log2rp(C_BURST_LEN);

-- The negative range of DBEATS has to be large enough to handle words
-- transferred by the AXI data channel before the address channel request.
subtype DBEATS is integer range -1024 to C_BURST_LEN*2-1;

signal wch_burstc : unsigned(BURST_W-1 downto 0);
signal wch_dbeats : DBEATS;

signal rch_dbeats : DBEATS;

-- when (m_axi_aXaddr_i /= comp_aXaddr) means there are outstanding transactions
signal comp_awaddr : unsigned(C_MEM_ADDR_WIDTH-1 downto 0); -- completed write address
signal comp_araddr : unsigned(C_MEM_ADDR_WIDTH-1 downto 0); -- completed read address

signal last_wr   : std_logic; -- last transaction was a write
signal last_rd   : std_logic; -- last transaction was a read
signal mem_full  : std_logic; -- memory is full
signal mem_empty : std_logic; -- memory is empty

signal m_fifo_rch_empty_d : std_logic; -- read channel empty delayed one cycle
signal forward : std_logic; -- forward data stored in memory to read channel
signal forward_sync : std_logic; -- synchronized to m_axi_aclk

-- AXI4-Lite Slave Bus Interface S_AXI
signal s_axi_awready_i : std_logic;
signal s_axi_wready_i  : std_logic;
signal s_axi_bvalid_i  : std_logic;
signal s_axi_arready_i : std_logic;
signal s_axi_rvalid_i  : std_logic;

-- AXI4-Full Master Bus Interface M_AXI
signal m_axi_awaddr_i  : unsigned(C_MEM_ADDR_WIDTH-1 downto 0);
signal m_axi_awvalid_i : std_logic;
signal m_axi_awready_i : std_logic;
signal m_axi_wvalid_i  : std_logic;
signal m_axi_wready_i  : std_logic;
signal m_axi_bvalid_i  : std_logic;
signal m_axi_bready_i  : std_logic;
signal m_axi_araddr_i  : unsigned(C_MEM_ADDR_WIDTH-1 downto 0);
signal m_axi_arvalid_i : std_logic;
signal m_axi_arready_i : std_logic;
signal m_axi_rlast_i   : std_logic;
signal m_axi_rvalid_i  : std_logic;
signal m_axi_rready_i  : std_logic;

-- FIFO signals
signal s_fifo_wch_rst    : std_logic;
signal s_fifo_wch_data   : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
signal s_fifo_wch_enable : std_logic;
signal s_fifo_wch_full   : std_logic;
signal s_fifo_wch_pfull  : std_logic;

signal m_fifo_wch_data   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal m_fifo_wch_enable : std_logic;
signal m_fifo_wch_empty  : std_logic;
signal m_fifo_wch_pempty : std_logic;

signal s_fifo_rch_rst    : std_logic;
signal s_fifo_rch_data   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
signal s_fifo_rch_enable : std_logic;
signal s_fifo_rch_full   : std_logic;
signal s_fifo_rch_pfull  : std_logic;

signal m_fifo_rch_data   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal m_fifo_rch_enable : std_logic;
signal m_fifo_rch_empty  : std_logic;
signal m_fifo_rch_pempty : std_logic;

begin

	-- AMBA AXI and ACE Protocol Specification

	-- Section A3.2.1 - Handshake process
	-- 1) Transfer occurs only when both the VALID and READY signals are HIGH.
	-- 2) No combinatorial paths between input and output signals.
	-- 3) A source is not permitted to wait until READY is asserted before asserting VALID.
	-- 4) Once VALID is asserted it must remain asserted until the handshake occurs.
	-- 5) A destination is permitted to wait for VALID to be asserted before asserting READY.
	-- 6) If READY is asserted, it is permitted to deassert READY before VALID is asserted.

	-- Section A3.2.2 - Channel signaling requirements
	-- 1) The default state of AxREADY and xREADY can be either HIGH or LOW.
	-- 2) A default state of HIGH is recommended for AxREADY.
	-- 3) The source must assert the xLAST signal when it is driving the final transfer in the burst.

	-- Section A3.3.1 - Dependencies between channel handshake signals
	-- 1) (ARVALID & ARREADY) must be asserted before asserting RVALID.
	-- 2) (AWVALID & AWREADY) and (WVALID & WREADY & WLAST) must be asserted before asserting BVALID.

	-- #################### AXI-Lite #################### --

	-- Slave memory mapped write channel

--	s_axi_awaddr 
--	s_axi_awprot 
--	s_axi_awvalid
	s_axi_awready <= s_axi_awready_i;
	--
--	s_axi_wdata 
--	s_axi_wstrb 
--	s_axi_wvalid
	s_axi_wready <= s_axi_wready_i;
	--
	s_axi_bresp  <= (others => '0');
	s_axi_bvalid <= s_axi_bvalid_i;
--	s_axi_bready

	s_axi_awready_i <= '1';
	s_axi_wready_i  <= '1';
	s_axi_bvalid_i  <= had_aw and had_w;

	s_axi_b: process(s_axi_aclk)
	begin
		if (rising_edge(s_axi_aclk)) then
			if (s_axi_aresetn = '0') then -- synchronous reset
				had_aw <= '0';
				had_w <= '0';
			else
				if (s_axi_awvalid = '1' and s_axi_awready_i = '1') then
					had_aw <= '1';
				end if;
				if (s_axi_wvalid = '1' and s_axi_wready_i = '1') then
					had_w <= '1';
				end if;
				if (s_axi_bvalid_i = '1' and s_axi_bready = '1') then
					had_aw <= '0';
					had_w <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Slave memory mapped read channel

--	s_axi_araddr
--	s_axi_arprot
--	s_axi_arvalid
	s_axi_arready <= s_axi_arready_i;
	--
	s_axi_rdata  <= m_fifo_rch_data when (m_fifo_rch_empty = '0') else (others => '0');
	s_axi_rresp  <= (others => '0');
	s_axi_rvalid <= s_axi_rvalid_i;
--	s_axi_rready

	m_fifo_rch_enable <= had_ar and s_axi_rready;

	s_axi_arready_i <= '1';
	s_axi_rvalid_i  <= had_ar
		and (not m_fifo_rch_empty or not forward);

	s_axi_r: process(s_axi_aclk)
	begin
		if (rising_edge(s_axi_aclk)) then
			if (s_axi_aresetn = '0') then -- synchronous reset
				had_ar <= '0';
			else
				if (s_axi_arvalid = '1' and s_axi_arready_i = '1') then
					had_ar <= '1';
				end if;
				if (s_axi_rvalid_i = '1' and s_axi_rready = '1') then
					had_ar <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Forward signal support

	s_axi_e: process(s_axi_aclk)
	begin
		if (rising_edge(s_axi_aclk)) then
			if (s_axi_aresetn = '0') then -- synchronous reset
				m_fifo_rch_empty_d <= '1';
			else
				m_fifo_rch_empty_d <= m_fifo_rch_empty;
			end if;
		end if;
	end process;

	s_axi_f: process(s_axi_aclk)
	begin
		if (rising_edge(s_axi_aclk)) then
			if (s_axi_aresetn = '0' or (m_fifo_rch_empty = '1' and m_fifo_rch_empty_d = '0')) then
				forward <= '0';
			elsif (s_axi_bvalid_i = '1' and s_axi_bready = '1') then
				forward <= '1';
			end if;
		end if;
	end process;

	i_cdc: xpm_cdc_single
	generic map (
	DEST_SYNC_FF   => 2, -- range: 2-10
	INIT_SYNC_FF   => 0, -- 0=disable simulation init values, 1=enable simulation init values
	SIM_ASSERT_CHK => 0, -- 0=disable simulation messages, 1=enable simulation messages
	SRC_INPUT_REG  => 0  -- 0=do not register input, 1=register input
	)
	port map (
	src_clk  => s_axi_aclk,  -- optional; required when SRC_INPUT_REG = 1
	src_in   => forward,
	dest_clk => m_axi_aclk,
	dest_out => forward_sync
	);

	-- #################### AXI-Stream #################### --

	-- Slave stream write channel

	s_fifo_wch_data   <= s_axis_tdata;
	s_fifo_wch_enable <= s_axis_tvalid;
	s_axis_tready     <= not s_fifo_wch_full;

	-- #################### AXI Memory Mapped #################### --

	-- Memory flow control

	mem_full  <= '1' when (m_axi_awaddr_i = comp_araddr and last_wr = '1') else '0';
	mem_empty <= '1' when (m_axi_araddr_i = comp_awaddr and last_rd = '1') else '0';

	m_axi_l: process(m_axi_aclk)
	begin
		if (rising_edge(m_axi_aclk)) then
			if (m_axi_aresetn = '0') then -- synchronous reset
				last_wr <= '0';
				last_rd <= '1';
			else
				if (m_axi_rvalid_i = '1' and m_axi_rready_i = '1' and m_axi_rlast_i = '1') then
					last_wr <= '0';
				elsif (m_axi_awvalid_i = '1' and m_axi_awready_i = '1') then
					last_wr <= '1';
				end if;
				if (m_axi_bvalid_i = '1' and m_axi_bready_i = '1') then
					last_rd <= '0';
				elsif (m_axi_arvalid_i = '1' and m_axi_arready_i = '1') then
					last_rd <= '1';
				end if;
			end if;
		end if;
	end process;

	-- Master memory mapped write channel

	m_axi_awid      <= (others => '0');
	m_axi_awaddr    <= std_logic_vector(resize(m_axi_awaddr_i, m_axi_awaddr'length));
	m_axi_awlen     <= std_logic_vector(to_unsigned(C_BURST_LEN-1, m_axi_awlen'length));
	m_axi_awsize    <= std_logic_vector(to_unsigned(log2rp(C_M_AXI_DATA_WIDTH/8), m_axi_awsize'length));
	m_axi_awburst   <= std_logic_vector(to_unsigned(BURST_INCR, m_axi_awburst'length));
	m_axi_awlock    <= (others => '0');
	m_axi_awcache   <= (others => '0');
	m_axi_awprot    <= (1 => '1', others => '0');
	m_axi_awqos     <= (others => '0');
	m_axi_awregion  <= (others => '0');
	m_axi_awuser    <= (others => '0');
	m_axi_awvalid   <= m_axi_awvalid_i;
	m_axi_awready_i <= m_axi_awready;
	--
--	m_axi_wid      <= (others => '0'); -- AXI3
	m_axi_wdata    <= m_fifo_wch_data;
	m_axi_wstrb    <= (others => '1');
	m_axi_wlast    <= '1' when (wch_burstc = 0) else '0';
	m_axi_wuser    <= (others => '0'); -- AXI4
	m_axi_wvalid   <= m_axi_wvalid_i;
	m_axi_wready_i <= m_axi_wready;
	--
--	m_axi_bid;
--	m_axi_bresp;
--	m_axi_buser;
	m_axi_bvalid_i <= m_axi_bvalid;
	m_axi_bready   <= m_axi_bready_i;

	m_fifo_wch_enable <= m_axi_wready_i;
	m_axi_wvalid_i    <= not m_fifo_wch_empty;

	-- start an AXI memory-mapped write transaction
	m_axi_awvalid_i <= '1'
		when (
			m_fifo_wch_pempty = '0' and -- sufficient data in FIFO for a burst
			wch_dbeats < C_BURST_LEN-2 and -- give pempty (read count) extra data beats to stabilize
			(mem_full = '0' or forward_sync = '0') -- memory not full or forward disabled
		) else '0';

	m_axi_aw: process(m_axi_aclk)
	begin
		if (rising_edge(m_axi_aclk)) then
			if (m_axi_aresetn = '0') then -- synchronous reset
				wch_dbeats <= 0;
				m_axi_awaddr_i <= (others => '0');
			else
				if (m_axi_awvalid_i = '1' and m_axi_awready_i = '1') then
					m_axi_awaddr_i <= m_axi_awaddr_i + BURST_SIZE;
					if (m_axi_wvalid_i = '1' and m_axi_wready_i = '1') then
						wch_dbeats <= wch_dbeats + (C_BURST_LEN-1);
					else
						wch_dbeats <= wch_dbeats + C_BURST_LEN;
					end if;
				elsif (m_axi_wvalid_i = '1' and m_axi_wready_i = '1') then
					wch_dbeats <= wch_dbeats - 1;
				end if;
			end if;
		end if;
	end process;

	m_axi_w: process(m_axi_aclk)
	begin
		if (rising_edge(m_axi_aclk)) then
			if (m_axi_aresetn = '0') then -- synchronous reset
				wch_burstc <= to_unsigned(C_BURST_LEN-1, BURST_W);
			else
				if (m_axi_wvalid_i = '1' and m_axi_wready_i = '1') then
					wch_burstc <= wch_burstc - 1;
				end if;
			end if;
		end if;
	end process;

	m_axi_bready_i <= '1';

	m_axi_b: process(m_axi_aclk)
	begin
		if (rising_edge(m_axi_aclk)) then
			if (m_axi_aresetn = '0') then -- synchronous reset
				comp_awaddr <= (others => '0');
			else
				if (m_axi_bvalid_i = '1' and m_axi_bready_i = '1') then
					comp_awaddr <= comp_awaddr + BURST_SIZE;
				end if;
			end if;
		end if;
	end process;

	-- Master memory mapped read channel

	m_axi_arid      <= (others => '0');
	m_axi_araddr    <= std_logic_vector(resize(m_axi_araddr_i, m_axi_araddr'length));
	m_axi_arlen     <= std_logic_vector(to_unsigned(C_BURST_LEN-1, m_axi_arlen'length));
	m_axi_arsize    <= std_logic_vector(to_unsigned(log2rp(C_M_AXI_DATA_WIDTH/8), m_axi_arsize'length));
	m_axi_arburst   <= std_logic_vector(to_unsigned(BURST_INCR, m_axi_arburst'length));
	m_axi_arlock    <= (others => '0');
	m_axi_arcache   <= (others => '0');
	m_axi_arprot    <= (1 => '1', others => '0');
	m_axi_arqos     <= (others => '0');
	m_axi_arregion  <= (others => '0');
	m_axi_aruser    <= (others => '0');
	m_axi_arvalid   <= m_axi_arvalid_i;
	m_axi_arready_i <= m_axi_arready;
	--
--	m_axi_rid
	s_fifo_rch_data <= m_axi_rdata;
--	m_axi_rresp
	m_axi_rlast_i <= m_axi_rlast;
--	m_axi_ruser
	m_axi_rvalid_i  <= m_axi_rvalid;
	m_axi_rready    <= m_axi_rready_i;

	s_fifo_rch_enable <= m_axi_rvalid_i;
	m_axi_rready_i    <= not s_fifo_rch_full; -- and forward?

	-- start an AXI memory-mapped read transaction
	m_axi_arvalid_i <= '1'
		when (
			s_fifo_rch_pfull = '0' and -- sufficient room in FIFO for a burst
			rch_dbeats < C_BURST_LEN-2 and -- give pfull (write count) extra data beats to stabilize
			mem_empty = '0' and forward_sync = '1' -- mem not empty and forward enabled
		) else '0';

	m_axi_ar: process(m_axi_aclk)
	begin
		if (rising_edge(m_axi_aclk)) then
			if (m_axi_aresetn = '0') then -- synchronous reset
				rch_dbeats <= 0;
				m_axi_araddr_i <= (others => '0');
			else
				if (forward_sync = '0') then -- overwrite memory
					if (m_axi_awvalid_i = '1' and m_axi_awready_i = '1' and mem_full = '1') then
						m_axi_araddr_i <= m_axi_araddr_i + BURST_SIZE;
					end if;
				elsif (m_axi_arvalid_i = '1' and m_axi_arready_i = '1') then
					m_axi_araddr_i <= m_axi_araddr_i + BURST_SIZE;
					if (m_axi_rready_i = '1' and m_axi_rvalid_i = '1') then
						rch_dbeats <= rch_dbeats + (C_BURST_LEN-1);
					else
						rch_dbeats <= rch_dbeats + C_BURST_LEN;
					end if;
				elsif (m_axi_rready_i = '1' and m_axi_rvalid_i = '1') then
					rch_dbeats <= rch_dbeats - 1;
				end if;
			end if;
		end if;
	end process;

	m_axi_r: process(m_axi_aclk)
	begin
		if (rising_edge(m_axi_aclk)) then
			if (m_axi_aresetn = '0') then -- synchronous reset
				comp_araddr <= (others => '0');
			else
				if (forward_sync = '0') then -- overwrite memory
					if (m_axi_awvalid_i = '1' and m_axi_awready_i = '1' and mem_full = '1') then
						comp_araddr <= comp_araddr + BURST_SIZE;
					end if;
				elsif (m_axi_rvalid_i = '1' and m_axi_rready_i = '1' and m_axi_rlast_i = '1') then
					comp_araddr <= comp_araddr + BURST_SIZE;
				end if;
			end if;
		end if;
	end process;

	-- #################### Read and Write FIFOs #################### --

	-- Write channel FIFO

	s_fifo_wch_rst <= not s_axis_aresetn;

	i_fifo_w: entity fifo_icwt
	generic map (
	C_FAMILY     => C_FAMILY,
	C_DEPTH      => C_FIFO_DEPTH,
	C_DIN_WIDTH  => C_S_AXIS_TDATA_WIDTH,
	C_DOUT_WIDTH => C_M_AXI_DATA_WIDTH,
	C_THRESH     => C_BURST_LEN
	)
	port map (
	rst        => s_fifo_wch_rst,
	wr_clk     => s_axis_aclk,
	rd_clk     => m_axi_aclk,
	din        => s_fifo_wch_data,
	wr_en      => s_fifo_wch_enable,
	rd_en      => m_fifo_wch_enable,
	dout       => m_fifo_wch_data,
	full       => s_fifo_wch_full,
	empty      => m_fifo_wch_empty,
	prog_full  => s_fifo_wch_pfull,
	prog_empty => m_fifo_wch_pempty
	);

	-- Read channel FIFO

	s_fifo_rch_rst <= not m_axi_aresetn;

	i_fifo_r: entity fifo_icwt
	generic map (
	C_FAMILY     => C_FAMILY,
	C_DEPTH      => C_FIFO_DEPTH,
	C_DIN_WIDTH  => C_M_AXI_DATA_WIDTH,
	C_DOUT_WIDTH => C_S_AXI_DATA_WIDTH,
	C_THRESH     => C_BURST_LEN
	)
	port map (
	rst        => s_fifo_rch_rst,
	wr_clk     => m_axi_aclk,
	rd_clk     => s_axi_aclk,
	din        => s_fifo_rch_data,
	wr_en      => s_fifo_rch_enable,
	rd_en      => m_fifo_rch_enable,
	dout       => m_fifo_rch_data,
	full       => s_fifo_rch_full,
	empty      => m_fifo_rch_empty,
	prog_full  => s_fifo_rch_pfull,
	prog_empty => m_fifo_rch_pempty
	);

end behavioral;
