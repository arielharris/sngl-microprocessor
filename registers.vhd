--------------------------------------------------------------------------------
--
-- LAB #3 ARIEL HARRIS
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
	
begin
	memmy_register8:
	for I in 0 to 7 generate
		CX: bitstorage port map 
			(datain(I), enout, writein, dataout(I));
	end generate;
	
end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	component register8
		port(datain: in std_logic_vector(7 downto 0);
	     	 	enout: inout std_logic;
		 	writein: inout std_logic;
		 	dataout: out std_logic_vector(7 downto 0));
	end component;
	
	signal en, wr: std_logic_vector(2 downto 0);
begin
	
	en(0) <= enout32 AND enout16 AND enout8;
	en(1) <= enout32 AND enout16;
	en(2) <= enout32;

	wr(0) <= writein32 OR writein16 OR writein8;
	wr(1) <= writein32 OR writein16;
	wr(2) <= writein32;



	F0: register8 port map (datain(7 downto 0), en(0), wr(0), dataout(7 downto 0));
	F1: register8 port map (datain(15 downto 8), en (1), wr(1), dataout(15 downto 8));
	F2: register8 port map (datain(23 downto 16), en(2), wr(2), dataout(23 downto 16));
	F3: register8 port map (datain(31 downto 24), en(2), wr(2), dataout(31 downto 24));


	
end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is

	component fulladder
		port (a : in std_logic;
         		b : in std_logic;
			cin : in std_logic;
        		sum : out std_logic;
         		carry : out std_logic);
	end component;

	signal c: std_logic_vector(32 downto 0);
	signal tempB: std_logic_vector(31 downto 0);

begin
	c(0) <= '0';

	with add_sub select
		tempB <= datain_b when '0', 
			not(datain_b)+1 when others;
	
	adder_subtracter_fulladder:
	for I in 0 to 31 generate
		AX: fulladder port map
			(datain_a(I), tempB(I), c(I), dataout(I), c(I+1));
		end generate;	

	co <= c(32);
	
end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
signal temp: std_logic_vector(31 downto 0);
signal shift: std_logic_vector(5 downto 0);
begin

shift <= dir & shamt;

with shift select temp <=
	datain(31 downto 0) when "000000",
	datain(30 downto 0) & '0' when "000001",
	datain(29 downto 0) & "00" when "000010",
	datain(28 downto 0) & "000" when "000011",
	datain(27 downto 0) & "0000" when "000100",
	datain(26 downto 0) & "00000" when "000101",
	datain(25 downto 0) & "000000" when "000110",
	datain(24 downto 0) & "0000000" when "000111",
	datain(23 downto 0) & "00000000" when "001000",
	datain(22 downto 0) & "000000000" when "001001",
	datain(21 downto 0) & "0000000000" when "001010",
	datain(20 downto 0) & "00000000000" when "001011",
	datain(19 downto 0) & "000000000000" when "001100",
	datain(18 downto 0) & "0000000000000" when "001101",
	datain(17 downto 0) & "00000000000000" when "001110",
	datain(16 downto 0) & "000000000000000" when "001111",
	datain(15 downto 0) & "0000000000000000" when "010000",
	datain(14 downto 0) & "00000000000000000" when "010001",
	datain(13 downto 0) & "000000000000000000" when "010010",
	datain(12 downto 0) & "0000000000000000000" when "010011",
	datain(11 downto 0) & "00000000000000000000" when "010100",
	datain(10 downto 0) & "000000000000000000000" when "010101",
	datain(9 downto 0) & "0000000000000000000000" when "010110",
	datain(8 downto 0) & "00000000000000000000000" when "010111",
	datain(7 downto 0) & "000000000000000000000000" when "011000",
	datain(6 downto 0) & "0000000000000000000000000" when "011001",
	datain(5 downto 0) & "00000000000000000000000000" when "011010",
	datain(4 downto 0) & "000000000000000000000000000" when "011011",
	datain(3 downto 0) & "0000000000000000000000000000" when "011100",
	datain(2 downto 0) & "00000000000000000000000000000" when "011101",
	datain(1 downto 0) & "000000000000000000000000000000" when "011110",
	"0000000000000000000000000000000" & datain(0) when "011111",
	'0' & datain(31 downto 1) when "100001",
	"00" & datain(31 downto 2) when "100010",
	"000" & datain (31 downto 3) when "100011",
	"0000" & datain (31 downto 4) when "100100",
	"00000" & datain (31 downto 5) when "100101",
	"000000" & datain (31 downto 6) when "100110",
	"0000000" & datain (31 downto 7) when "100111",
	"00000000" & datain (31 downto 8) when "101000",
	"000000000" & datain (31 downto 9) when "101001",
	"0000000000" & datain (31 downto 10) when "101010",
	"00000000000" & datain (31 downto 11) when "101011",
	"000000000000" & datain (31 downto 12) when "101100",
	"0000000000000" & datain (31 downto 13) when "101101",
	"00000000000000" & datain (31 downto 14) when "101110",
	"000000000000000" & datain (31 downto 15) when "101111",
	"0000000000000000" & datain (31 downto 16) when "110000",
	"00000000000000000" & datain (31 downto 17) when "110001",
	"000000000000000000" & datain (31 downto 18) when "110010",
	"0000000000000000000" & datain (31 downto 19) when "110011",
	"00000000000000000000" & datain (31 downto 20) when "110100",
	"000000000000000000000" & datain (31 downto 21) when "110101",
	"0000000000000000000000" & datain (31 downto 22) when "110110",
	"00000000000000000000000" & datain (31 downto 23) when "110111",
	"000000000000000000000000" & datain (31 downto 24) when "111000",
	"0000000000000000000000000" & datain (31 downto 25) when "111001",
	"00000000000000000000000000" & datain (31 downto 26) when "111010",
	"000000000000000000000000000" & datain (31 downto 27) when "111011",
	"0000000000000000000000000000" & datain (31 downto 28) when "111100",
	"00000000000000000000000000000" & datain (31 downto 29) when "111101",
	"000000000000000000000000000000" & datain (31 downto 30) when "111110",
	"0000000000000000000000000000000" & datain (31) when "111111",
	datain(31 downto 0) when others;

dataout <= temp;

end architecture shifter;



