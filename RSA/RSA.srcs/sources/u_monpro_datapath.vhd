-- ************************************************************************
-- Filename: u_monpro_datapath.vhd
-- Name: Monpro datapath
-- Description:
-- This module sets up the datapath for the monpro module.
-- ************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity u_monpro_datapath is
  port (
    clk    : in std_logic;
    resetN : in std_logic;

    -- Data input interface
    A              : in std_logic_vector(127 downto 0);
    B              : in std_logic_vector(127 downto 0);
    n              : in std_logic_vector(127 downto 0);
    M_reg_load_en  : in std_logic;
    M_reg_clear    : in std_logic;
    B_reg_load_en  : in std_logic;
    B_reg_shift_en : in std_logic;
    result_load_en : in std_logic;
    mux1           : in std_logic;
    mux2           : in std_logic;

    -- Data output interface
    B0     : out std_logic;
    M0     : out std_logic;
    result : out std_logic_vector(127 downto 0)
    );
end u_monpro_datapath;

architecture Behavioral of u_monpro_datapath is
  signal M_reg      : std_logic_vector(129 downto 0);
  signal M_reg_next : std_logic_vector(129 downto 0);
  signal result_tmp : std_logic_vector(129 downto 0);
  signal B_reg      : std_logic_vector(127 downto 0);
  signal operand    : std_logic_vector(129 downto 0);
  signal sum        : std_logic_vector(129 downto 0);
  signal mux1_out   : std_logic_vector(127 downto 0);
begin
  -- ************************************************************************
  -- Register M_reg
  -- ************************************************************************
  process(clk, resetN, M_reg_next, M_reg, M_reg_clear)
  begin
    if (resetN = '0') then
      M_reg <= (others => '0');
    elsif(clk'event and clk = '1') then
      if (M_reg_load_en = '1') then
        M_reg <= M_reg_next;
      elsif (M_reg_clear = '1') then
        M_reg <= (others => '0');
      end if;
    end if;
  end process;

  -- ************************************************************************
  -- Register Result
  -- ************************************************************************
  process(clk, resetN, result_load_en, M_reg)
  begin
    if (resetN = '0') then
      result <= (others => '0');
    elsif(clk'event and clk = '1') then
      if (result_load_en = '1') then
        if (M_reg >= (b"00" & n)) then
          result <= result_tmp(127 downto 0);
        else
          result <= M_reg(127 downto 0);
        end if;
      end if;
    end if;
  end process;

  -- ************************************************************************
  -- Register B_reg
  -- ************************************************************************
  process(clk, resetN, B_reg, B)
  begin
    if (resetN = '0') then
      B_reg <= (others => '0');
    elsif(clk'event and clk = '1') then
      if (B_reg_load_en = '1') then
        B_reg <= B;
      elsif(B_reg_shift_en = '1') then
        B_reg <= '0' & B_reg(127 downto 1);
      end if;
    end if;
  end process;

  -- ************************************************************************
  -- Multiplexer 1 (2:1)
  -- ************************************************************************
  process(mux1, n, A, sum)
  begin
    if (mux1 = '1') then
      mux1_out   <= n;
      M_reg_next <= '0' & sum(129 downto 1);
    else
      mux1_out   <= A;
      M_reg_next <= sum;
    end if;
  end process;

  -- ************************************************************************
  -- Multiplexer 2 (2:1)
  -- ************************************************************************
  process(mux2, mux1_out)
  begin
    if (mux2 = '1') then
      operand <= '0' & '0' & mux1_out;
    else
      operand <= (others => '0');
    end if;
  end process;

  -- ************************************************************************
  -- 130bit parallel adder
  -- ************************************************************************
  sum        <= std_logic_vector(unsigned(operand)+unsigned(M_reg));

  -- ************************************************************************
  -- 130bit parallel subtracter
  -- ************************************************************************
  result_tmp <= std_logic_vector(unsigned(M_reg)-unsigned(b"00" & n));

  -- ************************************************************************
  -- M0 and B0
  -- ************************************************************************
  M0         <= M_reg(0);
  B0         <= B_reg(0);
end Behavioral;
