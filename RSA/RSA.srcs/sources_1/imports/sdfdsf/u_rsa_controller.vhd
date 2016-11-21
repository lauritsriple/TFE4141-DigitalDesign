library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity u_rsa_controller is
	Port (
		clk 				: in std_logic;
		resetN 				: in std_logic;
                    
		monpro_mux_1_en1	: out std_logic;	
		monpro_mux_1_en2 	: out std_logic;	
		monpro_mux_2_en1	: out std_logic;
		monpro_mux_2_en2 	: out std_logic;
		                    
		Y_reg_shift_en  	: out std_logic;
		X_reg_shift_en  	: out std_logic;
		n_reg_shift_en  	: out std_logic;
		e_reg_shift_en  	: out std_logic;
		e_reg_shift_one_en 	: out std_logic;
		M_reg_shift_en  	: out std_logic;
		R_reg_load_en	  	: out std_logic;
		R_reg_shift_en  	: out std_logic;
		P_reg_load_en  		: out std_logic;

		eMSB  				: in std_logic;
	
		monpro_start 		: out std_logic;
		monpro_coreFinished	: in std_logic;

		initRsa 		 	: in std_logic;
		startRsa  			: in std_logic;
		coreFinished  		: out std_logic
	);
end u_rsa_controller;

architecture Behavioral of u_rsa_controller is
    type state is (IDLE,LOAD_KEYS,LOAD_MESSAGE,RUN_FIRST_PRECALC,RUN_SECOND_PRECALC,RUN_FIRST_LOOP_CALC,RUN_SECOND_LOOP_CALC,RUN_POSTCALC,OUTPUT_DATA);
    signal curr_state : state;
    signal waiting_for_monpro   : std_logic;
    signal substate_counter: integer range 0 to 130;
