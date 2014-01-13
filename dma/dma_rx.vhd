-- Author: 	Aragonés Orellana, Silvia
--				García Garcia, Ruy

-- Project Name: 	PIC 
-- Design  Name: 	dma.vhd
-- Module  Name:	dma_rx.vhd
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dma_rx is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  
			  -- Señales procedentes del bus del uP.
           Databus : out  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           ChipSelect : out  STD_LOGIC;
           WriteEnable : out  STD_LOGIC;
           OutputEnable : out  STD_LOGIC;
			  
			  -- Señales procedentes de la FSM del Controlador de Bus.
           Start_RX : in  STD_LOGIC;
           End_RX : out  STD_LOGIC;
			  
			  -- Bus de datos y señales de handshake orientadas al receptor del
			  -- RS232.
           DataIn : in  STD_LOGIC_VECTOR (7 downto 0);
           Read_DI : out  STD_LOGIC;
           Empty : in  STD_LOGIC);
end dma_rx;

architecture Behavioral of dma_rx is
	-- Definición de los posibles estados de la FSM del Transmisor:
	type Receiver_ST is (idle, MVE_REGX, CPY_NEWINST);
	signal RX_now, RX_next : Receiver_ST;
	
	-- Tabla de direcciones:
	-- El valor contenido en cada posición de la tabla será empleado como  
	-- dirección de memoria en la que se escribirá el dato de entrada, 
	-- utilizando como índice el orden de llegada de los bytes entrantes.
	type table is array (natural range <>) of std_logic_vector(7 downto 0);
	constant AddressTable : table := (X"00", X"01", X"02", X"03");
	
	-- Señales usadas para inferir un contador que vaya barriendo la tabla de 
	-- direcciones para ir almacenando los datos recibidos en su respectiva 
	-- posición de memoria.
	signal count : std_logic_vector(1 downto 0);
	-- Señal de enable y clear del contador anterior.
	signal count_enable, count_clear : std_logic;
	
begin

	-- El Receptor nunca leerá un valor de memoria. Únicamente escribe los 
	-- datos recibidos en ella.
	OutputEnable <= '0';


	-- Proceso secuencial que describe el contador necesario para indexar la 
	-- tabla de direcciones del Receptor.
	-- Dispone de una señal de Reset asíncrono activa a nivel bajo que 
	-- inicializa a 0 el valor del contador.
	-- Además dispone de dos entradas de control síncronas y activas a nivel 
	-- alto (enable y clear), procedentes de la FSM del Receptor, desde las 
	-- cuales se gobernará el contador.
	process(Clk, Reset)
	begin
		if (Reset = '0') then
			count <= (others => '0');
		elsif Clk'event and Clk = '1' then
			if count_clear = '1' then
				count <= (others => '0');
			elsif count_enable = '1' then
				count <= count + '1';
			end if;
		end if;
	end process;
	
	-- Proceso secuencial de la máquina de estados del Receptor. 
	-- Dispone de una señal de Reset asíncrono activa a nivel bajo. Mientras que
	-- esta señal se mantenga activa, la FSM se mantiene en el estado de 'Idle'.
	process(Clk, Reset)
	begin
		if (Reset = '0') then
			RX_now <= idle;
		elsif Clk'event and Clk = '1' then
			RX_now <= RX_next;
		end if;
	end process;
	
	-- Proceso combinacional de la máquina de estados.
	process(RX_now, Start_RX, DataIn, Empty, count)
	begin
		-- Valores preasignados por defecto.
		Databus <= DataIn;
		Address <= X"00";
		ChipSelect <= '0';
		WriteEnable <= '0';
		End_RX <= '0';
		Read_DI <= '0';
		
		count_enable <= '0';
		count_clear <= '0';

		case RX_now is
			when idle =>
				-- Si el Controlador de Bus da permiso para iniciar una nueva 
				-- recepción...
				if Start_RX = '1' then		
					RX_next <= MVE_REGX;
				else
					RX_next <= idle;
				end if;
				
			when MVE_REGX =>
				Address <= AddressTable(conv_integer(count));			
				ChipSelect <= '1';
				WriteEnable <= '1';

				Read_DI <= '1';
				count_enable <= '1';

				-- Si el RS232 ya no tiene más datos recibidos...
				if (Empty = '1') then
					-- No se realiza la transferencia .
					ChipSelect <= '0';
					WriteEnable <= '0';
					Read_DI <= '0';
					-- Ni se actualiza el contador.
					count_enable <= '0';
					-- Y se vuelve al estado de espera, devolviendo el control de 
					-- los buses.
					End_RX <= '1';
					
					RX_next <= idle;
				
				-- Si se está recibiendo correctamente el LSB...
				elsif (count = X"2") then					
					RX_next <= CPY_NEWINST;	
				else					
					RX_next <= MVE_REGX;
				end if;
			
			when CPY_NEWINST =>
				Address <= AddressTable(conv_integer(count));
				Databus <= X"FF";
				ChipSelect <= '1';
				WriteEnable <= '1';
				
				-- Se reinicia el contador y se vuelve al estado de espera, 
				-- devolviendo el control de los buses.
				count_clear <= '1';
				End_RX <= '1';
				
				RX_next <= idle;
		
		end case;
	end process;


end Behavioral;

