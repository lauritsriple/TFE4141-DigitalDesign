library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thing_with_latch is
    port (
        a   : in std_logic;
        b   : in std_logic;
        eq  : out std_logic
        );
end thing_with_latch;

architecture rtl of thing_with_latch is
    begin
        process(a,b)
            begin
                if (a=b) then
                    eq <= '1';
                end if;
        end process;
    end rtl;
