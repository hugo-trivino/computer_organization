LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
USE ieee.numeric_std.ALL;

ENTITY IDecodeGroup IS
	PORT( 
		clk			:	IN std_logic;
		InstrIn		:	IN	std_logic_vector(31 downto 0);
		IRWrite		:	IN	std_logic;
		RegDst		:	IN	std_logic;
		RegWrite		:	IN	std_logic;
		MemtoReg		:	IN	std_logic;
		AluResIn		: 	in	std_logic_vector(31 downto 0);
		OpcodeOut	: 	out std_logic_vector(5 downto 0):="000000";
		RegAOut		:  out std_logic_vector(31 downto 0):=x"00001234";
		RegBOut		:  out std_logic_vector(31 downto 0):=x"00001234";
		TargetOut	:  out std_logic_vector(25 downto 0):="00000000000000000000000100";
		ImmOut		:  out std_logic_vector(15 downto 0):=x"1234";
		FunOut		: 	out std_logic_vector(5 downto 0):="000000"
		);
END IDecodeGroup;

ARCHITECTURE final OF IDecodeGroup IS
-- I-type & R-type
		signal Rs			:  std_logic_vector(4 downto 0):="00000";
		signal Rt			:  std_logic_vector(4 downto 0):="00000";
-- Exclusive R-type
		signal Rd			:  std_logic_vector(4 downto 0):="00000";
		signal SAOut		:  std_logic_vector(4 downto 0):="00000";
		
-- Exclusive I-type
		
-- Exclusive J-type
		signal MemDataIn	:	std_logic_vector(31 downto 0):=x"00000000";
		signal RegAWire	:	std_logic_vector(31 downto 0):=x"00000000";
		signal RegBWire	:	std_logic_vector(31 downto 0):=x"00000000";
		SIGNAL RegAOutWire:  std_logic_vector(31 downto 0):=x"00000000";
		SIGNAL RegBOutWire:  std_logic_vector(31 downto 0):=x"00000000";
begin
	RegBOut <=RegBOutWire;
	RegAOut <=RegAOutWire;
	INSTREG: entity work.instructionregister(multycycle) port map(
		IRWrite 		=> 	IRWrite,
		InstrIn		=>		InstrIn,
		OpcodeOut	=>		OpcodeOut,
-- I-type & R-type
		RsOut			=>		Rs,
		RtOut			=>		Rt,
-- Exclusive R-type
		RdOut			=>		Rd,
		SAOut			=>		SAOut,
		FunOut		=>		FunOut,
-- Exclusive I-type
		ImmOut		=>		ImmOut,
-- Exclusive J-type
		TargetOut	=>	TargetOut
);

	MemDatReg: entity work.memorydataregister(multicycle) port map (
		clk			=> clk,
		MemDataIn	=> InstrIn,
		MemDataOut	=> MemDataIn
	);

	REGIS:	 entity work.Registers(multycycle) port map(
--***********************************************
--*				MUX reg input
--***********************************************
		clk			=>		clk,
		RegDst		=> 	RegDst,
		RdIn			=>		Rd,
--***********************************************
--*				MUX data input and output
--***********************************************
		MemtoReg		=> 	MemtoReg,
		AluResIn		=> 	AluResIn,
		MemDataIn	=> 	MemDataIn,
--***********************************************
--*				Register input and output
--***********************************************
		RegWrite		=>		RegWrite,

		RsIn			=> 	Rs,
		RtIn			=>		Rt,
		RegAOut		=>  	RegAWire,
		RegBOut		=>  	RegBWire
);

	RegisterA: entity work.regA(multicycle) port map (
		clk			=> clk,
		Data1In	=> RegAWire,
		Data1Out	=> RegAOutWire
	);
	RegisterB: entity work.regB(multicycle) port map (
		clk			=> clk,
		Data2In	=> RegBWire,
		Data2Out	=> RegBOutWire
	);

END ARCHITECTURE;
