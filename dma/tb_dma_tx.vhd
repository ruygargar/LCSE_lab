--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:54:09 01/07/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab-master/dma/tb_dma_tx.vhd
-- Project Name:  dma
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dma_tx
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
 
ENTITY tb_dma_tx IS
END tb_dma_tx;
 
ARCHITECTURE behavior OF tb_dma_tx IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dma_tx
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         Databus : IN  std_logic_vector(7 downto 0);
         Address : OUT  std_logic_vector(7 downto 0);
         ChipSelect : OUT  std_logic;
         WriteEnable : OUT  std_logic;
         OutputEnable : OUT  std_logic;
         Start_TX : IN  std_logic;
         Ready_TX : OUT  std_logic;
         End_TX : OUT  std_logic;
         DataOut : OUT  std_logic_vector(7 downto 0);
         Valid_DO : OUT  std_logic;
         Ack_DO : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Databus : std_logic_vector(7 downto 0) := (others => '0');
   signal Start_TX : std_logic := '0';
   signal Ack_DO : std_logic := '1';

 	--Outputs
   signal Address : std_logic_vector(7 downto 0);
   signal ChipSelect : std_logic;
   signal WriteEnable : std_logic;
   signal OutputEnable : std_logic;
   signal Ready_TX : std_logic;
   signal End_TX : std_logic;
   signal DataOut : std_logic_vector(7 downto 0);
   signal Valid_DO : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dma_tx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          Databus => Databus,
          Address => Address,
          ChipSelect => ChipSelect,
          WriteEnable => WriteEnable,
          OutputEnable => OutputEnable,
          Start_TX => Start_TX,
          Ready_TX => Ready_TX,
          End_TX => End_TX,
          DataOut => DataOut,
          Valid_DO => Valid_DO,
          Ack_DO => Ack_DO
        );

   -- Clock process definitions
	 Clk <= not Clk after Clk_period;
 

   -- Stimulus process
   stim_proc: process
   begin		
			wait for 100 ns;
			Reset <= '1';
			wait for 50 ns;
			Start_TX <= '1';
			wait for 25 ns;
			Start_TX <= '0';
			Databus <= X"AA";
			wait for 50 ns;
			Databus <= X"55";
			wait for 50 ns;
			Databus <= X"00";
			wait for 50 ns;
			Ack_DO <= '0';
			wait for 50 ns;
			Ack_DO <= '1';
			wait for 500 ns;
			Ack_DO <= '0';
			wait for 50 ns;
			Ack_DO <= '1';
      wait;
   end process;

END;
