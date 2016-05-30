library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_control is
     Port ( 	 clk        : in  STD_LOGIC;
                start      : in  STD_LOGIC;
                reset      : in  STD_LOGIC;
                button_l   : IN std_logic;
                button_r   : IN std_logic;
					 data_in    : IN std_logic_vector (31 downto 0);
					 data_changed_interrupt : IN std_logic;
                rgb        : out  STD_LOGIC_VECTOR (2 downto 0);
                h_s        : out  STD_LOGIC;
                v_s        : out  STD_LOGIC);
      end vga_control;

architecture Behavioral of vga_control is

COMPONENT img_gen
    PORT(		  clk          : IN std_logic;
					  reset			: IN std_LOGIC;
                 x_control    : IN std_logic_vector(9 downto 0);
                 button_l     : IN std_logic;
                 button_r     : IN std_logic;
                 y_control    : IN std_logic_vector(9 downto 0);
                 video_on     : IN std_logic;          
					  data_in 		: IN std_logic_vector( 31 downto 0);
					  data_changed_interrupt : IN std_logic;
                 rgb          : OUT std_logic_vector(2 downto 0) 
					  );
  END COMPONENT;

COMPONENT sync_mod
PORT( 		  clk        : IN std_logic;
              reset      : IN std_logic;
              start      : IN std_logic;          
              y_control  : OUT std_logic_vector(9 downto 0);
              x_control  : OUT std_logic_vector(9 downto 0);
              h_s        : OUT std_logic;
              v_s        : OUT std_logic;
              video_on   : OUT std_logic );
END COMPONENT;

signal x,y:std_logic_vector(9 downto 0);
signal video:std_logic;

begin
 U1: img_gen 
	PORT MAP( 
			clk =>clk , 
			reset => reset,
			x_control => x,
			button_l =>not button_l,
			button_r => not button_r,
			y_control => y,
		   video_on =>video ,
		   data_in => data_in,
			data_changed_interrupt => data_changed_interrupt,
			rgb => rgb
			);

 U2: sync_mod 
	PORT MAP( clk => clk, 
	reset => reset,
	start => start,
	y_control => y, 
	x_control =>x ,
	h_s => h_s ,
   v_s => v_s,
   video_on =>video
	);
end Behavioral;
