-- ***************************************************************************
-- Filename: rsa.vhd
-- Name: RSA top module
-- Description:
-- This module connects the datapath and controll logic
-- and acts as the top module with interfaceable signals
-- ***************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity RSACore is
  port (
    Clk    : in std_logic;
    Resetn : in std_logic;

    InitRsa  : in std_logic;
    StartRsa : in std_logic;
    DataIn   : in std_logic_vector(31 downto 0);

    DataOut      : out std_logic_vector(31 downto 0);
    CoreFinished : out std_logic
    );
end RSACore;

architecture rtl of RSACore is
  signal monpro_mux_1_en1 : std_logic;
  signal monpro_mux_1_en2 : std_logic;
  signal monpro_mux_2_en1 : std_logic;
  signal monpro_mux_2_en2 : std_logic;

  signal Y_reg_shift_en     : std_logic;
  signal X_reg_shift_en     : std_logic;
  signal n_reg_shift_en     : std_logic;
  signal e_reg_shift_en     : std_logic;
  signal e_reg_shift_one_en : std_logic;
  signal M_reg_shift_en     : std_logic;
  signal R_reg_load_en      : std_logic;
  signal R_reg_shift_en     : std_logic;
  signal P_reg_load_en      : std_logic;

  signal monpro_start        : std_logic;
  signal monpro_coreFinished : std_logic;
  signal monpro_1            : std_logic_vector(127 downto 0);
  signal monpro_2            : std_logic_vector(127 downto 0);
  signal monpro_3            : std_logic_vector(127 downto 0);
  signal monpro_result       : std_logic_vector(127 downto 0);

  signal eMSB : std_logic;

begin
  u_rsa_datapath : entity work.u_rsa_datapath port map(
    clk    => Clk,
    resetN => Resetn,

    -- Control inputs
    monpro_mux_1_en1 => monpro_mux_1_en1,
    monpro_mux_1_en2 => monpro_mux_1_en2,
    monpro_mux_2_en1 => monpro_mux_2_en1,
    monpro_mux_2_en2 => monpro_mux_2_en2,

    Y_reg_shift_en     => Y_reg_shift_en,
    X_reg_shift_en     => X_reg_shift_en,
    n_reg_shift_en     => n_reg_shift_en,
    e_reg_shift_en     => e_reg_shift_en,
    e_reg_shift_one_en => e_reg_shift_one_en,
    M_reg_shift_en     => M_reg_shift_en,
    R_reg_load_en      => R_reg_load_en,
    R_reg_shift_en     => R_reg_shift_en,
    P_reg_load_en      => P_reg_load_en,

    -- Data in/out to RSA
    dataOut => DataOut,
    dataIn  => DataIn,

    -- Data in/out to monpro
    monpro_1      => monpro_1,
    monpro_2      => monpro_2,
    monpro_3      => monpro_3,
    monpro_result => monpro_result,

    -- Data out to control
    eMSB => eMSB
    );

  u_rsa_controller : entity work.u_rsa_controller port map(
    clk    => Clk,
    resetN => Resetn,

    -- Control inputs from u_rsa_datapath
    monpro_mux_1_en1 => monpro_mux_1_en1,
    monpro_mux_1_en2 => monpro_mux_1_en2,
    monpro_mux_2_en1 => monpro_mux_2_en1,
    monpro_mux_2_en2 => monpro_mux_2_en2,

    Y_reg_shift_en     => Y_reg_shift_en,
    X_reg_shift_en     => X_reg_shift_en,
    n_reg_shift_en     => n_reg_shift_en,
    e_reg_shift_en     => e_reg_shift_en,
    e_reg_shift_one_en => e_reg_shift_one_en,
    M_reg_shift_en     => M_reg_shift_en,
    R_reg_load_en      => R_reg_load_en,
    R_reg_shift_en     => R_reg_shift_en,
    P_reg_load_en      => P_reg_load_en,

    eMSB => eMSB,

    -- Control inputs/outputs to MONPRO
    monpro_start        => monpro_start,
    monpro_coreFinished => monpro_coreFinished,

    -- Control inputs/outputs from RSA
    initRsa      => InitRsa,
    startRsa     => StartRsa,
    coreFinished => CoreFinished
    );
  monpro : entity work.monpro port map(
    clk    => Clk,
    resetN => Resetn,

    startMonpro => monpro_start,
    A           => monpro_1,
    B           => monpro_2,
    n           => monpro_3,

    coreFinished => monpro_coreFinished,
    result       => monpro_result
    );
end rtl;
