----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2014 06:06:40 PM
-- Design Name: 
-- Module Name: axi_shim - behavioral
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

library axi_shim_lib;
use axi_shim_lib.axi_shim_pkg.all;

entity axi_shim is

generic (
	C_AXI_PROTOCOL : integer := P_AXI4;
	C_MAP_WIDTH    : integer := 2;
	C_MAP_IN       : string := "00";
	C_MAP_OUT      : string := "00";

	-- AXI-Full Bus Interface
	C_AXI_ID_WIDTH     : integer := 1;
	C_AXI_ADDR_WIDTH   : integer := 32;
	C_AXI_DATA_WIDTH   : integer := 32
--	C_AXI_AWUSER_WIDTH : integer := 1; -- AXI4
--	C_AXI_ARUSER_WIDTH : integer := 1; -- AXI4
--	C_AXI_WUSER_WIDTH  : integer := 1; -- AXI4
--	C_AXI_RUSER_WIDTH  : integer := 1; -- AXI4
--	C_AXI_BUSER_WIDTH  : integer := 1 -- AXI4
);

port (
	-- AXI-Full Slave Bus Interface S_AXI
	s_axi_aclk     : in  std_logic;
	s_axi_aresetn  : in  std_logic;
	--
	s_axi_awid     : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0) := (others => '0');
	s_axi_awaddr   : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0) := (others => '0'); -- AXILITE
	s_axi_awlen    : in  std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0) := (others => '0'); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
	s_axi_awsize   : in  std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(log2rp(C_AXI_DATA_WIDTH/8),3));
	s_axi_awburst  : in  std_logic_vector(1 downto 0) := (0 => '1', others => '0');
	s_axi_awlock   : in  std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0) := (others => '0'); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
	s_axi_awcache  : in  std_logic_vector(3 downto 0) := (others => '0');
	s_axi_awprot   : in  std_logic_vector(2 downto 0) := (others => '0'); -- AXILITE
	s_axi_awqos    : in  std_logic_vector(3 downto 0) := (others => '0'); -- AXI4
	s_axi_awregion : in  std_logic_vector(3 downto 0) := (others => '0'); -- AXI4
--	s_axi_awuser   : in  std_logic_vector(C_AXI_AWUSER_WIDTH-1 downto 0) := (others => '0'); -- AXI4
	s_axi_awvalid  : in  std_logic;
	s_axi_awready  : out std_logic;
	--
	s_axi_wid      : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0) := (others => '0'); -- AXI3
	s_axi_wdata    : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0) := (others => '0'); -- AXILITE
	s_axi_wstrb    : in  std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '1'); -- AXILITE
	s_axi_wlast    : in  std_logic := '1';
--	s_axi_wuser    : in  std_logic_vector(C_AXI_WUSER_WIDTH-1 downto 0) := (others => '0'); -- AXI4
	s_axi_wvalid   : in  std_logic;
	s_axi_wready   : out std_logic;
	--
	s_axi_bid      : out std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
	s_axi_bresp    : out std_logic_vector(1 downto 0); -- AXILITE
--	s_axi_buser    : out std_logic_vector(C_AXI_BUSER_WIDTH-1 downto 0); -- AXI4
	s_axi_bvalid   : out std_logic;
	s_axi_bready   : in  std_logic;
	--
	s_axi_arid     : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0) := (others => '0');
	s_axi_araddr   : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0) := (others => '0'); -- AXILITE
	s_axi_arlen    : in  std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0) := (others => '0'); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
	s_axi_arsize   : in  std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(log2rp(C_AXI_DATA_WIDTH/8),3));
	s_axi_arburst  : in  std_logic_vector(1 downto 0) := (0 => '1', others => '0');
	s_axi_arlock   : in  std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0) := (others => '0'); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
	s_axi_arcache  : in  std_logic_vector(3 downto 0) := (others => '0');
	s_axi_arprot   : in  std_logic_vector(2 downto 0) := (others => '0'); -- AXILITE
	s_axi_arqos    : in  std_logic_vector(3 downto 0) := (others => '0'); -- AXI4
	s_axi_arregion : in  std_logic_vector(3 downto 0) := (others => '0'); -- AXI4
