
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prod is
    generic (
        N : integer := 4
    );
    port (
        a, b  : in signed(N-1 downto 0);
        en    : in std_logic;  -- enabler
        r     : out signed(N downto 0);
        ovfw  : out std_logic
    );
end prod;

architecture Behavioral of prod is
    signal result : signed(2*N-1 downto 0);
    constant max_pos : signed(N downto 0) := to_signed(2**N - 1, N+1);
    constant min_neg : signed(N downto 0) := to_signed(-(2**N), N+1);
    signal truncated_result : signed(N downto 0);
begin
    result <= a * b;

    -- Overflow si el valor original está fuera del rango representable en N+1 bits
    ovfw <= '1' when (result > resize(max_pos, 2*N) or result < resize(min_neg, 2*N)) else '0';

    -- Si hay overflow, asignamos un valor especial (-2^N), si no, el resultado truncado
    r <=  (others => '0') when (en = '1' and (result > resize(max_pos, 2*N) or result < resize(min_neg, 2*N))) else
          result(N downto 0)              when (en = '1') else
          to_signed(0, N+1); 

end Behavioral;