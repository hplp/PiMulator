----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2016 08:50:00 AM
-- Design Name: 
-- Module Name: short_hash - behavioral
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

entity short_hash is
generic (
	-- Stream Data
	C_AXIS_DAT_TDATA_WIDTH : integer := 128;
	C_AXIS_DAT_TUSER_WIDTH : integer := 8;
	-- Stream Tap
	C_AXIS_TAP_TDATA_WIDTH : integer := 256
	);
port (
	aclk    : in  std_logic;
	aresetn : in  std_logic;

	-- Stream Data In, key and key length in bytes
	s_axis_dat_tdata  : in  std_logic_vector(C_AXIS_DAT_TDATA_WIDTH-1 downto 0);
	s_axis_dat_tuser  : in  std_logic_vector(C_AXIS_DAT_TUSER_WIDTH-1 downto 0);
	s_axis_dat_tvalid : in  std_logic;
	s_axis_dat_tready : out std_logic;

	-- Stream Tap In, seed in
	s_axis_tap_tdata  : in  std_logic_vector(C_AXIS_TAP_TDATA_WIDTH-1 downto 0);
	s_axis_tap_tvalid : in  std_logic;
	s_axis_tap_tready : out std_logic;

	-- Stream Tap Out, hash out
	m_axis_tap_tdata  : out std_logic_vector(C_AXIS_TAP_TDATA_WIDTH-1 downto 0);
	m_axis_tap_tvalid : out std_logic;
	m_axis_tap_tready : in  std_logic
	);

end short_hash;

architecture behavioral of short_hash is

constant NUM_WIDTH : integer := C_AXIS_TAP_TDATA_WIDTH / 4;
subtype num is unsigned(NUM_WIDTH-1 downto 0);
type num_vector is array (natural range <>) of num;
subtype stages is natural range 0 to 11;

procedure emix (
	signal y, x, w, v: inout num_vector; -- variables
	constant ro: in natural; -- rotate
	constant ns: in natural -- next stage
) is
	variable xr: num;
begin
	xr := x(ns-1) rol ro;
	v(ns) <= v(ns-1);
	w(ns) <= w(ns-1);
	x(ns) <= xr;
	y(ns) <= (y(ns-1) xor x(ns-1)) + xr;
end emix;

signal len  : num;
signal data : num_vector(1 downto 0);
signal tapi : num_vector(3 downto 0);

signal a, b, c, d : num_vector(stages);
signal v : std_logic_vector(stages);

begin

	len <= resize(unsigned(s_axis_dat_tuser), NUM_WIDTH);
	gdat: for i in data'range generate
		data(i) <= unsigned(s_axis_dat_tdata(NUM_WIDTH*(i+1)-1 downto NUM_WIDTH*i));
	end generate;
	gtap: for i in tapi'range generate
		tapi(i) <= unsigned(s_axis_tap_tdata(NUM_WIDTH*(i+1)-1 downto NUM_WIDTH*i));
	end generate;

	s_axis_dat_tready <= m_axis_tap_tready and s_axis_tap_tvalid;
	s_axis_tap_tready <= m_axis_tap_tready and s_axis_dat_tvalid;

	process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				a <= (others => (others => '0'));
				b <= (others => (others => '0'));
				c <= (others => (others => '0'));
				d <= (others => (others => '0'));
				v <= (others => '0');
			else
				if (m_axis_tap_tready = '1') then
					a(0) <= tapi(0) xor     len;
					b(0) <= tapi(1) xor not len;
					c(0) <= tapi(2) + data(0);
					d(0) <= tapi(3) + data(1);

					emix(d,c,b,a,15, 1);
					emix(a,d,c,b,52, 2);
					emix(b,a,d,c,26, 3);

					emix(c,b,a,d,51, 4);
					emix(d,c,b,a,28, 5);
					emix(a,d,c,b, 9, 6);
					emix(b,a,d,c,47, 7);

					emix(c,b,a,d,54, 8);
					emix(d,c,b,a,32, 9);
					emix(a,d,c,b,25,10);
					emix(b,a,d,c,63,11);

					v <= (s_axis_dat_tvalid and s_axis_tap_tvalid) & v(0 to v'high-1);
				end if;
			end if;
		end if;
	end process;

	m_axis_tap_tdata <=
		std_logic_vector(resize(d(11) & c(11) & b(11) & a(11), C_AXIS_TAP_TDATA_WIDTH));
	m_axis_tap_tvalid <= v(v'high);

end behavioral;
