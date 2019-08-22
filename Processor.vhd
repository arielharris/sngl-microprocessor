--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port(clk : in  STD_LOGIC;
                   opcode : in  STD_LOGIC_VECTOR (5 downto 0);
		   funct  : in  STD_LOGIC_VECTOR (5 downto 0);
	           RegSrc : out  STD_LOGIC;
	           RegDst : out  STD_LOGIC;
	           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
	           MemRead : out  STD_LOGIC;
	           MemtoReg : out  STD_LOGIC;
	           ALUOp : out  STD_LOGIC_VECTOR(4 downto 0);
	           MemWrite : out  STD_LOGIC;
	           ALUSrc : out  STD_LOGIC;
	           RegWrite : out  STD_LOGIC);
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     Control: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0);
		     CarryOut: out std_logic );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component SmallBusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(4 downto 0);
		     Result: out std_logic_vector(4 downto 0) );
	end component;

	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;


	signal PCBranch, readAddress, PCnext, instruction, writeData, dataOne, dataTwo, extnd, inTwo, ALUres, rData, extndShift, ADDres: std_logic_vector (31 downto 0);
	signal opALU, readReg1, readReg2, wReg: std_logic_vector (4 downto 0);
	signal branchOp: std_logic_vector (1 downto 0);
	signal branchRes: std_logic_vector (2 downto 0);
	signal srcReg, dstReg, readMem, regMem, writeMem, srcALU, writeReg, zero, c, branchAdd, co: std_logic; 
begin

	
	P1: ProgramCounter port map (reset, clock, PCBranch, readAddress); -- program counter
	PA1: adder_subtracter port map (readAddress, x"00000004", '0', PCnext, c); -- increment PC
	I1: InstructionRAM port map (reset, clock, readAddress(31 downto 2), instruction); -- inst memory
	C1: Control port map (clock, instruction(31 downto 26), instruction(5 downto 0), srcReg, dstReg, branchOp, readMem, regMem, opALU, writeMem, srcALU, writeReg); -- control
	SM1: SmallBusMux2to1 port map (srcReg, instruction(25 downto 21), instruction(20 downto 16), readReg1); -- read register 1 small mux
	SM2: SmallBusMux2to1 port map (dstReg, instruction(20 downto 16), instruction(15 downto 11), wReg); -- write register small mux
	readReg2 <= instruction(20 downto 16);
	R1: Registers port map (readReg1, readReg2, wReg, writeData, writeReg, dataOne, dataTwo); -- registers 
	
	-- sign extension
	extnd <= "0000000000000000" & instruction(15 downto 0) when instruction (15) = '0' else
		"1111111111111111" & instruction(15 downto 0);
	
	
	BM1: BusMux2to1 port map (srcALU, dataTwo, extnd, inTwo); --ALU input 2 bus mux
	A1: ALU port map (dataOne, inTwo, opALU, zero, ALUres, co); -- ALU
	
	DM1: RAM port map (reset, clock, readMem, writeMem, ALUres(31 downto 2), dataTwo, rData); -- data memory using RAM
	BM2: BusMux2to1 port map (regMem, ALUres, rData, writeData); -- write data to registers bus mux

	extndShift <= extnd(29 downto 0) & "00";
	PA2: adder_subtracter port map (PCnext, extndShift, '0', ADDres, c);
	
	branchRes <= zero & branchOp;
	PCBranch <= ADDres when branchRes = "010" else
		ADDres when branchRes = "111" else
		PCnext;
	
	




end holistic;

