library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
entity instructionRegister is
	port(
		IRWrite		: in std_logic:='1';
		InstrIn		: in std_logic_vector(31 downto 0):=x"31291234";
		OpcodeOut	: out std_logic_vector(5 downto 0):="000000";
-- I-type & R-type
		RsOut			: out std_logic_vector(4 downto 0):="01001";
		RtOut			: out std_logic_vector(4 downto 0):="01001";
-- Exclusive R-type
		RdOut			: out std_logic_vector(4 downto 0):="01001";
		SAOut			: out std_logic_vector(4 downto 0):="01001";
		FunOut		: out std_logic_vector(5 downto 0):="100000";
-- Exclusive I-type
		ImmOut		: out std_logic_vector(15 downto 0):=x"0004";
-- Exclusive J-type
		TargetOut	: out std_logic_vector(25 downto 0):="00000000000000000000000100"
	);
end entity;
architecture multycycle of instructionRegister is
	signal OpCodeOutWire 	: std_logic_vector(5 downto 0):="000000";
-- I-type & R-type
	signal RsOutWire			: std_logic_vector(4 downto 0):="01001";
	signal RtOutWire			: std_logic_vector(4 downto 0):="01001";
-- Exclusive R-type
	signal RdOutWire			: std_logic_vector(4 downto 0):="01001";
	signal SAOutWire			: std_logic_vector(4 downto 0):="01001";
	signal FunOutWire			: std_logic_vector(5 downto 0):="000000";
-- Exclusive I-type
	signal ImmOutWire			: std_logic_vector(15 downto 0):=x"0004";
-- Exclusive J-type
	signal TargetOutWire		: std_logic_vector(25 downto 0):="00000000000000000000000100";

begin

	OpcodeOut 	<= OpCodeOutWire;

	RsOut			<= RsOutWire;
	RtOut			<= RtOutWire;

	RdOut			<= RdOutWire;
	SAOut			<= SAOutWire;
	FunOut		<= FunOutWire;

	ImmOut		<= ImmOutWire;

	TargetOut	<= TargetOutWire;


	process (IRWrite,InstrIn) begin
		if(IRWrite ='1') then
			OpCodeOutWire 	<= InstrIn(31 downto 26);

			RsOutWire		<= InstrIn(25 downto 21);
			RtOutWire		<= InstrIn(20 downto 16);

			RdOutWire		<= InstrIn(15 downto 11);
			SAOutWire		<= InstrIn(10 downto 6 );
			FunOutWire		<= InstrIn(5  downto 0 );

			ImmOutWire		<= InstrIn(15 downto 0 );

			TargetOutWire	<= InstrIn(25 downto 0);
		end if;
	end process;
end architecture;