----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2014 05:46:00 PM
-- Design Name: 
-- Module Name: axis_port - behavioral
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
use ieee.std_logic_arith.all;

entity axis_port is
generic (
	C_AXIS_CTL_TDATA_WIDTH : integer range 8 to 1024 := 32;
	C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
	C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	C_DATA_WIDTH : integer := 32;
	C_ADDR_WIDTH : integer := 3;
	C_NREG : integer := 8
	);

port (
	aclk    : in  std_logic;
	aresetn : in  std_logic;

	------------------
	-- Control Port --
	------------------

	-- Stream Control In
	s_axis_ctl_tdata  : in  std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
	s_axis_ctl_tid    : in  std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	s_axis_ctl_tdest  : in  std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	s_axis_ctl_tuser  : in  std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
	s_axis_ctl_tlast  : in  std_logic;
	s_axis_ctl_tvalid : in  std_logic;
	s_axis_ctl_tready : out std_logic;

	-- Stream Control Out
	m_axis_ctl_tdata  : out std_logic_vector(C_AXIS_CTL_TDATA_WIDTH-1 downto 0);
	m_axis_ctl_tid    : out std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	m_axis_ctl_tdest  : out std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	m_axis_ctl_tuser  : out std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);
	m_axis_ctl_tlast  : out std_logic;
	m_axis_ctl_tvalid : out std_logic;
	m_axis_ctl_tready : in  std_logic;

	-----------------------
	-- Command Interface --
	-----------------------

	-- Command Header
	command_tid   : out std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	command_tdest : out std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	command_tuser : out std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Command Sync
	command_valid : out std_logic;
	command_ready : in  std_logic;

	------------------------
	-- Register Interface --
	------------------------

	-- Vector Register Port, read and write
	vcmd : out std_logic_vector(C_DATA_WIDTH*C_NREG-1 downto 0);
	vrsp : in  std_logic_vector(C_DATA_WIDTH*C_NREG-1 downto 0);
	vwe  : in  std_logic_vector(C_NREG-1 downto 0);

	------------------------
	-- Response Interface --
	------------------------

	-- Response Registers
	response_sel : in std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	response_len : in std_logic_vector(C_ADDR_WIDTH-1 downto 0);

	-- Response Header
	response_tid   : in std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	response_tdest : in std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	response_tuser : in std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Response Sync
	response_valid : in  std_logic;
	response_ready : out std_logic
	);

end axis_port;

architecture behavioral of axis_port is

	-- Triple-ported register file, ports A, B, & V
	type reg_file is array(C_NREG-1 downto 0) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
	signal reg : reg_file;

	-- Register port A, write
	signal asel : integer range 0 to C_NREG-1;
	signal alen : integer range 0 to C_NREG-1;
	signal ain  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
	signal awe  : std_logic;

	-- Register port B, read
	signal bsel : integer range 0 to C_NREG-1;
	signal blen : integer range 0 to C_NREG-1;
	signal bout  : std_logic_vector(C_DATA_WIDTH-1 downto 0);

	-------------
	-- Command --
	-------------

	-- Assume s_axis_ctl_tuser same for multi-word message
	alias cgo : std_logic is s_axis_ctl_tuser(7);
	alias cwe : std_logic is s_axis_ctl_tuser(6);
	alias csel : std_logic_vector(2 downto 0) is s_axis_ctl_tuser(5 downto 3);
	alias clen : std_logic_vector(2 downto 0) is s_axis_ctl_tuser(2 downto 0);

	signal c_advance : std_logic; -- command advance

	signal awe_r  : std_logic; -- A port write enable
	signal asel_r : integer range 0 to 2**C_ADDR_WIDTH-1; -- A port register
	signal alen_r : integer range 0 to 2**C_ADDR_WIDTH-1; -- A port transfer length

	signal command_valid_i : std_logic;

	--------------
	-- Response --
	--------------

	signal r_advance : std_logic; -- response advance
	signal r_path : std_logic; -- response path, A = '0', B = '1'

	signal bsel_r : integer range 0 to 2**C_ADDR_WIDTH-1; -- B port register
	signal blen_r : integer range 0 to 2**C_ADDR_WIDTH-1; -- B port transfer length

	signal response_valid_i : std_logic;
	signal response_ready_i : std_logic;

	------------------------------------------
	-- Command Interface, Internal, Signals --
	------------------------------------------

	-- Command Header
	signal command_tid_s   : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	signal command_tdest_s : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	signal command_tuser_s : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Command Sync
	signal command_valid_s : std_logic;
	signal command_ready_s : std_logic;

	--------------------------------------------------
	-- Response Interface, Internal Port A, Signals --
	--------------------------------------------------

	-- Response Registers
	signal a_response_sel_s : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	signal a_response_len_s : std_logic_vector(C_ADDR_WIDTH-1 downto 0);

	-- Response Header
	signal a_response_tid_s   : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	signal a_response_tdest_s : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	signal a_response_tuser_s : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Response Sync
	signal a_response_valid_s : std_logic;
	signal a_response_ready_s : std_logic;

	-----------------------------------------
	-- Response Interface, Internal Port A --
	-----------------------------------------

	-- Response Registers
	signal a_response_sel_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	signal a_response_len_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0);

	-- Response Header
	signal a_response_tid_i   : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	signal a_response_tdest_i : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	signal a_response_tuser_i : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Response Sync
	signal a_response_valid_i : std_logic;
	signal a_response_ready_i : std_logic;

	-----------------------------------------
	-- Response Interface, Internal Port B --
	-----------------------------------------

	-- Response Registers
	signal b_response_sel_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	signal b_response_len_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0);

	-- Response Header
	signal b_response_tid_i   : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);
	signal b_response_tdest_i : std_logic_vector(C_AXIS_CTL_TDEST_WIDTH-1 downto 0);
	signal b_response_tuser_i : std_logic_vector(C_AXIS_CTL_TUSER_WIDTH-1 downto 0);

	-- Response Sync
	signal b_response_valid_i : std_logic;
	signal b_response_ready_i : std_logic;

