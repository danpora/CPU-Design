
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS

	PORT( 
		reset, clock					: IN 	STD_LOGIC; 
		pushBottun: in std_logic_vector(3 downto 0);
		ADXL_interrupt_in: in std_LOGIC;
		led : out std_logic_vector(3 downto 0);	
		
		segment0: out std_logic_vector(6 downto 0); -- output to 7-segment0
		segment1: out std_logic_vector(6 downto 0); -- output to 7-segment1
		segment2: out std_logic_vector(6 downto 0); -- output to 7-segment2
		segment3: out std_logic_vector(6 downto 0);  -- output to 7-segment3
		
		RGBOut	: out std_LOGIC_VECTOR(2 downto 0);
		h_s		: out std_LOGIC;
		v_s		: out std_LOGIC;
				
				
		M_scl: inout std_logic;
		M_sda: inout std_LOGIC;
		first_byte_recieved_out, i2c_read_write_out, is_fifo1_empty_out: out std_LOGIC -- to delete
		);
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				PCOfCommandInEX	: IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				PCOfCommandInID	: IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		Add_result 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		Flush 				: IN 	STD_LOGIC;
				IE						: IN STD_LOGIC; 
				I2CReadIF			: IN 	STD_LOGIC;
				I2CWriteIf			: IN 	STD_LOGIC;
				Ret_i					: IN STD_LOGIC;
				Stall 				: IN 	STD_LOGIC;
        		clock,reset 		: IN 	STD_LOGIC 
				);
	END COMPONENT; 

	COMPONENT IFe_ID 
				port(
				Instruction_in	   : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_in 		: IN  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				Stall 				: IN 	STD_LOGIC;
				Flush 				: IN 	STD_LOGIC;
				Flush_out	 		: OUT 	STD_LOGIC;
				Instruction_out	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				clock, reset		: IN 	STD_LOGIC
				);
	END COMPONENT;
	
	COMPONENT Idecode
 	     PORT(	read_data_1 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_data_out: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		Instruction 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		ALU_result 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		RegWrite, MemtoReg 	: IN 	STD_LOGIC;
        		RegDst 				: IN 	STD_LOGIC;
				write_register_address_in 		:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_out 	:OUT STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				Zero					:				OUT STD_LOGIC;
				Sign_extend 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				pushBottun: in std_logic_vector(3 downto 0);
				led : out std_logic_vector(3 downto 0);
        		clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;
	
	COMPONENT Hazard_detection is
				port(
				read_register_1_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				read_register_2_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_ID_EX							:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				MemtoReg,LwID_EX, Beq												:IN 	STD_LOGIC;	
				Zero															:IN STD_LOGIC;
				Stall, Flush												:OUT 	STD_LOGIC
				);
	END COMPONENT;
	
	COMPONENT ID_EX 
				port(
				read_data_1_in 		: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2_in 		: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend_in 		: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_1_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction_in	   : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction_out	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4_in 		: IN  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				write_register_address_in 				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				ALUSrc_in 				: IN 	STD_LOGIC;
            MemtoReg_in 			: IN 	STD_LOGIC;
            RegWrite_in 			: IN 	STD_LOGIC;
            MemRead_in 			   : IN 	STD_LOGIC;
            MemWrite_in 			: IN 	STD_LOGIC;
				RegDst_in 				: IN 	STD_LOGIC;
				RegDst_out  			: OUT 	STD_LOGIC;
            ALUop_in 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				write_register_address_out 				: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            ALUSrc_out  			: OUT 	STD_LOGIC;
            MemtoReg_out 			: OUT 	STD_LOGIC;
            RegWrite_out 			: OUT 	STD_LOGIC;
            MemRead_out 			: OUT 	STD_LOGIC;
            MemWrite_out 			: OUT 	STD_LOGIC;
            ALUop_out 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				Flush, Stall			: IN STD_LOGIC;
				clock, reset			: IN 	STD_LOGIC
				);
	END COMPONENT;
	
	COMPONENT control
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC;
             	ALUSrc 				: OUT 	STD_LOGIC;
             	MemtoReg 			: OUT 	STD_LOGIC;
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			   : OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
					flush_in 			: IN 	STD_LOGIC;
             	Zero 					: IN	 	STD_LOGIC;
					Ret_i					: OUT		STD_LOGIC;
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                  Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
               	ALUSrc 				: IN 	STD_LOGIC;
						forward_A  			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
						forward_B 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
						write_data_WB		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- write data from WB part
						write_data_MEM		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- write data from MEM part
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
						Add_Result 			: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
						Read_data_2_out: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
						Zero					: OUT STD_LOGIC;
						Sign_Extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
						PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
               	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;
	
	COMPONENT Forwarding_unit is
				port(
				read_register_1_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				read_register_2_address									:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_EX_MEM							:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				write_register_address_MEM_WB							:IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				RegDst_EX_MEM,RegDst_MEM_WB, MemtoReg_MEM_WB :IN 	STD_LOGIC;	
				ALU_Result_EX_MEM,ALU_Result_MEM_WB 			   :IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_MEM_WB 											:IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				forward_A,forward_B									   :OUT 	STD_LOGIC_VECTOR(1 downto 0)
				);
	END COMPONENT;

	COMPONENT EX_MEM 
				port(
            ALU_Result_in 			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Read_data_2_in 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
            Read_data_2_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
            ALU_Result_out 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_register_address_in 				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            MemtoReg_in 			: IN 	STD_LOGIC;
            RegWrite_in 			: IN 	STD_LOGIC;
            MemRead_in 			   : IN 	STD_LOGIC;
            MemWrite_in 			: IN 	STD_LOGIC;
				RegDst_in 				: IN 	STD_LOGIC;
				RegDst_out  			: OUT 	STD_LOGIC;
				write_register_address_out 				: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
            MemtoReg_out 			: OUT 	STD_LOGIC;
            RegWrite_out 			: OUT 	STD_LOGIC;
            MemRead_out 			: OUT 	STD_LOGIC;
            MemWrite_out 			: OUT 	STD_LOGIC;
				clock, reset		   : IN 	STD_LOGIC
				);
	END COMPONENT;
	
	COMPONENT dmemory
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC;
				ALU_10            : in std_logic				
				);	
	END COMPONENT;
	--added components:
	COMPONENT MEM_WB
		PORT (
				read_data_in 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_Result_in 		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_out 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_Result_out 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_register_address_in 				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            MemtoReg_in 			: IN 	STD_LOGIC;
            RegWrite_in 			: IN 	STD_LOGIC;
				write_register_address_out 				: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
            MemtoReg_out 			: OUT 	STD_LOGIC;
            RegWrite_out 			: OUT 	STD_LOGIC;
				RegDst_in 				: IN 	STD_LOGIC;
				RegDst_out  			: OUT 	STD_LOGIC;				
				clock, reset		   : IN 	STD_LOGIC
			  );
	END COMPONENT;
	
	component gpio is
		generic(N: positive := 32);     
		PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 				: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite : IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC;
				InterruptADXL		: IN STD_LOGIC;
				pushBottun: in std_logic_vector(3 downto 0);
				
				segment0: out std_logic_vector(6 downto 0); -- output to 7-segment0
				segment1: out std_logic_vector(6 downto 0); -- output to 7-segment1
				segment2: out std_logic_vector(6 downto 0); -- output to 7-segment2
				segment3: out std_logic_vector(6 downto 0);  -- output to 7-segment3
				
				I2C_Write_Interrupt : out std_logic;
				I2C_Read_Interrupt  : out std_logic;
				
				RGBOut	: out std_LOGIC_VECTOR(2 downto 0);
				h_s		: out std_LOGIC;
				v_s		: out std_LOGIC;
				
				scl:    inout std_logic;
				sda:    inout std_logic;
				first_byte_recieved_out, i2c_read_write_out, is_fifo1_empty_out: OUT std_LOGIC	-- to delete	
			);	
	end component;	
	
	-- declare signals used to connect VHDL components
			
	SIGNAL PC_plus_4,PC_plus_4_IFe_ID,PC_plus_4_ID_EX		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1,read_data_1_ID_EX,read_data_1_EX_MEM,read_data_1_MEM_WB 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend,sign_Extend_ID_EX 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2,read_data_2_ID_EX,read_data_2_EX, read_data_2_EX_MEM,read_data_2_MEM_WB 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result						 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result,ALU_Result_EX_MEM,ALU_Result_MEM_WB		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data,read_data_MEM_WB 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_final						: STD_LOGIC_VECTOR(31 downto 0); -- data from Dmemory or GPIO
	SIGNAL ALUSrc,ALUSrcID_EX,Stall 			: STD_LOGIC;
	SIGNAL Flush,Flush_IFe_ID, Flush_or_IFE				: STD_LOGIC;
	SIGNAL IE, I2CReadIF, I2CWriteIF, IFEn, I2CReadIF_tmp					:  STD_LOGIC; 
	SIGNAL Ret_i			: STD_LOGIC;
	SIGNAL RegDst,RegDst_ID_EX,RegDst_EX_MEM,RegDst_MEM_WB 			: STD_LOGIC;
	SIGNAL Regwrite,RegWriteID_EX,RegWrite_EX_MEM,RegWrite_MEM_WB 		: STD_LOGIC;
	SIGNAL Zero, Zero_ID			: STD_LOGIC;
	SIGNAL forward_A,forward_B	:	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL write_data_WB : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL MemWrite,MemWriteID_EX,MemWrite_EX_MEM 		: STD_LOGIC;
	SIGNAL MemtoReg,MemtoRegID_EX,MemtoReg_EX_MEM,MemtoReg_MEM_WB 		: STD_LOGIC;
	SIGNAL MemRead,MemReadID_EX,MemRead_EX_MEM 			: STD_LOGIC;
	SIGNAL ALUop,ALuOpID_EX 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction,Instruction_IFe_ID,Instruction_ID_EX,forward_data		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL write_register_address_out,write_register_addressID_EX,write_register_address_EX_MEM,write_register_address_MEM_WB:   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL gpio_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL dmemory_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL idcode_read_data_in: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL segment0_out 		: STD_LOGIC_VECTOR( 6 DOWNTO 0 );
	SIGNAL segment1_out 		: STD_LOGIC_VECTOR( 6 DOWNTO 0 );
	SIGNAL segment2_out 		: STD_LOGIC_VECTOR( 6 DOWNTO 0 );
	SIGNAL segment3_out 		: STD_LOGIC_VECTOR( 6 DOWNTO 0 );

