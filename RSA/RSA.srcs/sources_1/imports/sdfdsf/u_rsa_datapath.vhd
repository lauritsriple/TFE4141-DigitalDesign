library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity u_rsa_datapath is
	Port (
		-- Clocks and reset
		clk					: in std_logic;
		resetN				: in std_logic;
		-- Data input interface
		dataIn				: in std_logic_vector(31 downto 0);
		monpro_res			: in std_logic_vector(127 downto 0);
		-- Control inputs
		monpro_mux_1_en1	: in std_logic;
		monpro_mux_1_en2	: in std_logic;
		monpro_mux_2_en1	: in std_logic;
		monpro_mux_2_en2	: in std_logic;
		Y_reg_shift_en		: in std_logic;
		X_reg_shift_en		: in std_logic;
		n_reg_shift_en		: in std_logic;
		e_reg_shift_en		: in std_logic; -- Shifts 32 bits to right
		e_reg_shift_one_en	: in std_logic; -- Shifts one bit to left
		M_reg_shift_en		: in std_logic;
		R_reg_load_en		: in std_logic;
		P_reg_load_en		: in std_logic;
		

		-- Data output
		monpro_1			: out std_logic_vector(127 downto 0);
		monpro_2			: out std_logic_vector(127 downto 0);
		monpro_3			: out std_logic_vector(127 downto 0);
		data_out  			: out std_logic_vector(127 downto 0);
		-- Data control output
		eMSB				: out std_logic; -- MSB of the e register. Used for in control interface
	);
end u_rsa_datapath;

architecture Behavioral of u_rsa_datapath is
	signal Y_reg			: std_logic_vector(127 downto 0);
	signal X_reg			: std_logic_vector(127 downto 0);
	signal M_reg			: std_logic_vector(127 downto 0);
	signal n_reg			: std_logic_vector(127 downto 0);
	signal e_reg			: std_logic_vector(127 downto 0);
	signal P_reg			: std_logic_vector(127 downto 0);
	signal R_reg			: std_logic_vector(127 downto 0);
	signal Y_reg_shift_out	: std_logic_vector(31 downto 0);
	signal X_reg_shift_out	: std_logic_vector(31 downto 0);
	signal n_reg_shift_out	: std_logic_vector(31 downto 0);
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
				Y_reg_shift_out <= Y_reg(31 downto 0);
				Y_reg <= data_in & Y_reg(95 downto 0);
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
			elsif (X_reg_shift_en='1') then
				-- Shifts in and shifts out
				X_reg_shift_out <= X_reg(31 downto 0);
				X_reg <= Y_reg_shift_out & X_reg(95 downto 0);
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
				n_reg_shift_out <= n_reg(31 downto 0);
				n_reg <=X_reg_shift_out & n_reg(95 downto 0);
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
				e_reg_shift_out <= e_reg(31 downto 0);
				e_reg <= n_reg_shift_out & e_reg(95 downto 0);
			elsif (e_reg_shift_one_en='1'); --left shift
				eMSB<=e_reg(127);
				e_reg<=e_reg(126 downto 0) & '0';
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
                M_reg<=data_in & M_reg(126 downto 0);
            end if;
        end if;
    end process;

	-- ***************************************************************************
    -- Register P_reg
    -- ***************************************************************************
	process(clk,resetN) then
		if(resetN='0') then
			P_reg<=(others=>'0');
		elsif (clk'event and clk='1') then
			if (P_reg_load_en='1') then
				P_reg<=monpro_res;
			end if;
		end if;
	end process;

	-- ***************************************************************************
    -- Register R_reg
    -- ***************************************************************************
	process(clk,resetN) then
		if(resetN='0') then
			R_reg<=(others=>'0');
		elsif (clk'event and clk='1') then
			if (R_reg_load_en='1') then
				R_reg<=monpro_res;
			elsif (R_reg_shift_out='1') then
				data_out<=R_reg(31 downto 0);
				R_reg<="0" & R_reg(127 downto 32);
			end if;
		end if;
	end process;

    -- ***************************************************************************
    -- Multiplexer Monpro in 1  (4:1)
    -- ***************************************************************************
    process(monpro_mux_1_en1,monpro_mux_1_en2) begin
        if (monpro_mux_1_en1='1') and (monpro_mux_1_en2='1') then
            monpro_1<=Y_reg;
        elsif (monpro_mux_1_en1='1') and (monpro_mux_1_en2='0') then
			monpro_1<=R_reg;
        elsif (monpro_mux_1_en1='0') and (monpro_mux_1_en2='1') then
			monpro_1<=P_reg;
		else
			monpro_1<=(others=>'1');
        end if;
    end process;

    -- ***************************************************************************
    -- Multiplexer Monpro in 2  (3:1)
    -- ***************************************************************************
    process(monpro_mux_2_en1,monpro_mux_2_en2) begin
        if (monpro_mux_2_en1='1') and (monpro_mux_2_en2='1') then
            monpro_2<=R_reg;
        elsif (monpro_mux_2_en1='1') and (monpro_mux_2_en2='0') then
			monpro_2<=M_reg;
		else
			monpro_2<=(others=>'1');
        end if;
    end process;

    -- ***************************************************************************
    --  Monpro in 3
    -- ***************************************************************************
	monpro_3<=n_reg;

end Behavioral;