begin
    process(curr_state,substate_counter,clk,resetN,initRsa,startRsa,monpro_coreFinished,eMSB)
    begin
        if (resetN='0') then
            monpro_mux_1_en1	<='0';
            monpro_mux_1_en2    <='0';
            monpro_mux_2_en1    <='0';
            monpro_mux_2_en2    <='0';
            Y_reg_shift_en      <='0';
            X_reg_shift_en      <='0';
            e_reg_shift_en      <='0';    
            e_reg_shift_one_en  <='0';    
            n_reg_shift_en      <='0';
            M_reg_shift_en      <='0';    
            R_reg_load_en       <='0';    
            R_reg_shift_en      <='0';    
            P_reg_load_en       <='0';   
            monpro_start        <='0';
            coreFinished        <='1';
            substate_counter    <=0;
            curr_state<=IDLE;
            waiting_for_monpro  <='0';
        elsif(clk'event and clk='1') then
            --pulsed signals
            R_reg_load_en       <='0';
            P_reg_load_en       <='0';
            e_reg_shift_one_en  <='0';
            monpro_start        <='0';
        end if;
        
        case (curr_state) is
        when IDLE =>
            if (initRsa='1') then
                curr_state<=LOAD_KEYS;
            elsif(startRsa='1') then
                curr_state<=LOAD_MESSAGE;
            end if;
                
        when LOAD_KEYS =>
            coreFinished<='0';
            Y_reg_shift_en<='1';
            X_reg_shift_en<='1';
            n_reg_shift_en<='1';
            e_reg_shift_en<='1';
            if (clk'event and clk='1') then
                if (substate_counter<15) then
                    substate_counter<=substate_counter+1;
                else
                    coreFinished<='1';
                    substate_counter<=0;
                    Y_reg_shift_en<='0';
                    X_reg_shift_en<='0';
                    n_reg_shift_en<='0';
                    e_reg_shift_en<='0';
                    curr_state<= IDLE;
                end if;
            end if;
            
        when LOAD_MESSAGE =>
            coreFinished<='0';
            M_reg_shift_en<='1';
            if (clk'event and clk='1') then
                if (substate_counter<3) then
                    substate_counter<=substate_counter+1;
                else
                    M_reg_shift_en<='0';
                    substate_counter<=0;
                    curr_state<=RUN_FIRST_PRECALC;
                end if;
            end if;
            
        when RUN_FIRST_PRECALC =>
            --monpro_1 = Y
            monpro_mux_1_en1<='1';
            monpro_mux_1_en2<='1';
            --monpro_2 = m
            monpro_mux_2_en1<='1';
            monpro_mux_2_en2<='0';
            if (monpro_coreFinished'event and monpro_coreFinished='1') then
                --save result in P
                P_reg_load_en<='1';
                curr_state<=RUN_SECOND_PRECALC;
            end if;
            if (not rising_edge(monpro_coreFinished) and monpro_coreFinished='1') then
                monpro_start<='1';

            end if;
        
        when RUN_SECOND_PRECALC =>
                --monpro_1 = Y
                monpro_mux_1_en1<='1';
                monpro_mux_1_en2<='1';
                --monpro_2 = 1
                monpro_mux_2_en1<='0';
                monpro_mux_2_en2<='0';
                
                if (monpro_coreFinished'event and monpro_coreFinished='1') then
                    --save result in R
                    R_reg_load_en<='1';
                    curr_state<=RUN_FIRST_LOOP_CALC;
                end if;
                if (not rising_edge(monpro_coreFinished) and monpro_coreFinished='1') then
                    monpro_start<='1';
                end if;
            
        when RUN_FIRST_LOOP_CALC =>
            --monpro_1=R
            monpro_mux_1_en1<='1';
            monpro_mux_1_en2<='0';
            --monpro_2=R
            monpro_mux_2_en1<='1';
            monpro_mux_2_en2<='1';
            if (monpro_coreFinished'event and monpro_coreFinished='1') then
                --save result in R
                R_reg_load_en<='1';
                curr_state<=RUN_SECOND_LOOP_CALC;
            end if;
            if (not rising_edge(monpro_coreFinished) and monpro_coreFinished='1') then
                monpro_start<='1';
            end if;
            
        when RUN_SECOND_LOOP_CALC =>
            if(substate_counter<128) then
                if(eMSB='1') then
                    --monpro_1=P
                    monpro_mux_1_en1<='0';
                    monpro_mux_1_en2<='1';
                    --monpro_2=R
                    monpro_mux_2_en1<='1';
                    monpro_mux_2_en2<='1';
                    if (monpro_coreFinished'event and monpro_coreFinished='1') then
                        --save result in R
                        R_reg_load_en<='1';
                        curr_state<=RUN_FIRST_LOOP_CALC;
                        e_reg_shift_one_en<='1';
                        substate_counter<=substate_counter+1;
                    end if;
                    if (not rising_edge(monpro_coreFinished) and monpro_coreFinished='1') then
                        monpro_start<='1';
                    end if;
                else
                    substate_counter<=substate_counter+1;
                    curr_state<=RUN_FIRST_LOOP_CALC;
                    e_reg_shift_one_en<='1';
                end if;
            else
                curr_state<=RUN_POSTCALC;
                substate_counter<=0;
            end if;
            
        when RUN_POSTCALC =>
            --monpro_1 = 1
            monpro_mux_1_en1<='0';
            monpro_mux_1_en2<='0';
            --monpro_2 = R
            monpro_mux_2_en1<='1';
            monpro_mux_2_en2<='1';
            
            if (monpro_coreFinished'event and monpro_coreFinished='1') then
                --save result in R
                R_reg_load_en<='1';
                coreFinished<='1';
                curr_state<=OUTPUT_DATA;
            end if;
            if (not rising_edge(monpro_coreFinished) and monpro_coreFinished='1') then
                monpro_start<='1';
            end if;
            
        when OUTPUT_DATA =>
            R_reg_shift_en<='1';
            if (clk'event and clk='1') then
                if (substate_counter<4) then
                    substate_counter<=substate_counter+1;
                else 
                    substate_counter<=0;
                    curr_state<=IDLE;
                    R_reg_shift_en<='0';
                end if;
            end if;
        end case;
    end process;
end Behavioral;
                
            
            
        
                    
    
        
        
    






--architecture Behavioral of u_rsa_controller is
--begin
--	-- ***************************************************************************
--	-- initRSA process
--    -- ***************************************************************************
--	process(clk,resetN,initRsa)
--	variable shiftCounter	: unsigned(5 downto 0); -- Counts when shifting dataIn to Y,X,n and e,32 values
--	begin
	
--		if (resetN='0') then
--			monpro_mux_1_en1	<='0';
--			monpro_mux_1_en2	<='0';
--			monpro_mux_2_en1	<='0';
--			monpro_mux_2_en2	<='0';
--			Y_reg_shift_en		<='0';
--			X_reg_shift_en		<='0';
--			e_reg_shift_en  	<='0';	
--			e_reg_shift_one_en 	<='0';	
--			n_reg_shift_en      <='0';
--			M_reg_shift_en  	<='0';	
--			R_reg_load_en	  	<='0';	
--			R_reg_shift_en  	<='0';	
--			P_reg_load_en  		<='0';	

--			monpro_start		<='0';
			
--			coreFinished		<='1';
--			shiftCounter		:=b"010000"; --32, will not start process before shiftCounter is 0
--		elsif (clk'event and clk='1') then
--			--Pulsed signals
--			Y_reg_shift_en<='0';
--			X_reg_shift_en<='0';
--			n_reg_shift_en<='0';
--			e_reg_shift_en<='0';
--			e_reg_shift_one_en<='0';
--			if (initRsa='1') then
--				shiftCounter := b"000000";
--				coreFinished<='0';
--			end if;
--			if (shiftCounter<b"010000") then
--				Y_reg_shift_en<='1';
--				X_reg_shift_en<='1';
--				n_reg_shift_en<='1';
--				e_reg_shift_en<='1';
--				shiftCounter:=shiftCounter+1;
--			elsif(shiftCounter=b"010000") then
--			    shiftCounter:=b"010001";
--				coreFinished<='1';
--			end if;
--		end if;
--	end process;
--	-- ***************************************************************************
--	-- startRSA process
--    -- ***************************************************************************
--	process(clk,resetN,startRSA)
--	variable shiftMsgCounter: unsigned(2 downto 0); -- Counts when shifting in dataIn to M_reg, 8 values
--    variable fsmCounter        : unsigned(8 downto 0); -- Counts when running rsa algorithm, 512 values
--    variable shiftResultCounter    : unsigned(2 downto 0); -- Counts when shifitng out result
--    variable waiting_monpro    : std_logic;
--    begin
--		if(resetN='0') then
--			monpro_mux_1_en1	<='0';
--			monpro_mux_1_en2	<='0';
--			monpro_mux_2_en1	<='0';
--			monpro_mux_2_en2	<='0';

--			M_reg_shift_en  	<='0';	
--			R_reg_load_en	  	<='0';	
--			R_reg_shift_en  	<='0';	
--			P_reg_load_en  		<='0';	
--			monpro_start		<='0';
--			coreFinished		<='1';
			
--		elsif(clk'event and clk='1') then
--			--Pulsed signals
--			M_reg_shift_en		<='0';
--			monpro_start		<='0';
--			P_reg_load_en		<='0';
--			R_reg_load_en		<='0';

--			if (startRsa='1') then
--				shiftMsgCounter:=b"000";
--				coreFinished<='0';
--			end if;
--			if (shiftMsgCounter<b"101") then --0b101=5
--				M_reg_shift_en<='1';
--				shiftMsgCounter:=shiftMsgCounter+1;
--			elsif(shiftMsgCounter=b"101") then
--				fsmCounter:=b"000000000";
--				shiftMsgCounter:=b"111";
--			elsif(fsmCounter<x"103") then --259 (256 iterations in loop) + 2 before + 1 after
--				if (fsmCounter=0 and monpro_coreFinished='1') then
--					-- Monpro_1 = Y
--					monpro_mux_1_en1<='1';
--					monpro_mux_1_en2<='1';
--					-- monpro_2 = m
--					monpro_mux_2_en1<='1';
--					monpro_mux_2_en2<='0';
					
--					if (waiting_monpro='0') then
--						monpro_start<='1';
--						waiting_monpro := '1';
--					else
--						P_reg_load_en<='1';
--						fsmCounter:=fsmCounter+1;
--						waiting_monpro := '0';
--					end if;

--				elsif (fsmCounter=x"001" and monpro_coreFinished='1') then
--					-- Monpro_1 = Y
--					monpro_mux_1_en1<='1';
--					monpro_mux_1_en2<='1';
--					-- monpro_2 = 1
--					monpro_mux_2_en1<='0';
--					monpro_mux_2_en2<='0';
					
--					if (waiting_monpro='0') then
--						monpro_start<='1';
--						waiting_monpro := '1';
--					else
--						R_reg_load_en<='1';
--						fsmCounter:=fsmCounter+1;
--						waiting_monpro := '0';
--					end if;

--				elsif (fsmCounter=x"102" and monpro_coreFinished='1') then
--					-- Monpro_1 = 1
--					monpro_mux_1_en1<='0';
--					monpro_mux_1_en2<='0';
--					-- monpro_2 = R
--					monpro_mux_2_en1<='1';
--					monpro_mux_2_en2<='1';
					
--					if (waiting_monpro='0') then
--						monpro_start<='1';
--						waiting_monpro := '1';
--					else
--						R_reg_load_en<='1';
--						fsmCounter:=b"100000100"; --done with loop and monpro, ready to shift
--						shiftResultCounter:=b"000"; -- Setting shift result to 0 so we can start to shift out
--						coreFinished<='1';
--						waiting_monpro := '0';
--					end if;

--				elsif (monpro_coreFinished='1') then
--					if (fsmCounter(0)='0') then
--						-- Monpro_1 = R
--						monpro_mux_1_en1<='1';
--						monpro_mux_1_en2<='0';
--						-- monpro_2 = R
--						monpro_mux_2_en1<='1';
--						monpro_mux_2_en2<='1';
						
--						if (waiting_monpro='0') then
--							monpro_start<='1';
--							waiting_monpro := '1';
--						else
--							R_reg_load_en<='1';
--							fsmCounter:=fsmCounter+1;
--							waiting_monpro := '0';
--						end if;
--					elsif(fsmCounter(0)='1' and eMSB='1') then
--						-- Monpro_1 = P
--						monpro_mux_1_en1<='0';
--						monpro_mux_1_en2<='1';
--						-- monpro_2 = R
--						monpro_mux_2_en1<='1';
--						monpro_mux_2_en2<='1';
						
--						if (waiting_monpro='0') then
--							monpro_start<='1';
--							waiting_monpro := '1';
--						else
--							R_reg_load_en<='1';
--							fsmCounter:=fsmCounter+1;
--							waiting_monpro := '0';
--						end if;
--					end if;
--				end if;
--			elsif(fsmCounter=x"104" and shiftResultCounter<b"100") then --finished with fsm and shift out less then 4 iterations
--				R_reg_shift_en<='1';
--				shiftResultCounter:=shiftResultCounter+1;
--				if (shiftResultCounter=b"011") then
--					shiftResultCounter:=b"111";
--				end if;
--			end if;
--		end if;
--	end process;
--end Behavioral;
