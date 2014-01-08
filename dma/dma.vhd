----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:59:49 01/07/2014 
-- Design Name: 
-- Module Name:    dma - Behavioral 
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

entity dma is
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
           TX_data : out  STD_LOGIC_VECTOR (7 downto 0);
           Valid_D : out  STD_LOGIC;
           Ack_out : in  STD_LOGIC;
           TX_RDY : in  STD_LOGIC;
           RCVD_data : in  STD_LOGIC_VECTOR (7 downto 0);
           Data_read : out  STD_LOGIC;
           RX_Full : in  STD_LOGIC;
           RX_empty : in  STD_LOGIC);
end dma;

architecture Behavioral of dma is

	COMPONENT dma_bus_controller
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		Send : IN std_logic;
		DMA_ACK : IN std_logic;
		RX_empty : IN std_logic;
		RX_Databus : IN std_logic_vector(7 downto 0);
		RX_Address : IN std_logic_vector(7 downto 0);
		RX_ChipSelect : IN std_logic;
		RX_WriteEnable : IN std_logic;
		RX_OutputEnable : IN std_logic;
		RX_end : IN std_logic;
		TX_Address : IN std_logic_vector(7 downto 0);
		TX_ChipSelect : IN std_logic;
		TX_WriteEnable : IN std_logic;
		TX_OutputEnable : IN std_logic;
		TX_ready : IN std_logic;
		TX_end : IN std_logic;    
		Databus : INOUT std_logic_vector(7 downto 0);      
		Address : OUT std_logic_vector(7 downto 0);
		ChipSelect : OUT std_logic;
		WriteEnable : OUT std_logic;
		OutputEnable : OUT std_logic;
		Ready : OUT std_logic;
		DMA_RQ : OUT std_logic;
		RX_start : OUT std_logic;
		TX_Databus : OUT std_logic_vector(7 downto 0);
		TX_start : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT dma_tx
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		Databus : IN std_logic_vector(7 downto 0);
		Start_TX : IN std_logic;
		Ack_DO : IN std_logic;          
		Address : OUT std_logic_vector(7 downto 0);
		ChipSelect : OUT std_logic;
		WriteEnable : OUT std_logic;
		OutputEnable : OUT std_logic;
		Ready_TX : OUT std_logic;
		End_TX : OUT std_logic;
		DataOut : OUT std_logic_vector(7 downto 0);
		Valid_DO : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT dma_rx
	PORT(
		Clk : IN std_logic;
		Reset : IN std_logic;
		Start_RX : IN std_logic;
		DataIn : IN std_logic_vector(7 downto 0);
		Empty : IN std_logic;          
		Databus : OUT std_logic_vector(7 downto 0);
		Address : OUT std_logic_vector(7 downto 0);
		ChipSelect : OUT std_logic;
		WriteEnable : OUT std_logic;
		OutputEnable : OUT std_logic;
		End_RX : OUT std_logic;
		Read_DI : OUT std_logic
		);
	END COMPONENT;
	
	signal RX_Databus_i : std_logic_vector(7 downto 0);
	signal RX_Address_i : std_logic_vector(7 downto 0);
	signal RX_ChipSelect_i : std_logic;
	signal RX_WriteEnable_i : std_logic;
	signal RX_OutputEnable_i : std_logic;
	signal RX_start_i : std_logic;
	signal RX_end_i : std_logic;
	
	signal TX_Databus_i : std_logic_vector(7 downto 0);
	signal TX_Address_i : std_logic_vector(7 downto 0);
	signal TX_ChipSelect_i : std_logic;
	signal TX_WriteEnable_i : std_logic;
	signal TX_OutputEnable_i : std_logic;
	signal TX_start_i : std_logic;
	signal TX_ready_i : std_logic;
	signal TX_end_i : std_logic;
	
begin

	bus_controller: dma_bus_controller PORT MAP(
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
		RX_empty => RX_empty,
		RX_Databus => RX_Databus_i,
		RX_Address => RX_Address_i,
		RX_ChipSelect => RX_ChipSelect_i,
		RX_WriteEnable => RX_WriteEnable_i,
		RX_OutputEnable => RX_OutputEnable_i,
		RX_start => RX_start_i,
		RX_end => RX_end_i,
		TX_Databus => TX_Databus_i,
		TX_Address => TX_Address_i,
		TX_ChipSelect => TX_ChipSelect_i,
		TX_WriteEnable => TX_WriteEnable_i,
		TX_OutputEnable => TX_OutputEnable_i,
		TX_start => TX_start_i,
		TX_ready => TX_ready_i,
		TX_end => TX_end_i
	);
	
	tx: dma_tx PORT MAP(
		Clk => Clk,
		Reset => Reset,
		Databus => TX_Databus_i,
		Address => TX_Address_i,
		ChipSelect => TX_ChipSelect_i,
		WriteEnable => TX_WriteEnable_i,
		OutputEnable => TX_OutputEnable_i,
		Start_TX => TX_start_i,
		Ready_TX => TX_ready_i,
		End_TX => TX_end_i,
		DataOut => TX_data,
		Valid_DO => Valid_D,
		Ack_DO => Ack_out
	);
	
	rx: dma_rx PORT MAP(
		Clk => Clk,
		Reset => Reset,
		Databus => RX_Databus_i,
		Address => RX_Address_i,
		ChipSelect => RX_ChipSelect_i,
		WriteEnable => RX_WriteEnable_i,
		OutputEnable => RX_OutputEnable_i,
		Start_RX => RX_start_i,
		End_RX => RX_end_i,
		DataIn => RCVD_data,
		Read_DI => Data_read,
		Empty => RX_empty
	);

end Behavioral;

