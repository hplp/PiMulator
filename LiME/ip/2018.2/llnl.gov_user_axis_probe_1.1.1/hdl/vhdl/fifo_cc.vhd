-------------------------------------------------------------------------------
-- File Name: fifo_cc.vhd
-- $Revision: 1.00.a $

-- Description: FIFO module with common clock for read and write port.

-- History:
--	04/28/07 Scott: original revision
--	09/03/07 Scott: added architecture virtexSRL with SRL FIFO - may be too slow
--	09/07/07 Scott: added architecture behaviorR with registered empty and full status
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; -- unsigned

library unisim;
use unisim.vcomponents.all; -- SRL16E

entity fifo_cc is
	generic (
		C_WIDTH : integer := 8; -- width of FIFO
		C_DEPTH : integer := 2; -- depth of FIFO
		C_FWFT  : integer := 1 -- first word fall through
	);
	port (
		clk   : in  std_logic;
		din   : in  std_logic_vector(C_WIDTH-1 downto 0);
		rd_en : in  std_logic;
		srst  : in  std_logic;
		wr_en : in  std_logic;
		dout  : out std_logic_vector(C_WIDTH-1 downto 0);
		empty : out std_logic;
		full  : out std_logic
	);
end entity;

-- Implemented with Virtex SRL FIFOs
architecture virtexSRL of fifo_cc is

	-- return the log base 2 of the argument x rounded to plus infinity
	function log2rp(x : natural) return natural is
		variable i : natural;
	begin
		i := 0;
		while (x > 2**i) loop
			i := i + 1;
		end loop;
		return i;
	end log2rp;

	signal count : unsigned (log2rp(C_DEPTH)-1 downto 0);
	signal addr : unsigned (3 downto 0);

	signal wr_en_i : std_logic;
	signal rd_en_i : std_logic;
	signal full_i  : std_logic;
	signal empty_i : std_logic;
	signal dout_i  : std_logic_vector(C_WIDTH-1 downto 0);

	component SRL16E is
		generic (
			INIT : bit_vector := X"0000"
		);
		port (
			Clk : in  std_logic;
			CE  : in  std_logic;
			D   : in  std_logic;
			A0  : in  std_logic;
			A1  : in  std_logic;
			A2  : in  std_logic;
			A3  : in  std_logic;
			Q   : out std_logic
		);
	end component SRL16E;

  begin

	assert C_DEPTH > 0 and C_DEPTH <= 16
	report "fifo_cc(virtexSRL): C_DEPTH must be less than or equal to 16"
	severity ERROR;

	wr_en_i <= '1' when (wr_en = '1' and full_i = '0') else '0';
	rd_en_i <= '1' when (rd_en = '1' and empty_i = '0') else '0';

	full <= full_i;
	empty <= empty_i;
	addr <= conv_unsigned(count, addr'length);

	fifo_proc : process (clk) is
	begin
		if (clk'event and clk = '1') then
			if (srst = '1') then
				full_i <= '0';
				empty_i <= '1';
				count <= (others => '1');
			else
				if (wr_en_i = '1' and rd_en_i = '0') then
					if (count = C_DEPTH-2) then full_i <= '1'; end if;
					empty_i <= '0';
					count <= count + 1;
				elsif (wr_en_i = '0' and rd_en_i = '1') then
					full_i <= '0';
					if (count = 0) then empty_i <= '1'; end if;
					count <= count - 1;
				end if;
			end if;
		end if;
	end process;

	fifo : for i in 0 to C_WIDTH-1 generate
		bit_i : SRL16E
		generic map (
			INIT => X"0000"
		)
		port map (
			CLK => clk, -- Clock input
			CE => wr_en_i, -- Clock enable input
			D => din(i), -- SRL data input
			A0 => addr(0), -- Select[0] input
			A1 => addr(1), -- Select[1] input
			A2 => addr(2), -- Select[2] input
			A3 => addr(3), -- Select[3] input
			Q => dout_i(i) -- SRL data output
		);
	end generate fifo;

	fwft_ys: if (C_FWFT /= 0) generate
		dout <= dout_i;
	end generate;

	fwft_no: if (C_FWFT = 0) generate
		process (clk) is
		begin
			if (clk'event and clk = '1') then
				if (srst = '1') then
					dout <= (others => '0');
				else
					if (rd_en_i = '1') then
						dout <= dout_i;
					end if;
				end if;
			end if;
		end process;
	end generate;

end virtexSRL;

-- The empty and full status are combinatorial
architecture behaviorC of fifo_cc is

	type std_logic_array is array (0 to C_DEPTH-1) of
		 std_logic_vector(C_WIDTH-1 downto 0);
	signal data : std_logic_array;
	signal rd_idx : integer range 0 to C_DEPTH-1;
	signal wr_idx : integer range 0 to C_DEPTH-1;

	signal last_wr : std_logic; -- last enable was a write

	signal idx_eq  : std_logic; -- indexes equal
	signal wr_en_i : std_logic;
	signal rd_en_i : std_logic;
	signal full_i  : std_logic;
	signal empty_i : std_logic;

begin

	wr_en_i <= '1' when (wr_en = '1' and full_i = '0') else '0';
	rd_en_i <= '1' when (rd_en = '1' and empty_i = '0') else '0';

	idx_eq <= '1' when (rd_idx = wr_idx) else '0';
	full_i <= idx_eq and last_wr;
	empty_i <= idx_eq and not last_wr;
	full <= full_i;
	empty <= empty_i;

	fifo_proc : process (clk) is
	begin
		if (clk'event and clk = '1') then
			if (srst = '1') then
				for i in 0 to C_DEPTH-1 loop
					data(i) <= (others => '0');
				end loop;
				rd_idx <= 0;
				wr_idx <= 0;
				last_wr <= '0';
			else
				if (wr_en_i = '1') then
					data(wr_idx) <= din;
					wr_idx <= (wr_idx + 1) mod C_DEPTH;
					last_wr <= '1';
				end if;
				if (rd_en_i = '1') then
					rd_idx <= (rd_idx + 1) mod C_DEPTH;
					last_wr <= '0';
				end if;
			end if;
		end if;
	end process;

	fwft_ys: if (C_FWFT /= 0) generate
		dout <= data(rd_idx);
	end generate;

	fwft_no: if (C_FWFT = 0) generate
		process (clk) is
		begin
			if (clk'event and clk = '1') then
				if (srst = '1') then
					dout <= (others => '0');
				else
					if (rd_en_i = '1') then
						dout <= data(rd_idx);
					end if;
				end if;
			end if;
		end process;
	end generate;

end behaviorC;

-- The empty and full status are registered
architecture behaviorR of fifo_cc is

	-- return the log base 2 of the argument x rounded to plus infinity
	function log2rp(x : natural) return natural is
		variable i : natural;
	begin
		i := 0;
		while (x > 2**i) loop
			i := i + 1;
		end loop;
		return i;
	end log2rp;

	constant DEPTH : integer := 2**log2rp(C_DEPTH); -- round to nearest power of 2

	type std_logic_array is array (0 to DEPTH-1) of
		 std_logic_vector(C_WIDTH-1 downto 0);
	signal data : std_logic_array;
	signal rd_idx : integer range 0 to DEPTH-1;
	signal wr_idx : integer range 0 to DEPTH-1;

	signal wr_en_i : std_logic;
	signal rd_en_i : std_logic;
	signal full_i  : std_logic;
	signal empty_i : std_logic;

begin

	wr_en_i <= '1' when (wr_en = '1' and full_i = '0') else '0';
	rd_en_i <= '1' when (rd_en = '1' and empty_i = '0') else '0';

	full <= full_i;
	empty <= empty_i;

	fifo_proc : process (clk) is
		variable wr_inc : integer range 0 to DEPTH-1;
		variable rd_inc : integer range 0 to DEPTH-1;
	begin
		if (clk'event and clk = '1') then
			wr_inc := (wr_idx + 1) mod DEPTH;
			rd_inc := (rd_idx + 1) mod DEPTH;
			if (srst = '1') then
				for i in 0 to DEPTH-1 loop
					data(i) <= (others => '0');
				end loop;
				rd_idx <= 0;
				wr_idx <= 0;
				full_i <= '0';
				empty_i <= '1';
			else
				if (wr_en_i = '1') then
					data(wr_idx) <= din;
					wr_idx <= wr_inc;
					if (rd_en_i = '0') then
						if (wr_inc = rd_idx) then full_i <= '1'; end if;
						empty_i <= '0';
					end if;
				end if;
				if (rd_en_i = '1') then
					rd_idx <= rd_inc;
					if (wr_en_i = '0') then
						full_i <= '0';
						if (rd_inc = wr_idx) then empty_i <= '1'; end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	fwft_ys: if (C_FWFT /= 0) generate
		dout <= data(rd_idx);
	end generate;

	fwft_no: if (C_FWFT = 0) generate
		process (clk) is
		begin
			if (clk'event and clk = '1') then
				if (srst = '1') then
					dout <= (others => '0');
				else
					if (rd_en_i = '1') then
						dout <= data(rd_idx);
					end if;
				end if;
			end if;
		end process;
	end generate;

end behaviorR;
