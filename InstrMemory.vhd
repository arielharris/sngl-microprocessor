--------------------------------------------------------------------------------
--
-- LAB #6 - Instruction Memory
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity InstructionRAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity InstructionRAM;

architecture instrucRAM of InstructionRAM is

   type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;
   signal i_address : std_logic_vector(4 downto 0);

begin

  RamProc: process(Clock, Reset) is
  begin
    if Reset = '1' then
       i_ram <= (0 => B"000000_00000_00000_10000_00000_100000",		-- add  $s0, $zero, $zero    
		 1 => B"001000_00000_10111_0000000000000000",		-- addi $s7, $zero, 0x0000
		 2 => B"000000_00000_10111_10111_10000_000000",		-- sll  $s7,$s7,16       
		 3 => B"001000_00000_10010_0000100010001000",		-- addi $s2, $zero, 0x0888
		 4 => B"000000_00000_10000_10001_00010_000000",		-- sll  $s1,$s0,2    "line 2"  
		 5 => B"000000_00000_10001_10001_00010_000000",		-- sll  $s1,$s1,2    
		 6 => B"000000_10001_10111_10001_00000_100000",		-- add  $s1,$s1,$s7      
		 7 => B"000000_00000_10010_10010_00001_000000",		-- sll  $s2,$s2,1       
		 8 => B"101011_10001_10000_0000000000000000",		-- sw   $s0,0($s1)
		 9 => B"101011_10001_10010_0000000000000100",		-- sw   $s2,4($s1)
		10 => B"000000_00000_10010_10011_00010_000000",	   	-- sll  $s3,$s2,2   
		11 => B"101011_10001_10011_0000000000001000",		-- sw   $s3,8($s1)
		12 => B"000000_10011_10010_10100_00000_100010",		-- sub  $s4,$s3,$s2
		13 => B"101011_10001_10100_0000000000001100",		-- sw   $s4,12($s1)
		14 => B"001000_10000_10000_0000000000000001",		-- addi $s0, $s0, 1       
		15 => B"001000_00000_10101_0000000000000101",		-- addi $s5, $zero, 5   
		16 => B"000000_10101_10000_10110_00000_100010",		-- sub  $s6,$s5,$s0
		17 => B"000101_10110_00000_1111111111110010",		-- bne	$s6, $zero, "line 2" (immed = -14)
		18 => B"100011_10001_10111_0000000000000000",		-- lw   $s7,0($s1)
		19 => B"000000_00000_10010_10011_01010_000000",	   	-- sll  $s3,$s2,10 -- TEST SHIFT 
		20 => B"000100_00000_00000_1111111111111111",		-- beq	$zero, $zero, -1
		others => X"00000000");             
    end if;
  end process RamProc;

  -- Decode address and return instruction to execute
  i_address <= Address(4 downto 0);
  DataOut   <= i_ram(to_integer(unsigned(i_address)));
 
end instrucRAM;	

----------------------------------------------------------------------------------------------------------------------------------------------------------------
