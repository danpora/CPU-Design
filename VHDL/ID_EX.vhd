
-- libraries decleration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX is
				port(
				read_data_1_in 		: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2_in 		: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_1_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction_in	  		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend_in 		: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_in 		: IN  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				Instruction_out		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_register_address_in 				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				ALUSrc_in 				: IN 	STD_LOGIC;
            MemtoReg_in 			: IN 	STD_LOGIC;
            RegWrite_in 			: IN 	STD_LOGIC;
            MemRead_in 			   : IN 	STD_LOGIC;
            MemWrite_in 			: IN 	STD_LOGIC;
            ALUop_in 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				RegDst_in 				: IN 	STD_LOGIC;
				RegDst_out  			: OUT 	STD_LOGIC;
				write_register_address_out 				: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            ALUSrc_out  			: OUT 	STD_LOGIC;
            MemtoReg_out 			: OUT 	STD_LOGIC;
            RegWrite_out 			: OUT 	STD_LOGIC;
            MemRead_out 			: OUT 	STD_LOGIC;
            MemWrite_out 			: OUT 	STD_LOGIC;
            ALUop_out 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				Flush						: IN STD_LOGIC;
				Stall						: IN STD_LOGIC;
				clock, reset			: IN 	STD_LOGIC
				);
END entity;
-- Architecture Definition
architecture behavioral of ID_EX is                       
-- Design Body
begin
	process(clock)
	begin
	  if (rising_edge(clock)) then
			if(reset='0' and Flush='0' and Stall = '0') then
				 RegDst_out<=RegDst_in;
				 read_data_1_out<=read_data_1_in;
				 read_data_2_out<=read_data_2_in;
				 Instruction_out<=Instruction_in;
				 PC_plus_4_out<=PC_plus_4_in;
				 Sign_extend_out<=Sign_extend_in;
				 write_register_address_out<=write_register_address_in;
				 ALUSrc_out<=ALuSrc_in;
				 MemtoReg_out<=MemtoReg_in;
				 RegWrite_out<=RegWrite_in;
				 MemRead_out<=MemRead_in;
				 MemWrite_out<=MemWrite_in;
				 ALUop_out<=ALUop_in;
			 else
				 RegDst_out<='0';
				 read_data_1_out<=(others => '0');
				 read_data_2_out<=(others => '0');
				 Instruction_out<=(others => '0');
				 Sign_extend_out<=(others => '0');
				 PC_plus_4_out<=(others=>'0');
				 write_register_address_out<=(others => '0');
				 ALUSrc_out<='0';
				 MemtoReg_out<='0';
				 RegWrite_out<='0';
				 MemRead_out<='0';
				 MemWrite_out<='0';
				 ALUop_out<="00";
			end if;
	  end if;
	end process; 
end behavioral;