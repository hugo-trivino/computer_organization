library ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.ALL;

entity regB is
	port(
		clk			:	in std_logic;
		Data2In		:	in  std_logic_vector(31 downto 0);
		Data2Out		:	out std_logic_vector(31 downto 0):=x"00000000"
	);
end entity;
architecture multicycle of regB is
	begin
		process (Data2In) begin--(clk) begin
			--if(rising_edge(clk)) then
				Data2Out	<= Data2In;
			--end if;
		end process;
end architecture;
