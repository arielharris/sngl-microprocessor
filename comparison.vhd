Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity comparison is
	port (difference: in std_logic;
		compare: in std_logic;
		lessThan: out std_logic_vector(31 downto 0) := x"00000000");
end;

architecture steps of comparison is
signal temp: std_logic;
begin

	temp <= difference nor compare;
	lessThan(0) <= temp;
end;
	