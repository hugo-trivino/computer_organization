
library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
USE ieee.numeric_std.ALL;

ENTITY IFetchGroup IS
	PORT( 
--**********************************************************************
--*	PC Register including combinational logic
--**********************************************************************
		clk				:IN	std_logic;
		Zero				:IN	std_logic;
		PCWriteCond		:IN	std_logic;
		PCWriteCondN	:IN	std_logic;
		PCWrite			:IN	std_logic;
		NextPC			:IN	std_logic_vector( 31 DOWNTO 0 );
--**********************************************************************
--*	PC->MUX input
--**********************************************************************
		IorD				:IN	std_logic;
		ALUOut			:IN	std_logic_vector( 31 DOWNTO 0 );
--**********************************************************************
--*	Memory inputs
--**********************************************************************
		MemRead			:IN	std_logic;
		MemWrite			:IN	std_logic;
		WriteData		:IN 	std_logic_vector( 31 DOWNTO 0 );
--**********************************************************************
--*	Memory Outputs
--**********************************************************************
		MemData			:OUT	std_logic_vector( 31 DOWNTO  0 ):=x"00000000";				
		PC_Out			:OUT	std_logic_vector( 31 DOWNTO  0 ):=x"00000000"
		);
END IFetchGroup;


ARCHITECTURE final OF IFetchGroup IS
	
	SIGNAL MuxOut			:	std_logic_vector( 31 DOWNTO  0 ):=x"00000000";
	SIGNAL pc_write		:	std_logic; -- W Signal
	SIGNAL PC				:	std_logic_vector( 31 DOWNTO  0 ):=x"00000000"; -- What type of Signal



BEGIN	
	--pc_write		<= PCWrite	OR	(Zero AND PCWriteCond);
	PC_Out		<= PC;
	MuxOut		<= ALUOut	WHEN (IorD = '1')	ELSE PC;

	
	DMemory: entity work.memory(multycycle) port map(
		 MemRead		=> MemRead,
		 MemWrite	=>	MemWrite,
		 DataIn		=>	WriteData,
	    AddressIn	=>	MuxOut,
		 DataOut		=>	MemData
	);

	

PROCESS(NextPC)
	BEGIN
	--if(rising_edge(clk)) then
		if NextPC(31) ='0' then
		IF ((PCWrite	OR	(Zero AND PCWriteCond) or ((not Zero) AND PCWriteCondN)) = '1' )  THEN
			PC <= NextPC ;
		ELSE
			PC <= PC;
		END IF;

	end if;
END PROCESS;

END ARCHITECTURE;
