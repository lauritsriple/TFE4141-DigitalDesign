library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
begin
    process (Clk,ResetN,StartMonpro) is
        variable Counter    : unsigned(7 downto 0); -- Can represent 256 values
    begin
        if (ResetN='0') then
            mux1 <= (others => '0');
            mux2 <= (others => '0');
            M_reg_load_en <= (others => '0');
            B_reg_load_en <= (others => '0');
            B_reg_shift_en <= (others => '0');
            Counter <= 255;
            coreFinished <='1';
        end if;
        
        if (StartMonpro='1') then
            CoreFinished<='0';
            Counter<='0';
        --Normal monpro operation
        elsif (Clk'event and Clk='1') then
            -- Pulsed signals
            M_reg_load_en<='0';
            B_reg_load_en<='0';
            B_reg_shift_en<='0';
            
            if (Counter >=255) then --Check if finished
                CoreFinished<='1';
            else
                -- Alternate between two operations based on even or odd counter.
                -- M+A (counter is odd) or M+n>>1 (counter is even) 
                if (Counter(0)='0') then            -- Counter is even
                    if (B0) then                    -- B_i is odd
                        mux1<='0';                  -- Mux choosing A
                        mux2<='0';                  -- Mux choosing M
                        M_reg_load_en<='1';         -- Enable input so we can overwrite M with M+A
                    end if;
                    B_reg_shift_en<='1';            -- Shifting B so we can get B_(i+1) next time
                    
                elsif (Counter(0)='1') then         -- Counter is odd
                    if (M0) then                    -- M[0] is 
                        mux1<='1';                  -- Mux choosing n
                        mux2<='1';                  -- Mux choosing M<<1
                        M_reg_load_en<='1';         -- Enable input so we can overwrite M with M+n
                    end if;
                end if;
                counter<=counter+1;
            end if;
        end if;
        end process;
end Behavioral;