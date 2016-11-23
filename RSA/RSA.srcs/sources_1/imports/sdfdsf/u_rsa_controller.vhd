library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity u_rsa_controller is
  port (
    clk    : in std_logic;
    resetN : in std_logic;

    monpro_mux_1_en1 : out std_logic;
    monpro_mux_1_en2 : out std_logic;
    monpro_mux_2_en1 : out std_logic;
    monpro_mux_2_en2 : out std_logic;

    Y_reg_shift_en     : out std_logic;
    X_reg_shift_en     : out std_logic;
    n_reg_shift_en     : out std_logic;
    e_reg_shift_en     : out std_logic;
    e_reg_shift_one_en : out std_logic;
    M_reg_shift_en     : out std_logic;
    R_reg_load_en      : out std_logic;
    R_reg_shift_en     : out std_logic;
    P_reg_load_en      : out std_logic;

    eMSB : in std_logic;

    monpro_start        : out std_logic;
    monpro_coreFinished : in  std_logic;

    initRsa      : in  std_logic;
    startRsa     : in  std_logic;
    coreFinished : out std_logic
    );
end u_rsa_controller;


architecture Behavioral of u_rsa_controller is
  type state is (IDLE, LOAD_KEYS, LOAD_MESSAGE, FIRST_PRECALC, SECOND_PRECALC,
                 FIRST_LOOP_CALC, SECOND_LOOP_CALC, POST_CALC, OUTPUT_DATA);
  signal curr_state, next_state              : state;
  signal counter, counter_next               : integer range 0 to 130;
  signal monpro_started, monpro_started_next : std_logic;

