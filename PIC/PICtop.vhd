
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk      : in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    Switches : out std_logic_vector(7 downto 0);  -- Switch status bargraph
    Temp_L   : out std_logic_vector(6 downto 0);  -- Less significant figure of T_STAT
    Temp_H   : out std_logic_vector(6 downto 0));  -- Most significant figure of T_STAT
end PICtop;

architecture behavior of PICtop is

	COMPONENT peripherics
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		RX : IN std_logic;
		Send : IN std_logic;
		DMA_ACK : IN std_logic;    
		Databus : INOUT std_logic_vector(7 downto 0);
		Address : INOUT std_logic_vector(7 downto 0);
		ChipSelect : INOUT std_logic;
		WriteEnable : INOUT std_logic;
		OutputEnable : INOUT std_logic;      
		TX : OUT std_logic;
		Ready : OUT std_logic;
		DMA_RQ : OUT std_logic;
		Switches : OUT std_logic_vector(7 downto 0);
		Temp_L : OUT std_logic_vector(6 downto 0);
		Temp_H : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ROM
	PORT(
		Program_counter : IN std_logic_vector(11 downto 0);          
		Instruction : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;
	
	COMPONENT uc
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		ROM_Data : IN std_logic_vector(11 downto 0);
		ALU_Index : IN std_logic_vector(7 downto 0);
		Flag_Z : IN std_logic;
		Flag_C : IN std_logic;
		Flag_N : IN std_logic;
		Flag_E : IN std_logic;
		DMA_RQ : IN std_logic;
		DMA_Ready : IN std_logic;          
		ROM_Address : OUT std_logic_vector(11 downto 0);
		Databus : OUT std_logic_vector(7 downto 0);
		RAM_Address : OUT std_logic_vector(7 downto 0);
		RAM_CS : OUT std_logic;
		RAM_WE : OUT std_logic;
		RAM_OE : OUT std_logic;
		ALU_Operation : OUT alu_op;
		DMA_ACK : OUT std_logic;
		Send : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT alu
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		u_instruction : IN alu_op;    
		Databus : INOUT std_logic_vector(7 downto 0);      
		FlagZ : OUT std_logic;
		FlagC : OUT std_logic;
		FlagN : OUT std_logic;
		FlagE : OUT std_logic;
		Index : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	
	signal Instruction, IAddress : std_logic_vector(11 downto 0);
	
	signal Databus, Address, Index : std_logic_vector(7 downto 0);
	signal ChipSelect, WriteEnable, OutputEnable : std_logic;
	signal Send, Ready, DMA_RQ, DMA_ACK : std_logic;
	
	signal Operation : alu_op;
	signal Flag_Z, Flag_C, Flag_N, Flag_E : std_logic;

begin  -- behavior

  Peripherics0: peripherics
    port map (
		Clk => Clk,
		Reset => Reset,
		TX => RS232_TX,
		RX => RS232_RX,
		Databus => Databus,
		Address => Address,
		ChipSelect => ChipSelect,
		WriteEnable => WriteEnable,
		OutputEnable => OutputEnable,
		Send => Send,
		Ready => Ready,
		DMA_RQ => DMA_RQ,
		DMA_ACK => DMA_ACK,
		Switches => Switches,
		Temp_L => Temp_L,
		Temp_H => Temp_H
	);
	 
  	ROM0: ROM PORT MAP(
		Instruction => Instruction,
		Program_counter => IAddress
	);
	
	
	
	ALU0: alu PORT MAP(
		Clk => Clk,
		Reset => Reset,
		u_instruction => Operation,
		FlagZ => Flag_Z,
		FlagC => Flag_C,
		FlagN => Flag_N,
		FlagE => Flag_E,
		Index => Index,
		Databus => Databus
	);

	UC0: uc PORT MAP(
		Clk => Clk,
		Reset => Reset,
		ROM_Data => Instruction,
		ROM_Address => IAddress,
		Databus => Databus,
		RAM_Address => Address,
		RAM_CS => ChipSelect,
		RAM_WE => WriteEnable,
		RAM_OE => OutputEnable,
		ALU_Operation => Operation,
		ALU_Index => Index,
		Flag_Z => Flag_Z,
		Flag_C => Flag_C,
		Flag_N => Flag_N,
		Flag_E => Flag_E,
		DMA_RQ => DMA_RQ,
		DMA_ACK => DMA_ACK,
		Send => Send,
		DMA_Ready => Ready
	);

end behavior;

