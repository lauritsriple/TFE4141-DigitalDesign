----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2016 06:00:22 PM
-- Design Name: 
-- Module Name: u_monpro_datapath - Behavioral
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

entity u_monpro_datapath is
    Port (
        -- Clocks and resets
        clk                 : in std_logic;
        resetN              : in std_logic;
        
        -- Data input interface
        A                   : in std_logic_vector(127 downto 0);
        B                   : in std_logic_vector(127 downto 0);
        n                   : in std_logic_vector(127 downto 0);
        M_reg_load_en       : in std_logic;
        B_reg_load_en       : in std_logic;
        B_reg_shift_en      : in std_logic;
        
        -- Data output interface
        result              : out std_logic_vector(127 downto 0);
    );
end u_monpro_datapath;

architecture Behavioral of u_monpro_datapath is
    signal M_reg            : std_logic_vector(127 downto 0);
    signal M_reg_next       : std_logic_vector(127 downto 0);
    signal B_reg            : std_logic_vector(127 downto 0);
    signal operand          : std_logic_vector(127 downto 0);
    signal sum              : std_logic_vector(127 downto 0);
    signal sum_shift        : std_logic_vector(127 downto 0);
begin
    -- ***************************************************************************
    -- Register M_reg                                                            
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            M_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
            if (M_reg_load_en='1') then
                M_reg<=M_reg_next;
            end if;
        end if;
    end process;
    
    -- ***************************************************************************
    -- Register B_reg                                                            
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            B_reg<=(others=>'0');
        elsif(clk'event and clk='1') then
            if (B_reg_load_en='1') then
                B_reg<=B;
            elsif(B_reg_shift_en='1') then
                B_reg<='0' & B_reg(127 downto 1);
            end if;
        end if;
    end process;

    -- ***************************************************************************
    -- Multiplexer 1 (2:1)                                                      
    -- ***************************************************************************
    process(mux1,n ,A) begin
        if (mux1='1') then
            operand<=n;
        else
            operand<=A;
        end if;
    end process;

    -- ***************************************************************************
    -- Multiplexer 2 (2:1)                                                      
    -- ***************************************************************************            
    process(mux2, n, A) begin
        if (mux2='1') then
            M_reg_next<='0' & sum(127 downto 1);
        else
            M_reg_next<=sum;
        end if;
    end process;
    
    -- ***************************************************************************
    -- 128bit parallel adder                                                  
    -- ***************************************************************************
    sum<=operand+m_Reg;
    
        


end Behavioral;