begin

	-------------------
	-- Register File --
	-------------------

	assert C_NREG <= 2**C_ADDR_WIDTH
		report "too few address bits for number of registers"
		severity FAILURE;

	bout <= reg(bsel);

	gv: for i in C_NREG-1 downto 0 generate
		vcmd(C_DATA_WIDTH*i+C_DATA_WIDTH-1 downto C_DATA_WIDTH*i) <= reg(i);
	end generate;

	process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				for i in C_NREG-1 downto 0 loop
					reg(i) <= (others => '0');
				end loop;
			else
				for i in C_NREG-1 downto 0 loop
					if (vwe(i) = '1') then
						reg(i) <= vrsp(C_DATA_WIDTH*i+C_DATA_WIDTH-1 downto C_DATA_WIDTH*i);
					elsif (i = asel and awe = '1') then
						reg(i) <= ain;
					end if;
				end loop;
			end if;
		end if;
	end process;

	-------------
	-- Command --
	-------------

	-- alen  /= 0 : active
	-- alen   = 1 : last word
	-- alen_r = 0 : first word

	ain <= s_axis_ctl_tdata;

	process(awe_r, asel_r, alen_r, s_axis_ctl_tvalid, cwe, csel, clen, c_advance)
	begin
		awe <= awe_r;
		asel <= asel_r;
		alen <= alen_r;
		if (alen_r = 0) then
			if (s_axis_ctl_tvalid = '1') then
				awe <= cwe;
				asel <= conv_integer(unsigned(csel));
				alen <= conv_integer(unsigned(clen));
			else
				awe <= '0';
			end if;
		end if;
		if (c_advance = '0') then
			awe <= '0';
		end if;
	end process;

	process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				awe_r <= '0';
				asel_r <= 0;
				alen_r <= 0;
			else
				if (alen_r = 0) then
					awe_r <= awe;
				end if;
				if (c_advance = '1') then
					asel_r <= asel + 1;
					alen_r <= alen - 1;
				end if;
			end if;
		end if;
	end process;

	c_advance <= s_axis_ctl_tvalid and (
		not s_axis_ctl_tlast or ( -- if last,
			(cwe or a_response_ready_s) and -- if read, wait for response ready
			((not cgo and not cwe) or command_ready_s) -- if go or write, wait for command ready
		)
	);

	s_axis_ctl_tready <= c_advance;

	-- interface presents one cycle of delay and a bubble between responses
	-- is registered in both forward and reverse directions
	a_response_sel_s <= csel;
	a_response_len_s <= clen;
	a_response_tid_s <= s_axis_ctl_tdest; -- swap source and destination
	a_response_tdest_s <= s_axis_ctl_tid;
	a_response_tuser_s <= '1' & '0' & csel & clen;
	a_response_valid_s <= s_axis_ctl_tvalid and s_axis_ctl_tlast and not cwe;
	-- a_response_ready_s

	-- interface presents one cycle of delay
	-- is registered in the forward direction
	command_tid_s <= s_axis_ctl_tid;
	command_tdest_s <= s_axis_ctl_tdest;
	command_tuser_s <= s_axis_ctl_tuser;
	command_valid_s <= s_axis_ctl_tvalid and s_axis_ctl_tlast and cgo;
	-- command_ready_s

	--------------
	-- Response --
	--------------

	-- blen  /= 0 : active
	-- blen   = 1 : last word
	-- blen_r = 0 : first word

	-- give priority to response interface B

	process(aclk, aresetn, blen_r, a_response_valid_i)
	begin
		if (aclk = '1') then -- latch
			if (aresetn = '0') then -- synchronous reset
				r_path <= '1';
			else
				if (blen_r = 0) then
					r_path <= '1';
					if (a_response_valid_i = '1') then
						r_path <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	process(bsel_r, blen_r,
		a_response_valid_i, a_response_sel_i, a_response_len_i,
		b_response_valid_i, b_response_sel_i, b_response_len_i)
	begin
		bsel <= bsel_r;
		blen <= blen_r;
		if (blen_r = 0) then
			if (b_response_valid_i = '1') then
				bsel <= conv_integer(unsigned(b_response_sel_i));
				blen <= conv_integer(unsigned(b_response_len_i));
			elsif (a_response_valid_i = '1') then
				bsel <= conv_integer(unsigned(a_response_sel_i));
				blen <= conv_integer(unsigned(a_response_len_i));
			end if;
		end if;
	end process;

	process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				bsel_r <= 0;
				blen_r <= 0;
			else
				if (r_advance = '1') then
					bsel_r <= bsel + 1;
					blen_r <= blen - 1;
				end if;
			end if;
		end if;
	end process;

	response_valid_i <= b_response_valid_i when r_path = '1' else a_response_valid_i;
	r_advance <= response_valid_i and m_axis_ctl_tready when blen /= 0 else '0';

	m_axis_ctl_tdata <= bout;
	m_axis_ctl_tid <= b_response_tid_i when r_path = '1' else a_response_tid_i;
	m_axis_ctl_tdest <= b_response_tdest_i when r_path = '1' else a_response_tdest_i;
	m_axis_ctl_tuser <= b_response_tuser_i when r_path = '1' else a_response_tuser_i;
	m_axis_ctl_tlast <= '1' when blen = 1 else '0';
	m_axis_ctl_tvalid <= response_valid_i;
	-- m_axis_ctl_tready

	a_response_ready_i <= m_axis_ctl_tready when (r_path = '0' and blen < 2) else '0';
	b_response_ready_i <= m_axis_ctl_tready when (r_path = '1' and blen < 2) else '0';

	---------------------------------
	-- Command Interface, Internal --
	---------------------------------

	command_ready_s <= command_ready or not command_valid_i;
	command_valid <= command_valid_i;

	cii: process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				command_tid <= (others => '0');
				command_tdest <= (others => '0');
				command_tuser <= (others => '0');
				command_valid_i <= '0';
			else
				if (command_ready_s = '1') then
					command_tid <= command_tid_s;
					command_tdest <= command_tdest_s;
					command_tuser <= command_tuser_s;
					command_valid_i <= command_valid_s;
				end if;
			end if;
		end if;
	end process;

	-----------------------------------------
	-- Response Interface, Internal Port A --
	-----------------------------------------

	a_response_ready_s <= not a_response_valid_i;

	arii: process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				a_response_sel_i <= (others => '0');
				a_response_len_i <= (others => '0');
				a_response_tid_i <= (others => '0');
				a_response_tdest_i <= (others => '0');
				a_response_tuser_i <= (others => '0');
				a_response_valid_i <= '0';
			else
				if (a_response_ready_i = '1' or a_response_valid_i = '0') then
					a_response_sel_i <= a_response_sel_s;
					a_response_len_i <= a_response_len_s;
					a_response_tid_i <= a_response_tid_s;
					a_response_tdest_i <= a_response_tdest_s;
					a_response_tuser_i <= a_response_tuser_s;
					a_response_valid_i <= a_response_valid_s and not a_response_valid_i;
				end if;
			end if;
		end if;
	end process;

	-----------------------------------------
	-- Response Interface, Internal Port B --
	-----------------------------------------

	response_ready_i <= b_response_ready_i or not b_response_valid_i;
	response_ready <= response_ready_i;

	brii: process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				b_response_sel_i <= (others => '0');
				b_response_len_i <= (others => '0');
				b_response_tid_i <= (others => '0');
				b_response_tdest_i <= (others => '0');
				b_response_tuser_i <= (others => '0');
				b_response_valid_i <= '0';
			else
				if (response_ready_i = '1') then
					b_response_sel_i <= response_sel;
					b_response_len_i <= response_len;
					b_response_tid_i <= response_tid;
					b_response_tdest_i <= response_tdest;
					b_response_tuser_i <= response_tuser;
					b_response_valid_i <= response_valid;
				end if;
			end if;
		end if;
	end process;

end behavioral;
