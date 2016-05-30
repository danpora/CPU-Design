
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	flush_in 	: IN 	STD_LOGIC;
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Zero 			: IN	 	STD_LOGIC;
	Ret_i			: OUT		STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq,imit 	: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '0' WHEN flush_in='1' ELSE '1'  WHEN  Opcode = "000000" AND reset='0' ELSE '0';
	Lw          <=  '0' WHEN flush_in='1' ELSE '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '0' WHEN flush_in='1' ELSE '1'  WHEN  Opcode = "101011"  ELSE '0';
   Beq         <=  '0' WHEN flush_in='1' ELSE '1'  WHEN  Opcode = "000100"  ELSE '0'; 
	Ret_i			<=	 '0' WHEN flush_in='1' ELSE '1'  WHEN  Opcode = "000010"  ELSE '0'; 
  	RegDst    	<=  '0' WHEN flush_in='1' ELSE R_format;
 	ALUSrc  		<=  '0' WHEN flush_in='1' ELSE Lw OR Sw;
	MemtoReg 	<=  '0' WHEN flush_in='1' ELSE Lw;
  	RegWrite 	<=  '0' WHEN flush_in='1' ELSE R_format OR Lw;
  	MemRead 		<=  '0' WHEN flush_in='1' ELSE Lw;
   MemWrite 	<=  '0' WHEN flush_in='1' ELSE Sw; 
	ALUOp( 1 ) 	<=  '0' WHEN flush_in='1' ELSE R_format;
	ALUOp( 0 ) 	<=  '0' WHEN flush_in='1' ELSE Beq; 
   END behavior;