BEGIN
-- connect the 5 MIPS components   
	PROCESS(reset)
		BEGIN
			IF reset = '1' THEN
				   IE <= '1';
			END IF;
	END PROCESS;
		
  IFE : Ifetch
	PORT MAP (	
				Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				PCOfCommandInEX=> PC_plus_4_ID_EX,
				PCOfCommandInID=> PC_plus_4_IFe_ID,
				Add_Result 		=> Add_Result,
				Flush 			=> Flush,
				IE					=> IE,
				I2CReadIF		=> I2CReadIF,
				I2CWriteIF		=> I2CWriteIF,
				Stall          =>Stall,
				Ret_i				=> Ret_i,
				clock 			=> clock,  
				reset 			=> reset 
				);

  IFEn <= I2CWriteIF or I2CReadIF;
  Flush_or_IFE <= Flush or IFEn or Ret_i;
  IFetch_IDecode: IFe_ID  
		PORT MAP 
	   ( 
			Instruction_in=>Instruction,
			Instruction_out=>Instruction_IFe_ID,
			PC_plus_4_in=>PC_plus_4,
			PC_plus_4_out=>PC_plus_4_IFe_ID,
			Flush=>Flush_or_IFE,
			Flush_out=>Flush_IFe_ID,
			Stall=>Stall,
			clock=>clock,
			reset=>reset
		);
  ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
				write_data_out => write_data_WB,
        		Instruction 	=> Instruction_IFe_ID,
        		read_data 		=> read_data_MEM_WB,
				ALU_result 		=> ALU_Result_MEM_WB,
				RegWrite 		=> RegWrite_MEM_WB,
				MemtoReg 		=> MemtoReg_MEM_WB,
				RegDst 			=> RegDst,
				write_register_address_out=>write_register_address_out,
			   write_register_address_in=>write_register_address_MEM_WB,
				--Add_Result     =>Add_Result,
				--PC_plus_4		=>PC_plus_4_IFe_ID,
				Zero				=> Zero_ID,
				Sign_extend 	=> Sign_extend,
        		clock 			=> clock,
				pushBottun    =>pushBottun,
				led           =>led,
				reset 			=> reset );
	Hazard_unit:Hazard_detection 
			port map(
				read_register_1_address			=>Instruction_IFe_ID(20 downto 16),
				read_register_2_address			=>Instruction_IFe_ID(25 downto 21),
				write_register_address_ID_EX  =>Instruction_ID_EX(20 downto 16),	
				MemtoReg								=>MemtoReg,
				LwID_EX								=>MemReadID_EX,
				Beq									=>ALuOpID_EX(0),
				Zero									=>Zero,
				Stall									=>Stall,
				Flush									=> Flush
	);
	CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction_IFe_ID( 31 DOWNTO 26 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		   => MemRead,
				MemWrite 		=> MemWrite,
				Zero	 			=> Zero,
				Ret_i				=> Ret_i,
				Flush_in			=>Flush_IFe_ID,
				ALUop 			=> ALUop,
            clock 			=> clock,
				reset 			=> reset );
				
	IDecode_Excute: ID_EX
	PORT MAP 
	(
		read_data_1_in 	=>read_data_1,
      read_data_2_in 	=>read_data_2,
		Sign_extend_in 	=>sign_Extend,
		Sign_extend_out 	=>sign_Extend_ID_EX,
		read_data_1_out 	=>read_data_1_ID_EX,
      read_data_2_out 	=>read_data_2_ID_EX,
		Instruction_in	   =>Instruction_IFe_ID,
		Instruction_out	=>Instruction_ID_EX,
		PC_plus_4_in		=>PC_plus_4_IFe_ID,
		PC_plus_4_out		=>PC_plus_4_ID_EX,
		write_register_address_in         =>write_register_address_out,
		ALUSrc_in 			=>ALUSrc,
      MemtoReg_in 		=>MemtoReg,
      RegWrite_in 		=>RegWrite,
      MemRead_in 			=>MemRead,
      MemWrite_in 		=>MemWrite,
      ALUop_in 			=>ALuOp,
		RegDst_in 		=> RegDst,
		RegDst_out 		=> RegDst_ID_EX,
	   write_register_address_out 			=>write_register_addressID_EX,
      ALUSrc_out  		=>ALUSrcID_EX,
      MemtoReg_out 		=>MemtoRegID_EX,
      RegWrite_out 		=>RegWriteID_EX,
      MemRead_out 		=>MemReadID_EX,
      MemWrite_out 		=>MemWriteID_EX,
      ALUop_out 			=>ALuOpID_EX,
		Flush		 			=> Flush_or_IFE,
		Stall					=> Stall,
		clock             =>clock,
		reset		         =>reset
	);
	Forward_unit: Forwarding_unit 
				port MAP(
				read_register_1_address									=>Instruction_ID_EX( 25 DOWNTO 21 ),
				read_register_2_address									=>Instruction_ID_EX( 20 DOWNTO 16 ),
				write_register_address_EX_MEM							=>write_register_address_EX_MEM,
				write_register_address_MEM_WB							=>write_register_address_MEM_WB,
				RegDst_EX_MEM												=>RegDst_EX_MEM,
				RegDst_MEM_WB												=>RegDst_MEM_WB,
				MemtoReg_MEM_WB 											=>MemtoReg_MEM_WB,
				ALU_Result_EX_MEM											=>ALU_Result_EX_MEM,
				ALU_Result_MEM_WB 			  							=>ALU_Result_MEM_WB,
				read_data_MEM_WB 											=>read_data_MEM_WB,
				forward_A													=>forward_A,
				forward_B									  				=>forward_B
				);
				
   EXE:  Execute
   	PORT MAP (	
				Read_data_1 	=> read_data_1_ID_EX,
            Read_data_2 	=> read_data_2_ID_EX,
            Function_opcode	=> Instruction_ID_EX( 5 DOWNTO 0 ),
				ALUOp 			=> ALuOpID_EX,
				ALUSrc 			=> ALUSrcID_EX,
            ALU_Result		=> ALU_Result,
				Add_Result     =>Add_Result,
				PC_plus_4		=>PC_plus_4_ID_EX,
				Read_data_2_out=> read_data_2_EX,
            Clock			=> clock,
				Sign_extend 	=> sign_Extend_ID_EX,
				forward_A      =>forward_A,
				forward_B      =>forward_B,
				write_data_WB	=> write_data_WB,
				write_data_MEM	=> ALU_Result_EX_MEM,
				Zero				=>Zero,
				Reset			=> reset );
	
   Excute_Memory: EX_MEM 
	PORT MAP (
         ALU_Result_in 			=>ALU_Result,
         ALU_Result_out 		=>ALU_Result_EX_MEM,
			read_data_2_in       =>read_data_2_EX,
			read_data_2_out      =>read_data_2_EX_MEM,
			write_register_address_in         	=>write_register_addressID_EX,
			MemtoReg_in 			=>MemtoRegID_EX,
			RegWrite_in 			=>RegWriteID_EX,
			MemRead_in 				=>MemReadID_EX,
			MemWrite_in 			=>MemWriteID_EX,
			write_register_address_out 				=>write_register_address_EX_MEM,
			MemtoReg_out 			=>MemtoReg_EX_MEM,
			RegWrite_out 			=>RegWrite_EX_MEM,
			MemRead_out 			=>MemRead_EX_MEM,
			MemWrite_out 			=>MemWrite_EX_MEM,
			RegDst_in 				=> RegDst_ID_EX,
			RegDst_out 				=> RegDst_EX_MEM,
		   clock                =>clock,
			reset		   			=>reset
	);
	
   MEM:  dmemory
	PORT MAP (	
	         read_data     => read_data,
				address 		  => ALU_Result_EX_MEM (7 DOWNTO 0),--(9 DOWNTO 2) UPDATE
				write_data    => read_data_2_EX_MEM,
				MemRead 		  => MemRead_EX_MEM, 
				Memwrite 	  => MemWrite_EX_MEM, 
            clock 		  => clock,  
				reset 		  => reset,
				ALU_10        => ALU_Result_EX_MEM (10)
				);
			
	GPIO_Unit: gpio
	port map (  read_data       => gpio_out,
					address         => ALU_Result_EX_MEM,
					write_data      => read_data_2_EX_MEM,
					MemRead         => MemRead_EX_MEM,
					Memwrite        => MemWrite_EX_MEM,
					clock           => clock,
					reset           => reset,
					segment0        => segment0,
					segment1        => segment1,
					segment2        => segment2,
					segment3        => segment3,
					RGBOut	=> RGBOut,
					h_s		=> h_s,
					v_s		=> v_s,
					I2C_Write_Interrupt=> I2CWriteIF,
					I2C_Read_Interrupt => I2CReadIF,
					scl 				 => M_scl,
					sda				 => M_sda,
					InterruptADXL	 => ADXL_interrupt_in,
					pushBottun		 => pushBottun,
					first_byte_recieved_out => first_byte_recieved_out, -- to delete
					i2c_read_write_out => i2c_read_write_out,
					is_fifo1_empty_out => is_fifo1_empty_out
	);
	
	read_data_final <= read_data when ALU_Result_EX_MEM(10) = '0' else gpio_out;
	memory_wb :MEM_WB
		PORT MAP(
			read_data_in  =>read_data_final,
			read_data_out =>read_data_MEM_WB,
			ALU_Result_in =>ALU_Result_EX_MEM,
			ALU_Result_out=>ALU_Result_MEM_WB,			
			write_register_address_in         =>write_register_address_EX_MEM,			
			MemtoReg_in 		=>MemtoReg_EX_MEM,
			RegWrite_in 		=>RegWrite_EX_MEM,				
			write_register_address_out 			=>write_register_address_MEM_WB,				
			MemtoReg_out 		=>MemtoReg_MEM_WB,
			RegWrite_out 		=>RegWrite_MEM_WB,
			RegDst_in 				=> RegDst_EX_MEM,
			RegDst_out 				=> RegDst_MEM_WB,
			clock=>clock,
			reset=>reset
		);
END structure;

