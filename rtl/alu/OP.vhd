library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Computo is
    generic(N : integer := 4);
    port(
        a, b   : in  signed(N-1 downto 0);
        sel_op : in  std_logic_vector(1 downto 0); -- selector de operación
        r      : out signed(N downto 0);
        ovfw   : out std_logic
    );
end Computo;

architecture Behavioral of Computo is
    -- Señales internas para salidas de módulos
    signal r_add, r_prod, r_comp, r_resta : signed(N downto 0);
    signal b_neg : signed(N-1 downto 0);
    signal add_en, rest_en, prod_en, comp_en : std_logic;
    signal ovfw_prod : std_logic;

begin

add_en <= '1' when (sel_op = "01") else '0';
rest_en <= '1' when (sel_op = "10") else '0';
prod_en <= '1' when (sel_op = "11") else '0';
comp_en <= '1' when (sel_op = "00") else '0';
b_neg <= -b;

    -- Instancia del sumador
    U_ADD: entity work.adder
        generic map(N => N)
        port map(
            a => a,
            b => b,
            en => add_en,    
            r => r_add
        );
        
        -- Instancia del sumador
    U_REST: entity work.adder
        generic map(N => N)
        port map(
            a => a,
            b => b_neg,
            en => rest_en,    
            r => r_resta
        );

    -- Instancia del multiplicador
    U_PROD: entity work.prod
        generic map(N => N)
        port map(
            a => a,
            b => b,
            en => prod_en,      -- si tu prod no tiene 'en', habría que agregarlo
            r => r_prod,
            ovfw => ovfw_prod
        );

    -- Instancia del comparador
    U_COMP: entity work.comp
        generic map(N => N)
        port map(
            a => a,
            b => b,
            en => comp_en,
            r => r_comp
        );

    -- Multiplexor para seleccionar la operación
    with sel_op select
        r <= r_add  when "01",
             r_prod when "11",
             r_comp when "00",
             r_resta when "10",
             (others => '0') when others;

    -- Overflow solo desde prod (o podrías tener más flags combinados)
    ovfw <= ovfw_prod when sel_op="11" else
            '0';

end Behavioral;