LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY Control IS 
	PORT(
		clock			:IN	std_logic;
		reset			:IN	std_logic;		
		Opcode		:IN	std_logic_vector( 5 DOWNTO 0 );

		PCSource		:OUT	std_logic_vector( 1 DOWNTO 0 ):="00";
		ALUOp			:OUT	std_logic_vector( 1 DOWNTO 0 ):= "00";
		ALUSrcB		:OUT	std_logic_vector( 1 DOWNTO 0 ):="01";
		ALUSrcA		:OUT	std_logic:= '0';
		RegWrite		:OUT	std_logic:= '0';
		RegDst		:OUT	std_logic:= '0';
		PCWriteCondN :out	std_logic:='0';
		PCWriteCond	:OUT	std_logic:= '0';
		PCWrite		:OUT	std_logic:= '0';
		IorD			:OUT	std_logic:= '0';
		MemRead		:OUT	std_logic:= '0';
		MemWrite		:OUT	std_logic:= '0';
		MemtoReg		:OUT	std_logic:= '0';
		IRWrite		:OUT	std_logic:= '0';
		state_wire	:out	std_logic_vector(3 downto 0)
);
END Control;

ARCHITECTURE final OF Control IS

COMPONENT LCELL				-- How about get rid off theses lines of code?
	PORT(	a_in	 :IN  std_logic;
		a_out	 :OUT std_logic);
	END COMPONENT;

TYPE State IS(si,s0, s1, s2, s3, s4, s5, s6, s7,s8, s9,s10);

SIGNAL next_state	:State;
signal wake: std_logic:='0';
SIGNAL current_state	:State:=si;
SIGNAL Opcode_out	:std_logic_vector( 5 DOWNTO 0 ); --

BEGIN
    OP_BUf0: LCELL	PORT MAP( a_in => Opcode(0), a_out => Opcode_out(0));
    OP_BUf1: LCELL	PORT MAP( a_in => Opcode(1), a_out => Opcode_out(1));
    OP_BUf2: LCELL	PORT MAP( a_in => Opcode(2), a_out => Opcode_out(2));
    OP_BUf3: LCELL	PORT MAP( a_in => Opcode(3), a_out => Opcode_out(3));
    OP_BUf4: LCELL	PORT MAP( a_in => Opcode(4), a_out => Opcode_out(4));
    OP_BUf5: LCELL	PORT MAP( a_in => Opcode(5), a_out => Opcode_out(5));

state_trans:	PROCESS(current_state,Opcode, next_state,wake ) --, Opcode_out, next_state,wake)

BEGIN
    CASE current_state IS
--initialize
WHEN si => 
		state_wire<= X"F";
	   MemRead	<= '1';
	   ALUSrcA	<= '0';
	   IorD		<= '0';
	   IRWrite	<= '1';
	   ALUSrcB	<= "01";
	   ALUOp	<= "00";
	   PCWrite	<= '1';
	   PCSource	<= "00";
	   
	   RegWrite	<= '0';
	   MemWrite	<= '0';
	   PCWriteCond	<= '0';
	   PCWriteCondN	<= '0';
	   next_state	<= s0; --Instruction Fetch
	WHEN s0 => 
		state_wire<= X"0";
	   MemRead	<= '1';
	   ALUSrcA	<= '0';
	   IorD		<= '0';
	   IRWrite	<= '1';
	   ALUSrcB	<= "01";
	   ALUOp	<= "00" after 10 ps;
	   PCWrite	<= '1';
	   PCSource	<= "00";
	   
	   RegWrite	<= '0';
	   MemWrite	<= '0';
	   PCWriteCond	<= '0';
	   PCWriteCondN	<= '0';
	   next_state	<= s1; --Instruction Fetch

	WHEN s1 => 
		state_wire<= X"1";
	   ALUSrcA	<= '0';
	   ALUSrcB	<= "11";
	   ALUOp	<= "00";
	   
	   RegWrite	<= '0';
	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0'; -- Block Instruction Compilation
		PCWriteCondN	<= '0';
	   --******************************
