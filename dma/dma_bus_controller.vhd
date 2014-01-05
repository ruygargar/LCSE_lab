----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:17:06 01/04/2014 
-- Design Name: 
-- Module Name:    dma_bus_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dma_bus_controller is
	Port ( Clk : in  STD_LOGIC;
			 Reset : in  STD_LOGIC;
			 Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
			 Address : out  STD_LOGIC_VECTOR (7 downto 0);
			 ChipSelect : out  STD_LOGIC;
			 WriteEnable : out  STD_LOGIC;
			 OutputEnable : out  STD_LOGIC;
			 Send : in  STD_LOGIC;
			 Ready : out  STD_LOGIC;
			 DMA_RQ : out  STD_LOGIC;
			 DMA_ACK : in  STD_LOGIC;
			 RX_empty : in  STD_LOGIC;
			 
			 -- pragma synthesis off
			 BC_state_ns : out integer;					
			 -- pragma synthesis on
			 
			 RX_Databus : in  STD_LOGIC_VECTOR (7 downto 0);
			 RX_Address : in  STD_LOGIC_VECTOR (7 downto 0);
			 RX_ChipSelect : in  STD_LOGIC;
			 RX_WriteEnable : in  STD_LOGIC;
			 RX_OutputEnable : in  STD_LOGIC;
			 RX_start : out STD_LOGIC;
			 RX_end : in STD_LOGIC;
			 
			 TX_Databus : out  STD_LOGIC_VECTOR (7 downto 0);
			 TX_Address : in  STD_LOGIC_VECTOR (7 downto 0);
			 TX_ChipSelect : in  STD_LOGIC;
			 TX_WriteEnable : in  STD_LOGIC;
			 TX_OutputEnable : in  STD_LOGIC;
			 TX_start : out STD_LOGIC;
			 TX_ready : in STD_LOGIC;
			 TX_end : in STD_LOGIC
			);
end dma_bus_controller;

architecture Behavioral of dma_bus_controller is
	type BusController_ST is (idle, RX_wait_bus, RX_use_bus , RX_free_bus, TX_use_bus, TX_free_bus);
	signal BC_now, BC_next : BusController_ST;

begin
	
	process(Clk, Reset)
	begin
		if (Reset = '0') then
			BC_now <= idle;
		elsif Clk'event and Clk = '1' then
			BC_now <= BC_next;
		end if;
	end process;
	
	process(BC_now, RX_empty, Send, DMA_ACK, RX_end, TX_ready, TX_end, RX_Databus,
			  RX_Address, RX_ChipSelect, RX_WriteEnable, RX_OutputEnable,
			  TX_Address, TX_ChipSelect, TX_WriteEnable, TX_OutputEnable)
	begin
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
				
				if (Send = '1' and TX_ready = '1') then
					Ready <= '0';
					TX_start <= '1';
					BC_next <= TX_use_bus;
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
				
				if Send = '0' then
					BC_next <= idle;
				else
					BC_next <= TX_free_bus;
				end if;
			
			when RX_wait_bus =>
				DMA_RQ <= '1';

				if DMA_ACK = '1' then
					RX_start <= '1';
					BC_next <= RX_use_bus;
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
				if RX_end = '1' then
					DMA_RQ <= '0';
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
				
				if DMA_ACK = '0' then
					BC_next <= idle;
				else
					BC_next <= RX_free_bus;
				end if;
			end case;
	end process;
	
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

