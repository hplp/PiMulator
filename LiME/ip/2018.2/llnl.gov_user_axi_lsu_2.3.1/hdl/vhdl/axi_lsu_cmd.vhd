----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2014 08:48:00 AM
-- Design Name: 
-- Module Name: axi_lsu_cmd - behavioral
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

entity axi_lsu_cmd is
generic (
	-- Command Control
	C_AXIS_CTL_TID_WIDTH   : integer range 2 to 8 := 4;
	C_AXIS_CTL_TDEST_WIDTH : integer range 2 to 8 := 4;
	C_AXIS_CTL_TUSER_WIDTH : integer range 4 to 16 := 8;

	-- Command Registers
	C_DATA_WIDTH : integer := 32;
	C_ADDR_WIDTH : integer := 3;
	C_NREG : integer := 8;

	-- Memory Mapped
	C_AXI_MAP_ADDR_WIDTH : integer range 32 to 64 := 32;

	-- Stream Command and Status
	C_AXIS_CMD_TDATA_WIDTH : integer := 72; 
	C_AXIS_STS_TDATA_WIDTH : integer := 8
	);

port (
	aclk    : in  std_logic;
	aresetn : in  std_logic;

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

	------------------------------
	-- Stream Command Interface --
	------------------------------

	-- Stream Command Out
	m_axis_cmd_tdata  : out std_logic_vector(C_AXIS_CMD_TDATA_WIDTH-1 downto 0);
	m_axis_cmd_tvalid : out std_logic;
	m_axis_cmd_tready : in  std_logic;

	-- Stream Status In
	s_axis_sts_tdata  : in  std_logic_vector(C_AXIS_STS_TDATA_WIDTH-1 downto 0);
	s_axis_sts_tkeep  : in  std_logic_vector((C_AXIS_STS_TDATA_WIDTH/8)-1 downto 0);
	s_axis_sts_tlast  : in  std_logic;
	s_axis_sts_tvalid : in  std_logic;
	s_axis_sts_tready : out std_logic
	);

end axi_lsu_cmd;

architecture behavioral of axi_lsu_cmd is

--      load-store unit
--      register map
-- reg   31   bits   0
--     |---------------|
--   0 | status:32     | zero:24 okay:1 slverr:1 decerr:1 interr:1 treqstat:1 tdest:3
--   1 | addrhi/cmd:32 | addrhi:16 ignore:8 reqstat:1 ignore:4 command:3
--   2 | addrlo:32     |
--   3 | size:30       |
--   4 | inc/index:30  |
--   5 | rep/trans:30  |
--   6 | ignore:32     |
--   7 | ignore:32     |
--     |---------------|

constant C_SADDR_WIDTH : natural := (C_AXI_MAP_ADDR_WIDTH+7)/8*8;

signal tid : std_logic_vector(C_AXIS_CTL_TID_WIDTH-1 downto 0);

-- Command

constant CMD_nop    : std_logic_vector(2 downto 0) := "000";
constant CMD_move   : std_logic_vector(2 downto 0) := "001";
constant CMD_smove  : std_logic_vector(2 downto 0) := "010";
constant CMD_index  : std_logic_vector(2 downto 0) := "011";
constant CMD_index2 : std_logic_vector(2 downto 0) := "100";
constant CMD_flush  : std_logic_vector(2 downto 0) := "111";

alias command : std_logic_vector(3-1 downto 0) is vcmd(C_DATA_WIDTH*1+3-1 downto C_DATA_WIDTH*1);
alias reqstat : std_logic is vcmd(C_DATA_WIDTH*1+7);
alias addrhi  : std_logic_vector(16-1 downto 0) is vcmd(C_DATA_WIDTH*1+C_DATA_WIDTH-1 downto C_DATA_WIDTH*1+16);
alias addrlo  : std_logic_vector(C_DATA_WIDTH-1 downto 0) is vcmd(C_DATA_WIDTH*2+C_DATA_WIDTH-1 downto C_DATA_WIDTH*2);
alias size    : std_logic_vector(30-1 downto 0) is vcmd(C_DATA_WIDTH*3+30-1 downto C_DATA_WIDTH*3);
alias inc     : std_logic_vector(30-1 downto 0) is vcmd(C_DATA_WIDTH*4+30-1 downto C_DATA_WIDTH*4);
alias rep     : std_logic_vector(30-1 downto 0) is vcmd(C_DATA_WIDTH*5+30-1 downto C_DATA_WIDTH*5);
alias index   : std_logic_vector(30-1 downto 0) is vcmd(C_DATA_WIDTH*4+30-1 downto C_DATA_WIDTH*4);
alias trans   : std_logic_vector(30-1 downto 0) is vcmd(C_DATA_WIDTH*5+30-1 downto C_DATA_WIDTH*5);

-- Status
alias status : std_logic_vector(8-1 downto 0) is vcmd(8-1 downto 0);

