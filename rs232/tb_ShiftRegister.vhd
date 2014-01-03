--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:02:57 11/15/2013
-- Design Name:   
-- Module Name:   C:/Users/Silvia/Desktop/RS232 project/RS232/tb_ShiftRegister.vhd
-- Project Name:  RS232
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ShiftRegister
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
 
ENTITY tb_ShiftRegister IS
END tb_ShiftRegister;
 
ARCHITECTURE behavior OF tb_ShiftRegister IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ShiftRegister
    PORT(
         Reset : IN  std_logic;
         Clk : IN  std_logic;
         Enable : IN  std_logic;
         D : IN  std_logic;
         Q : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '0';
   signal Clk : std_logic := '0';
   signal Enable : std_logic := '0';
   signal D : std_logic := '0';

 	--Outputs
   signal Q : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ShiftRegister PORT MAP (
          Reset => Reset,
          Clk => Clk,
          Enable => Enable,
          D => D,
          Q => Q
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 
	D <= NOT D after 51 ns;
   -- Stimulus process
   stim_proc: process
   begin		
      wait for 100 ns;	
		Reset <= '1';
		wait for 300 ns;
		Enable <= '1';
		wait for 300 ns;
		Enable <= '0';
		wait;
   end process;

END;
