----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2016 06:00:22 PM
-- Design Name: 
-- Module Name: u_monpro_controller - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity u_monpro_controller is
    port (
    -- Clocks and resets
    clk                 : in std_logic;
    resetN              : in std_logic;
    
    -- Datapath control signals
    mux1                : out std_logic; -- the mux that chooses between A and n
    mux2                : out std_logic; -- the mux that chooses between sum and sum_shift
    M_reg_load_en       : out std_logic;
    M_reg_out_en        : out std_logic;
    B_reg_load_en       : out std_logic;
    B_reg_shift_en      : out std_logic;
    
    
    -- Control signals for the input interface
    startMonpro         : in std_logic;
    
    --Control signals for the output interface
    coreFinished        : out std_logic;
    
end u_monpro_controller;

architecture Behavioral of u_monpro_controller is
    --signals
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
                        M_reg_out_en<='1';          -- Enable output from M register so we add it with A
                        M_reg_load_en<='1';         -- Enable input so we can overwrite M with M+A
                    else then
                        M_reg_input_en<='0';        -- Do the adding, but dont overwrite M
                    end if
                    B_reg_shift_en<='1';            -- Shifting B so we can get B_(i+1) next time
                    counter<=counter+1;
                elsif (Counter[0]='1') then         -- Counter is odd
                    if (M[0]='1') then              -- M[0] is 
                        C1<='1';                    -- Mux choosing n
                        C2<='1';                    -- Mux choosing M<<1
                        M_reg_out_en<='1';          -- Enable output from M register so we add it with n
                        M_reg_load_en<='1';         -- Enable input so we can overwrite M with M+n
                    else then
                        M_reg_load_en<='0';         -- Do the adding, but dont overwrite M
                    end if
                    counter<=counter+1;
                end if
            end if
end Behavioral;
