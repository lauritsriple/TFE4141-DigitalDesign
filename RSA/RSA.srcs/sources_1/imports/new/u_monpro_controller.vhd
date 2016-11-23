library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity u_monpro_controller is
  port (
    -- Clocks and resets
    clk    : in std_logic;
    resetN : in std_logic;

    -- Datapath control signals
    mux1           : out std_logic;     -- the mux that chooses between A and n
    mux2           : out std_logic;  -- the mux that chooses between sum and sum >> 1
    M_reg_load_en  : out std_logic;
    M_reg_clear    : out std_logic;
    B_reg_load_en  : out std_logic;
    B_reg_shift_en : out std_logic;
    result_load_en : out std_logic;

    -- LSB from registers in datapath
    B0 : in std_logic;
    M0 : in std_logic;

    -- Control signals for the input interface
    startMonpro : in std_logic;

    --Control signals for the output interface
    coreFinished : out std_logic
    );

end u_monpro_controller;

architecture Behavioral of u_monpro_controller is
  type monpro_state is (IDLE, LOAD_B, CALC_MA, CALC_MN);
  signal curr_state, next_state : monpro_state;
  signal counter, counter_next  : integer range 0 to 130;
begin
  -- Lower section of FSM
  process (clk, resetN)
  begin
    if (resetN = '0') then
      curr_state <= IDLE;
      counter    <= 0;
    elsif (clk'event and clk = '1') then
      curr_state <= next_state;
      counter    <= counter_next;
    end if;
  end process;

  -- Upper section of FSM
  process (curr_state, startMonpro, B0, M0, counter)
  begin
    -- Default values
    mux1           <= '0';
    mux2           <= '0';
    M_reg_load_en  <= '0';
    M_reg_clear    <= '0';
    B_reg_load_en  <= '0';
    B_reg_shift_en <= '0';
    result_load_en <= '0';
    coreFinished   <= '0';
    counter_next   <= counter;

    case curr_state is
      when IDLE =>
        M_reg_clear <= '1';
        coreFinished <= '1';
        if (startMonpro = '1') then
          next_state <= LOAD_B;
        else
          next_state <= IDLE;
        end if;

      when LOAD_B =>
        B_reg_load_en <= '1';
        next_state    <= CALC_MA;

      when CALC_MA =>
        if (B0 = '1') then
          mux1          <= '0';
          mux2          <= '1';
          M_reg_load_en <= '1';
        end if;
        B_reg_shift_en <= '1';
        next_state     <= CALC_MN;

      when CALC_MN =>
        if (counter < 128) then
          if (M0 = '1') then
            mux1 <= '1';
            mux2 <= '1';
          else
            mux1 <= '1';
            mux2 <= '0';
          end if;
          M_reg_load_en <= '1';
          counter_next  <= counter + 1;
          next_state    <= CALC_MA;
        else
          result_load_en <='1';
          counter_next <= 0;
          next_state   <= IDLE;
        end if;
    end case;
  end process;
end Behavioral;
