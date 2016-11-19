library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity rsa is
    Port ( 
        clk             : in std_logic;
        resetN          : in std_logic;
        
        initRsa         : in std_logic;
        startRsa        : in std_logic;
        dataIn          : in std_logic_vector(31 downto 0);
        
        dataOut         : out std_logic_vector(31 downto 0);
        coreFinished    : std_logic
    );
end rsa;

architecture rtl of rsa is
    -- Control inputs
    signal data_in_mux_en		: std_logic;
    signal monpro_mux_1_en      : std_logic;
    signal monpro_mux_2_en      : std_logic;
    signal Y_reg_shift_en       : std_logic;
    signal X_reg_shift_en       : std_logic;
    signal n_reg_shift_en       : std_logic;
    signal e_reg_shift_en       : std_logic;
    signal M_reg_shift_en       : std_logic;
    signal X_reg_load_en        : std_logic;
    signal M_hat_reg_load_en    : std_logic;
    
    -- Data output
    signal result                      : std_logic_vector(31 downto 0);
    -- Data control output
    signal eMSB                        : std_logic;
    
begin
    u_rsa_datapath  : entity work.u_rsa_datapath port map(
        clk => clk,
        resetN => resetN,
        
        -- Data => Control
        data_in_mux_en => data_in_mux_en,
        monpro_mux_1_en => monpro_mux_1_en,
        monpro_mux_2_en => monpro_mux_2_en,
        Y_reg_shift_en => Y_reg_shift_en,
        X_reg_shift_en => X_reg_shift_en,
        n_reg_shift_en => n_reg_shift_en,
        e_reg_shift_en => e_reg_shift_en,
        M_reg_shift_en => M_reg_shift_en,
        X_reg_load_en => X_reg_load_en,    
        M_hat_reg_load_en => M_hat_reg_load_en,
        eMSB => eMSB,
        
        -- Data => RSA
        result => dataOut,
        dataIn => dataIn    
    );
    
    u_rsa_controller : entity work.u_rsa_controller port map(
        clk => clk,
        resetN => resetN,
    
        -- Control => Data
        data_in_mux_en => data_in_mux_en,
        monpro_mux_1_en => monpro_mux_1_en,
        monpro_mux_2_en => monpro_mux_2_en,
        Y_reg_shift_en => Y_reg_shift_en,
        X_reg_shift_en => X_reg_shift_en,
        n_reg_shift_en => n_reg_shift_en,
        e_reg_shift_en => e_reg_shift_en,
        M_reg_shift_en => M_reg_shift_en,
        X_reg_load_en => X_reg_load_en,    
        M_hat_reg_load_en => M_hat_reg_load_en,
        eMSB => eMSB,
        
        -- Control => RSA
        initRsa => initRsa,
        startRsa => startRsa,
        coreFinished => coreFinished
    );
end rtl;
