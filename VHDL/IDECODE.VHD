				
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			write_data_out: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			RegDst 		: IN 	STD_LOGIC;
			write_register_address_in 		:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			write_register_address_out 	:OUT STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Zero			: OUT STD_LOGIC;
			pushBottun: in std_logic_vector(3 downto 0);
			led : out std_logic_vector(3 downto 0);
			clock,reset	: IN 	STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS

component random is
	port(
	clock:in std_logic;
	num:out std_logic_vector(3 downto 0));
end component;

component seven_segment_16bit is 
 port (
	number : in std_logic_vector(15 downto 0);
	en: in std_logic; 	
	frist_4bit: out std_logic_vector (6 downto 0);
	second_4bit: out std_logic_vector (6 downto 0);
	third_4bit: out std_logic_vector (6 downto 0);
	fourth_4bit: out std_logic_vector (6 downto 0)
	);
end component;

TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL Branch_Add 						: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL read_data_1_in					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2_in					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL rand_num,pushBottun_in			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
			-- Read Register 1 Operation
			read_data_1_in <= register_array(CONV_INTEGER(   read_register_1_address ));
		--read_data_1_in <= ALU_result WHEN (read_register_1_address=write_register_address_in and write_register_address_in/=
		--						"00000" and RegWrite='1') ELSE register_array(CONV_INTEGER(   read_register_1_address ) );
			-- Read Register 2 Operation		
			read_data_2_in <= register_array(CONV_INTEGER( read_register_2_address ));
		--read_data_2_in <= ALU_result WHEN (read_register_2_address=write_register_address_in and write_register_address_in/=
		--						"00000" and RegWrite='1') ELSE register_array(CONV_INTEGER( read_register_2_address ) );	
		read_data_1<=read_data_1_in;
		read_data_2<=read_data_2_in;
			-- Mux for Register Write Address
      write_register_address_out <= write_register_address_1 
			WHEN RegDst = '1'  	ELSE write_register_address_0;
		   -- Mux to bypass data memory for Rformat instructions
	   write_data <= ALU_result( 31 DOWNTO 0 ) 
			WHEN ( MemtoReg = '0' ) 	ELSE read_data;
		write_data_out <= write_data;
		
		-- Adder to compute Branch Address
		--Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Instruction_immediate_value( 7 DOWNTO 0 ) ;
		--Add_Result 	<= Branch_Add( 7 DOWNTO 0 );		
		
		Zero<='1' WHEN (read_data_1_in = read_data_2_in) ELSE '0'; 

			-- Sign Extend 16-bits to 32-bits
    	Sign_extend <= X"0000" & Instruction_immediate_value
		WHEN Instruction_immediate_value(15) = '0'
		ELSE	X"FFFF" & Instruction_immediate_value;
		--roll out the address to write in 
      write_register_address<=write_register_address_in;
		
PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
	      IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
				FOR i IN 0 TO 31 LOOP
					register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
				END LOOP;
					-- Write back to register - don't write to register 0
			ELSE 
					if RegWrite = '1' AND write_register_address /= 0 THEN
						register_array( CONV_INTEGER( write_register_address)) <= write_data;
					end if;
			END IF;
END PROCESS;
END behavior;


