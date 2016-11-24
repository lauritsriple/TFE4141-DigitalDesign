-- ***************************************************************************
-- Filename: monpro.vhd
-- Name: Monpro top module
-- Description:
-- This module connects the datapath and controll logic
-- and acts as the top module with interfaceable signals
-- ***************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity monpro is
  port (
    -- Clocks and resets
    clk    : in std_logic;
    resetN : in std_logic;

    -- Data input interface
    startMonpro : in std_logic;
    A           : in std_logic_vector(127 downto 0);
    B           : in std_logic_vector(127 downto 0);
    n           : in std_logic_vector(127 downto 0);

    -- Data output interface
    coreFinished : out std_logic;
    result       : out std_logic_vector(127 downto 0)
    );
end monpro;

architecture rtl of monpro is
  signal M_reg_load_en  : std_logic;
  signal M_reg_clear    : std_logic;
  signal B_reg_load_en  : std_logic;
  signal B_reg_shift_en : std_logic;
  signal result_load_en : std_logic;
  signal mux1           : std_logic;
  signal mux2           : std_logic;
  signal B0             : std_logic;
  signal M0             : std_logic;

begin
  u_monpro_datapath : entity work.u_monpro_datapath port map(
    clk    => clk,
    resetN => resetN,

    --Data in interface
    A => A,
    B => B,
    n => n,

    --Internal interface between datapath and controllpath
    M_reg_load_en  => M_reg_load_en,
    M_reg_clear    => M_reg_clear,
    B_reg_load_en  => B_reg_load_en,
    B_reg_shift_en => B_reg_shift_en,
    result_load_en => result_load_en,
    mux1           => mux1,
    mux2           => mux2,
    B0             => B0,
    M0             => M0,

    --Data out interface
    result => result
    );

  u_monpro_controller : entity work.u_monpro_controller port map(
    clk    => clk,
    resetN => resetN,

    --Data in interface
    startMonpro => startMonpro,

    --Data out interface
    coreFinished => coreFinished,

    --Internal interface between datapath and controllpath
    M_reg_load_en  => M_reg_load_en,
    M_reg_clear    => M_reg_clear,
    B_reg_load_en  => B_reg_load_en,
    B_reg_shift_en => B_reg_shift_en,
    result_load_en => result_load_en,
    mux1           => mux1,
    mux2           => mux2,
    B0             => B0,
    M0             => M0
    );
end rtl;
