
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			SIGNAL PCOfCommandInEX	: IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			SIGNAL PCOfCommandInID	: IN STD_LOGIC_VECTOR( 9 downto 0);
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL Stall 				: IN 	STD_LOGIC;
        	SIGNAL Flush 				: IN 	STD_LOGIC;
			SIGNAL IE					: IN STD_LOGIC; 
			SIGNAL I2CReadIF			: IN 	STD_LOGIC;
			SIGNAL I2CWriteIf			: IN 	STD_LOGIC;
			SIGNAL Ret_i				: IN STD_LOGIC;
        	SIGNAL clock, reset 		: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC,PC_plus_4, PC_RET_REG 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL Next_PC, Mem_Addr 		 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL Next_PC_No_Interrputs	: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 8,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr(7 downto 0), -- (9 downto 2) UPDATE
		q_a 			=> Instruction );
		
					-- copy output signals - allows read inside module
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		Mem_Addr <= Next_PC;
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1 WHEN Stall='0' ELSE PC( 9 DOWNTO 2 );
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
						
		Next_PC_No_Interrputs <= "0000000000" WHEN Reset = '1' ELSE
			Add_result&"00"  WHEN ( Flush='1' ) 
			ELSE   PC_plus_4;
			
		Next_PC  <= "0000000100" when (IE = '1' and I2CReadIF = '1') 
							ELSE PC_RET_REG when Ret_i = '1'
							ELSE Next_PC_No_Interrputs;
							
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC <= "0000000000" ;
			ELSIF IE = '1' AND I2CReadIF = '1' THEN
					IF Flush = '1' THEN 							
							PC_RET_REG <= Next_PC_No_Interrputs;						
					ELSIF (PCOfCommandInEX = "0000000000" and PCOfCommandInID = "0000000000") THEN
							PC_RET_REG <= PC;
					ELSIF (PCOfCommandInEX = "0000000000") THEN
							PC_RET_REG <= PC_plus_4;
					ELSE
						PC_RET_REG <= PCOfCommandInEX;
					END IF;
					PC <= Next_PC;	
			ELSE
				   PC <= Next_PC;
			END IF;
	END PROCESS;
END behavior;


