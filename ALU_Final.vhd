LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
	PORT( 
--**********************************************************************
--*		MUX_2, Reg_A, input and MUX_2_output
--**********************************************************************
		clk				:IN	std_logic;
		ALUSrcA			:IN	std_logic;
		Reg_A				:IN	std_logic_vector( 31 DOWNTO 0 );
		PCin				:IN	std_logic_vector( 31 DOWNTO 0 );
--**********************************************************************
--*		MUX_4, Reg_B, input and MUX_4_output
--**********************************************************************
		ALUSrcB			:IN	std_logic_vector(  1 DOWNTO 0 );
		Reg_B				:IN	std_logic_vector( 31 DOWNTO 0 );
		
		Sign_extend		:IN	std_logic_vector( 31 DOWNTO 0 );
		Sign_ex_shift	:IN	std_logic_vector( 31 DOWNTO 0 );
--**********************************************************************
--*		ALU Control and ALU Output
--**********************************************************************
		IR					:IN	std_logic_vector(  5 DOWNTO  0 );
		ALUOp				:IN	std_logic_vector(  1 DOWNTO  0 );	
			
		ALUResult		:OUT	std_logic_vector( 31 DOWNTO  0 ):=x"00000000";
		ALUOut			:OUT	std_logic_vector( 31 DOWNTO  0 ):=x"00000000";
		Zero				:OUT	std_logic :='0' );
END ALU;

ARCHITECTURE final OF ALU IS

SIGNAL  MUX_A_INPUT, MUX_B_INPUT	:	std_logic_vector( 31 DOWNTO 0 ):=x"00000000";
SIGNAL  ALU_MUX_OUTPUT				:	std_logic_vector( 31 DOWNTO 0 ):=x"00000000";
SIGNAL  ALU_CTR						:	std_logic_vector(  2 DOWNTO 0 ):="000";
Signal  Input_4						:std_logic_vector( 31 DOWNTO 0 ):=x"00000004";
BEGIN
	Input_4 <=	X"00000004";
--**********************************************************************
--*		MUX Reg A Logic
--**********************************************************************
	MUX_A:    
	process(ALUSrcA,Reg_A,PCin)
	begin
	if ALUSrcA = '0' then
		
		MUX_A_INPUT <= PCin;
	ELSE 
			MUX_A_INPUT <= Reg_A;
	end if;
	end process MUX_A;
--**********************************************************************
--*		MUX Reg B Logic
--**********************************************************************
    MUX_B:
	PROCESS(ALUSrcB, Reg_B, Input_4, Sign_extend, Sign_ex_shift)
	BEGIN
		IF(ALUSrcB = "00" ) THEN
			MUX_B_INPUT <= Reg_B;
		ELSIF(ALUSrcB = "01") THEN
			MUX_B_INPUT <=Input_4; -- PC + 4
 		ELSIF(ALUSrcB = "10") THEN
			MUX_B_INPUT <= Sign_extend;
		ELSIF(ALUSrcB = "11") THEN
			MUX_B_INPUT <= Sign_ex_shift;
		END IF;
	END PROCESS MUX_B;

--**********************************************************************
--*				ALU Control Logic
--**********************************************************************
    ALU_CTR(0) <= ( IR(0) OR IR(3)) AND ALUOp(1); -- STILL NEED WORK CHECK
    ALU_CTR(1) <= ( NOT IR(2)) OR (NOT IR(1)); 
    ALU_CTR(2) <= ( IR(1) AND ALUOp(1)) OR ALUOp(0);

    Zero <= '1'	-- logic signal for ctr unit
	 WHEN(ALU_MUX_OUTPUT( 31 DOWNTO 0 ) = (X"00000000"))
	 ELSE '0';

    ALUResult <= ALU_MUX_OUTPUT( 31 DOWNTO 0 );
--**********************************************************************
--*			ALU Out
--*  Flip flop register 
--**********************************************************************
	ALUOutReg	: entity work.ALUOut(multicycle) port map(
					clk=>clk,
					ALUResIn		=>ALU_MUX_OUTPUT,
					ALUResOut	=> ALUOut
);

--**********************************************************************
--*			ALU Computation
--*  Input values are both selected from Mux_2 and Mux_4 port
--*  In which immediate values and register values are selected 
--**********************************************************************
	
    ALU_Compute: 
	PROCESS (clk)--( MUX_A_INPUT, MUX_B_INPUT)
	
	BEGIN
	if(rising_edge(clk)) then
	CASE ALU_CTR IS

	     WHEN "000"	=>	ALU_MUX_OUTPUT	<= MUX_A_INPUT AND MUX_B_INPUT;	-- AND, ANDI
	     WHEN "001"	=>	ALU_MUX_OUTPUT	<= MUX_A_INPUT OR  MUX_B_INPUT; -- OR,  ORI
	     WHEN "010"	=>	ALU_MUX_OUTPUT	<= MUX_A_INPUT + MUX_B_INPUT;	-- ADD, ADDI
	     WHEN "011"	=>	ALU_MUX_OUTPUT	<= (others => '0'); -- new command
	     WHEN "100"	=>	ALU_MUX_OUTPUT	<= MUX_A_INPUT NOR MUX_B_INPUT; -- NOR
	     WHEN "101"	=>	ALU_MUX_OUTPUT	<= (others => '0'); -- new command
	     WHEN "110"	=>	ALU_MUX_OUTPUT	<= (MUX_A_INPUT - MUX_B_INPUT);	-- SUB, SUBI
	     WHEN "111"	=>	IF MUX_A_INPUT < MUX_B_INPUT THEN		-- SLT
				ALU_MUX_OUTPUT	<= (X"00000001");
				ELSE 
				ALU_MUX_OUTPUT	<= (X"00000000");
				END IF;
	     
	     WHEN OTHERS =>	ALU_MUX_OUTPUT	<= (others => '0');
	END CASE;
	end if;
      END PROCESS ALU_Compute;
END architecture;
