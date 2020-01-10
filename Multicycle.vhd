LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
use ieee.numeric_std.all;
entity multicycleCPU is
end entity;

Architecture summary of multicycleCPU is
		signal 	state_wire	:	std_logic_vector(3 downto 0);
		signal	clock			:	std_logic :='0';
		signal 	clk			:	std_logic :='0';
		signal	reset			:	std_logic;		
		signal	Opcode		:	std_logic_vector( 5 DOWNTO 0 ):= "001000";

		signal	PCSource		:	std_logic_vector( 1 DOWNTO 0 ):="00";
		signal	ALUOp			:	std_logic_vector( 1 DOWNTO 0 ):="00";
		signal	ALUSrcB		:	std_logic_vector( 1 DOWNTO 0 ):="00";
		signal	ALUSrcA		:	std_logic:='0';
		signal	RegWrite		:	std_logic:='0';
		signal	RegDst		:	std_logic:='0';

		signal	PCWriteCond	:	std_logic:='0';
		signal	PCWriteCondN	:	std_logic:='0';
		signal	PCWrite		:	std_logic:='0';
		signal	IorD			:	std_logic:='0';
		signal	MemRead		:	std_logic:='0';
		signal	MemWrite		:	std_logic:='0';
		signal	MemtoReg		:	std_logic:='0';
		signal	IRWrite		:	std_logic:='0';
--**********************************************************************
--*	Instruction Fetch signals
--**********************************************************************
		signal	Zero				: 	std_logic:='0';
		signal	NextPC			:	std_logic_vector( 31 DOWNTO 0 ):=X"00000000";
		signal	ALUOut			:	std_logic_vector( 31 DOWNTO 0 ):=X"00000000";
		signal	WriteData		: 	std_logic_vector( 31 DOWNTO 0 ):=X"00000000";
--		out
		signal	MemData			:	std_logic_vector( 31 DOWNTO  0 ):=X"00000000";
		signal	PC_Out			:	std_logic_vector( 31 DOWNTO  0 ):=X"00000000";
--**********************************************************************
--*	Instruction Decode signals
--**********************************************************************
--		out
		signal	RegAOut			:   std_logic_vector(31 downto 0):=X"00000000";
		signal	RegBOut			:   std_logic_vector(31 downto 0):=X"00000000";
		signal	TargetOut		:   std_logic_vector(25 downto 0):="00000000000000000000000000";

		signal	ImmOut			:   std_logic_vector(15 downto 0):=x"0000";
		signal	FunOut			:   std_logic_vector(5 downto 0):="000000";

		signal	Sign_extend		:	std_logic_vector(31 downto 0):=x"00000000";
		signal	Sign_ex_shift	:	std_logic_vector(31 downto 0):=x"00000000";
		signal	ALUResult		:	std_logic_vector(31 downto 0):=x"00000000";

begin
	FinControlUnit	: entity work.control(final) port map(
		clock 		=>		clock,
		reset 		=>		reset,
		Opcode 		=>		Opcode,
		PCSource 	=>		PCSource,
		ALUOp 		=>		ALUOp,
		ALUSrcB 		=>		ALUSrcB,
		ALUSrcA 		=>		ALUSrcA,
		RegWrite 	=>		RegWrite,
		RegDst 		=>		RegDst,
		PCWriteCond =>		PCWriteCond,
		PCWriteCondN =>		PCWriteCondN,
		PCWrite 		=>		PCWrite,
		IorD 			=>		IorD,
		MemRead 		=>		MemRead,
		MemWrite 	=>		MemWrite,
		MemtoReg 	=>		MemtoReg,
		IRWrite 		=>		IRWrite,
		state_wire	=>	state_wire
);

	FinInstructionFetch	: entity work.IFetchGroup(final) port map(
		clk			=>	clk,
		Zero				=>	Zero,
		PCWriteCond		=>	PCWriteCond,
		PCWriteCondN =>		PCWriteCondN,
		PCWrite			=>	PCWrite,
		NextPC			=>	NextPC,
--**********************************************************************
--*	PC->MUX input
--**********************************************************************
		IorD				=>	IorD,
		ALUOut			=>	ALUOut,
--**********************************************************************
--*	Memory inputs
--**********************************************************************
		MemRead			=>	MemRead,	
		MemWrite			=> MemWrite,	
		WriteData		=> WriteData,
--**********************************************************************
--*	Memory Outputs
--**********************************************************************
		MemData			=> MemData,			
		PC_Out			=> PC_Out
);
	FinInstructionDecode	: entity work.idecodeGroup(final) port map(
		clk			=>	clk,
		InstrIn		=> MemData	,
		IRWrite		=>	IRWrite,
		RegDst		=>	RegDst,
		RegWrite		=> RegWrite,
		MemtoReg		=>	MemtoReg,
		AluResIn		=> ALUOut,
		OpcodeOut	=> Opcode,
--		 out
		RegAOut		=>	RegAOut,
		RegBOut		=>	RegBOut,
		TargetOut	=>	TargetOut,
		ImmOut		=> ImmOut,
		FunOut		=>	FunOut
);
	Sign_extend <= std_logic_vector(resize(signed(ImmOut), Sign_extend'length));
	Sign_ex_shift <="00000000000000" & ImmOut &"00";

		FinALU	: entity work.ALU(final) port map(
			--**********************************************************************
--*		MUX_2, Reg_A, input and MUX_2_output
--**********************************************************************
		clk				=>	clk,
		ALUSrcA			=>	ALUSrcA,
		Reg_A				=>	RegAOut,
		PCin				=>	PC_Out,
--**********************************************************************
--*		MUX_4, Reg_B, input and MUX_4_output
--**********************************************************************
		ALUSrcB			=>	ALUSrcB,
		Reg_B				=>	RegBOut,
		Sign_extend		=> Sign_extend,
		Sign_ex_shift	=> Sign_extend,
--**********************************************************************
--*		ALU Control and ALU Output
--**********************************************************************
		IR					=>	FunOut,
		ALUOp				=> ALUOp,	
			
		ALUResult		=> ALUResult,
		ALUOut			=> ALUOut,
		Zero				=> Zero
);
FinJump	: entity work.jumpBlock(final) port map(
		clk			=> clk,
		target		=> TargetOut,
		pccont		=> PC_Out(31 downto 28),
		ALUOut		=>	ALUOut,
		ALUResult	=>	ALUResult,
		PCSource		=>	PCSource,
		NextPC		=>	NextPC
);


	clk_process :process
   begin

        clock <= '0';
		  wait for 1 ns;
			clk <='0';
        wait for 4 ns;  --for 0.5 ns signal is '0'.
		  clock <= '1';
        wait for 1 ns;  --for next 0.5 ns signal is '1'.
		  clk <='1';
		  wait for 4 ns;  --for 0.5 ns signal is '0'.
			
   end process;

end architecture;