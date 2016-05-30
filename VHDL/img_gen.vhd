library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity img_gen is
	Port ( clk         : in  STD_LOGIC;
			 reset       : in  std_logic;
			 x_control   : in  STD_LOGIC_VECTOR(9 downto 0);
			 button_l    : in  STD_LOGIC;
			 button_r    : in  STD_LOGIC;
			 y_control   : in  STD_LOGIC_VECTOR(9 downto 0);
			 video_on    : in  STD_LOGIC;
			 data_in     : in  std_logic_vector(31 downto 0);
			 data_changed_interrupt: in std_LOGIC;
			 rgb         : out STD_LOGIC_VECTOR(2 downto 0)
			 );	
end img_gen;

architecture Behavioral of img_gen is
	
	--signal line_h_to_screen_res: std_logic_vector ( DATA_WIDTH - 1 downto 0);
	signal fifoReadEn: std_LOGIC;
	signal fifoWriteEn: std_LOGIC;
	
	--signal delta object
	signal line_h :integer; --Line Height
	constant line_w :integer :=4; --Line width
	
	--line
	signal line_on:std_logic;
	signal rgb_line:std_logic_vector(2 downto 0); 
	
	signal rgb_graph: std_logic_vector(2 downto 0);
	signal graph_on: std_logic;
	
	--x,y pixel cursor
	signal x,y:integer range 0 to 650;
	
	--mux
	signal vdbt:std_logic_vector(3 downto 0);
	
	--buffer
	signal rgb_reg,rgb_next:std_logic_vector(2 downto 0);
	
	signal data_in_manipulation: std_logic_vector(31 downto 0);

begin
			
	line_h <= to_integer(resize(signed(data_in(31 downto 2)), 32));
	
	--x,y pixel cursor
	x <=to_integer(unsigned("00" & x_control(9 downto 2)));
	y <=to_integer(unsigned(y_control));
		
	-- Memory Pointer Process
	
	process(clk)
		type FIFO_Memory is array (0 to 160-1) of integer;
		variable Memory : FIFO_Memory;
		variable Head : natural range 0 to 160 - 1;
		variable Tail : natural range 0 to 160 - 1;
		variable Looped : boolean;
		variable ind : integer;
	begin
		if rising_edge(CLK) then
			if reset = '1' then
				Head := 0;
				Tail := 0;
				
				Looped := false;
			
			else
				fifoReadEn <= '0';
				fifoWriteEn <= '0';
				if (data_changed_interrupt = '1') then
					fifoReadEn <= '1';
					fifoWriteEn <= '1';
				end if;
				if (fifoReadEn = '1') then
					if ((Looped = true) or (Head /= Tail)) then
						-- Update data output
						--DataOut <= Memory(Tail);
						
						-- Update Tail pointer as needed
						if (Tail = 160 - 1) then
							Tail := 0;
							
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
						
						
					end if;
				end if;
				
				if (fifoWriteEn = '1') then
					if ((Looped = false) or (Head /= Tail)) then
						-- Write Data to Memory
						Memory(Head) := line_h;
						
						-- Increment Head pointer as needed
						if (Head = 160 - 1) then
							Head := 0;
							
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
				end if;
				
				line_on <= '0';
				ind := Memory(x);
				if ( y < 240 and y > 240 - ind and ind > 0) or ( y > 240 and y < 240 - ind and ind < 0) then
					line_on <= '1';
				end if;
			end if;
		end if;
	end process;
									
	rgb_line <="010";  --Green 
	
	rgb_graph <= "010";

	--buffer
	process(clk)
	begin
		if clk'event and clk='1' then
			rgb_reg<=rgb_next;
		end if;
	end process;

	--mux
	vdbt <= video_on & '0' & '0' &line_on;      
	with vdbt select
		rgb_next <= "100"            when "1000", --Background of the screen is red  		 
		            rgb_line         when "1001",
						rgb_graph 		  when "1010",
	               "000"            when others;
	--output
	 rgb<=rgb_reg;

end Behavioral;
