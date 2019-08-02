----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 1/10/2015 08:42:30 PM
-- Design Name:
-- Module Name: axi_delay_pkg - behavioral
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


package axi_delay_pkg is

	constant P_AXI4 : integer := 0;
	constant P_AXI3 : integer := 1;
	constant P_AXILITE : integer := 2;

	-- protocol = 0:AXI4 1:AXI3 2:AXILITE
	function axi_len_width  (constant p : in integer) return integer;
	function axi_lock_width (constant p : in integer) return integer;

	function ite(constant i : boolean; t, e : integer) return integer;

	-- return the log base 2 of the argument x rounded to plus infinity
	function log2rp (x : natural) return natural;

end axi_delay_pkg;

package body axi_delay_pkg is

	function axi_len_width (constant p : in integer) return integer is
	begin
		if (p = P_AXI3) then return 4; else return 8; end if;
	end axi_len_width;

	function axi_lock_width (constant p : in integer) return integer is
	begin
		if (p = P_AXI3) then return 2; else return 1; end if;
	end axi_lock_width;

	function ite(constant i : boolean; t, e : integer) return integer is
	begin
		if (i) then return t; else return e; end if;
	end ite;

	function log2rp (x : natural) return natural is
		variable i : natural;
	begin
		i := 0;
		while (x > 2**i) loop
			i := i + 1;
		end loop;
		return i;
	end log2rp;

end axi_delay_pkg;