begin

	-- synthesis translate_off
	assert C_AXIS_STS_TDATA_WIDTH = 8
		report "can only handle 8-bit status stream"
			severity FAILURE;
	-- synthesis translate_on

	vrsp(C_DATA_WIDTH*3+C_DATA_WIDTH-1 downto C_DATA_WIDTH*3) <= (others => '0');
	vwe(3) <= '0';
	vrsp(C_DATA_WIDTH*4+C_DATA_WIDTH-1 downto C_DATA_WIDTH*4) <= (others => '0');
	vwe(4) <= '0';
	vrsp(C_DATA_WIDTH*6+C_DATA_WIDTH-1 downto C_DATA_WIDTH*6) <= (others => '0');
	vwe(6) <= '0';
	vrsp(C_DATA_WIDTH*7+C_DATA_WIDTH-1 downto C_DATA_WIDTH*7) <= (others => '0');
	vwe(7) <= '0';

	-- save the id of this sub-unit
	tid_seq: process(aclk)
	begin
		if (rising_edge(aclk)) then
			if (aresetn = '0') then -- synchronous reset
				tid <= (others => '0');
			else
				if (command_valid = '1') then
					tid <= command_tdest;
				end if;
			end if;
		end if;
	end process;

	cmd: process(command_tid, command_valid, m_axis_cmd_tready, command, reqstat, addrhi, addrlo, size, inc, rep, index, trans, vcmd)
		variable rsvd : std_logic_vector(3 downto 0);
		variable tag : std_logic_vector(3 downto 0);
		variable saddr : std_logic_vector(C_SADDR_WIDTH-1 downto 0);
		variable iaddr : std_logic_vector((addrhi'length+addrlo'length)-1 downto 0);
		variable drr : std_logic;
		variable eof : std_logic;
		variable dsa : std_logic_vector(5 downto 0);
		variable typ : std_logic;
		variable btt : std_logic_vector(22 downto 0);
	begin
		rsvd := (others => '0');
		tag := reqstat & ext(command_tid,3);
		saddr := (others => '0');
		drr := '1';
		eof := '1';
		dsa := (others => '0');
		typ := '1';
		btt := (others => '0');

		m_axis_cmd_tvalid <= '0';
		command_ready <= '1';

		vrsp(C_DATA_WIDTH*1+C_DATA_WIDTH-1 downto C_DATA_WIDTH*1) <= vcmd(C_DATA_WIDTH*1+C_DATA_WIDTH-1 downto C_DATA_WIDTH*1);
		vwe(1) <= '0';
		vrsp(C_DATA_WIDTH*2+C_DATA_WIDTH-1 downto C_DATA_WIDTH*2) <= (others => '0');
		vwe(2) <= '0';
		vrsp(C_DATA_WIDTH*5+C_DATA_WIDTH-1 downto C_DATA_WIDTH*5) <= (others => '0');
		vwe(5) <= '0';

		if (command_valid = '1') then
			case command is
				when CMD_move =>
					saddr := ext(addrhi&addrlo,saddr'length);
					btt := ext(size,btt'length);
					m_axis_cmd_tvalid <= '1';
					command_ready <= m_axis_cmd_tready;
				when CMD_smove =>
					saddr := ext(addrhi&addrlo,saddr'length);
					btt := ext(size,btt'length);
					if (unsigned(rep) = 1) then -- last
						command_ready <= m_axis_cmd_tready;
					else
						command_ready <= '0';
						tag(tag'high) := '0';
						--eof := '0';
					end if;
					if (m_axis_cmd_tready = '1') then
						iaddr := unsigned(addrhi&addrlo) + unsigned(inc);
						vrsp(C_DATA_WIDTH*1+C_DATA_WIDTH-1 downto C_DATA_WIDTH*1+C_DATA_WIDTH-16) <= iaddr(C_DATA_WIDTH+16-1 downto C_DATA_WIDTH);
						vwe(1) <= '1';
						vrsp(C_DATA_WIDTH*2+C_DATA_WIDTH-1 downto C_DATA_WIDTH*2) <= iaddr(C_DATA_WIDTH-1 downto 0);
						vwe(2) <= '1';
						vrsp(C_DATA_WIDTH*5+rep'length-1 downto C_DATA_WIDTH*5) <= unsigned(rep) - 1;
						vwe(5) <= '1';
					end if;
					m_axis_cmd_tvalid <= '1';
				when CMD_index | CMD_index2 =>
					-- saddr := conv_unsigned(unsigned(index)*unsigned(size),saddr'length)+unsigned(addrhi&addrlo);
					saddr := conv_unsigned(unsigned(index)*conv_unsigned(unsigned(size),18),saddr'length) +
						conv_unsigned(unsigned(addrhi&addrlo),saddr'length); -- for DSP48
					if (command = CMD_index) then
						btt := ext(size,btt'length);
					else
						btt := ext(trans,btt'length);
					end if;
					m_axis_cmd_tvalid <= '1';
					command_ready <= m_axis_cmd_tready;
				when others => null;
			end case;
		end if;
		m_axis_cmd_tdata <= rsvd & tag & saddr & drr & eof & dsa & typ & btt;
	end process;

	rsp: process(s_axis_sts_tvalid, s_axis_sts_tkeep, s_axis_sts_tdata, status, tid, response_ready)
		alias treqstat : std_logic is s_axis_sts_tdata(3);
		alias tdest : std_logic_vector is s_axis_sts_tdata(2 downto 0);
		constant rsel : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := conv_std_logic_vector(0,C_ADDR_WIDTH);
		constant rlen : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := conv_std_logic_vector(1,C_ADDR_WIDTH);
	begin
		-- s_axis_sts_tlast is always set (from AXI DataMover v5.1)
		s_axis_sts_tready <= '1';

		vrsp(C_DATA_WIDTH-1 downto 0) <= ext(status or ext(s_axis_sts_tdata,status'length),C_DATA_WIDTH);
		vwe(0) <= '0';

		response_sel   <= rsel;
		response_len   <= rlen;
		response_tid   <= tid;
		response_tdest <= ext(tdest,response_tdest'length); -- from tag
		response_tuser <= '1' & '0' & rsel & rlen;
		response_valid <= '0';

		if (s_axis_sts_tvalid = '1' and s_axis_sts_tkeep(0) = '1') then
			if (treqstat = '1') then
				response_valid <= '1';
				s_axis_sts_tready <= response_ready;
			end if;
			-- FIXME: should vwe(0) depend on response_ready?
			-- Would need to have response_ready default to '1'.
			-- vwe(0) <= response_ready;
			vwe(0) <= '1';
		end if;
	end process;

end behavioral;
