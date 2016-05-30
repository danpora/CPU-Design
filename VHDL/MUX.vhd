library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
	generic ( n : integer:= 32 );   
	Port ( 	  SelectIN : in  STD_LOGIC;
				  entrance1 : in  STD_LOGIC_VECTOR (n-1 downto 0);
				  entrance2 : in  STD_LOGIC_VECTOR (n-1 downto 0);
				  outData :  out  STD_LOGIC_VECTOR (n-1 downto 0)
			);
end mux;

architecture Behavioral of mux is
begin

		WITH SelectIN SELECT
		outData <=  entrance1 WHEN '0',
					   entrance2 WHEN OTHERS;
end Behavioral;