begin
  -- Lower section of FSM
  process (clk, resetN)
  begin
    if (resetN = '0') then
      curr_state <= IDLE;
      counter    <= 0;
      monpro_started <= '0';
    elsif (clk'event and clk = '1') then
      curr_state     <= next_state;
      counter        <= counter_next;
      monpro_started <= monpro_started_next;
    end if;
  end process;

  -- Upper section of FSM
  process(curr_state, startRsa, initRsa, counter, monpro_coreFinished, eMSB, monpro_started)
  begin
    Y_reg_shift_en      <= '0';
    X_reg_shift_en      <= '0';
    n_reg_shift_en      <= '0';
    e_reg_shift_en      <= '0';
    e_reg_shift_one_en  <= '0';
    M_reg_shift_en      <= '0';
    R_reg_load_en       <= '0';
    R_reg_shift_en      <= '0';
    P_reg_load_en       <= '0';
    monpro_mux_1_en1    <= '0';
    monpro_mux_1_en2    <= '0';
    monpro_mux_2_en1    <= '0';
    monpro_mux_2_en2    <= '0';
    monpro_start        <= '0';
    coreFinished        <= '0';
    counter_next        <= counter;
    monpro_started_next <= monpro_started;
    next_state          <= curr_state;

    case curr_state is
      when IDLE =>
        coreFinished <= '1';
        if (initRsa = '1') then
          Y_reg_shift_en <= '1';
          X_reg_shift_en <= '1';
          n_reg_shift_en <= '1';
          e_reg_shift_en <= '1';
          next_state <= LOAD_KEYS;
        elsif (startRsa = '1') then
          M_reg_shift_en <= '1';        next_state <= LOAD_MESSAGE;
        else
          next_state <= IDLE;
        end if;

      when LOAD_KEYS =>
        Y_reg_shift_en <= '1';
        X_reg_shift_en <= '1';
        n_reg_shift_en <= '1';
        e_reg_shift_en <= '1';

        --Counting one less, because first iteration is done in IDLE
        if (counter < 14) then
          counter_next <= counter + 1;
        else
          coreFinished <= '1';
          counter_next <= 0;
          next_state   <= IDLE;
        end if;

      when LOAD_MESSAGE =>
        M_reg_shift_en <= '1';
        --Counting one less, because first iteration is done in IDLE
        if (counter < 2) then
          counter_next <= counter + 1;
        else
          counter_next <= 0;
          next_state   <= FIRST_PRECALC;
        end if;

      when FIRST_PRECALC =>
        monpro_mux_1_en1 <= '1';
        monpro_mux_1_en2 <= '1';
        monpro_mux_2_en1 <= '1';
        monpro_mux_2_en2 <= '0';

        if (monpro_coreFinished = '1' and monpro_started = '0') then
          monpro_start        <= '1';
          monpro_started_next <= '1';
          next_state          <= FIRST_PRECALC;
        elsif (monpro_coreFinished = '1' and monpro_started = '1') then
          P_reg_load_en       <= '1';
          monpro_started_next <= '0';
          next_state          <= SECOND_PRECALC;
        else
          next_state <= FIRST_PRECALC;
        end if;

      when SECOND_PRECALC =>
        monpro_mux_1_en1 <= '1';
        monpro_mux_1_en2 <= '1';
        monpro_mux_2_en1 <= '0';
        monpro_mux_2_en2 <= '0';
        if (monpro_coreFinished = '1' and monpro_started = '0') then
          monpro_start        <= '1';
          monpro_started_next <= '1';
          next_state          <= SECOND_PRECALC;
        elsif (monpro_coreFinished = '1' and monpro_started = '1') then
          R_reg_load_en       <= '1';
          monpro_started_next <= '0';
          next_state          <= FIRST_LOOP_CALC;
        else
          next_state <= SECOND_PRECALC;
        end if;

      when FIRST_LOOP_CALC =>
        monpro_mux_1_en1 <= '1';
        monpro_mux_1_en2 <= '0';
        monpro_mux_2_en1 <= '1';
        monpro_mux_2_en2 <= '1';
        if (monpro_coreFinished = '1' and monpro_started = '0') then
          monpro_start        <= '1';
          monpro_started_next <= '1';
          next_state          <= FIRST_LOOP_CALC;
        elsif (monpro_coreFinished = '1' and monpro_started = '1') then
          R_reg_load_en       <= '1';
          monpro_started_next <= '0';
          next_state          <= SECOND_LOOP_CALC;
        else
          next_state <= FIRST_LOOP_CALC;
        end if;

      when SECOND_LOOP_CALC =>
        monpro_mux_1_en1 <= '0';
        monpro_mux_1_en2 <= '1';
        monpro_mux_2_en1 <= '1';
        monpro_mux_2_en2 <= '1';
        if (counter < 128) then
          if (eMSB = '1') then
            if (monpro_coreFinished = '1' and monpro_started = '0') then
              monpro_start        <= '1';
              monpro_started_next <= '1';
              next_state          <= SECOND_LOOP_CALC;
            elsif (monpro_coreFinished = '1' and monpro_started = '1') then
              R_reg_load_en       <= '1';
              monpro_started_next <= '0';
              next_state          <= FIRST_LOOP_CALC;
              counter_next        <= counter + 1;
              e_reg_shift_one_en  <= '1';
              if (counter=127) then
                next_state        <= POST_CALC;
                counter_next      <=0;
              end if;
            else
              next_state <= SECOND_LOOP_CALC;
            end if;
          else
            counter_next       <= counter + 1;
            next_state         <= FIRST_LOOP_CALC;
            e_reg_shift_one_en <= '1';
          end if;
        else
          next_state   <= POST_CALC;
          counter_next <= 0;
        end if;

      when POST_CALC =>
        monpro_mux_1_en1 <= '0';
        monpro_mux_1_en2 <= '0';
        monpro_mux_2_en1 <= '1';
        monpro_mux_2_en2 <= '1';
        if (monpro_coreFinished = '1' and monpro_started = '0') then
          monpro_start        <= '1';
          monpro_started_next <= '1';
          next_state          <= POST_CALC;
        elsif (monpro_coreFinished = '1' and monpro_started = '1') then
          R_reg_load_en       <= '1';
          monpro_started_next <= '0';
          next_state          <= OUTPUT_DATA;
        else
          next_state <= POST_CALC;
        end if;

      when OUTPUT_DATA =>
        R_reg_shift_en <= '1';
        if (counter>0) then
          coreFinished<='1';
        end if;
        if (counter < 3) then
          counter_next <= counter + 1;
          next_state   <= OUTPUT_DATA;
        else
          counter_next <= 0;
          next_state   <= IDLE;
        end if;
    end case;
  end process;
end Behavioral;

