--------------------------------------------------------------------------------
--
-- LAB #5 - Memory and Register Bank
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic;
	 WE:      in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;
  
 --  signal tmp: std_logic_vector(31 downto 0);

begin

  RamProc: process(Clock, Reset, OE, WE, Address) is

  begin
    if Reset = '1' then
	rst_RAM:
	for I in 0 to 127 loop
		RX: i_ram(I) <= (others => '0');
	end loop;
    end if;

    if ((to_integer(unsigned(Address))) > 127) then
	DataOut <= (others => 'Z');
    else

	if falling_edge(Clock) then
		if WE = '1' then
			i_ram(to_integer(unsigned(Address))) <= DataIn;
		end if;
   	 end if;

	if OE = '0' then
		DataOut <= i_ram(to_integer(unsigned(Address)));
	else
		DataOut <= (others => 'Z');
	end if;

    end if;
  end process RamProc;


end staticRAM;	


--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0); 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);
	 WriteData: in std_logic_vector(31 downto 0);
	 WriteCmd: in std_logic;
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
end entity Registers;

architecture remember of Registers is
	component register32
  	    port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
	end component;
	

	
	signal hold0, holdS0, holdS1, holdS2, holdS3, holdS4, holdS5, holdS6, holdS7 : std_logic_vector(31 downto 0);
	--signal writeCmd0, writeCmdS0, writeCmdS1, writeCmdS2, writeCmdS3, writeCmdS4, writeCmdS5, writeCmdS6, writeCmdS7 : std_logic := '0';
	signal writeCmdS: std_logic_vector(8 downto 0) := "000000000";
	signal writeRegCmd: std_logic_vector(5 downto 0);
	

begin

	writeRegCmd <= WriteCmd & WriteReg;

	with writeRegCmd select
	writeCmdS <= "000000001" when "100000", 
			"000000010" when "110000", 
			"000000100" when "110001",
			"000001000" when "110010", 
			"000010000" when "110011", 
			"000100000" when "110100", 
			"001000000" when "110101",
			"010000000" when "110110", 
			"100000000" when "110111", 
			"000000000" when OTHERS;

	
	hold0 <= "00000000000000000000000000000000"; -- $0 always 0

	S0: register32 port map (writeData, '0', '1', '1', writeCmdS(0), '0', '0', hold0);
	S1: register32 port map (writeData, '0', '1', '1', writeCmdS(1), '0', '0', holdS0);
	S2: register32 port map (writeData, '0', '1', '1', writeCmdS(2), '0', '0', holdS1);
	S3: register32 port map (writeData, '0', '1', '1', writeCmdS(3), '0', '0', holdS2);
	S4: register32 port map (writeData, '0', '1', '1', writeCmdS(4), '0', '0', holdS3);
	S5: register32 port map (writeData, '0', '1', '1', writeCmdS(5), '0', '0', holdS4);
	S6: register32 port map (writeData, '0', '1', '1', writeCmdS(6), '0', '0', holdS5);
	S7: register32 port map (writeData, '0', '1', '1', writeCmdS(7), '0', '0', holdS6);
	S8: register32 port map (writeData, '0', '1', '1', writeCmdS(8), '0', '0', holdS7);
	
	with ReadReg1 select ReadData1 <=
		hold0 when "00000",
		holdS0 when "10000",
		holdS1 when "10001",
		holdS2 when "10010",
		holdS3 when "10011",
		holdS4 when "10100",
		holdS5 when "10101",
		holdS6 when "10110",
		holdS7 when "10111",
		"00000000000000000000000000000000" when others;

	with ReadReg2 select ReadData2 <=
		hold0 when "00000",
		holdS0 when "10000",
		holdS1 when "10001",
		holdS2 when "10010",
		holdS3 when "10011",
		holdS4 when "10100",
		holdS5 when "10101",
		holdS6 when "10110",
		holdS7 when "10111",
		"00000000000000000000000000000000" when others;
		
end remember;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
