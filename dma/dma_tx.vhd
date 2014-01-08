----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:45:05 01/06/2014 
-- Design Name: 
-- Module Name:    dma_tx - Behavioral 
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

entity dma_tx is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Databus : in  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           ChipSelect : out  STD_LOGIC;
           WriteEnable : out  STD_LOGIC;
           OutputEnable : out  STD_LOGIC;
           Start_TX : in  STD_LOGIC;
           Ready_TX : out  STD_LOGIC;
           End_TX : out  STD_LOGIC;
           DataOut : out  STD_LOGIC_VECTOR(7 downto 0);
           Valid_DO : out  STD_LOGIC;
           Ack_DO : in  STD_LOGIC);
end dma_tx;

architecture Behavioral of dma_tx is
	type Transmitter_ST is (idle, CPY_REG0, CPY_REG1, SND_REG0, SND_REG1);
	signal TX_now, TX_next : Transmitter_ST;

	signal REG0, REG1 : std_logic_vector(7 downto 0);
	signal R0_enable, R1_enable : std_logic;
	
	constant R0_address : std_logic_vector(7 downto 0) := X"04";
	constant R1_address : std_logic_vector(7 downto 0) := X"05";
begin

	WriteEnable <= '0';

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

	process(TX_now, Start_TX, REG0, REG1, Ack_DO)
	begin
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
				
				TX_next <= CPY_REG1;
			
			when CPY_REG1 =>
				Address <= R1_address;
				ChipSelect <= '1';
				OutputEnable <= '1';
				R1_enable <= '1';
				
				TX_next <= SND_REG0;
				End_TX <= '1';
			
			when SND_REG0 =>
				DataOut <= REG0;
				Valid_DO <= '0';
					
				if Ack_DO = '0' then
					Valid_DO <= '1';
					TX_next <= SND_REG1;
				else
					TX_next <= SND_REG0;
				end if;
					
			when SND_REG1 =>
				DataOut <= REG1;
				Valid_DO <= '0';
					
				if Ack_DO = '0' then
					Valid_DO <= '1';
					TX_next <= idle;
				else
					TX_next <= SND_REG1;
				end if;
					
		end case;
	end process;

end Behavioral;

