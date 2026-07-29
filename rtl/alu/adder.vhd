
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder is
    generic (
        N : integer := 4  
    );
    port (
        a, b : in signed(N-1 downto 0);
        en    : in std_logic;  -- enabler
        r    : out signed(N downto 0)  
    );
end adder;

architecture Behavioral of adder is
begin
    r <= (a(N-1) & a) + (b(N-1) & b) when en='1' else
         to_signed(0, N+1) when en= '0';
    
end Behavioral;