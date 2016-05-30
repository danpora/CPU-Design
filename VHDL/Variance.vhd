
library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

entity Variance is
	port 
	(
		Data0 : in STD_LOGIC_VECTOR (15 downto 0);
		Data1 : in STD_LOGIC_VECTOR (15 downto 0);
		Data2 : in STD_LOGIC_VECTOR (15 downto 0);
		Data3 : in STD_LOGIC_VECTOR (15 downto 0);
		Data4 : in STD_LOGIC_VECTOR (15 downto 0);
		Data5 : in STD_LOGIC_VECTOR (15 downto 0);
		Data6 : in STD_LOGIC_VECTOR (15 downto 0);
		DataOut: out STD_LOGIC_VECTOR (31 downto 0)
	);
end entity;

architecture rtl of Variance is
	signal mean_data:  STD_LOGIC_VECTOR (31 downto 0);
	signal mean_squared_data:  STD_LOGIC_VECTOR (63 downto 0);
	signal variance: STD_LOGIC_VECTOR (31 downto 0);
	COMPONENT mean is
	generic(
		DATA_WIDTH: integer
	);
	port 
	(
		Data0 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		Data1 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		Data2 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		Data3 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		Data4 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		Data5 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		Data6 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		DataOut: out STD_LOGIC_VECTOR (DATA_WIDTH+DATA_WIDTH-1 downto 0)
	);
	end COMPONENT;

begin

mean0: mean
	GENERIC MAP(
		DATA_WIDTH => 16
	)
	PORT MAP (
		Data0 			=> Data0,
		Data1 			=> Data1,
		Data2 			=> Data2,
		Data3 			=> Data3,
		Data4 			=> Data4,
		Data5 			=> Data5,
		Data6 			=> Data6,
		DataOut 			=> mean_data
);
	
mean_squared: mean
		GENERIC MAP(
		DATA_WIDTH => 32
	)
	PORT MAP (
		Data0 			=> STD_LOGIC_VECTOR(signed(Data0)*signed(Data0)),
		Data1 			=> STD_LOGIC_VECTOR(signed(Data1)*signed(Data1)),
		Data2 			=> STD_LOGIC_VECTOR(signed(Data2)*signed(Data2)),
		Data3 			=> STD_LOGIC_VECTOR(signed(Data3)*signed(Data3)),
		Data4 			=> STD_LOGIC_VECTOR(signed(Data4)*signed(Data4)),
		Data5 			=> STD_LOGIC_VECTOR(signed(Data5)*signed(Data5)),
		Data6 			=> STD_LOGIC_VECTOR(signed(Data6)*signed(Data6)),
		DataOut 			=> mean_squared_data
);
variance <= STD_LOGIC_VECTOR(signed(mean_squared_data(31 downto 0)) - (signed(mean_data(15 downto 0))*signed(mean_data(15 downto 0))));
DataOut <= X"00000000"; -- Variance is not working
end rtl;
