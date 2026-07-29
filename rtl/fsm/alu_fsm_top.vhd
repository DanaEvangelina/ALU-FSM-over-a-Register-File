----------------------------------------------------------------------------------
-- Institution: Instituto Balseiro
-- Dev:         Jose Quinteros del Castillo
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: ALU FSM top
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
use work.sdp_ram_pkg.all;

entity alu_fsm_top is
  generic (
    SIM_ONLY : std_logic := '0'
  );
  port (
    sys_clk_in  : in std_logic;

    buttons_in  : in std_logic_vector(3 downto 0);
    switches_in : in std_logic_vector(7 downto 0);

    sseg_out    : out std_logic_vector(7 downto 0);
    an_out      : out std_logic_vector(3 downto 0);
    error_out   : out std_logic
  );
end entity alu_fsm_top;

architecture rtl of alu_fsm_top is
  signal sys_rst : std_logic;

  -- PEEK function: read a value from the RAM
  signal peek_en : std_logic;
  signal peek_addr : ram_addr_t;
  signal peek_data : ram_data_t;
  signal peek_valid : std_logic;

  -- POKE function: writes a value to the RAM
  signal poke_en : std_logic;
  signal poke_addr : ram_addr_t;
  signal poke_data : ram_data_t;

  -- OP function: operates over RAM values
  signal op_en : std_logic;
  signal op_sel : std_logic_vector(1 downto 0);
  signal op_addrres : ram_addr_t;
  signal op_addr0 : ram_addr_t;
  signal op_addr1 : ram_addr_t;

  -- ALU can write or read to the RAM
  signal alu_wr_en : std_logic;
  signal alu_wr_addr : ram_addr_t;
  signal alu_wr_data : ram_data_t;
  signal alu_rd_en : std_logic;
  signal alu_rd_addr : ram_addr_t;
  signal alu_rd_data : ram_data_t;
  signal sseg0 : std_logic_vector(4 downto 0);
  signal sseg1 : std_logic_vector(4 downto 0);
  signal sseg2 : std_logic_vector(4 downto 0);
  signal sseg3 : std_logic_vector(4 downto 0);
  signal sseg_en : std_logic_vector(3 downto 0);
begin

  -- Input conditioning, to avoid glitches in the rest of the logic
  input_conditioning_inst : entity work.input_conditioning
    generic map(
      SIM_ONLY => SIM_ONLY
    )
    port map(
      sys_clk_in     => sys_clk_in,
      buttons_in     => buttons_in,
      switches_in    => switches_in,
      sys_rst_out    => sys_rst,
      poke_addr_out  => poke_addr,
      poke_data_out  => poke_data,
      poke_en_out    => poke_en,
      peek_addr_out  => peek_addr,
      peek_en_out    => peek_en,
      op_sel_out     => op_sel,
      op_addrres_out => op_addrres,
      op_addr0_out   => op_addr0,
      op_addr1_out   => op_addr1,
      op_en_out      => op_en
    );

  -- Arbitered RAM
  -- Write masters: poke function or ALU FSM
  -- Read masters: peek function or ALU FSM
  arbitered_ram_inst : entity work.arbitered_ram
    port map(
      sys_clk_in   => sys_clk_in,
      rd0_en_in    => peek_en,
      rd0_addr_in  => peek_addr,
      rd0_data_out => peek_data,
      rd1_en_in    => alu_rd_en,
      rd1_addr_in  => alu_rd_addr,
      rd1_data_out => alu_rd_data,
      wr0_en_in    => poke_en,
      wr0_addr_in  => poke_addr,
      wr0_data_in  => poke_data,
      wr1_en_in    => alu_wr_en,
      wr1_addr_in  => alu_wr_addr,
      wr1_data_in  => alu_wr_data
    );

  -- ALU FSM (ToDo)
alu_fsm_inst : entity work.alu_fsm
  port map (
    sys_clk_in   => sys_clk_in,
    op_en        => op_en,
    op_sel       => op_sel,
    op_addr0     => op_addr0,
    op_addr1     => op_addr1,
    op_addrres   => op_addrres,
    alu_wr_en    => alu_wr_en,
    alu_wr_addr  => alu_wr_addr,
    alu_wr_data  => alu_wr_data,
    alu_rd_en    => alu_rd_en,
    alu_rd_addr  => alu_rd_addr,
    alu_rd_data  => alu_rd_data,
    error_out    => error_out
  );
  -- ...

  -- Delay peek_en to qualify peek_data
  -- RAM introduces 1 clock cycle delay
  process (sys_clk_in)
  begin
    if rising_edge(sys_clk_in) then
      peek_valid <= peek_en;
    end if;
  end process;

  -- Decides if we will display the PEEK function or the ALU result
  sseg_arbiter_inst : entity work.sseg_arbiter
    generic map(
      N => MEM_WIDTH
    )
    port map(
      sys_clk_in     => sys_clk_in,
      sys_rst_in     => sys_rst,

      data0_in       => alu_wr_data,
      data0_valid_in => alu_wr_en,

      data1_in       => peek_data,
      data1_valid_in => peek_valid,

      sseg0_out      => sseg0,
      sseg1_out      => sseg1,
      sseg2_out      => sseg2,
      sseg3_out      => sseg3,
      sseg_en_out    => sseg_en
    );

  -- SSEG controller
  sseg_controller_inst : entity work.sseg_controller
    generic map(
      SIM_ONLY => SIM_ONLY
    )
    port map(
      sys_clk_in => sys_clk_in,
      sys_rst_in => sys_rst,
      sseg0_in   => sseg0,
      sseg1_in   => sseg1,
      sseg2_in   => sseg2,
      sseg3_in   => sseg3,
      sseg_en_in => sseg_en,
      sseg_out   => sseg_out,
      an_out     => an_out
    );

end architecture rtl;
