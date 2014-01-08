----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:56:13 01/07/2014 
-- Design Name: 
-- Module Name:    dma_rx - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dma_rx is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Databus : out  STD_LOGIC_VECTOR (7 downto 0);
           Address : out  STD_LOGIC_VECTOR (7 downto 0);
           ChipSelect : out  STD_LOGIC;
           WriteEnable : out  STD_LOGIC;
           OutputEnable : out  STD_LOGIC;
           Start_RX : in  STD_LOGIC;
           End_RX : out  STD_LOGIC;
           DataIn : in  STD_LOGIC_VECTOR (7 downto 0);
           Read_DI : out  STD_LOGIC;
           Empty : in  STD_LOGIC);
end dma_rx;

architecture Behavioral of dma_rx is
	type Receiver_ST is (idle, MVE_REGX, CPY_NEWINST);
	signal RX_now, RX_next : Receiver_ST;
	
	type table is array (natural range <>) of std_logic_vector(7 downto 0);
	constant AddressTable : table := (X"00", X"01", X"02", X"03");
	
	signal count : std_logic_vector(1 downto 0);
	signal count_enable, count_clear : std_logic;
	
begin

	OutputEnable <= '0';

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
	
	process(Clk, Reset)
	begin
		if (Reset = '0') then
			RX_now <= idle;
		elsif Clk'event and Clk = '1' then
			RX_now <= RX_next;
		end if;
	end process;
	
	process(RX_now, Start_RX, DataIn, Empty, count)
	begin
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

				if (Empty = '1') then
					ChipSelect <= '0';
					WriteEnable <= '0';
					Read_DI <= '0';
					count_enable <= '0';
					End_RX <= '1';
					
					RX_next <= idle;
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
				
				count_clear <= '1';
				End_RX <= '1';
				
				RX_next <= idle;
		
		end case;
	end process;


end Behavioral;

