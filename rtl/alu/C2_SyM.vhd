library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity C2_a_SyM is
    generic(N : integer := 4);
    port(
        ent : in  signed(N downto 0);  -- en C2
        sal : out std_logic_vector(N downto 0)  -- signo-magnitud
    );
end C2_a_SyM;

architecture Behavioral of C2_a_SyM is
    signal magnitud : unsigned(N-1 downto 0);
begin
    magnitud <= unsigned( not ent(N-1 downto 0) + 1 ) when ent(N) = '1' else
                unsigned( ent(N-1 downto 0) );

    sal <= '1' & std_logic_vector(magnitud) when ent(N) = '1' else
           '0' & std_logic_vector(magnitud);
end Behavioral;
