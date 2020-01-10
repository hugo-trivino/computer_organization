library ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.ALL;

entity ALUOut is
	port(
		clk			:	in std_logic;
		ALUResIn		:	in  std_logic_vector(31 downto 0):=x"00000000";
		ALUResOut	:	out std_logic_vector(31 downto 0):=x"00000000"
	);
end entity;
architecture multicycle of ALUOut is
	begin
		process(clk) begin
			if(rising_edge(clk)) then
				ALUResOut	<= ALUResIn;
			end if;
		end process;
end architecture;
