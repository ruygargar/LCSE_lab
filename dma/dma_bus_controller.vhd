-------------------------------------------------------------------------------
-- Author: 	Aragonés Orellana, Silvia
--				García Garcia, Ruy

-- Project Name: 	PIC 
-- Design  Name: 	dma.vhd
-- Module  Name:	dma_bus_controller.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- La funcionalidad del Controlador de Bus es enmascarar las señales de entrada
-- y salida de los subsistemas Transmisor y Receptor del DMA, con el fin de 
-- mantener tanto los Buses de Datos y Direcciones como las señales de control
-- conectadas entre la fuente y el destino correspondiente en función de las
-- señales de handshake entre uP/DMA y DMA/RS232.
-- A su vez, se encarga de mantener excitados los buses y las señales de 
-- control (a una combinación de valores que no modifiquen el estado de la 
-- memoria) durante las transiciones entre Receptor/Transmisor y el uP.

entity dma_bus_controller is
	Port ( -- Señales procedentes del bus del uP.
			 Clk : in  STD_LOGIC;
			 Reset : in  STD_LOGIC;
			 Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
			 Address : out  STD_LOGIC_VECTOR (7 downto 0);
			 ChipSelect : out  STD_LOGIC;
			 WriteEnable : out  STD_LOGIC;
			 OutputEnable : out  STD_LOGIC;
			 
			 -- Señales de handshake entre uP y DMA.
			 Send : in  STD_LOGIC;
			 Ready : out  STD_LOGIC;
			 
			 -- Señales de handshake entre RS232 y DMA.
			 DMA_RQ : out  STD_LOGIC;
			 DMA_ACK : in  STD_LOGIC;
			 RX_empty : in  STD_LOGIC;
			 
			 -- pragma synthesis off
			 BC_state_ns : out integer;					
			 -- pragma synthesis on
			 
			 -- Señales procedentes del Receptor para el control de los buses de 
			 -- datos y direcciones, y las señales de control.
			 RX_Databus : in  STD_LOGIC_VECTOR (7 downto 0);
			 RX_Address : in  STD_LOGIC_VECTOR (7 downto 0);
			 RX_ChipSelect : in  STD_LOGIC;
			 RX_WriteEnable : in  STD_LOGIC;
			 -- Señales de control utilizadas por la máquina de estados del 
			 -- Controlador de Bus para comunicarse con el Receptor.		 
			 RX_OutputEnable : in  STD_LOGIC;
			 RX_start : out STD_LOGIC;
			 RX_end : in STD_LOGIC;
			 
			 -- Señales procedentes del Transmisor.
			 TX_Databus : out  STD_LOGIC_VECTOR (7 downto 0);
			 TX_Address : in  STD_LOGIC_VECTOR (7 downto 0);
			 TX_ChipSelect : in  STD_LOGIC;
			 TX_WriteEnable : in  STD_LOGIC;
			 TX_OutputEnable : in  STD_LOGIC;
			 -- Señales de control utilizadas por la máquina de estados del 
			 -- Controlador de Bus para comunicarse con el Transmisor.		
			 TX_start : out STD_LOGIC;
			 TX_ready : in STD_LOGIC;
			 TX_end : in STD_LOGIC
			);
end dma_bus_controller;

architecture Behavioral of dma_bus_controller is
	
	-- Definición de los posibles estados de la FSM del Controlador de Bus:
	-- + Idle: Los buses de datos y direcciones, y las señales de control están 
	--		bajo el control del uP.
	--		Las salidas del DMA se mantienen a alta impedancia.
	-- + RX_wait_bus: Los buses de datos y direcciones, y las señales de control 
	-- 	están bajo el control del uP. El DMA avisa al uP de que hay datos a la
	--		espera de ser recibidos.
	--		Las salidas del DMA se mantienen a alta impedancia.
	-- + RX_use_bus: El Controlador de Bus da el control de los buses de datos y
	--		direcciones, y las señales de control, al Receptor.
	--		Las salidas del DMA se correponden con las del Receptor.
	-- + RX_free_bus: El Receptor ha terminado de utilizar los buses de datos y
	--		direcciones, y las señales de control. El Controlador de Bus mantiene
	-- 	excitadas dichas señales a la espera de que el uP vuelva a tomar su
	--		control.
	-- + TX_use_bus: El Controlador de Bus da el control de los buses de datos y
	--		direcciones, y las señales de control, al Transmisor.
	--		Las salidas del DMA se correponden con las del Transmisor.
	-- + RX_free_bus: El Transmisor ha terminado de utilizar los buses de datos
	--		y direcciones, y las señales de control. El Controlador de Bus 
	-- 	mantiene excitadas dichas señales a la espera de que el uP vuelva a 
	--		tomar su control.
	
	type BusController_ST is (idle, RX_wait_bus, RX_use_bus , RX_free_bus, 
										TX_use_bus, TX_free_bus);
	signal BC_now, BC_next : BusController_ST;

