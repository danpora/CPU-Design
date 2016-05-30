library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
entity STD_FIFO is
	Generic (
		constant DATA_WIDTH  : positive;
		constant FIFO_DEPTH	: positive
	);
	Port ( 
		CLK		: in  STD_LOGIC;
		RST		: in  STD_LOGIC;
		WriteEn	: in  STD_LOGIC;
		DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		ReadEn	: in  STD_LOGIC;
		DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Empty	: out STD_LOGIC;
		Full	: out STD_LOGIC;
		Data0 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Data1 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Data2 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Data3 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Data4 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Data5 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Data6 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		FIFO_Memory_OUT: out STD_LOGIC_VECTOR (DATA_WIDTH*FIFO_DEPTH - 1 downto 0)
	);
end STD_FIFO;
 
architecture Behavioral of STD_FIFO is
 
begin
 
	-- Memory Pointer Process
	fifo_proc : process (CLK)
		type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		variable Memory : FIFO_Memory;
		
		variable Head : natural range 0 to FIFO_DEPTH - 1;
		variable Tail : natural range 0 to FIFO_DEPTH - 1;
		
		variable Looped : boolean;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				Head := 0;
				Tail := 0;
				
				Looped := false;
				
				Full  <= '0';
				Empty <= '1';
			else
				if (ReadEn = '1') then
					if ((Looped = true) or (Head /= Tail)) then
						-- Update data output
						DataOut <= Memory(Tail);
						
						-- Update Tail pointer as needed
						if (Tail = FIFO_DEPTH - 1) then
							Tail := 0;
							
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
						
						
					end if;
				end if;
				
				if (WriteEn = '1') then
					if ((Looped = false) or (Head /= Tail)) then
						-- Write Data to Memory
						Memory(Head) := DataIn;
						
						-- Increment Head pointer as needed
						if (Head = FIFO_DEPTH - 1) then
							Head := 0;
							
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
				end if;
				
				-- Update Empty and Full flags
				if (Head = Tail) then
					if Looped then
						Full <= '1';
					else
						Empty <= '1';
					end if;
				else
					Empty	<= '0';
					Full	<= '0';
				end if;
			end if;
			
			Data0 <= Memory(Head);
			Data1 <= Memory((Head+1) mod 7);
			Data2 <= Memory((Head+2) mod 7);
			Data3 <= Memory((Head+3) mod 7);
			Data4 <= Memory((Head+4) mod 7);
			Data5 <= Memory((Head+5) mod 7);
			Data6 <= Memory((Head+6) mod 7);
		end if;
	end process;
		
end Behavioral;