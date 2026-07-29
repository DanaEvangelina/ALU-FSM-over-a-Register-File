----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.08.2025 16:48:55
-- Design Name: 
-- Module Name: SyM_C2 - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SyM_C2 is
	generic(N: integer:=4);
	port(
		ent : in std_logic_vector(N-1 downto 0);
		sal : out signed(N-1 downto 0)
		);
end SyM_C2;

architecture Behavioral of SyM_C2 is

begin
    sal <= signed(not('0' & ent(N-2 downto 0))) + 1 when ent(N-1)='1' else --niego y casteo a C2
            signed ('0' & ent(N-2 downto 0)); -- Casteo a C2 directamente

end Behavioral;