begin
	
	-- Proceso secuencial de la máquina de estados del Controlador de Bus. 
	-- Dispone de una señal de Reset asíncrono activa a nivel bajo. Mientras que
	-- esta señal se mantenga activa, la FSM se mantiene en el estado de 'Idle'.
	process(Clk, Reset)
	begin
		if (Reset = '0') then
			BC_now <= idle;
		elsif Clk'event and Clk = '1' then
			BC_now <= BC_next;
		end if;
	end process;
	
	-- Proceso combinacional de la máquina de estados.
	process(BC_now, 
			  RX_empty, Send, 
			  DMA_ACK, RX_end, TX_ready, TX_end, RX_Databus,
			  RX_Address, RX_ChipSelect, RX_WriteEnable, RX_OutputEnable,
			  TX_Address, TX_ChipSelect, TX_WriteEnable, TX_OutputEnable)
	begin
		-- Valores preasignados por defecto.
		Databus <= (others => 'Z');
		Address <= (others => 'Z');
		ChipSelect <= 'Z';
		WriteEnable <= 'Z';
		OutputEnable <= 'Z';
		DMA_RQ <= '0';
		Ready <= '0';
		
		RX_start <= '0';
		TX_start <= '0';
		
		case BC_now is
			when idle =>
				Ready <= '1';
				
				-- Cuando el uP ordene envíar datos y el Transmisor del DMA este 
				-- listo:
				if (Send = '1' and TX_ready = '1') then
					Ready <= '0';
					TX_start <= '1';
					BC_next <= TX_use_bus;
				-- Si no, si el DMA recibe la señal de que hay datos preparados 
				-- para leer desde el RS232...
				elsif (RX_empty = '0') then
					DMA_RQ <= '1';
					BC_next <= RX_wait_bus;
				else
					BC_next <= idle;
				end if;
		
			when TX_use_bus =>
				Address <= TX_Address;
				ChipSelect <= TX_ChipSelect;
				WriteEnable <= TX_WriteEnable;
				OutputEnable <= TX_OutputEnable;
			
				--	Si el Transmisor ha terminado de utilizar el bus...
				if TX_end = '1' then
					BC_next <= TX_free_bus;
				else
					BC_next <= TX_use_bus;
				end if;
			
			when TX_free_bus =>
				Databus <= (others => '0');
				Address <= (others => '0');
				ChipSelect <= '0';
				WriteEnable <= '0';
				OutputEnable <= '0';
				
				Ready <= '1';
				
				-- Si el uP vuelve a tomar el control del bus en el siguiente
				-- ciclo de reloj...
				if Send = '0' then
					BC_next <= idle;
				else
					BC_next <= TX_free_bus;
				end if;
			
			when RX_wait_bus =>
				DMA_RQ <= '1';
				Ready <= '1';

				-- Si el uP cede el bus a partir del siguiente ciclo de reloj...
				if DMA_ACK = '1' then
					RX_start <= '1';
					BC_next <= RX_use_bus;
				-- Si no, y el uP ordene envíar datos y el Transmisor del DMA este 
				-- listo:
				elsif (Send = '1' and TX_ready = '1') then
					Ready <= '0';
					TX_start <= '1';
					BC_next <= TX_use_bus;
				else
					BC_next <= RX_wait_bus;
				end if;
			
			when RX_use_bus =>
				Databus <= RX_Databus;
				Address <= RX_Address;
				ChipSelect <= RX_ChipSelect;
				WriteEnable <= RX_WriteEnable;
				OutputEnable <= RX_OutputEnable;
			
				DMA_RQ <= '1';
				--	Si el Receptor ha terminado de utilizar el bus...
				if RX_end = '1' then
					BC_next <= RX_free_bus;
				else
					BC_next <= RX_use_bus;
				end if;
			
			when RX_free_bus =>
				Databus <= (others => '0');
				Address <= (others => '0');
				ChipSelect <= '0';
				WriteEnable <= '0';
				OutputEnable <= '0';
				
				-- Si el uP vuelve a tomar el control del bus en el siguiente
				-- ciclo de reloj...
				if DMA_ACK = '0' then
					BC_next <= idle;
				else
					BC_next <= RX_free_bus;
				end if;
			end case;
	end process;
	 
	-- El bus de datos siempre estará conectado a la entrada del bus de datos 
	-- del subsistema receptor. 
	TX_Databus <= Databus;
	
	-- pragma synthesis off
	process(BC_now)
	begin
		case BC_now is
			when idle => BC_state_ns <= 0;
			when TX_use_bus => BC_state_ns <= 1;	
			when TX_free_bus => BC_state_ns <= 2;
			when RX_wait_bus => BC_state_ns <= 3;
			when RX_use_bus => BC_state_ns <= 4;
			when RX_free_bus => BC_state_ns <= 5;
		end case;
	end process;
	-- pragma synthesis on
	
end Behavioral;

