Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity branch is
	port (zeroIn: in std_logic;
		branch: in std_logic_vector (1 downto 0);
		branchOut: out std_logic);
end;

architecture steps of branch is

	signal branchTrue : std_logic;
	signal andB: std_logic;

begin

	branchTrue <= '1' when branch(1) = '1' else
		'0' when branch(1) = '0';
	
	andB <= branch(0) and zeroIn;

	branchOut <= '1' when andB = '1' else
		'0' when andB ='0';

end;
