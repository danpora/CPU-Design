
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY LPF IS
   PORT( 	
		Coef0 : in STD_LOGIC_VECTOR (31 downto 0);
		Coef1 : in STD_LOGIC_VECTOR (31 downto 0);
		Coef2 : in STD_LOGIC_VECTOR (31 downto 0);
		Coef3 : in STD_LOGIC_VECTOR (31 downto 0);
		Coef4 : in STD_LOGIC_VECTOR (31 downto 0);
		Coef5 : in STD_LOGIC_VECTOR (31 downto 0);
		Coef6 : in STD_LOGIC_VECTOR (31 downto 0);
		Data0 : in STD_LOGIC_VECTOR (15 downto 0);
		Data1 : in STD_LOGIC_VECTOR (15 downto 0);
		Data2 : in STD_LOGIC_VECTOR (15 downto 0);
		Data3 : in STD_LOGIC_VECTOR (15 downto 0);
		Data4 : in STD_LOGIC_VECTOR (15 downto 0);
		Data5 : in STD_LOGIC_VECTOR (15 downto 0);
		Data6 : in STD_LOGIC_VECTOR (15 downto 0);
		DataOut: out STD_LOGIC_VECTOR (31 downto 0)
	);
END LPF;

ARCHITECTURE behavior OF LPF IS
	signal Ytmp: signed(63 downto 0);	
BEGIN   
	
	Ytmp <= (resize(signed(Data0), 32) * signed(Coef0)) + 
			(resize(signed(Data1), 32) * signed(Coef1)) + 
			(resize(signed(Data2), 32) * signed(Coef2)) + 
			(resize(signed(Data3), 32) * signed(Coef3)) + 
			(resize(signed(Data4), 32) * signed(Coef4)) + 
			(resize(signed(Data5), 32) * signed(Coef5)) + 
			(resize(signed(Data6), 32) * signed(Coef6));	
			
	DataOut <= std_LOGIC_VECTOR(resize(Ytmp(55 downto 24),32));
END behavior;


