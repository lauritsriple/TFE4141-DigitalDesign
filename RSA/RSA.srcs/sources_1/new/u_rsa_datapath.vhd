library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity u_rsa_datapath is
	Port (
		-- Clocks and reset
		clk					: in std_logic
		resetN				: in std_logic
		-- Data input interface
		dataIn				: in std_logic
		-- Control inputs
		data_in_mux_en		: in std_logic
		monpro_mux_1_en		: in std_logic
		monpro_mux_2_en		: in std_logic
		Y_reg_shift_en		: in std_logic
		X_reg_shift_en		: in std_logic
		n_reg_shift_en		: in std_logic
		e_reg_shift_en		: in std_logic
		M_reg_shift_en		: in std_logic
		X_reg_load_en		: in std_logic
		M_hat_reg_load_en	: in std_logic

		-- Data output
		result 				: out std_logic_vector(127 downto 0)
		-- Data control output
		eMSB				: out std_logic
	);
end u_rsa_datapath;

architecture Behavioral of u_rsa_datapath is
	signal Y_reg			: std_logic_vector(127 downto 0);
	signal X_reg			: std_logic_vector(127 downto 0);
	signal M_reg			: std_logic_vector(127 downto 0);
	signal M_hat_reg		: std_logic_vector(127 downto 0);
	signal n_reg			: std_logic_vector(127 downto 0);
	signal e_reg			: std_logic_vector(127 downto 0);
	signal data_in_mux_init	: std_logic_vector(127 downto 0);
	signal data_in_mux_start: std_logic_vector(127 downto 0);
	signal Y_reg_shift_out	: std_logic;
	signal X_reg_shift_out	: std_logic;
	signal n_reg_shift_out	: std_logic;
begin
	-- ***************************************************************************
	-- REGISTERS Y->X->n->e
	-- ***************************************************************************
    -- Register Y_reg (R**2modn)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            Y_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
			if (Y_reg_shift_en='1') then
				-- Shifts in and shifts out
				Y_reg_shift_out=Y_reg(0);
				Y_reg<=data_in_mux_init & Y_reg(126 downto 0);
            end if;
        end if;
    end process;

	-- ***************************************************************************
    -- Register X_reg (Rmodn)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            X_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
            if (X_reg_load_en='1') then
                X_reg<=X_reg_next;
			elsif (X_reg_shift_en='1') then
				-- Shifts in and shifts out
				X_reg_shift_out=X_reg(0);
				X_reg <=Y_reg_shift_out & X_reg(126 downto 0);
            end if;
        end if;
    end process;

	-- ***************************************************************************
    -- Register n_reg (R**2modn)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            n_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
			if (n_reg_shift_en='1') then
				-- Shifts in and shifts out
				n_reg_shift_out=n_reg(0);
				n_reg <=X_reg_shift_out & n_reg(126 downto 0);
            end if;
        end if;
    end process;

	-- ***************************************************************************
    -- Register e_reg (R**2modn)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            e_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
			if (e_reg_shift_en='1') then
				-- Shifts in and shifts out
				e_reg_shift_out=e_reg(0);
				e_reg <=n_reg_shift_out & e_reg(126 downto 0);
            end if;
        end if;
    end process;

    -- ***************************************************************************
    -- Multiplexer data in (1:2)
    -- ***************************************************************************
    process(data_in_mux_en,dataIn) begin
        if (data_in_mux_en='1') then
            data_in_mux_init<=data_in;
			data_in_mux_start<='0';
        else
			data_in_mux_start<=data_in;
			data_in_mux_init<='0';
        end if;
    end process;

    -- ***************************************************************************
    -- Multiplexer Monpro in 1  (2:1)
    -- ***************************************************************************
    process(X_reg, m_hat_reg) begin
        if (monpro_mux_1_en='1') then
            monpro_1<=X_reg;
        else
			monpro_1<=m_hat_reg;
        end if;
    end process;

    -- ***************************************************************************
    -- Multiplexer Monpro in 2  (2:1)
    -- ***************************************************************************
    process(X_reg) begin
        if (monpro_mux_2_en='1') then
            monpro_2<=X_reg;
        else
			monpro_2<='1';
        end if;
    end process;

	-- ***************************************************************************
    -- Register M_reg (Message to encode or decode)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            M_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
            if (M_reg_shift_en='1') then
                M_reg<=data_in_mux_start & M_reg(126 downto 0);
            end if;
        end if;
    end process;

	-- ***************************************************************************
    -- Register and multiplication M_hat_reg (m*x_hat)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            M_hat_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
            if (M_hat_reg_load_en='1') then
				M_hat_reg <= M_reg*X_reg;
            end if;
        end if;
    end process;

	-- ***************************************************************************
    -- Register M_reg (Message to encode or decode)
    -- ***************************************************************************
    process(clk,resetN) begin
        if (resetN='0') then
            M_reg <= (others=>'0');
        elsif(clk'event and clk='1') then
            if (M_reg_shift_en='1') then
                M_reg<=data_in_mux_start & M_reg(126 downto 0);
            end if;
        end if;
    end process;
