library ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.ALL;

entity memoryDataRegister is
	port(
		clk			:	in std_logic;
		MemDataIn	:	in  std_logic_vector(31 downto 0);
		MemDataOut	:	out std_logic_vector(31 downto 0):=x"00000000"
	);
end entity;
architecture multicycle of memoryDataRegister is
	signal MemDataOutWire	: std_logic_vector(31 downto 0):=x"00000000";
	begin
	MemDataOut	<=	MemDataOutWire;
		process(clk) begin
			if(rising_edge(clk)) then
				MemDataOutWire	<= MemDataIn;
			end if;
		end process;
end architecture;