--	s_axi_aruser   : in  std_logic_vector(C_AXI_ARUSER_WIDTH-1 downto 0) := (others => '0'); -- AXI4
	s_axi_arvalid  : in  std_logic;
	s_axi_arready  : out std_logic;
	--
	s_axi_rid      : out std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
	s_axi_rdata    : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0); -- AXILITE
	s_axi_rresp    : out std_logic_vector(1 downto 0); -- AXILITE
	s_axi_rlast    : out std_logic;
--	s_axi_ruser    : out std_logic_vector(C_AXI_RUSER_WIDTH-1 downto 0); -- AXI4
	s_axi_rvalid   : out std_logic;
	s_axi_rready   : in  std_logic;

	-- AXI-Full Master Bus Interface M_AXI
	m_axi_aclk     : in  std_logic;
	m_axi_aresetn  : in  std_logic;
	--
	m_axi_awid     : out std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
	m_axi_awaddr   : out std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0); -- AXILITE
	m_axi_awlen    : out std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
	m_axi_awsize   : out std_logic_vector(2 downto 0);
	m_axi_awburst  : out std_logic_vector(1 downto 0);
	m_axi_awlock   : out std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
	m_axi_awcache  : out std_logic_vector(3 downto 0);
	m_axi_awprot   : out std_logic_vector(2 downto 0); -- AXILITE
	m_axi_awqos    : out std_logic_vector(3 downto 0); -- AXI4
	m_axi_awregion : out std_logic_vector(3 downto 0); -- AXI4
--	m_axi_awuser   : out std_logic_vector(C_AXI_AWUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_awvalid  : out std_logic;
	m_axi_awready  : in  std_logic;
	--
	m_axi_wid      : out std_logic_vector(C_AXI_ID_WIDTH-1 downto 0); -- AXI3
	m_axi_wdata    : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0); -- AXILITE
	m_axi_wstrb    : out std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0); -- AXILITE
	m_axi_wlast    : out std_logic;
--	m_axi_wuser    : out std_logic_vector(C_AXI_WUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_wvalid   : out std_logic;
	m_axi_wready   : in  std_logic;
	--
	m_axi_bid      : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0) := (others => '0');
	m_axi_bresp    : in  std_logic_vector(1 downto 0) := (others => '0'); -- AXILITE
--	m_axi_buser    : in  std_logic_vector(C_AXI_BUSER_WIDTH-1 downto 0) := (others => '0'); -- AXI4
	m_axi_bvalid   : in  std_logic;
	m_axi_bready   : out std_logic;
	--
	m_axi_arid     : out std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
	m_axi_araddr   : out std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0); -- AXILITE
	m_axi_arlen    : out std_logic_vector(AXI_LEN_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (3 downto 0), AXI4 (7 downto 0)
	m_axi_arsize   : out std_logic_vector(2 downto 0);
	m_axi_arburst  : out std_logic_vector(1 downto 0);
	m_axi_arlock   : out std_logic_vector(AXI_LOCK_WIDTH(C_AXI_PROTOCOL)-1 downto 0); -- AXI3 (1 downto 0), AXI4 (0 downto 0)
	m_axi_arcache  : out std_logic_vector(3 downto 0);
	m_axi_arprot   : out std_logic_vector(2 downto 0); -- AXILITE
	m_axi_arqos    : out std_logic_vector(3 downto 0); -- AXI4
	m_axi_arregion : out std_logic_vector(3 downto 0); -- AXI4
--	m_axi_aruser   : out std_logic_vector(C_AXI_ARUSER_WIDTH-1 downto 0); -- AXI4
	m_axi_arvalid  : out std_logic;
	m_axi_arready  : in  std_logic;
	--
	m_axi_rid      : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0) := (others => '0');
	m_axi_rdata    : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0) := (others => '0'); -- AXILITE
	m_axi_rresp    : in  std_logic_vector(1 downto 0) := (others => '0'); -- AXILITE
	m_axi_rlast    : in  std_logic := '1';
