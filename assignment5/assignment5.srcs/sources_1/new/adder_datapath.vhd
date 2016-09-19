----------------------------------------------------------------------------------
-- Company    :  NTNU
-- Engineer   : Øystein Gjermundnes
-- 
-- Create Date: 09/11/2016 04:21:16 PM
-- Module Name: mega_adder_datapath
-- Description:   
--   Datapath for the mega_adder. The datapath consists of shift registers
--   at the inputs and outputs and a large 128 bit adder.
--
--   CHALLENGE 1:
--   Set different synthesis constraints for the max frequency and check how the
--   area of the design changes.
--  
--   CHALLENGE 2: 
--   Can you think of a way to significantly increase the max clock frequency 
--   as well as reducing the area?
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_datapath is
  port (      
    -- Clocks and resets
    clk             : in std_logic;
    reset_n         : in std_logic;
    
    -- Data in interface       
    data_in         : in std_logic_vector (31 downto 0);
    input_reg_en    : in std_logic;
    
    -- Data out interface
    data_out        : out std_logic_vector (31 downto 0);
    output_reg_en   : in std_logic;
    output_reg_load : in std_logic);
        
end adder_datapath;

architecture rtl of adder_datapath is

  -- Signals associated with the input registers
  signal a_r, a_nxt: std_logic_vector(159 downto 0);
  signal cr_r,cr_nxt: std_logic;
  -- Signals associated with the output registers
  signal y_r, y_nxt: std_logic_vector(31 downto 0);
    
begin

  -- ***************************************************************************
  -- Register a_r
  -- ***************************************************************************
  process (clk, reset_n) begin
    if(reset_n = '0') then
      a_r <= (others => '0');    
    elsif(clk'event and clk='1') then
      if(input_reg_en ='1') then
        a_r <= a_nxt;
      end if;
    end if;
  end process;
    
  process (data_in, a_r) begin
    a_nxt <= data_in & a_r(159 downto 32);
  end process; 


  -- ***************************************************************************
  -- Register y_r
  -- Add the content of a_r and b_r and store it in y_r.
  -- Logic for shifting out the content of y_r to data_out
  -- ***************************************************************************
  process (clk, reset_n) begin
    if(reset_n = '0') then
      y_r <= (others => '0');
      cr_r <= '0';          
    elsif(clk'event and clk='1') then
      if(output_reg_en ='1') then
        y_r <= y_nxt;
        cr_r <= cr_nxt;
      end if;
    end if;
  end process;
  
  
  process (y_r, a_r, output_reg_load) 
  variable adend1,adend2: unsigned(33 downto 0);
  variable result: std_logic_vector(33 downto 0);
  begin
    if(output_reg_load = '1') then
      adend1:=unsigned('0' & a_r(159 downto 128)& b"1");
      adend2:= unsigned('0' & a_r(31 downto 0)& cr_r);
      result:=std_logic_vector(adend1 + adend2);
      y_nxt <= result(32 downto 1);
      cr_nxt<= result(33);
    end if;
  end process;
  
  data_out <= y_r(31 downto 0);

end rtl;
