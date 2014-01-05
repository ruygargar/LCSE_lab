--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:06:11 01/04/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab/dma/tb_dma_bus_controller.vhd
-- Project Name:  dma
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dma_bus_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_dma_bus_controller IS
END tb_dma_bus_controller;
 
ARCHITECTURE behavior OF tb_dma_bus_controller IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dma_bus_controller
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         Databus : INOUT  std_logic_vector(7 downto 0);
         Address : OUT  std_logic_vector(7 downto 0);
         ChipSelect : OUT  std_logic;
         WriteEnable : OUT  std_logic;
         OutputEnable : OUT  std_logic;
         Send : IN  std_logic;
         Ready : OUT  std_logic;
         DMA_RQ : OUT  std_logic;
         DMA_ACK : IN  std_logic;
			RX_empty : IN  std_logic;
			-- pragma synthesis_off
			 BC_state_ns : out integer;					
			-- pragma synthesis_on	
         RX_Databus : IN  std_logic_vector(7 downto 0);
         RX_Address : IN  std_logic_vector(7 downto 0);
         RX_ChipSelect : IN  std_logic;
         RX_WriteEnable : IN  std_logic;
         RX_OutputEnable : IN  std_logic;
         RX_start : OUT  std_logic;
         RX_end : IN  std_logic;
         TX_Databus : OUT  std_logic_vector(7 downto 0);
         TX_Address : IN  std_logic_vector(7 downto 0);
         TX_ChipSelect : IN  std_logic;
         TX_WriteEnable : IN  std_logic;
         TX_OutputEnable : IN  std_logic;
         TX_start : OUT  std_logic;
         TX_ready : IN  std_logic;
         TX_end : IN  std_logic				
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Send : std_logic := '0';
   signal DMA_ACK : std_logic := '0';
   signal RX_empty : std_logic := '1';
   signal RX_Databus : std_logic_vector(7 downto 0) := X"AA";
   signal RX_Address : std_logic_vector(7 downto 0) := X"AA";
   signal RX_ChipSelect : std_logic := '1';
   signal RX_WriteEnable : std_logic := '0';
   signal RX_OutputEnable : std_logic := '1';
   signal RX_end : std_logic := '0';
   signal TX_Address : std_logic_vector(7 downto 0) := X"55";
   signal TX_ChipSelect : std_logic := '1';
   signal TX_WriteEnable : std_logic := '1';
   signal TX_OutputEnable : std_logic := '0';
   signal TX_ready : std_logic := '1';
   signal TX_end : std_logic := '0';

	--BiDirs
   signal Databus : std_logic_vector(7 downto 0) := X"55";

 	--Outputs
   signal Address : std_logic_vector(7 downto 0);
   signal ChipSelect : std_logic;
   signal WriteEnable : std_logic;
   signal OutputEnable : std_logic;
   signal Ready : std_logic;
   signal DMA_RQ : std_logic;
   signal RX_start : std_logic;
   signal TX_Databus : std_logic_vector(7 downto 0);
   signal TX_start : std_logic;
	
	-- pragma synthesis_on
	signal BC_state_ns : integer;
	-- pragma synthesis_on

   -- Clock period definitions
   constant Clk_period : time := 25ns;
 
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: dma_bus_controller PORT MAP (
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
			 -- pragma synthesis_off
			 BC_state_ns => BC_state_ns,	
			 -- pragma synthesis_on	
          RX_Databus => RX_Databus,
          RX_Address => RX_Address,
          RX_ChipSelect => RX_ChipSelect,
          RX_WriteEnable => RX_WriteEnable,
          RX_OutputEnable => RX_OutputEnable,
          RX_start => RX_start,
          RX_end => RX_end,
          TX_Databus => TX_Databus,
          TX_Address => TX_Address,
          TX_ChipSelect => TX_ChipSelect,
          TX_WriteEnable => TX_WriteEnable,
          TX_OutputEnable => TX_OutputEnable,
          TX_start => TX_start,
          TX_ready => TX_ready,
          TX_end => TX_end
        );

	Clk <= not Clk after Clk_period;
 
   -- Stimulus process
	process
   begin		
      wait for 50 ns;
		Reset <= '1';
		wait for 100 ns;
		RX_Empty <= '0';
		wait until BC_state_ns = 2;
		Databus <= (others => 'Z');
		
		wait for 325 ns;
		DMA_ACK <= '1';
		wait for 175 ns;
		RX_empty <= '1';
		wait until DMA_RQ = '0';
		DMA_ACK <= '0';
		
		wait until BC_state_ns = 0;
		Databus <= X"22";
		wait;
   end process;
	
	process
   begin		
      wait until BC_state_ns = 1;
		TX_ready <= '0';
		wait for 325 ns;
		TX_end <= '1';
		wait for 50 ns;
		TX_end <= '0';
		wait for 500 ns;
		TX_ready <= '1';
		wait;
   end process;
	
	process
   begin		
      wait until BC_state_ns = 4;
		wait for 325 ns;
		RX_end <= '1';
		wait for 50 ns;
		RX_end <= '0';
		wait;
   end process;
	
	process
	begin
		wait for 300 ns;
		Send <= '1';
		wait until Ready = '1';
		Send <= '0' after 10 ns;
		wait;
	end process;

END;
