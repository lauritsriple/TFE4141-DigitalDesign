library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity u_monpro_controller is
    port (
    -- Clocks and resets
    clk                 : in std_logic;
    resetN              : in std_logic;
    
    -- Datapath control signals
    mux1                : out std_logic; -- the mux that chooses between A and n
    mux2                : out std_logic; -- the mux that chooses between sum and sum_shift
    M_reg_load_en       : out std_logic;
    B_reg_load_en       : out std_logic;
    B_reg_shift_en      : out std_logic;
    
    -- LSB from registers in datapath
    B0                  : in std_logic;
    M0                  : in std_logic;
    
    -- Control signals for the input interface
    startMonpro         : in std_logic;
    
    --Control signals for the output interface
    coreFinished        : out std_logic
    );
    
end u_monpro_controller;

architecture Behavioral of u_monpro_controller is
    type state is (IDLE, LOAD_B, CALC_MA, CALC_Mn);
    signal adder_wait : integer range 0 to 3;
    signal curr_state : state;
    signal substate_counter : integer range 0 to 130;

begin
    process(curr_state, substate_counter, clk, resetN, startMonpro)
    begin
        if (resetN='0') then
            mux1          <= '0';
            mux2          <= '0';
            M_reg_load_en <= '0';
            B_reg_load_en <= '0';
            B_reg_shift_en    <= '0';
            coreFinished <= '1';
            substate_counter <= 0;
            adder_wait <= 0;
        elsif(clk'event and clk='1') then
            M_reg_load_en <= '0';
            B_reg_load_en <= '0';
            B_reg_shift_en <= '0';
        end if;
        
        case (curr_state) is
        when IDLE =>
            if (startMonpro = '1') then
                curr_state <= LOAD_B;
                coreFinished <= '0';
            end if;
        when LOAD_B =>
           if (clk'event and clk = '1') then
               B_reg_load_en <= '1';
               curr_state <= CALC_MA;
           end if;
        when CALC_MA =>
            if (clk'event and clk = '1') then
                if (adder_wait = 0) then
                    if (B0 = '1') then 
                        mux1 <= '0';
                        mux2 <= '1';
                        M_reg_load_en <= '1';
                    end if;
                    B_reg_shift_en <= '1';
                    adder_wait <= 1;
                    --curr_state <= CALC_Mn;
                elsif (adder_wait <= 2) then
                    adder_wait <= adder_wait + 1;
                elsif (adder_wait >2) then
                    curr_state <= CALC_Mn;
                    adder_wait <= 0;    
                end if;
                
            end if;
            
        when CALC_Mn =>
            if (substate_counter < 128) then
                if (clk'event and clk='1') then
                    if (adder_wait = 0) then
                        if (M0 = '1') then
                            mux1 <= '1';
                            mux2 <= '1';
                            M_reg_load_en <= '1';
                        else
                            mux1 <= '1';
                            mux2 <= '0';
                            M_reg_load_en <= '1';
                        end if;
                        substate_counter <= substate_counter + 1;
                        adder_wait <= 1;
                        --curr_state <= CALC_MA;
                    elsif (adder_wait <= 2) then
                        adder_wait <= adder_wait + 1;
                    elsif (adder_wait > 2) then
                        curr_state <= CALC_MA;
                        adder_wait <= 0;
                    end if;
                end if;
            else
                substate_counter <= 0;
                curr_state <= IDLE;
                coreFinished <= '1';
            end if;
        end case;
    end process;
end Behavioral;
                    
             
--    process (Clk,ResetN,StartMonpro) is
--        variable Counter    : unsigned(7 downto 0); -- Can represent 256 values
--    begin
--        if (ResetN='0') then
--            mux1 <= '0';
--            mux2 <= '0';
--            M_reg_load_en <= '0';
--            B_reg_load_en <= '0';
--            B_reg_shift_en <= '0';
--            Counter:= x"ff";
--            coreFinished <='1';

--        --Normal monpro operation
--        elsif (Clk'event and Clk='1') then
--            -- Pulsed signals
--            M_reg_load_en<='0';
--            B_reg_load_en<='0';
--            B_reg_shift_en<='0';
            
--            if (StartMonpro='1') then
--                CoreFinished<='0';
--                Counter:=x"00";
--                B_reg_load_en<='1';

--            elsif (Counter >=255) then --Check if finished
--                CoreFinished<='1';
--            else
--                -- Alternate between two operations based on even or odd counter.
--                -- M+A (counter is odd) or M+n>>1 (counter is even) 
--                if (Counter(0)='0') then            -- Counter is even
--                    if (B0='1') then                    -- B_i is odd
--                        mux1<='0';                  -- Mux choosing A and not shifting
--                        mux2<='1';
--                        M_reg_load_en<='1';         -- Enable input so we can overwrite M with M+A
--                    end if;
--                    B_reg_shift_en<='1';            -- Shifting B so we can get B_(i+1) next time
                    
--                else                            -- Counter is odd
--                    if (M0='1') then                -- M[0] is 
--                        mux1<='1';                  -- Mux choosing n and shifting
--                        mux2<='1';                  -- Mux choosing operand to be mux1_out
--                    else
--                        mux1<='1'; 
--                        mux2<='0';
--                    end if;
--                    M_reg_load_en<='1';         -- Enable input so we can overwrite M with M+n
--                end if;
--                counter:=counter+1;
--            end if;
--        end if;
--        end process;
--end Behavioral;