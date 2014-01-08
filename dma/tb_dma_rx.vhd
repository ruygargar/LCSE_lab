--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:51:10 01/07/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab-master/dma/tb_dma_rx.vhd
-- Project Name:  dma
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dma_rx
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
 
ENTITY tb_dma_rx IS
END tb_dma_rx;
 
ARCHITECTURE behavior OF tb_dma_rx IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dma_rx
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         Databus : OUT  std_logic_vector(7 downto 0);
         Address : OUT  std_logic_vector(7 downto 0);
         ChipSelect : OUT  std_logic;
         WriteEnable : OUT  std_logic;
         OutputEnable : OUT  std_logic;
         Start_RX : IN  std_logic;
         End_RX : OUT  std_logic;
         DataIn : IN  std_logic_vector(7 downto 0);
         Read_DI : OUT  std_logic;
         Empty : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Start_RX : std_logic := '0';
   signal DataIn : std_logic_vector(7 downto 0) := X"AA";
   signal Empty : std_logic := '1';

 	--Outputs
   signal Databus : std_logic_vector(7 downto 0);
   signal Address : std_logic_vector(7 downto 0);
   signal ChipSelect : std_logic;
   signal WriteEnable : std_logic;
   signal OutputEnable : std_logic;
   signal End_RX : std_logic;
   signal Read_DI : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dma_rx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          Databus => Databus,
          Address => Address,
          ChipSelect => ChipSelect,
          WriteEnable => WriteEnable,
          OutputEnable => OutputEnable,
          Start_RX => Start_RX,
          End_RX => End_RX,
          DataIn => DataIn,
          Read_DI => Read_DI,
          Empty => Empty
        );

   -- Clock process definitions
   Clk <= not Clk after Clk_period;
 

   -- Stimulus
	 Reset <= '1' after 100 ns;
	 Empty <= '1', '0' after 100 ns, '1' after 300 ns, '0' after 350 ns, '1' after 500 ns, 
								 '0' after 650 ns;
   Start_RX <= '0', '1' after 150 ns, '0' after 175 ns, '1' after 400 ns, '0' after 425 ns,
										'1' after 600 ns, '0' after 625 ns, '1' after 700 ns, '0' after 725 ns;
		
END;
