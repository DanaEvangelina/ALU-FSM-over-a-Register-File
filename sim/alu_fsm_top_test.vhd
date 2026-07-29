----------------------------------------------------------------------------------
-- Institution: Instituto Balseiro
-- Dev:         Jose Quinteros del Castillo
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: ALU FSM testbench
--
-- Dependencies: None.
--
-- Revision: 2024-09-09
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity alu_fsm_top_test is
  -- port (

  -- );
end entity alu_fsm_top_test;

architecture sim of alu_fsm_top_test is
  -- interfaces to DUT
  signal sys_clk : std_logic;
  signal buttons : std_logic_vector(3 downto 0);
  signal switches : std_logic_vector(7 downto 0);
  signal error : std_logic;

  -- clock period
  constant T_CLK : time := 10 ns;

  -- buttons to functions mapping
  signal peek_en : std_logic;
  signal poke_en : std_logic;
  signal op_en : std_logic;
  signal sys_rst : std_logic;

  -- ALU operation codes
  constant POS_ADD : natural := 0;
  constant POS_SUB : natural := 1;
  constant POS_MUL : natural := 2;
  constant POS_EQ : natural := 3;

begin
  alu_fsm_top_solved_inst : entity work.alu_fsm_top
    generic map(
      SIM_ONLY => '1'
    )
    port map(
      sys_clk_in  => sys_clk,
      buttons_in  => buttons,
      switches_in => switches,
      sseg_out    => open,
      an_out      => open,
      error_out   => error
    );

  -- buttons to functions mapping
  buttons(0) <= poke_en;
  buttons(1) <= peek_en;
  buttons(2) <= op_en;
  buttons(3) <= sys_rst;

  clk_gen_proc : process
  begin
    sys_clk <= '0';
    wait for T_CLK/2;
    sys_clk <= '1';
    wait for T_CLK/2;
  end process;

  stimuli_gen_proc : process
  begin
    poke_en <= '0';
    peek_en <= '0';
    op_en <= '0';
    switches <= (others => '0');
    sys_rst <= '0';

    -- align to clock edge
    wait until rising_edge(sys_clk);
    -- do synchronous reset
    sys_rst <= '1';
    wait for T_CLK;
    sys_rst <= '0';
    wait for T_CLK;

    ---- load two values to the RAM by doing POKE
    -- -10 in address 3
    switches <= (others => '0');
    switches(6 downto 2) <= '1' & x"F";
    switches(1 downto 0) <= "11";
    poke_en <= '1';
    wait for T_CLK;
    poke_en <= '0';
    wait for T_CLK;

    -- 3 in address 2
    switches <= (others => '0');
    switches(6 downto 2) <= '0' & x"3";
    switches(1 downto 0) <= "10";
    poke_en <= '1';
    wait for T_CLK;
    poke_en <= '0';
    wait for T_CLK;

    --check if a value can be displayed in the SSEG by doing PEEK
    switches <= (others => '0');
    switches(1 downto 0) <= "10";
    peek_en <= '1';
    wait for T_CLK;
    peek_en <= '0';
    wait for 8 * T_CLK;

    -- operate: do addr3 * addr2 = addr1
    -- op_sel
    switches(7 downto 6) <= std_logic_vector(to_unsigned(POS_MUL, 2));
    -- op_addrres
    switches(1 downto 0) <= "01";
    -- op_addr0
    switches(3 downto 2) <= "11";
    -- op_addr1
    switches(5 downto 4) <= "10";
    op_en <= '1';
    wait for T_CLK;
    op_en <= '0';
    wait for 8 * T_CLK;

    -- -2 in address 3
    switches <= (others => '0');
    switches(6 downto 2) <= '1' & x"2";
    switches(1 downto 0) <= "11";
    poke_en <= '1';
    wait for T_CLK;
    poke_en <= '0';
    wait for T_CLK;

    -- operate: do addr3 * addr2 = addr1
    -- op_sel
    switches(7 downto 6) <= std_logic_vector(to_unsigned(POS_MUL, 2));
    -- op_addrres
    wait for 8*T_CLK;
    switches(1 downto 0) <= "01";
    -- op_addr0
    wait for 8*T_CLK;
    switches(3 downto 2) <= "11";
    wait for 8*T_CLK;
    -- op_addr1
    switches(5 downto 4) <= "10";
    wait for 8*T_CLK;
    op_en <= '1';
    wait for T_CLK;
    op_en <= '0';
    wait for 5 * T_CLK;

    wait for 20 * T_CLK;

    assert FALSE report "Sim ended OK" severity failure;
  end process;

end architecture sim;
