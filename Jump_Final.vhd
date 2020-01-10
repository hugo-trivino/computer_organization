library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity jumpBlock is 
	port(
		clk			:in	std_logic;
		target		: In  std_logic_vector(25 downto 0);
		pccont		: in	std_logic_vector(3 downto 0);
		ALUOut		: in	std_logic_vector(31 downto 0);
		ALUResult	: in	std_logic_vector(31 downto 0);
		PCSource		: in	std_logic_vector( 1 DOWNTO 0 );
		NextPC		: out	std_logic_vector(31 downto 0) :=X"00000000"
	);
end entity;
architecture final of jumpBlock is
	signal	JMPAddress	: std_logic_vector(31 downto 0):=X"00000000";
begin
	
	JMPAddress(31 DOWNTO  28) <= pccont;
	JMPAddress(27 DOWNTO  2)  <= target;
	JMPAddress(1 DOWNTO  0)   <= "00";
	process(ALUResult,ALUOut,JMPAddress,PCSource) begin
	--if(rising_edge(clk)) then
		case PCSource is
			when "00"	=> NextPC <= ALUResult;
			when "01"	=> NextPC <= ALUOut;
			when "10"	=> NextPC <= JMPAddress;
			when others => report "Unreachable!" severity FAILURE;
		end case;
	--end if;
	end process;


end architecture;