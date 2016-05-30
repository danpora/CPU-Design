
-- libraries decleration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hazard_detection is
				port(
				read_register_1_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				read_register_2_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_ID_EX							:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				MemtoReg,LwID_EX, Beq												:IN 	STD_LOGIC;	
				Zero															:IN 	STD_LOGIC;
				Stall, Flush												:OUT 	STD_LOGIC
				);
END entity;
-- Architecture Definition
architecture behavioral of Hazard_detection is                       
-- Design Body
SIGNAL Result_MEM_WB:STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL from_EX_MEM,from_MEM_WB:STD_LOGIC;
  
begin
	 Flush <=  Beq and Zero;
	 Stall<= '1' WHEN (write_register_address_ID_EX=read_register_1_address or 
							(write_register_address_ID_EX=read_register_2_address and MemtoReg = '0') ) and LwID_EX='1'
					 ELSE '0';
end behavioral;