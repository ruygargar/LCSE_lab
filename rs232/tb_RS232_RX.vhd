--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:22:05 11/15/2013
-- Design Name:   
-- Module Name:   C:/Users/Silvia/Desktop/RS232 project/RS232/tb_RS232_RX.vhd
-- Project Name:  RS232
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RS232_RX
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
 
ENTITY tb_RS232_RX IS
END tb_RS232_RX;
 
ARCHITECTURE behavior OF tb_RS232_RX IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RS232_RX
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         LineRD_in : IN  std_logic;
         Valid_out : OUT  std_logic;
         Code_out : OUT  std_logic;
         Store_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal LineRD_in : std_logic := '1';

 	--Outputs
   signal Valid_out : std_logic;
   signal Code_out : std_logic;
   signal Store_out : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RS232_RX PORT MAP (
          Clk => Clk,
          Reset => Reset,
          LineRD_in => LineRD_in,
          Valid_out => Valid_out,
          Code_out => Code_out,
          Store_out => Store_out
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
	stim_proc_1: process
   begin
		Reset <= '0';
		wait for 200 ns;
		Reset <= '1';
		wait for 117800 ns;
	end process;
	
   stim_proc_2: process
   begin	
		LineRD_in <= '1',
           '0' after 500 ns,    -- StartBit
           '1' after 9150 ns,   -- LSb
           '0' after 17800 ns,
           '1' after 26450 ns,
           '0' after 35100 ns,
           '1' after 43750 ns,
           '0' after 52400 ns,
           '1' after 61050 ns,
           '1' after 69700 ns,  -- MSb
           '0' after 78350 ns,  -- Stopbit
           '1' after 87000 ns;
      wait for 100000 ns;
   end process;

END;
