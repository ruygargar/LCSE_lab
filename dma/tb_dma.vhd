--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:22:16 01/07/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab/dma/tb_dma.vhd
-- Project Name:  dma
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dma
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
use ieee.std_logic_unsigned.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_dma IS
END tb_dma;
 
ARCHITECTURE behavior OF tb_dma IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dma
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
         TX_data : OUT  std_logic_vector(7 downto 0);
         Valid_D : OUT  std_logic;
         Ack_out : IN  std_logic;
         TX_RDY : IN  std_logic;
         RCVD_data : IN  std_logic_vector(7 downto 0);
         Data_read : OUT  std_logic;
         RX_Full : IN  std_logic;
         RX_empty : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Send : std_logic := '0';
   signal DMA_ACK : std_logic := '0';
   signal Ack_out : std_logic := '0';
   signal TX_RDY : std_logic := '0';
   signal RCVD_data : std_logic_vector(7 downto 0) := (others => '0');
   signal RX_Full : std_logic := '1';
   signal RX_empty : std_logic := '1';

	--BiDirs
   signal Databus : std_logic_vector(7 downto 0);

 	--Outputs
   signal Address : std_logic_vector(7 downto 0);
   signal ChipSelect : std_logic;
   signal WriteEnable : std_logic;
   signal OutputEnable : std_logic;
   signal Ready : std_logic;
   signal DMA_RQ : std_logic;
   signal TX_data : std_logic_vector(7 downto 0);
   signal Valid_D : std_logic;
   signal Data_read : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dma PORT MAP (
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
          TX_data => TX_data,
          Valid_D => Valid_D,
          Ack_out => Ack_out,
          TX_RDY => TX_RDY,
          RCVD_data => RCVD_data,
          Data_read => Data_read,
          RX_Full => RX_Full,
          RX_empty => RX_empty
        );

   -- Clock process definitions
   Clk <= not Clk after Clk_period;
 
   -- Stimulus
	Reset <= '1' after 100 ns;
	
	Databus <= X"00", (others => 'Z') after 326 ns, X"22" after 576 ns, X"AA" after 676 ns, (others => 'Z') after 776 ns, X"22" after 826 ns,
							(others => 'Z') after 976 ns;
	Address <= X"00", (others => 'Z') after 326 ns, X"88" after 576 ns, (others => 'Z') after 676 ns, X"88" after 826 ns,
							(others => 'Z') after 976 ns;
	ChipSelect <= '0', 'Z' after 326 ns, '1' after 576 ns, 'Z' after 676 ns, '1' after 826 ns, 'Z' after 976 ns;
	WriteEnable <= '0', 'Z' after 326 ns, '1' after 576 ns, 'Z' after 676 ns, '1' after 826 ns, 'Z' after 976 ns;
	OutputEnable <= '0', 'Z' after 326 ns, '0' after 576 ns, 'Z' after 676 ns, '1' after 826 ns, 'Z' after 976 ns;
	
	Send <= '1' after 626 ns, '0' after 776 ns;
	
	DMA_ACK <= '1' after 276 ns, '0' after 526 ns, '1' after 926 ns, '0' after 1076 ns, '1' after 1226 ns;
	
	RCVD_data <= X"55" after 250 ns;
	RX_empty <= '0' after 250 ns, '1' after 1026 ns, '0' after 1201 ns, '1' after 1376 ns;
	
	
	
	process
   begin		

      wait;
   end process;

END;
