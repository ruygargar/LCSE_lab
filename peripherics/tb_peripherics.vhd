--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   04:24:24 01/12/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab/peripherics/tb_peripherics.vhd
-- Project Name:  peripherics
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: peripherics
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

use work.PIC_pkg.all;
use work.RS232_test.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_peripherics IS
END tb_peripherics;
 
ARCHITECTURE behavior OF tb_peripherics IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT peripherics
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         TX : OUT  std_logic;
         RX : IN  std_logic;
         Databus : INOUT  std_logic_vector(7 downto 0);
         Address : INOUT  std_logic_vector(7 downto 0);
         ChipSelect : INOUT  std_logic;
         WriteEnable : INOUT  std_logic;
         OutputEnable : INOUT  std_logic;
         Send : IN  std_logic;
         Ready : OUT  std_logic;
         DMA_RQ : OUT  std_logic;
         DMA_ACK : IN  std_logic;
         Switches : OUT  std_logic_vector(7 downto 0);
         Temp_L : OUT  std_logic_vector(6 downto 0);
         Temp_H : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal RX : std_logic := '1';
   signal Send : std_logic := '0';
   signal DMA_ACK : std_logic := '0';

	--BiDirs
   signal Databus : std_logic_vector(7 downto 0) := (others => 'Z');
   signal Address : std_logic_vector(7 downto 0) := (others => 'Z');
   signal ChipSelect : std_logic := 'Z';
   signal WriteEnable : std_logic := 'Z';
   signal OutputEnable : std_logic := 'Z';

 	--Outputs
   signal TX : std_logic;
   signal Ready : std_logic;
   signal DMA_RQ : std_logic;
   signal Switches : std_logic_vector(7 downto 0);
   signal Temp_L : std_logic_vector(6 downto 0);
   signal Temp_H : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: peripherics PORT MAP (
          Clk => Clk,
          Reset => Reset,
          TX => TX,
          RX => RX,
          Databus => Databus,
          Address => Address,
          ChipSelect => ChipSelect,
          WriteEnable => WriteEnable,
          OutputEnable => OutputEnable,
          Send => Send,
          Ready => Ready,
          DMA_RQ => DMA_RQ,
          DMA_ACK => DMA_ACK,
          Switches => Switches,
          Temp_L => Temp_L,
          Temp_H => Temp_H
        );

   -- Clock process definitions
   Clk <= not Clk after Clk_period;
	
	Reset <= '1' after 100 ns;
	
	Databus <= X"55" after 102 ns, X"AA" after 127 ns, -- Write TX Buffers
				  X"00" after 177 ns, -- Send handshake
				  (others => 'Z') after 227 ns; -- Free bus
				  
	Address <= DMA_TX_BUFFER_MSB after 102 ns, DMA_TX_BUFFER_LSB after 127 ns, -- Write TX Buffers
				  X"FF" after 177 ns, -- Send handshake
				   (others => 'Z') after 227 ns; -- Free bus
					
	ChipSelect <= '1' after 102 ns, '0' after 177 ns, -- Write TX Buffers & Send handshake
					  'Z' after 227 ns; -- Free bus
	
	WriteEnable <= '1' after 102 ns, '0' after 177 ns, -- Write TX Buffers & Send handshake
						'Z' after 227 ns; -- Free bus
	
	OutputEnable <= '0' after 102 ns, -- Write TX Buffers & Send handshake
						 'Z' after 227 ns; -- Free bus
 
   Send <= '1' after 177 ns, '0' after 227 ns; -- Send handshake
	
	DMA_ACK <= '1' after 111775 ns, '0' after 120000 ns; -- DMA-ACK handshake

   -- Stimulus process
	process
	begin
		wait for 200 ns;
		Transmit(RX, X"01");
		Transmit(RX, X"02");
		Transmit(RX, X"03");
		Transmit(RX, X"04");
		Transmit(RX, X"05");
		Transmit(RX, X"06");
		wait;
	end process;
END;
