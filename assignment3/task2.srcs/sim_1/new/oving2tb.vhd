library ieee;
use ieee.std_logic_1164.all;

entity test is
end test;

architecture Behavioral of test is
signal A_tb : std_logic;
signal B_tb : std_logic;
signal Q_tb : std_logic;
signal QN_tb: std_logic;
begin
 dut: entity work.task2
    port map(
        A => A_tb,
        B => B_tb,
        Q => Q_tb,
        QN => QN_tb); 
    process
    begin
    A_tb<='1';
    B_tb<='0';
    wait for 10 ns;
    A_tb<='0';
    wait for 10 ns;
    B_tb<='1';
    wait for 10 ns;
    B_tb<='0';
    wait for 10 ns;
    B_tb<='1';
    A_tb<='1';
    end process;
end;