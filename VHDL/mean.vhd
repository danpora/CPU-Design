
library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

entity mean is
	generic(
		data_width: integer
	);
	port 
	(
		Data0 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Data1 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Data2 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Data3 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Data4 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Data5 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		Data6 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
		DataOut: out STD_LOGIC_VECTOR (data_width+data_width-1 downto 0)
	);
end entity;

architecture rtl of mean is
	signal tmp: signed (data_width+data_width-1 downto 0);
	signal zeroes: signed (data_width-1 downto 0) := (others => '0');
begin
zeroes(0) <= '1';
zeroes(3) <= '1';
tmp<= (signed(Data0)+signed(Data1)+signed(Data2)+signed(Data3)
							+signed(Data4)+signed(Data5)+signed(Data6))*zeroes;
DataOut <= std_LOGIC_VECTOR(resize(tmp(data_width+data_width-1 downto 6), data_width+data_width));
end rtl;
