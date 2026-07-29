----------------------------------------------------------------------------------
-- Company: IB 
-- Engineer: Dana Evangelina Gonzalez 
-- 
-- Create Date: 04.09.2025 17:06:56
-- Design Name: 
-- Module Name: alu_fsm - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.sdp_ram_pkg.all;


entity alu_fsm is
  generic(N : integer := 5);
  Port (
    sys_clk_in : in std_logic;
    op_en : in std_logic;
    op_sel : in std_logic_vector(1 downto 0);
    op_addrres : in ram_addr_t;
    op_addr0 : in ram_addr_t;
    op_addr1 : in ram_addr_t;
    alu_wr_en : out std_logic;
    alu_wr_addr : out ram_addr_t;
    alu_wr_data : out ram_data_t;
    alu_rd_en : out std_logic;
    alu_rd_addr : out ram_addr_t;
    alu_rd_data : in ram_data_t;
    error_out : out std_logic
  );
end alu_fsm;

architecture Behavioral of alu_fsm is

-- FSM signals
type state_type is (IDLE, READ_0, WAIT_0, READ_1, WAIT_1, OP, WRITE, ER);
signal state_reg, state_next : state_type;

-- Data path signals
signal num1_reg, num1_next : ram_data_t;
signal num2_reg, num2_next : ram_data_t;
signal result : std_logic_vector(N downto 0);
signal alu_error : std_logic;

-- Control signals
signal en_0 : std_logic;
signal en_1 : std_logic;

begin

-- ALU instance
alu_inst : entity work.TOP(Behavioral)
    generic map(
        N  => N
    )
    port map(
        a => num1_reg,
        b => num2_reg,
        sel_op=> op_sel,
        r => result,
        ovfw => alu_error
    );

-- Registro de estado y datos
process(sys_clk_in)
begin
    if rising_edge(sys_clk_in) then
        state_reg <= state_next;
        
        if en_0 = '1' then
            num1_reg <= num1_next;
        else 
             num1_reg <= num1_reg;
        end if;
        
        if en_1 = '1' then
            num2_reg <= num2_next;
        else 
             num2_reg <= num2_reg;
        end if;

    end if;
end process;

-- Logica del proximo estado
process(state_reg, op_en, alu_error)
begin
    -- Default
    state_next <= state_reg;

    case state_reg is
        when IDLE =>
            if op_en = '1' then
                state_next <= READ_0;
            end if;

        when READ_0 =>
            state_next <= WAIT_0;

        when WAIT_0 =>
            state_next <= READ_1;

        when READ_1 =>
            state_next <= WAIT_1;

        when WAIT_1 =>
            state_next <= OP;

        when OP =>
            if alu_error = '1' then
                state_next <= ER;
            else
                state_next <= WRITE;
            end if;

        when WRITE =>
            state_next <= IDLE;

        when ER =>
            state_next <= IDLE;

        when others =>
            state_next <= IDLE;
    end case;
end process;

-- Logica de outputs
process(state_reg, op_addr0, op_addr1, op_addrres, alu_rd_data, op_sel, alu_error, result)
begin
    -- Default values
    alu_rd_en <= '0';
    alu_rd_addr <= 0;
    alu_wr_en <= '0';
    alu_wr_addr <= 0;
    alu_wr_data <= (others => '0');
    error_out <= '0';
    en_0 <= '0';
    en_1 <= '0';
    num1_next <= (others => '0');
    num2_next <= (others => '0');
    
    case state_reg is
        when IDLE =>
            -- Valores por defecto ya asignados

        when READ_0 =>
            en_0 <= '1';
            alu_rd_en <= '1';
            alu_rd_addr <= op_addr0;
            num1_next <= alu_rd_data;
             
        when WAIT_0 =>
           -- en_0 <= '1';
            --num1_next <= alu_rd_data;
            -- Mantener valores por defecto
             
        when READ_1 =>
            en_1 <= '1';
            alu_rd_en <= '1';
            alu_rd_addr <= op_addr1;
            num2_next <= alu_rd_data;
      
        when WAIT_1 =>
            --en_1 <= '1';
           -- num2_next <= alu_rd_data;
            -- Mantener valores por defecto
             
        when OP =>
            error_out <= alu_error;
       
        when WRITE =>
            alu_wr_en <= '1';
            alu_wr_addr <= op_addrres;
            
            -- Chequear error de ALU
            if alu_error = '1' then
                error_out <= '1';
                alu_wr_data <= (others => '0');
            else
                -- 
                alu_wr_data <= result(N)&result(N-2 downto 0);
            end if;
                
        when ER =>
            error_out <= '1';
    
    end case;
end process;

end Behavioral;