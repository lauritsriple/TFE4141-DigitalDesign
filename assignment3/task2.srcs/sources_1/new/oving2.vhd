library ieee;
use ieee.std_logic_1164.all;

entity task2 is
    port(
        Q   : out std_logic;
        QN  : out std_logic;
        A   : in std_logic;
        B   : in std_logic);
end task2;

architecture rtl of task2 is
    signal q_i : std_logic;
    signal qn_i: std_logic;
begin
    q_i<=not(A or qn_i);
    qn_i<=not(B or q_i);
    Q <= q_i;
    QN <= qn_i;
end rtl;