	-- ====================================================================
--
--	File Name:		GPIO.vhd			     
--	Date:			   10/06/2015
--	Designer:		Dan Porat, Or Koren
--
-- =======================================================================

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;
use work.Functions.all;

entity gpio is
		generic(N: positive := 32);     
		PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 			   : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite : IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC;
				InterruptADXL		: IN STD_LOGIC;
				pushBottun: in std_logic_vector(3 downto 0);
				
				segment0: out std_logic_vector(6 downto 0); -- output to 7-segment0
				segment1: out std_logic_vector(6 downto 0); -- output to 7-segment1
				segment2: out std_logic_vector(6 downto 0); -- output to 7-segment2
				segment3: out std_logic_vector(6 downto 0);  -- output to 7-segment3
				
				--filtered_data: out std_logic_vector(31 downto 0);
				
				scl:    inout std_logic;
				sda:    inout std_logic;
				
				I2C_Write_Interrupt : out std_logic;
				I2C_Read_Interrupt  : out std_logic;
				
				RGBOut	: out std_LOGIC_VECTOR(2 downto 0);
				h_s		: out std_LOGIC;
				v_s		: out std_LOGIC;
				
				first_byte_recieved_out, i2c_read_write_out, is_fifo1_empty_out: out std_LOGIC -- to be deleted
			);	
end gpio;	

architecture structure of gpio is

	signal M_scl_line_out: std_logic;
	signal M_sda_line_out: std_logic;
	signal masterBusy: std_logic;
	signal masterDataRead: STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
	signal masterAckError: std_logic;
	signal to_seven_seg: std_logic_vector(31 downto 0);
	signal seven_seg_en: std_logic;
	signal data_to_7_seg: std_logic_vector(31 downto 0);
	signal write_clock: std_logic;
	signal i2c_master_enable: std_logic;
	signal data_out_of_FIFO: std_logic_vector(7 downto 0);	
	signal i2c_read_write: std_logic;
	signal i2c_master_reset: std_logic;
	signal interrupt_write_out: std_logic;
	signal interrupt_read_out: std_logic;
	signal i2c_has_data2write_flag: std_LOGIC;
	signal prev_fifo_read_enable: std_LOGIC;
	signal I2C_has_data: std_LOGIC;
	signal i2c_ready_to_load_new_write: std_LOGIC;
	signal slave_ack2: std_logic;
	signal write_state_flag: std_logic;
	signal master_ack_flag: std_LOGIC;
	signal fifo1_read_enable: std_logic;
	signal fifo1_data_out: std_logic_vector( 7 downto 0);
	signal fifo1_data_in: std_logic_vector( 7 downto 0);
	signal is_fifo1_full: std_logic;
	signal is_fifo1_empty: std_logic;
	signal fifo1_reset: std_logic;
	signal fifo1_write_enable: std_logic;
	signal fifo2_read_enable: std_logic;
	signal fifo2_data_out: std_logic_vector( 15 downto 0);
	signal fifo2_data_in: std_logic_vector( 15 downto 0);
	signal is_fifo2_full: std_logic;
	signal is_fifo2_empty: std_logic;
	signal fifo2_reset: std_logic;
	signal fifo2_write_enable: std_logic;
	signal data_read_HI: std_logic_vector( 7 downto 0 );
	signal data_read_LO: std_logic_vector( 7 downto 0 );
	signal first_byte_received: std_logic;
	signal fifo2_data0: std_logic_vector( 15 downto 0);
	signal fifo2_data1: std_logic_vector( 15 downto 0);
	signal fifo2_data2: std_logic_vector( 15 downto 0);
	signal fifo2_data3: std_logic_vector( 15 downto 0);
	signal fifo2_data4: std_logic_vector( 15 downto 0);
	signal fifo2_data5: std_logic_vector( 15 downto 0);
	signal fifo2_data6: std_logic_vector( 15 downto 0);
	signal LPS_Coef0  : std_logic_vector( 31 downto 0);
	signal LPS_Coef1  : std_logic_vector( 31 downto 0);
	signal LPS_Coef2  : std_logic_vector( 31 downto 0);
	signal LPS_Coef3  : std_logic_vector( 31 downto 0);
	signal LPS_Coef4  : std_logic_vector( 31 downto 0);
	signal LPS_Coef5  : std_logic_vector( 31 downto 0);
	signal LPS_Coef6  : std_logic_vector( 31 downto 0);
	signal began_second_read: std_LOGIC;
	signal num_configurations_sent: std_LOGIC_vector(11 downto 0);
	signal stopped_flag: std_LOGIC;
	signal data_has_changed: std_LOGIC;
	signal filtered_data: std_LOGIC_vector(31 downto 0);
	signal mean_data: std_LOGIC_vector(31 downto 0);
	signal variance_data: std_LOGIC_vector(31 downto 0);
	signal display_data: std_LOGIC_vector(31 downto 0);
	signal displaySwitch: std_LOGIC_vector(1 downto 0);
