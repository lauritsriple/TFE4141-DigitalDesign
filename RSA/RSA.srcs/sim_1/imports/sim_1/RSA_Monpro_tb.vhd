library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RSAParameters.all;
use work.CompDecl.all;

--library std;
--use std.textio.all;

entity RSA_Monpro_TB is
end RSA_Monpro_TB;

architecture struct of RSA_Monpro_TB is

  -- ---------------------------------------------------------------------------
  -- Signal declarations
  -- ---------------------------------------------------------------------------
  signal  Clk              :  std_logic;
  signal  Resetn           :  std_logic;
  signal  startMonpro      :  std_logic;
  signal  A           	   :  std_logic_vector(W_DATA-1 downto 0);
  signal  B                :  std_logic_vector(W_DATA-1 downto 0);
  signal  n                :  std_logic_vector(W_DATA-1 downto 0);
  signal  Result           :  std_logic_vector(W_DATA-1 downto 0);
  signal  coreFinished     :  std_logic;  
  
  --type   ComFileType  is array(natural range <>) of std_logic_vector(15 downto 0);
  --constant ComFileName : string :="ComFile.txt";  
  --file ComFile: TEXT open read_mode is ComFileName;
  
  type MonproStateType is (e_IDLE, e_EXECUTE, e_WAIT_EXECUTE_FINISHED, e_TEST_FINISHED);
                           
  signal MonproState : MonproStateType;
begin

  -- Generates a 50MHz Clk
  CLKGEN: process is
  begin
    Clk <= '1';
    wait for 10 ns;
    Clk <= '0';
    wait for 10 ns;
  end process;
  
  -- Resetn generator
  RSTGEN: process is
  begin
    Resetn <= '0';
    wait for 20 ns;
    Resetn <= '1';
    wait;
  end process;
  
  CryptoCtrl: process(Clk, Resetn)
  begin  
    if (Resetn = '0') then
    
      -- RSACore signals
      startMonpro         <= '0';
      A           <= (others => '0');
      B           <= (others => '0');
      n           <= (others => '0');
    
      -- TB signals    
      MonproState  <= e_IDLE;
      Result       <= (others => '0');
   
    elsif (Clk'event and Clk='1') then
    
      -- Pulsed signals
      startMonpro <= '0';      
      
      case MonproState is
  
        -- Start the state machine
        when e_IDLE=>
          MonproState <= e_EXECUTE;

        when e_EXECUTE =>
          MonproState <= e_WAIT_EXECUTE_FINISHED;                                      
          startMonpro <= '1';
          -- Mulig vi m� lage A og n som registere. Vet ikke helt hvordan det fungerer.
          A <= "3";
    	  B <= "3";
	      n <= "13";
          
        -- Wait for the initialization to finish
        when e_WAIT_EXECUTE_FINISHED => 
          if (coreFinished = '1') then
            MonproState <= e_TEST_FINISHED;
          end if;            
                           
        -- End testbench
        when others => -- e_TEST_FINISHED;
            assert true;
              report "Finished"
              severity Failure;                 
      end case;
    end if;  
  
  end process;
  
  
  R: monpro
  port map(      
    clk             	=> clk, 
    resetN           	=> resetN,
    startMonpro         => startMonpro, 
    A           	=> A, 
    B          		=> B, 
    n           	=> n, 
    result           	=> result, 
    coreFinished     	=> coreFinished
  );  
  
 
    
end struct;  
