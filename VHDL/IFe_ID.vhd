
-- libraries decleration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IFe_ID is
				port(
				Instruction_in	   : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_in 		: IN  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				Stall 				: IN 	STD_LOGIC;
				Flush 				: IN 	STD_LOGIC;
				Flush_out 			: OUT 	STD_LOGIC;
				Instruction_out	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				clock, reset		: IN 	STD_LOGIC
				);
END entity;
-- Architecture Definition
architecture behavioral of IFe_ID is                       
-- Design Body
begin
	process(clock)
	begin
	  if (rising_edge(clock)) then
	     if(reset/='1' and Stall/='1' and Flush/='1') then
          Instruction_out<=Instruction_in;
			 PC_plus_4_out<=PC_plus_4_in;
			 Flush_out<=Flush;
		  elsif (Flush='1') then
			 Instruction_out<=(others=>'0');
			 PC_plus_4_out<=(others=>'0');
			 Flush_out<=Flush;
		  end if;
	  end if;
	end process; 
end behavioral;