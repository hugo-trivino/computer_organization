library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity memory is generic(ADDRESSBITS : integer:=10);
	port(
		MemRead		: In std_logic;
		MemWrite		: In std_logic;
		DataIn		: In std_logic_vector(31 downto 0);
		AddressIn	: in std_logic_vector(31 downto 0);
		DataOut		: out std_logic_vector(31 downto 0):=x"00000000"
	);
end entity;

architecture multycycle of memory is

	signal dataOut1			: std_logic_vector(31 downto 0) :=x"31291234";
	signal addressIn1			: std_logic_vector(9 downto 0) :="0000000000";
	constant RAM_LINES		: integer := 2**ADDRESSBITS;
	type RAM is array(integer range<>) of std_logic_vector(31 downto 0);
	signal Mem : RAM (0 to RAM_LINES-1);

begin 
DataOut <=dataOut1;
-- addressIn1 <=AddressIn(9 downto 0);



Mem_Write:
	process (AddressIn)
		begin
			if(MemWrite='1') then
				mem(conv_integer(AddressIn)/4) <=DataIn ;
		
			end if;
	end process;


Mem_Read:
	process (MemWrite,DataIn,AddressIn,MemRead)
		begin
			if(MemRead='1') then
				dataOut1 <= mem(conv_integer(AddressIn)/4) after 2 ns;
			end if;
	end process;
end architecture;
