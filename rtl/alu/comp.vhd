
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comp is
    generic (
        N : integer := 4
    );
    port (
        a : in  signed(N-1 downto 0);
        b : in  signed(N-1 downto 0);
        en    : in std_logic;  -- enabler
        r : out signed(N downto 0)  -- salida de 5 bits
    );
end comp;

architecture Behavioral of comp is
begin
    r <= (a(N-1) & a) when (a = b AND en= '1') else
         '1' & (N-1 downto 0 => '0') when (a /= b AND en='1') else
         to_signed(0, N+1); -- 10000
end Behavioral;
