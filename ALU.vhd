--------------------------------------------------------------------------------
--
-- LAB #4 ARIEL HARRIS
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port(	DataIn1: in std_logic_vector(31 downto 0);
		DataIn2: in std_logic_vector(31 downto 0);
		Control: in std_logic_vector(4 downto 0);
		Zero: out std_logic;
		ALUResult: out std_logic_vector(31 downto 0);
		CarryOut: out std_logic );
end entity ALU;

architecture ALU_Arch of ALU is
	-- ALU components	
	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	component shift_register
		port(	datain: in std_logic_vector(31 downto 0);
		   	dir: in std_logic;
			shamt:	in std_logic_vector(4 downto 0);
			dataout: out std_logic_vector(31 downto 0));
	end component shift_register;

	signal l_shift,r_shift,temp: std_logic_vector (31 downto 0);
	signal resadd,resaddi,ressub: std_logic_vector (31 downto 0);
	signal loadW, storeW, beq, bne: std_logic_vector (31 downto 0);
	signal c: std_logic;

begin
-- sel for using extnd vs. DataIn2


-- run port maps 
	A0: adder_subtracter port map (DataIn1, DataIn2, '0', resadd, c);
	AI0: adder_subtracter port map (DataIn1, DataIn2, '0', resaddi, c);
	S0: adder_subtracter port map (DataIn1, DataIn2, '1', ressub, c);
	L0: shift_register port map (DataIn1, '0', DataIn2(10 downto 6), l_shift);
	R0: shift_register port map (DataIn1, '1', DataIn2(10 downto 6), r_shift);
	LW0: adder_subtracter port map (DataIn1, DataIn2, '0', loadW, c);
	SW0: adder_subtracter port map (DataIn1, DataIn2, '0', storeW, c); 
	BQ0: adder_subtracter port map (DataIn1, DataIn2, '1', beq, c);
	BN0: adder_subtracter port map (DataIn1, DataIn2, '1', bne, c);

-- 
--when/else for control

	with Control select temp <=
		resadd when "00000",		--add
		resaddi when "00001",		--addi
		ressub when "00010",		--sub
		(DataIn1 AND DataIn2) when "00011",	--and		
		(DataIn1 OR DataIn2) when "00100",	--or
		(DataIn1 OR DataIn2) when "00101",	--ori
		l_shift when "00110",		--sll
		r_shift when "00111",		--slr
		loadW when "01000",		--lw
		storeW when "01001",		--sw
		beq when "01010",		--beq
		bne when "01011",		--bne
		"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others;



Zero <= '1' when temp = "00000000000000000000000000000000" else '0';




ALUResult <= temp;
CarryOut <= c;

end architecture ALU_Arch;


