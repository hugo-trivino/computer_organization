library ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.ALL;

entity registers  is
	port(

--***********************************************
--*				MUX reg input
--***********************************************
		clk			: in std_logic;
		RegDst		: in	std_logic;
		RdIn			: in std_logic_vector(4 downto 0);

--***********************************************
--*				MUX data input and output
--***********************************************
		MemtoReg		: in	std_logic;
		AluResIn		: in	std_logic_vector(31 downto 0);
		MemDataIn	: in	std_logic_vector(31 downto 0);

--***********************************************
--*				Register input and output
--***********************************************
		RegWrite		:	in std_logic:='0';

		RsIn			: 	in std_logic_vector(4  downto 0);
		RtIn			:	in std_logic_vector(4  downto 0);
		
		RegAOut		:  out std_logic_vector(31 downto 0):=x"00000000";
		RegBOut		:  out std_logic_vector(31 downto 0):=x"00000000"
	);
end entity;

architecture multycycle of registers is
--regFile as memory 32 registers 32 bits each in MIPS
	type RAM is array (integer range<>) of std_logic_vector(31 downto 0);
	signal regFile 		: RAM(0 to 31);
	signal RegAOutWire	: std_logic_vector(31 downto 0):=x"00000000";
	signal RegBOutWire	: std_logic_vector(31 downto 0):=x"00000000";
	signal MuxRegIn		: std_logic_vector(4  downto 0):="00000";
	signal MuxDataIn		: std_logic_vector(31 downto 0):=X"00000000";

begin
	RegAOut	<=RegAOutWire;
	RegBOut	<=RegBOutWire;
	
-- Destination Register Mux
	process(RegDst,RtIn,RdIn) begin
		case RegDst is
			when '0'	=> MuxRegIn <= RtIn;
			when '1' => MuxRegIn <= RdIn;
			when others => report "Unreachable!" severity FAILURE;
		end case;
	end process;
-- Data write Mux 
	process(MemtoReg,AluResIn) begin
		case MemtoReg is
			when '0'	=> MuxDataIn <= AluResIn;
			when '1' => MuxDataIn <= MemDataIn;
			when others => report "Unreachable!" severity FAILURE;
		end case;
	end process;
--Read Function
	Reg_Read:
	process(clk,RsIn,RtIn) begin
		if(rising_edge(clk)) then
			RegAOutWire		<=	regFile(conv_integer(RsIn));
			RegBOutWire		<=	regFile(conv_integer(RtIn));
		end if;
	end process;
--Read Function
	Reg_Write:
	process(RegWrite,MuxRegIn,MuxDataIn) begin
		if (RegWrite ='1') then
			regFile(conv_integer(MuxRegIn)) <= MuxDataIn;
		end if;
	end process;
end architecture;