	-- ====================================================================
--
--	File Name:		MEM_WB.vhd
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

entity MEM_WB is
		PORT (
				read_data_in 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_Result_in 		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_Result_out 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_register_address_in 				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );				
            MemtoReg_in 			: IN 	STD_LOGIC;
            RegWrite_in 			: IN 	STD_LOGIC;
				write_register_address_out 				: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            MemtoReg_out 			: OUT 	STD_LOGIC;
            RegWrite_out 			: OUT 	STD_LOGIC;
				RegDst_in 				: IN 	STD_LOGIC;
				RegDst_out  			: OUT 	STD_LOGIC;
				clock, reset		: IN 	STD_LOGIC
			  );
END entity;
-- Architecture Definition
architecture behavioral of MEM_WB is                       
-- Design Body
begin
	process(clock)
	begin
	  if (rising_edge(clock)) then
	       RegDst_out<=RegDst_in;
          read_data_out<=read_data_in;
			 ALU_Result_out<=ALU_Result_in;
			 write_register_address_out<=write_register_address_in;
          MemtoReg_out<=MemtoReg_in;
          RegWrite_out<=RegWrite_in;
	  end if;
	end process; 
end behavioral;