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
				  (others => 'Z') after 227 ns, -- Free bus (Send)
					X"00" after 377 ns, -- Catch bus again
					(others => 'Z') after 89977 ns, -- Free bus (1º DMA_ACK)
					X"00" after 90127 ns, -- Catch bus again
					(others => 'Z') after 256627 ns, -- Free bus (2º DMA_ACK)
					X"00" after 256827 ns, -- Catch bus 
					X"00" after 300027 ns, -- Clean NEW_INST flag		
					X"00" after 300077 ns, -- Catch bus
					(others => 'Z') after 610027 ns, -- Free bus (3º DMA_ACK)
					X"00" after 610477 ns; -- Catch bus 
				  
	Address <= DMA_TX_BUFFER_MSB after 102 ns, DMA_TX_BUFFER_LSB after 127 ns, -- Write TX Buffers
				  X"FF" after 177 ns, -- Send handshake
				  (others => 'Z') after 227 ns, -- Free bus (Send)
					X"FF" after 377 ns, -- Catch bus again
					(others => 'Z') after 89977 ns, -- Free bus (1º DMA_ACK)
					X"FF" after 90127 ns, -- Catch bus 
					(others => 'Z') after 256627 ns, -- Free bus	(2º DMA_ACK)
					X"FF" after 256827 ns, -- Catch bus 
					NEW_INST after 300027 ns, -- Clean NEW_INST flag							
					X"FF" after 300077 ns, -- Catch bus 
					(others => 'Z') after 610027 ns, -- Free bus (3º DMA_ACK)
					X"FF" after 610477 ns; -- Catch bus 
					
	ChipSelect <= '1' after 102 ns, '0' after 177 ns, -- Write TX Buffers
					  'Z' after 227 ns, -- Free bus (Send)
						'0' after 377 ns, -- Catch bus again
						'Z' after 89977 ns, -- Free bus (1º DMA_ACK)
						'0' after 90127 ns, -- Catch bus again
						'Z' after 256627 ns, -- Free bus (2º DMA_ACK)						 
						'0' after 256827 ns, -- Catch bus again
						'1' after 300027 ns, -- Clean NEW_INST flag
						'0' after 300077 ns, -- Catch bus again
						'Z' after 610027 ns, -- Free bus (3º DMA_ACK)
						'0' after 610477 ns; -- Catch bus again
						
	WriteEnable <= '1' after 102 ns, '0' after 177 ns, -- Write TX Buffers
						'Z' after 227 ns, -- Free bus (Send)
						'0' after 377 ns, -- Catch bus again
						'Z' after 89977 ns, -- Free bus (1º DMA_ACK)
						'0' after 90127 ns, -- Catch bus again
						'Z' after 256627 ns, -- Free bus (2º DMA_ACK)
						'0' after 256827 ns, -- Catch bus again
						'1' after 300027 ns, -- Clean NEW_INST flag
						'0' after 300077 ns, -- Catch bus again
						'Z' after 610027 ns, -- Free bus
						'0' after 610477 ns; -- Catch bus again

	
	OutputEnable <= '0' after 102 ns, -- Write TX Buffers
						 'Z' after 227 ns, -- Free bus (Send)
						 '0' after 377 ns, -- Catch bus again
						 'Z' after 89977 ns, -- Free bus (1º DMA_ACK)
						 '0' after 90127 ns, -- Catch bus again
						 'Z' after 256627 ns, -- Free bus (2º DMA_ACK)
						 '0' after 256827 ns, -- Catch bus again
						 '0' after 300027 ns, -- Clean NEW_INST flag
						 '0' after 300077 ns, -- Catch bus again
						 'Z' after 610027 ns, -- Free bus (3º DMA_ACK)
						 '0' after 610477 ns; -- Catch bus again
						 
  Send <= '1' after 177 ns, '0' after 327 ns; -- Send handshake
	
	DMA_ACK <= '1' after 89927 ns, '0' after 90077 ns, -- 1º DMA-ACK handshake
						 '1' after 256577 ns, '0' after 256777 ns, -- 2º DMA-ACK handshake
						 '1' after 609977 ns, '0' after 610427 ns; -- 3º DMA-ACK handshake
						 
   -- Stimulus process
	 
	
	RX_process: process	-- Data received from RS232 RX
	begin
		wait for 200 ns;
		Transmit(RX, X"01");
		Transmit(RX, X"02");
		Transmit(RX, X"03");
		Transmit(RX, X"04");
		Transmit(RX, X"05");
		Transmit(RX, X"06");
		Transmit(RX, X"07");
		wait;
	end process;
END;
