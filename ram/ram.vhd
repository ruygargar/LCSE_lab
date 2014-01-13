-------------------------------------------------------------------------------
-- Author: 	Aragonés Orellana, Silvia
--				García Garcia, Ruy

-- Project Name: 	PIC 
-- Design  Name: 	ram.vhd
-- Module  Name:	ram.vhd
-------------------------------------------------------------------------------

library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity ram is
PORT (
		Clk      		: in    std_logic;
		Reset				: in 	  std_logic;
		WriteEnable		: in    std_logic;
		OutputEnable   : in    std_logic;
		ChipSelect		: in	  std_logic;
		Address  		: in    std_logic_vector(7 downto 0);
		Databus  		: inout std_logic_vector(7 downto 0) := (others => 'Z');
		Switches			: out   std_logic_vector(7 downto 0);
		Temp_L			: out   std_logic_vector(6 downto 0);
		Temp_H			: out   std_logic_vector(6 downto 0)
	);
end ram;

architecture Behavioral of ram is
	
	-- Declaración del componente Bloque de Ram de 64 Bytes.
	COMPONENT bram64
	PORT(
		Clk : IN std_logic;
		WriteEnable : IN std_logic;
		OutputEnable : IN std_logic;
		Address : IN std_logic_vector(5 downto 0);       
		Databus : INOUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	-- Declaración del componente SPR.
	COMPONENT spr
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		WriteEnable : IN std_logic;
		OutputEnable : IN std_logic;
		Address : IN std_logic_vector(5 downto 0);    
		Databus : INOUT std_logic_vector(7 downto 0);      
		Switches : OUT std_logic_vector(7 downto 0);
		Temp_L : OUT std_logic_vector(6 downto 0);
		Temp_h : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	-- Buses de señales procedentes del decodificador "DEC2:4", que controlan
	-- las señales WriteEnable y OutputEnable de cada BRAM (Block RAM) y del 
	-- bloque SPR (Specific Porpouse Registers).
	signal WE : std_logic_vector(3 downto 0);
	signal OE : std_logic_vector(3 downto 0);

begin

	-- Instancia del SPR. En el decodificador "DEC2:4", sus señales de control 
	-- se corresponden con la salida 0.
	spr_0: spr PORT MAP(
		Clk => Clk,
		Reset => Reset,
		WriteEnable => WE(0),
		OutputEnable => OE(0),
		Address => Address(5 downto 0),
		Databus => Databus(7 downto 0),
		Switches => Switches,
		Temp_L => Temp_L,
		Temp_H => Temp_H
	);

	-- Instancia de BRAM. En el decodificador "DEC2:4", sus señales de control 
	-- se corresponden con la salida 1.
	bram_1: bram64 PORT MAP(
		Clk => Clk,
		WriteEnable => WE(1),
		OutputEnable => OE(1),
		Address => Address(5 downto 0),
		Databus => Databus(7 downto 0)
	);
	
	-- Instancia de BRAM. En el decodificador "DEC2:4", sus señales de control 
	-- se corresponden con la salida 2.
	bram_2: bram64 PORT MAP(
		Clk => Clk,
		WriteEnable => WE(2),
		OutputEnable => OE(2),
		Address => Address(5 downto 0),
		Databus => Databus(7 downto 0)
	);
	
	-- Instancia de BRAM. En el decodificador "DEC2:4", sus señales de control 
	-- se corresponden con la salida 3.
	bram_3: bram64 PORT MAP(
		Clk => Clk,
		WriteEnable => WE(3),
		OutputEnable => OE(3),
		Address => Address(5 downto 0),
		Databus => Databus(7 downto 0)
	);
	
	-- Proceso combinacional que decodifica en función del bus de dirección y
	-- las señales ChipSelect, WriteEnable y OutputEnable, las señales de 
	-- control WE y OE de cada uno de los bloques del sistema de almacenamiento.
	-- La escritura predomina sobre la lectura, en caso de tener activadas ambas
	-- señales de control.
	process(ChipSelect, WriteEnable, OutputEnable, Address(7 downto 6))
	begin
		WE <= X"0";
		OE <= X"0";
		if (ChipSelect = '1' and WriteEnable = '1') then
			WE(conv_integer(Address(7 downto 6))) <= '1';
		elsif (ChipSelect = '1' and OutputEnable = '1') then
			OE(conv_integer(Address(7 downto 6))) <= '1';
		end if;
	end process;

end Behavioral;

