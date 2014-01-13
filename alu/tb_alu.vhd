--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   03:48:33 01/13/2014
-- Design Name:   
-- Module Name:   C:/Users/Ruy/Desktop/LCSE_lab/alu/tb_alu.vhd
-- Project Name:  alu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
 
ENTITY tb_alu IS
END tb_alu;
 
ARCHITECTURE behavior OF tb_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         u_instruction : IN  alu_op;
         FlagZ : OUT  std_logic;
         FlagC : OUT  std_logic;
         FlagN : OUT  std_logic;
         FlagE : OUT  std_logic;
         Index : OUT  std_logic_vector(7 downto 0);
         Databus : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal u_instruction : alu_op := nop;

	--BiDirs
   signal Databus : std_logic_vector(7 downto 0) := X"00";

 	--Outputs
   signal FlagZ : std_logic;
   signal FlagC : std_logic;
   signal FlagN : std_logic;
   signal FlagE : std_logic;
   signal Index : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          Clk => Clk,
          Reset => Reset,
          u_instruction => u_instruction,
          FlagZ => FlagZ,
          FlagC => FlagC,
          FlagN => FlagN,
          FlagE => FlagE,
          Index => Index,
          Databus => Databus
        );

	Clk <= not Clk after Clk_period;

   -- Stimulus process
   stim_proc: process
   begin
		wait for 100 ns;	-- Quitar reset y cargar A desde el bus de datos
		Reset <= '1' after 1 ns;
		wait for 25 ns;
		Databus <= X"05" after 1 ns;	-- 5
		u_instruction <= op_lda after 1 ns;
		wait for 50 ns;	-- Cargar B desde el bus de datos
		Databus <= X"FB" after 1 ns;	-- -5
		u_instruction <= op_ldb after 1 ns;
		wait for 50 ns;	-- Cargar ACC desde el bus de datos
		Databus <= X"55" after 1 ns;
		u_instruction <= op_ldacc after 1 ns;
		wait for 50 ns;	-- Cargar INDEX desde el bus de datos
		Databus <= X"AA" after 1 ns;
		u_instruction <= op_ldid after 1 ns;
		
		wait for 50 ns;	-- Suma
		Databus <= X"00" after 1 ns;
		u_instruction <= op_add after 1 ns;
		wait for 50 ns;	-- Resta
		Databus <= X"00" after 1 ns;
		u_instruction <= op_sub after 1 ns;
		
		wait for 50 ns;	-- Mueve ACC a INDEX
		Databus <= X"00" after 1 ns;
		u_instruction <= op_mvacc2id after 1 ns;
		wait for 50 ns;	-- Mueve ACC a A
		Databus <= X"00" after 1 ns;
		u_instruction <= op_mvacc2a after 1 ns;
		wait for 50 ns;	-- Mueve ACC a B
		Databus <= X"00" after 1 ns;
		u_instruction <= op_mvacc2b after 1 ns;
		
		wait for 50 ns;	-- XOR
		Databus <= X"00" after 1 ns;
		u_instruction <= op_xor after 1 ns;
		
		wait for 50 ns;	-- Compare <
		Databus <= X"00" after 1 ns;
		u_instruction <= op_cmpl after 1 ns;
		
		wait for 50 ns;	-- Compare =
		Databus <= X"00" after 1 ns;
		u_instruction <= op_cmpe after 1 ns;
		
		wait for 50 ns;	-- Carga en A
		Databus <= X"FF" after 1 ns; -- FF
		u_instruction <= op_lda after 1 ns;
		wait for 50 ns;	-- Carga en B
		Databus <= X"80" after 1 ns; -- 80
		u_instruction <= op_ldb after 1 ns;
		
		wait for 50 ns;	-- OR
		Databus <= X"00" after 1 ns;
		u_instruction <= op_or after 1 ns;
		wait for 50 ns;	-- AND
		Databus <= X"00" after 1 ns;
		u_instruction <= op_and after 1 ns;
		
		wait for 50 ns;	-- SUM
		Databus <= X"00" after 1 ns;
		u_instruction <= op_add after 1 ns;		
		wait for 50 ns;	-- Compare >
		Databus <= X"00" after 1 ns;
		u_instruction <= op_cmpg after 1 ns;
		
		wait for 50 ns;	-- BIN 2 ASCII (con error)
		Databus <= X"00" after 1 ns;
		u_instruction <= op_bin2ascii after 1 ns;
		
		wait for 50 ns;	-- Carga en A
		Databus <= X"08" after 1 ns;
		u_instruction <= op_lda after 1 ns;
		wait for 50 ns;	-- BIN 2 ASCII (sin error)
		Databus <= X"00" after 1 ns;
		u_instruction <= op_bin2ascii after 1 ns;
		
		wait for 50 ns;	-- Carga ACC en A
		Databus <= X"00" after 1 ns;
		u_instruction <= op_mvacc2a after 1 ns;
		wait for 50 ns;	-- ASCII 2 BIN (sin error)
		Databus <= X"00" after 1 ns;
		u_instruction <= op_ascii2bin after 1 ns;
		
		wait for 50 ns;	-- Carga ACC en A
		Databus <= X"00" after 1 ns;
		u_instruction <= op_mvacc2a after 1 ns;
		wait for 50 ns;	-- Carga ACC en B
		Databus <= X"00" after 1 ns;
		u_instruction <= op_mvacc2b after 1 ns;
		
		wait for 50 ns;	-- Suma con acarreo de nibble
		Databus <= X"00" after 1 ns;
		u_instruction <= op_add after 1 ns;
		
		wait for 50 ns;	-- Saca ACC por el bus de datos
		Databus <= (others => 'Z');
		u_instruction <= op_oeacc after 1 ns;
      wait;

   end process;
	
END;
