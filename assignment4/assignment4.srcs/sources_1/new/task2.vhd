library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity task2 is
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        a       : in std_logic;
        b       : in std_logic;
        y       : out std_logic
    );
end task2;

--architecture design1 of task2 is
--begin
--    process (clk, reset) is
--        variable t : std_ulogic;
--    begin
--        if (reset = '1') then
--            t := '0';
--            y <= '0';
--        elsif (rising_edge(clk)) then
--            y <= t;
--            t := a xor b;
--        end if;
--    end process;
--end architecture;

architecture design2 of task2 is
begin
    process (clk, reset) is
        variable t : std_ulogic;
    begin
        if (reset = '1') then
            t := '0';
            y <= '0';
        elsif (rising_edge(clk)) then
            t := a xor b;
            y <= t;
        end if;
    end process;
end architecture;