component i2c_master IS
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC;                   --serial clock output of i2c bus
	 interrupt_write_out : OUT    STD_LOGIC;
	 ready_to_load_new_write		: OUT STD_LOGIC;
	 slave_ack2 : OUT std_logic;
	 began_second_read: OUT std_LOGIC;
	 write_state_flag : OUT std_logic;
	 master_ack_flag  : OUT std_logic;
	 stopped_flag		: OUT std_LOGIC
	 );
END component;
	
component STD_FIFO is
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
		Data6 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
	);
end component;

component LPF IS
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
END component;

COMPONENT vga_control is
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
end COMPONENT;
	
COMPONENT mean is
	generic(
		DATA_WIDTH: integer
	);
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
end COMPONENT;

COMPONENT Variance is
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
end COMPONENT;

begin
	
	I2C_Write_Interrupt <=  interrupt_write_out;
	I2C_Read_Interrupt <=  interrupt_read_out;

		i2c_mstr: I2C_Master
		port map(
			clk 							=> Clock,
			reset_n						=> i2c_master_reset,
			ena 							=> i2c_master_enable,
			addr							=> "1010011",
			rw								=> i2c_read_write,
			data_wr						=> fifo1_data_out,
			busy							=> masterBusy,
			data_rd						=> MasterDataRead,
			ack_error					=> masterAckError,
			sda							=> sda,
			scl							=> scl,
			interrupt_write_out 		=> interrupt_write_out,
			ready_to_load_new_write => i2c_ready_to_load_new_write,
			slave_ack2					=> slave_ack2,
			write_state_flag 			=> write_state_flag,
			began_second_read			=> began_second_read,
			master_ack_flag 			=> master_ack_flag,
			stopped_flag		      => stopped_flag
			);
	
	fifo1: STD_FIFO 
		generic map (FIFO_DEPTH => 256,
					 DATA_WIDTH => 8)
		port map(
			CLK         => Clock,
			RST 			  => reset,
			WriteEn		  => fifo1_write_enable,
			DataIn		  => fifo1_data_in,
			ReadEn		  => fifo1_read_enable,
			DataOut		  => fifo1_data_out,
			Empty			  => is_fifo1_empty,
			Full			  => is_fifo1_full
			);
			
	fifo2: STD_FIFO
		generic map (FIFO_DEPTH => 7,
						 DATA_WIDTH => 16)
		port map(
			CLK         => Clock,
			RST 			  => reset,
			WriteEn		  => fifo2_write_enable,
			DataIn		  => fifo2_data_in,
			ReadEn		  => fifo2_read_enable,
			DataOut		  => fifo2_data_out,
			Empty			  => is_fifo2_empty,
			Full			  => is_fifo2_full,
			Data0         => fifo2_data0,
			Data1         => fifo2_data1,
			Data2         => fifo2_data2,
			Data3			  => fifo2_data3,
			Data4			  => fifo2_data4,
			Data5  		  => fifo2_data5,
			Data6			  => fifo2_data6
			);
	
	lowPass: LPF
		PORT map( 	
			Coef0          => LPS_Coef0,
			Coef1          => LPS_Coef1,
			Coef2          => LPS_Coef2,
			Coef3          => LPS_Coef3,
			Coef4          => LPS_Coef4,
			Coef5          => LPS_Coef5,
			Coef6          => LPS_Coef6,
			Data0 			=> fifo2_data0,
			Data1 			=> fifo2_data1,	
			Data2 			=>	fifo2_data2,
			Data3 			=> fifo2_data3,
			Data4 			=> fifo2_data4,
			Data5 			=> fifo2_data5,
			Data6 			=> fifo2_data6,
			DataOut 			=> filtered_data
		);
		
	mean0: mean
		GENERIC MAP(
			DATA_WIDTH => 16
		)
		PORT MAP (
			Data0 			=> fifo2_data0,
			Data1 			=> fifo2_data1,
			Data2 			=> fifo2_data2,
			Data3 			=> fifo2_data3,
			Data4 			=> fifo2_data4,
			Data5 			=> fifo2_data5,
			Data6 			=> fifo2_data6,
			DataOut 			=> mean_data
	);
	variance0: Variance
		PORT MAP (
			Data0 			=> fifo2_data0,
			Data1 			=> fifo2_data1,
			Data2 			=> fifo2_data2,
			Data3 			=> fifo2_data3,
			Data4 			=> fifo2_data4,
			Data5 			=> fifo2_data5,
			Data6 			=> fifo2_data6,
			DataOut 			=> variance_data
	);
	VGA_CTRL: vga_control
     Port map( 	 
			clk        		=>	Clock,
			start      		=>	'1',
			reset      		=>	reset,
			data_in    		=>	display_data,
			data_changed_interrupt => interrupt_read_out,
			button_l   		=> '0',
			button_r   		=> '0',
			rgb        		=>	RGBOut,
			h_s        		=>	h_s,
			v_s        		=> v_s
	);
	
	i2c_master_reset <= reset;

	process(address, write_clock)
		variable byte_2write_cnt : integer range 0 to 100;
		begin	
			if (reset = '1') then
				i2c_has_data <= '0';
				fifo1_read_enable <= '0';
				fifo2_read_enable <= '0';
				first_byte_received <= '0'; 
				interrupt_read_out <= '0';
				data_has_changed <= '0';
				num_configurations_sent <= "000000000001";
			elsif (rising_edge(write_clock)) then
				fifo1_write_enable <= '0';	
				fifo2_write_enable <= '0';
				fifo2_read_enable <= '0';
				interrupt_read_out <= '0';
				
				if (Memwrite = '1') then
				
					case address is
					
						-- 7-Segments control
						when X"00000404" =>	
							--data_to_7_seg <= write_data;					
						
						-- I2C Master control - write to slave
						when X"00000408" =>						
							fifo1_data_in <= write_data(7 downto 0);
							fifo1_write_enable <= '1';	
			
						when X"0000040C" => LPS_Coef0 <= write_data;
											
						
						when X"00000410" => LPS_Coef1 <= write_data;
											 
						
						when X"00000414" => LPS_Coef2 <= write_data;
							
										
						when X"00000418" => LPS_Coef3 <= write_data;
									
						
						when X"0000041C" => LPS_Coef4 <= write_data;
										
						
						when X"00000420" => LPS_Coef5 <= write_data;
							
						
						when X"00000424" => LPS_Coef6 <= write_data;		
				
						-- FIFO2 control
						when X"00000430" => 
							fifo2_data_in <= write_data(15 downto 0);
							fifo2_read_enable <= '1';
							fifo2_write_enable <= '1';
						when others => null;
					 
					end case;
				
				elsif (MemRead = '1') then
					case address is
						when X"00000428" => read_data <= X"0000" & data_read_HI & data_read_LO;
						when others => read_data <= X"00000000";
					end case;
				end if;
						
			if (is_fifo1_empty = '0') then
					if (i2c_has_data = '0') then
						if (num_configurations_sent(2) = '1' or num_configurations_sent(5) = '1' or 
								num_configurations_sent(8) = '1' or num_configurations_sent(11) = '1') then						
								i2c_master_enable <= '0';
						else
								i2c_read_write <= '0';	
								i2c_master_enable <='1';
								fifo1_read_enable <='1';
								i2c_has_data <= '1';
								num_configurations_sent <= num_configurations_sent(10 downto 0) & '0';
						end if;
					else
						fifo1_read_enable <='0';
					end if;
			else 
					if (write_state_flag = '1' and first_byte_received='0') then
						i2c_read_write <= '1';
					end if;
			end if;	
			
			if (i2c_ready_to_load_new_write = '1') then
				i2c_has_data <= '0';
			end if;
			
			if (stopped_flag = '1' and 
					(num_configurations_sent(2) = '1' or num_configurations_sent(5) = '1' 
						or num_configurations_sent(8) = '1' or num_configurations_sent(11) = '1')) then						
					num_configurations_sent <= num_configurations_sent(10 downto 0) & '0';
			end if;
			
			if (master_ack_flag = '1' and first_byte_received = '1') then
				first_byte_received <= '0';
				data_read_HI <= masterDataRead;
				if (data_has_changed = '1') then
						data_has_changed <= '0';
						interrupt_read_out <= '1';
				end if;
			elsif (master_ack_flag = '1' and first_byte_received = '0') then
				first_byte_received <= '1';
				data_read_LO <= masterDataRead;
			end if;
			
			if (began_second_read = '1') then
					i2c_read_write <= '0';
			end if;
			
			if ( InterruptADXL = '1' ) then
				data_has_changed <= '1';
			end if;			
		end if;	
	
	end process;
	
	process (Clock)
	begin
		if (rising_edge(Clock)) then
			case pushBottun is
				when "1110" => displaySwitch <= "01";
				when "1101" => displaySwitch <= "10";
				when "1011" => displaySwitch <= "11";
				when others => null;
			end case;
		end if;
	end process;
	
	data_to_7_seg <= display_data;
	display_data <= filtered_data when displaySwitch = "01" else 
							mean_data when displaySwitch = "10" else 
							variance_data when displaySwitch = "11" else 
							filtered_data;
	first_byte_recieved_out <= first_byte_received; -- to delete
	i2c_read_write_out <= data_has_changed; -- to delete
	is_fifo1_empty_out <= i2c_master_enable; -- to delete
	write_clock <= not Clock;
	segment0 <= seven_segment(data_to_7_seg(3 downto 0)); --seven_segment(write_data(3 downto 0)); 
	segment1 <= seven_segment(data_to_7_seg(7 downto 4)); --write_data(13 downto 7); --seven_segment(write_data(7 downto 4)); 
	segment2 <= seven_segment(data_to_7_seg(11 downto 8)); --seven_segment(write_data(11 downto 8));
	segment3 <= seven_segment(data_to_7_seg(15 downto 12)); --seven_segment(write_data(15 downto 12));		
end structure;	



