library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Functions is 
		function seven_segment(signal valu: std_logic_vector(3 downto 0)) return std_logic_vector;
end package;

package body Functions is

function seven_segment(signal valu: std_logic_vector(3 downto 0)) return std_logic_vector is
begin
   case valu is
     when "0000" => return "1000000";
     when "0001" => return "1111001";
	  when "0010" => return "0100100";
	  when "0011" => return "0110000";
	  when "0100" => return "0011001";
	  when "0101" => return "0010010";
	  when "0110" => return "0000010";
	  when "0111" => return "1111000";
	  when "1000" => return "0000000";
     when "1001" => return "0010000";
	  when "1010" => return "0001000";
	  when "1011" => return "0000011";
	  when "1100" => return "1000110";
	  when "1101" => return "0100001";
	  when "1110" => return "0000110";
	  when "1111" => return "0001110";
     when others => return "0111000";
   end case;
end seven_segment;

end package body;