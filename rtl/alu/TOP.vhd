library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TOP is
    generic(N : integer := 5);
    port(
        a, b   : in  std_logic_vector(N-1 downto 0);
        sel_op : in  std_logic_vector(1 downto 0); -- selector de operación
        r      : out std_logic_vector(N downto 0);
        ovfw   : out std_logic
    );
end TOP;



architecture Behavioral of TOP is

signal a_C2, b_C2 : signed(N-1 downto 0);  -- 4 bits (N=4)
signal r_C2 : signed(N downto 0); -- 5 bits


begin

    -- Instancia de los conversores SyM a C2
    U_CONV1_A: entity work.SyM_C2
       generic map(N => N)
        port map(
            ent => a, 
            sal => a_C2
        );
        
    
    U_CONV1_B: entity work.SyM_C2
       generic map(N => N)
        port map(
            ent => b, 
            sal => b_C2
        );
        
        
    -- Instancia del modulo de computo        
    U_OP: entity work.Computo
       generic map(N => N)
        port map(
            a => a_C2, 
            b => b_C2,
            sel_op => sel_op,
            r => r_C2,
            ovfw => ovfw
        );
        
     -- Instancia del conversor C2 a SyM
     
    U_CONV2: entity work.C2_a_SyM
        generic map (N => N)
            port map (
            ent => r_C2,
            sal => r
    );
    

end Behavioral;