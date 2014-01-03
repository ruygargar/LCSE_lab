----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:35:22 11/15/2013 
-- Design Name: 
-- Module Name:    RS232_RX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_RX is
	port (
			Clk       : in  std_logic;
			Reset     : in  std_logic;
			LineRD_in : in  std_logic;
			Valid_out : out std_logic;
			Code_out  : out std_logic;
			Store_out : out std_logic
			);
end RS232_RX;

architecture Behavioral of RS232_RX is

type state is (idle, startbit, rcvdata, endbit);
SIGNAL current_st, next_st: state; 

CONSTANT PEOC: std_logic_vector (8 downto 0) := "010101101";
CONSTANT HPEOC : std_logic_vector (8 downto 0) := "001010110";
SIGNAL data_count: std_logic_vector (2 downto 0);
SIGNAL bit_counter: std_logic_vector (8 downto 0);
SIGNAL bc_sreset, dc_sreset, dc_enable: std_logic;



begin

Code_out <= LineRD_in;

PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN 
			current_st <= idle;
		  ELSIF clk'event AND clk='1' THEN
         current_st <= next_st;
        END IF;
END PROCESS;

PROCESS (current_st, LineRD_in, bit_counter, data_count)
	 BEGIN 
		bc_sreset <= '0';
		dc_sreset <= '0';
		dc_enable <= '0';
		Valid_out <= '0';
		Store_out <= '0';
		
		CASE current_st IS
			WHEN idle =>
				IF (LineRD_in = '0') THEN 
					bc_sreset <= '1';
					next_st <= startbit;
				ELSE 
					next_st <= idle;
				END IF;
			WHEN startbit =>
				IF (bit_counter = HPEOC) THEN
					bc_sreset <= '1';
					dc_sreset <= '1';
					next_st <= rcvdata;
				ELSE
					next_st <= startbit;
				END IF;
			WHEN rcvdata =>
				IF (bit_counter = PEOC) THEN
					dc_enable <= '1';
					bc_sreset <= '1';
					valid_out <= '1';
				END IF;
				IF (data_count = "111") AND (bit_counter = PEOC) THEN
					bc_sreset <= '1';
					next_st <= endbit;
				ELSE 
					next_st <= rcvdata;
				END IF;
			WHEN endbit =>			
				IF (bit_counter = PEOC) THEN					
					IF (LineRD_in = '1') THEN
						store_out <= '1';
					END IF;
					next_st <= idle;
				ELSE
					next_st <= endbit;
				END IF;
		END CASE;
END PROCESS;

PROCESS (clk, reset, bc_sreset)
	BEGIN
		IF reset = '0' THEN 
			bit_counter <= (others => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF bc_sreset = '1' THEN
				bit_counter <= (others => '0');
			ELSE
				bit_counter <= bit_counter + '1';
			END IF;
		END IF;
END PROCESS;

PROCESS (clk, reset, dc_sreset)
	BEGIN
		IF reset = '0' THEN 
			data_count <= (others => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF dc_sreset = '1' THEN
				data_count <= (others => '0');
			ELSIF dc_enable = '1' THEN
				data_count <= data_count + '1';
			END IF;
		END IF;
END PROCESS;

end Behavioral;