--******	ORIGINALLY Opcode_out
		--*****************************
	   IF		Opcode = "100011"	THEN	next_state <= s2; -- lw opcode
	   ELSIF	Opcode = "101011"	THEN	next_state <= s2; -- sw opcode
		ELSIF	Opcode = "001000"	THEN	next_state <= s2; -- addi opcode
		ELSIF	Opcode = "001100"	THEN	next_state <= s2; -- andi opcode
		ELSIF	Opcode = "001101"	THEN	next_state <= s2; -- ori opcode
	   ELSIF	Opcode = "000000"	THEN	next_state <= s6; -- R-opcode
	   ELSIF	Opcode = "000100"	THEN	next_state <= s8; -- beq opcode
		ELSIF	Opcode = "000101"	THEN	next_state <= s8; -- beq opcode
	   ELSIF	Opcode = "000010"	THEN	next_state <= s9; -- j opcode
	   ELSE		next_state <= next_state;
	   END IF; --Instruction decode/ Register Fetch

	WHEN s2 => 
		state_wire<= X"2";
	   ALUSrcA	<= '1';
	   ALUSrcB	<= "10";
	   ALUOp	<= "00";
	   
	   RegWrite	<= '0';
	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
		PCWriteCondN	<= '0';
	   --******************************
--******	ORIGINALLY Opcode_out
		--*****************************
	   IF		Opcode = "100011"	THEN	next_state <= s3;
		ELSIF	Opcode = "001000"	THEN	next_state <= s10; -- addi opcode
		ELSIF	Opcode = "001100"	THEN	next_state <= s10; -- andi opcode
		ELSIF	Opcode = "001101"	THEN	next_state <= s10; -- ori opcode
	   ELSIF	Opcode = "101011"	THEN	next_state <= s5;
	   ELSE		next_state <= next_state;  -- Stable Purpose
	   END IF;

	WHEN s3 => 
		state_wire<= X"3";
	   MemRead	<= '1';
	   IorD		<= '1';

	   RegWrite	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
		PCWriteCondN	<= '0';
	   if Opcode ="100011" then	next_state	<= s4;
		else	next_state	<= s10;
		end if;
	WHEN s4 =>
		state_wire<= X"4";
	   RegDst	<= '0';  --Report Indicates  RegDst	<= '0'
	   RegWrite	<= '1'; 
	   MemtoReg	<= '1';

	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
	   PCWriteCondN	<= '0';
	   next_state	<= s0;
	WHEN s10 =>
		state_wire<= X"A";
	   RegDst	<= '0';  --Report Indicates  RegDst	<= '0'
	   RegWrite	<= '1'; 
	   MemtoReg	<= '0';
	   ALUSrcB	<= "01";
	   ALUOp	<= "00";
	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
	   PCWriteCondN	<= '0';
	   next_state	<= s0;
	WHEN s5 =>
		state_wire<= X"5";
	   MemWrite	<= '1';
	   IorD		<= '1';
 
	   RegWrite	<= '0';
	   MemRead	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
	   PCWriteCondN	<= '0';
	   next_state	<= s0;

	WHEN s6 =>
		state_wire<= X"6";
	   ALUSrcA	<= '1';
	   ALUSrcB	<= "00";
	   ALUOp	<= "10";
	   
	   RegWrite	<= '0';
	   MemRead	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
		PCWriteCondN	<= '0';
	   MemWrite	<= '0';

	   next_state	<= s7;

	WHEN s7 =>
		state_wire<= X"7";
	   RegDst	<= '1';
	   RegWrite	<= '1';
	   MemtoReg	<= '0';
	   
	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';
	   PCWriteCond	<= '0';
		PCWriteCondN	<= '0';
	   next_state	<= s0;

	WHEN s8 =>
		state_wire<= X"8";
	   ALUSrcA	<= '1';
	   ALUSrcB	<= "00";
	   ALUOp	<= "01";
	   PCSource	<= "01";
	   if Opcode  ="000100" then
			PCWriteCond		<= '1';
		else
			PCWriteCondN	<= '1';
		end if;
	   RegWrite	<= '0';
	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWrite	<= '0';

	   next_state	<= s0;
	WHEN s9 =>
		state_wire<= X"9";
	   PCSource	<= "10";
	   PCWrite	<= '1';

	   RegWrite	<= '0';
	   MemRead	<= '0';
	   MemWrite	<= '0';
	   IRWrite	<= '0';
	   PCWriteCond	<= '0';
		PCWriteCondN	<= '0';
	   next_state	<= s0;
    END CASE;
END PROCESS state_trans;

state_clock:PROCESS(clock,reset)
BEGIN
	IF reset='1' THEN 
		current_state <= s0;

	ELSIF clock'EVENT and clock='1' THEN
	current_state <= next_state;
 	wake <= not wake;
	END IF;
END PROCESS state_clock;

END architecture;