--	m_axi_ruser    : in  std_logic_vector(C_AXI_RUSER_WIDTH-1 downto 0) := (others => '0'); -- AXI4
	m_axi_rvalid   : in  std_logic;
	m_axi_rready   : out std_logic
);

end axi_shim;

architecture behavioral of axi_shim is

subtype rng_map is integer range C_AXI_ADDR_WIDTH-1 downto C_AXI_ADDR_WIDTH-C_MAP_WIDTH; -- map address range
subtype rng_low is integer range C_AXI_ADDR_WIDTH-C_MAP_WIDTH-1 downto 0; -- low address range

signal axi_awaddr : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal axi_araddr : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);

function to_slv(str : string) return std_logic_vector is
	alias tstr : string(str'length downto 1) is str;
	variable res : std_logic_vector(str'length-1 downto 0);
begin
	for idx in tstr'range loop
		if tstr(idx) = '0' then
			res(idx-1) := '0';
		else
			res(idx-1) := '1';
		end if;
	end loop;
	return res;
end function;

begin

	axi_awaddr(rng_low) <= s_axi_awaddr(rng_low);
	axi_awaddr(rng_map) <=
		to_slv(C_MAP_OUT) when s_axi_awaddr(rng_map) = to_slv(C_MAP_IN) else
		s_axi_awaddr(rng_map);

	axi_araddr(rng_low) <= s_axi_araddr(rng_low);
	axi_araddr(rng_map) <=
		to_slv(C_MAP_OUT) when s_axi_araddr(rng_map) = to_slv(C_MAP_IN) else
		s_axi_araddr(rng_map);

	m_axi_awid     <= s_axi_awid;
	m_axi_awaddr   <= axi_awaddr;
	m_axi_awlen    <= s_axi_awlen;
	m_axi_awsize   <= s_axi_awsize;
	m_axi_awburst  <= s_axi_awburst;
	m_axi_awlock   <= s_axi_awlock;
	m_axi_awcache  <= s_axi_awcache;
	m_axi_awprot   <= s_axi_awprot;
	m_axi_awqos    <= s_axi_awqos;
	m_axi_awregion <= s_axi_awregion;
--	m_axi_awuser   <= s_axi_awuser;
	m_axi_awvalid  <= s_axi_awvalid;
	s_axi_awready  <= m_axi_awready;

	m_axi_wid      <= s_axi_wid;
	m_axi_wdata    <= s_axi_wdata;
	m_axi_wstrb    <= s_axi_wstrb;
	m_axi_wlast    <= s_axi_wlast;
--	m_axi_wuser    <= s_axi_wuser;
	m_axi_wvalid   <= s_axi_wvalid;
	s_axi_wready   <= m_axi_wready;

	s_axi_bid      <= m_axi_bid;
	s_axi_bresp    <= m_axi_bresp;
--	s_axi_buser    <= m_axi_buser;
	s_axi_bvalid   <= m_axi_bvalid;
	m_axi_bready   <= s_axi_bready;

	m_axi_arid     <= s_axi_arid;
	m_axi_araddr   <= axi_araddr;
	m_axi_arlen    <= s_axi_arlen;
	m_axi_arsize   <= s_axi_arsize;
	m_axi_arburst  <= s_axi_arburst;
	m_axi_arlock   <= s_axi_arlock;
	m_axi_arcache  <= s_axi_arcache;
	m_axi_arprot   <= s_axi_arprot;
	m_axi_arqos    <= s_axi_arqos;
	m_axi_arregion <= s_axi_arregion;
--	m_axi_aruser   <= s_axi_aruser;
	m_axi_arvalid  <= s_axi_arvalid;
	s_axi_arready  <= m_axi_arready;

	s_axi_rid      <= m_axi_rid;
	s_axi_rdata    <= m_axi_rdata;
	s_axi_rresp    <= m_axi_rresp;
	s_axi_rlast    <= m_axi_rlast;
--	s_axi_ruser    <= m_axi_ruser;
	s_axi_rvalid   <= m_axi_rvalid;
	m_axi_rready   <= s_axi_rready;

end behavioral;
