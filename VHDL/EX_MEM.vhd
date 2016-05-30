-- ====================================================================
--
--	File Name:		EX_MEM.vhd
--	Description:	register to data. updates the interior data.
--					     
--	Date:			24/05/2013
--	Designer:		Goldfarb Maxim, Mushailov Michael
--
-- ====================================================================


-- libraries decleration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MEM is
				port(
            ALU_Result_in 			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Read_data_2_in 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
            Read_data_2_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
            ALU_Result_out 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_register_address_in 				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );				
            MemtoReg_in 			: IN 	STD_LOGIC;
            RegWrite_in 			: IN 	STD_LOGIC;
            MemRead_in 			   : IN 	STD_LOGIC;
            MemWrite_in 			: IN 	STD_LOGIC;
				RegDst_in 				: IN 	STD_LOGIC;
				RegDst_out  			: OUT 	STD_LOGIC;
				write_register_address_out 				: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            MemtoReg_out 			: OUT 	STD_LOGIC;
            RegWrite_out 			: OUT 	STD_LOGIC;
            MemRead_out 			: OUT 	STD_LOGIC;
            MemWrite_out 			: OUT 	STD_LOGIC;
				clock, reset		   : IN 	STD_LOGIC
				);
END entity;
-- Architecture Definition
architecture behavioral of EX_MEM is                       
-- Design Body
begin
	process(clock)
	begin
	  if (rising_edge(clock)) then
			 RegDst_out<=RegDst_in;
			 ALU_Result_out<=ALU_Result_in;
			 Read_data_2_out<=Read_data_2_in;
			 write_register_address_out<=write_register_address_in;
          MemtoReg_out<=MemtoReg_in;
          RegWrite_out<=RegWrite_in;
          MemRead_out<=MemRead_in;
          MemWrite_out<=MemWrite_in;
	  end if;
	end process; 
end behavioral;