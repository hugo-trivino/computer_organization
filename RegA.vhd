library ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.ALL;

entity regA is
	port(
		clk			:	in std_logic;
		--RegWrite		:	in std_logic;
		Data1In		:	in  std_logic_vector(31 downto 0);
		Data1Out		:	out std_logic_vector(31 downto 0):=x"00000000"
	);
end entity;
architecture multicycle of regA is
	begin
		process(Data1In) begin
			--if(rising_edge(clk))  then
				Data1Out	<= Data1In;
			--end if;
		end process;


end architecture;
