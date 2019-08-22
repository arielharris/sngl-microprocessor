--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- address MUX
entity SmallBusMux2to1 is
	Port(selector: in std_logic;
	     In0, In1: in std_logic_vector(4 downto 0);
	     Result:   out std_logic_vector(4 downto 0) );
end entity SmallBusMux2to1;

architecture switching of SmallBusMux2to1 is
begin
    with selector select
	Result <= In0 when '0',
		  In1 when others;
end architecture switching;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- other three MUX, when using w/ data memory Result gets In0 when '1'
entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
	with selector select
		Result <= In0 when '0',
			In1 when others;
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (5 downto 0);
           funct  : in  STD_LOGIC_VECTOR (5 downto 0);
           RegSrc : out  STD_LOGIC;			--
           RegDst : out  STD_LOGIC;			--
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);	--
           MemRead : out  STD_LOGIC;			--
           MemtoReg : out  STD_LOGIC;			--
           ALUOp : out  STD_LOGIC_VECTOR(4 downto 0);	-- 
           MemWrite : out  STD_LOGIC;			--
           ALUSrc : out  STD_LOGIC;			--
           RegWrite : out  STD_LOGIC);			--
end Control;
-- clk, opcode, funct are inputs 

architecture Boss of Control is

	signal opFunct: std_logic_vector(11 downto 0);
begin
	-- DO REGSRC AND BRANCH
opFunct <= opcode & funct;


	ALUOp <= "00001" when  opFunct(11 downto 6) = "001000" else -- opcode for addi
		"00101" when  opFunct(11 downto 6) = "001101" else -- opocde for ori
		"01000" when  opFunct(11 downto 6) = "100011" else -- opcode for lw
		"01001" when  opFunct(11 downto 6) = "101011" else -- opcode for sw
		"01010"	when  opFunct(11 downto 6) = "000100" else -- opcode for beq
		"01011" when  opFunct(11 downto 6) = "000101" else -- opcode for bne
		"00000" when  opFunct (5 downto 0) = "100000" else -- func code for add
		"00010" when  opFunct (5 downto 0) = "100010" else -- func code for sub
		"00011" when  opFunct (5 downto 0) = "100100" else -- func code for and
		"00100" when  opFunct (5 downto 0) = "100101" else -- func code for or
		"00110" when  opFunct (5 downto 0) = "000000" else -- func code for sll
		"00111" when  opFunct (5 downto 0) = "000010"; -- func code for srl

 
	-- RegSrc for shifts
	with funct select RegSrc <= 
		'1' when "000000",
		'1' when "000010",
		'0' when others;

	-- RegDst 1 or 0 based on R (1) or I (0) type codes 
	with opcode select RegDst <=
		'1' when "000000",
		'0' when others;

	-- Branch 
	with opcode select Branch <=
		"11" when "000100", -- beq
		"10" when "000101", -- bne
		"00" when others;

	-- MemRead 0 for all but lw, takes ALU out, for lw reads memory
	with opcode select MemRead <=
		'0' when "100011",
		'1' when others;

	-- MemtoReg controls what is sent to write data
	with opcode select MemtoReg <=
		'1' when "100011",
		'0' when others;
	
	-- MemWrite controls is memory is written to, only for sw
	with opcode select MemWrite <=
		'1' when "101011",
		'0' when others;

	-- RegWrite controls if write data is written to the write reg determind by RegDst
	
	with opcode select RegWrite <=
		'0' when "101011",
		'0' when "000100",
		'0' when "000101",
		NOT clk when others;
	

	-- ALUSrc deiedes what goes into the ALU, data in reg2 if R type and sign extnd bottom 16 if I

	ALUsrc <= '1' when opFunct (11 downto 6) = "001000" else
		'1' when opFunct (11 downto 6) = "001101" else
		'1' when opFunct (11 downto 6) = "100011" else
		'1' when opFunct (11 downto 6) = "101011" else
		'1' when opFunct (5 downto 0) = "000000" else
		'1' when opFunct (5 downto 0) = "000010" else
		'0'; 
		

end Boss;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;


architecture executive of ProgramCounter is

begin

process (Clock, Reset)
begin



if (Reset = '1') then
	PCout <= x"00400000";
else
	if (rising_edge(Clock)) then
		PCout <= PCin;
	end if;
end if;

end process;

end executive;
--------------------------------------------------------------------------------
