library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- TODO
-- Make counter
-- Make shiftRegister
-- Make Full adder

entity monpro is
    port (
        Clk                 : in std_logic;
        StartMonpro         : in std_logic;
        A                   : in std_logic_vector(127 downto 0);
        B                   : in std_logic_vector(127 downto 0);
        n                   : in std_logic_vector(127 downto 0);
        ResetN              : in std_logic;
        CoreFinished        : out std_logic;
        result              : out std_logic_vector(127 downto 0);
end monpro;

architecture Behavioral of monpro is
    signal mux1             : std_logic; -- the mux that chooses between A and n
    signal mux2             : std_logic; -- the mus that chooses between sum and sum_shift
    signal M_reg            : std_logic_vector(127 downto 0); -- output from M register
    signal M_reg_next       : std_logic_vector(127 downto 0); -- input to M register
    signal M_reg_load_en    : std_logic;
    --signal M_reg_0          : std_logic;
    signal B_reg            : std_logic_vector(127 downto 0);
    signal B_reg_load_en    : std_logic;
    signal B_reg_shift_en   : std_logic;
    --signal B_reg_0          : std_logic;
    signal operand          : std_logic_vector(127 downto 0);
    signal sum              : std_logic_vector(127 downto 0);
    signal sum_shift        : std_logic_vector(127 downto 0);
begin
    process (Clk,ResetN,StartMonpro) is
        variable Counter    : unsigned(7 downto 0); -- Can represent 256 values
    begin
        if (ResetN='0') then
            M <= (others => '0');
            Counter <= (others => '0');
            B <= (others => '0'); 
        if (StartMonpro='1') then
            CoreFinished<='0';
            Counter<='0';
            
        --Normal monpro operation
        elsif (Clk'event and clk='1'); then
            if (Counter >=255); --Check if finished
                CoreFinished<='1';
            else then    
                -- Alternate between two operations based on even or odd counter.
                -- M+A (counter is odd) or M+n>>1 (counter is even) 
                if (Counter[0]='0') then            -- Counter is even
                    if (B(0)='1') then              -- B_i is odd
                        C1<='0';                    -- Mux choosing A
                        C2<='0';                    -- Mux choosing M
                        M_output_en<='1';           -- Enable output from M register so we add it with A
                        M_input_en<='1';            -- Enable input so we can overwrite M with M+A
                    else then
                        M_input_en<='0';            -- Do the adding, but dont overwrite M
                    end if
                    B>>1;                           -- Shifting B so we can get B_(i+1) next time
                    counter<=counter+1;
                elsif (Counter[0]='1') then         -- Counter is odd
                    if (M[0]='1') then              -- M[0] is 
                        C1<='1';                    -- Mux choosing n
                        C2<='1';                    -- Mux choosing M<<1
                        M_output_en<='1';           -- Enable output from M register so we add it with n
                        M_input_en<='1';            -- Enable input so we can overwrite M with M+n
                    else then
                        M_input_en<='0';            -- Do the adding, but dont overwrite M
                    end if
                    counter<=counter+1;
                end if
            end if
                
                    
                
            
            
        


end Behavioral;
