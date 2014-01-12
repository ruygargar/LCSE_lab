----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:42:50 01/12/2014 
-- Design Name: 
-- Module Name:    peripherics - Behavioral 
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

entity peripherics is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           TX : out  STD_LOGIC;
           RX : in  STD_LOGIC;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           Address : inout  STD_LOGIC_VECTOR (7 downto 0);
           ChipSelect : inout  STD_LOGIC;
           WriteEnable : inout  STD_LOGIC;
           OutputEnable : inout  STD_LOGIC;
           Send : in  STD_LOGIC;
           Ready : out  STD_LOGIC;
           DMA_RQ : out  STD_LOGIC;
           DMA_ACK : in  STD_LOGIC;
			  Switches		: out   std_logic_vector(7 downto 0);
			  Temp_L			: out   std_logic_vector(6 downto 0);
			  Temp_H			: out   std_logic_vector(6 downto 0)
			 );
end peripherics;

architecture Behavioral of peripherics is

	COMPONENT RS232top
	PORT(
		Reset : IN std_logic;
		Clk : IN std_logic;
		Data_in : IN std_logic_vector(7 downto 0);
		Valid_D : IN std_logic;
		RD : IN std_logic;
		Data_read : IN std_logic;          
		Ack_in : OUT std_logic;
		TX_RDY : OUT std_logic;
		TD : OUT std_logic;
		Data_out : OUT std_logic_vector(7 downto 0);
		Full : OUT std_logic;
		Empty : OUT std_logic
		);
	END COMPONENT;

	COMPONENT dma
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		Send : IN std_logic;
		DMA_ACK : IN std_logic;
		Ack_out : IN std_logic;
		TX_RDY : IN std_logic;
		RCVD_data : IN std_logic_vector(7 downto 0);
		RX_Full : IN std_logic;
		RX_empty : IN std_logic;    
		Databus : INOUT std_logic_vector(7 downto 0);      
		Address : OUT std_logic_vector(7 downto 0);
		ChipSelect : OUT std_logic;
		WriteEnable : OUT std_logic;
		OutputEnable : OUT std_logic;
		Ready : OUT std_logic;
		DMA_RQ : OUT std_logic;
		TX_data : OUT std_logic_vector(7 downto 0);
		Valid_D : OUT std_logic;
		Data_read : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ram
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		WriteEnable : IN std_logic;
		OutputEnable : IN std_logic;
		ChipSelect : IN std_logic;
		Address : IN std_logic_vector(7 downto 0);    
		Databus : INOUT std_logic_vector(7 downto 0);      
		Switches : OUT std_logic_vector(7 downto 0);
		Temp_L : OUT std_logic_vector(6 downto 0);
		Temp_h : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	signal data_in_i, data_out_i :std_logic_vector(7 downto 0);
	signal valid_i, ack_i, txready_i, dataread_i : std_logic;
	signal empty_i, full_i : std_logic;

begin

	RS232: RS232top PORT MAP(
		Reset => Reset,
		Clk => Clk,
		Data_in => data_in_i,
		Valid_D => valid_i,
		Ack_in => ack_i,
		TX_RDY => txready_i,
		TD => TX,
		RD => RX,
		Data_out => data_out_i,
		Data_read => dataread_i,
		Full => full_i,
		Empty => empty_i
	);
	
	DMA0: dma PORT MAP(
		Clk => Clk,
		Reset => Reset,
		Databus => Databus,
		Address => Address,
		ChipSelect => ChipSelect,
		WriteEnable => WriteEnable,
		OutputEnable => OutputEnable,
		Send => Send,
		Ready => Ready,
		DMA_RQ => DMA_RQ,
		DMA_ACK => DMA_ACK,
		TX_data => data_in_i,
		Valid_D => valid_i,
		Ack_out => ack_i,
		TX_RDY => txready_i,
		RCVD_data => data_out_i,
		Data_read => dataread_i,
		RX_Full => full_i,
		RX_empty => empty_i
	);

	RAM0: ram PORT MAP(
		Clk => Clk,
		Reset => Reset,
		WriteEnable => WriteEnable,
		OutputEnable => OutputEnable,
		ChipSelect => ChipSelect,
		Address => Address,
		Databus => Databus,
		Switches => Switches,
		Temp_L => Temp_L,
		Temp_H => Temp_H
	);

end Behavioral;

