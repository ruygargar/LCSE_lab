--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:21:46 01/03/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab/ram/tb_ram.vhd
-- Project Name:  ram
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ram
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
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
 
USE work.PIC_pkg.all;
 
ENTITY tb_ram IS
END tb_ram;
 
ARCHITECTURE behavior OF tb_ram IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         WriteEnable : IN  std_logic;
         OutputEnable : IN  std_logic;
         ChipSelect : IN  std_logic;
         Address : IN  std_logic_vector(7 downto 0);
         Databus : INOUT  std_logic_vector(7 downto 0) := (others => 'Z');
         Switches : OUT  std_logic_vector(7 downto 0);
         Temp_L : OUT  std_logic_vector(6 downto 0);
         Temp_h : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal WriteEnable : std_logic := '0';
   signal OutputEnable : std_logic := '0';
   signal ChipSelect : std_logic := '0';
   signal Address : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal Databus : std_logic_vector(7 downto 0) := (others => 'Z');

 	--Outputs
   signal Switches : std_logic_vector(7 downto 0);
   signal Temp_L : std_logic_vector(6 downto 0);
   signal Temp_h : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram PORT MAP (
          Clk => Clk,
          Reset => Reset,
          WriteEnable => WriteEnable,
          OutputEnable => OutputEnable,
          ChipSelect => ChipSelect,
          Address => Address,
          Databus => Databus,
          Switches => Switches,
          Temp_L => Temp_L,
          Temp_h => Temp_h
        );

  Clk <= not Clk after Clk_period;
 
   -- Stimulus process
   process
   begin		
      wait for 100 ns;	
		Reset <= '1';
		wait;
   end process;
		
	process
	variable aux_address : integer range 0 to 255;
   begin		
      wait for 150 ns;
		ChipSelect <= '1';
		WriteEnable <= '1';
		OutputEnable <= '0';
		Databus <= X"55";
		for aux_address in 0 to 255 loop
			Address <= conv_std_logic_vector(aux_address, 8);
			wait for 50 ns;
		end loop;
		WriteEnable <= '0';
		OutputEnable <= '1';
		Databus <= (others => 'Z');
		for aux_address in 0 to 255 loop
			Address <= conv_std_logic_vector(aux_address, 8);
			wait for 50 ns;
		end loop;		
		wait;
   end process;

END;
