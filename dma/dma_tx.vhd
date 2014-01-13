-------------------------------------------------------------------------------
-- Author: 	Aragonés Orellana, Silvia
--				García Garcia, Ruy

-- Project Name: 	PIC 
-- Design  Name: 	dma.vhd
-- Module  Name:	dma_tx.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dma_tx is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  
			  -- Señales procedentes del bus del uP.
           Databus : in  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           ChipSelect : out  STD_LOGIC;
           WriteEnable : out  STD_LOGIC;
           OutputEnable : out  STD_LOGIC;
			  
			  -- Señales procedentes de la FSM del Controlador de Bus.
           Start_TX : in  STD_LOGIC;
           Ready_TX : out  STD_LOGIC;
           End_TX : out  STD_LOGIC;
			  
			  -- Bus de datos y señales de handshake orientadas al transmisor del
			  -- RS232.
           DataOut : out  STD_LOGIC_VECTOR(7 downto 0);
           Valid_DO : out  STD_LOGIC;
           Ack_DO : in  STD_LOGIC);
end dma_tx;

architecture Behavioral of dma_tx is
	-- Definición de los posibles estados de la FSM del Transmisor:
	type Transmitter_ST is (idle, CPY_REG0, CPY_REG1, SND_REG0, SND_REG1);
	signal TX_now, TX_next : Transmitter_ST;

	-- Señales usadas para inferir los biestables necesarios para cada uno de
	-- los registros de copia de los datos a envíar.
	signal REG0, REG1 : std_logic_vector(7 downto 0);
	-- Señal de enable de cada uno de los registros anteriores.
	signal R0_enable, R1_enable : std_logic;
	
	-- Tabla de direcciones:
	-- El valor contenido en cada uno de los registros anteriores será recibido 
	-- desde su respectiva dirección de memoria.
	constant R0_address : std_logic_vector(7 downto 0) := X"04";
	constant R1_address : std_logic_vector(7 downto 0) := X"05";
begin

	-- El Transmisor nunca modificará un valor de memoria. Únicamente lee los 
	-- datos necesarios de ella.
	WriteEnable <= '0';

	-- Proceso secuencial de la máquina de estados del Transmisor. 
	-- Dispone de una señal de Reset asíncrono activa a nivel bajo. Mientras que
	-- esta señal se mantenga activa, la FSM se mantiene en el estado de 'Idle',
	-- y los registros se inicializan a 0.
	process(Clk, Reset)
	begin
		if (Reset = '0') then
			TX_now <= idle;
			REG0 <= X"00";
			REG1 <= X"00";
		elsif Clk'event and Clk = '1' then
			TX_now <= TX_next;
			if R0_enable = '1' then
				REG0 <= Databus;
			end if;
			if R1_enable = '1' then
				REG1 <= Databus;
			end if;
		end if;
	end process;

	-- Proceso combinacional de la máquina de estados.
	process(TX_now, Start_TX, REG0, REG1, Ack_DO)
	begin
		-- Valores preasignados por defecto.
		Address <= X"00";
		ChipSelect <= '0';
		OutputEnable <= '0';
		
		Ready_TX <= '0';
		End_TX <= '0';
		
		DataOut <= X"00";
		Valid_DO <= '1';
		
		R0_enable <= '0';
		R1_enable <= '0';
				
		case TX_now is
			when idle =>
				Ready_TX <= '1';
				
				-- Si el Controlador de Bus da permiso para iniciar una nueva
				-- transmisión...
				if Start_TX = '1' then
					TX_next <= CPY_REG0;
				else
					TX_next <= idle;
				end if;
					
			when CPY_REG0 =>
				Address <= R0_address;
				ChipSelect <= '1';
				OutputEnable <= '1';
				R0_enable <= '1';
				
				-- Las lecturas desde memoria se realizan en un único ciclo de
				-- reloj. Por tanto en el siguiente flanco de reloj, R0 habrá 
				-- almacenado su dato, y se debe pedir a la memoria el siguiente 
				-- valor.
				TX_next <= CPY_REG1;
			
			when CPY_REG1 =>
				Address <= R1_address;
				ChipSelect <= '1';
				OutputEnable <= '1';
				R1_enable <= '1';
				
				-- Las lecturas desde memoria se realizan en un único ciclo de
				-- reloj. Por tanto en el siguiente flanco de reloj, R1 habrá 
				-- almacenado su dato, terminando así el uso de los buses del uP, 
				-- pudiendo devolver su control e iniciando la tranferencia con el 
				-- RS232.
				End_TX <= '1';
				TX_next <= SND_REG0;
			
			when SND_REG0 =>
				DataOut <= REG0;
				Valid_DO <= '0';
				
				-- Si el RS232 ha aceptado el dato...
				if Ack_DO = '0' then
					Valid_DO <= '1';
					TX_next <= SND_REG1;
				else
					TX_next <= SND_REG0;
				end if;
					
			when SND_REG1 =>
				DataOut <= REG1;
				Valid_DO <= '0';
				
				-- Si el RS232 ha aceptado el dato...				
				if Ack_DO = '0' then
					Valid_DO <= '1';
					TX_next <= idle;
				else
					TX_next <= SND_REG1;
				end if;
					
		end case;
	end process;

end Behavioral;

