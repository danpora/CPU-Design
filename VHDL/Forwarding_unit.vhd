
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Forwarding_unit is
				port(
				read_register_1_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				read_register_2_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_EX_MEM							:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_MEM_WB							:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				RegDst_EX_MEM,RegDst_MEM_WB, MemtoReg_MEM_WB :IN 	STD_LOGIC;	
				ALU_Result_EX_MEM,ALU_Result_MEM_WB 			   :IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_MEM_WB 											:IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				forward_A,forward_B									   :OUT 	STD_LOGIC_VECTOR(1 downto 0)
				);
END entity;
-- Architecture Definition
architecture behavioral of Forwarding_unit is                       
-- Design Body
SIGNAL Result_MEM_WB:STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL from_EX_MEM,from_MEM_WB:STD_LOGIC;
  
begin

    --Decides if the first register should get the new data	
	forward_A<="01" WHEN (write_register_address_EX_MEM=read_register_1_address and RegDst_EX_MEM='1') ELSE
					"10" WHEN	 (write_register_address_MEM_WB=read_register_1_address and (RegDst_MEM_WB='1' or MemtoReg_MEM_WB='1')) ELSE "00";
	--Decides if the seconed register should get the new data
	 forward_B<="01" WHEN (write_register_address_EX_MEM=read_register_2_address and RegDst_EX_MEM='1') ELSE
					"10" WHEN (write_register_address_MEM_WB=read_register_2_address and (RegDst_MEM_WB='1' or MemtoReg_MEM_WB='1')) ELSE "00";		
 
end behavioral;