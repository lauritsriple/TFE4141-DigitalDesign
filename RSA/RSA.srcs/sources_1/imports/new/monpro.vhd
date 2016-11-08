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
-- Make shiftRegister (See mega adder, it has multiple shift registers)
-- DONE! Added mega adder Make Full adder

entity monpro is
    port (
        -- Clocks and resets
        clk                 : in std_logic;
        resetN              : in std_logic;
        
        -- Data input interface
        startMonpro         : in std_logic;
        A                   : in std_logic_vector(127 downto 0);
        B                   : in std_logic_vector(127 downto 0);
        n                   : in std_logic_vector(127 downto 0);
        
        -- Data output interface
        coreFinished        : out std_logic;
        result              : out std_logic_vector(127 downto 0);
    );
end monpro;

architecture rtl of monpro is
    --signals here
    
begin
    u_monpro_datapath: entity work.monpro_datapath port map(
        clk=>clk,
        resetN=>resetN,
        
        --Data in interface
        A => A,
        B => B,
        n => n,
        
        --Data out interface
        result=>result
    );
    
    u_monpro_controller: entity work.monpro_controller port map(
        clk=>clk,
        resetN=>resetN,
        
        --Data in interface
        startMonpro=>startMonpro,
        
        --Data out interface
        coreFinished=>coreFinished
    );
end rtl;
        


