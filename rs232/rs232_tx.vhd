----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:53:43 11/10/2013 
-- Design Name: 
-- Module Name:    RS232_TX - Behavioral 
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

entity RS232_TX is
 port (
	Clk   : in  std_logic;
	Reset : in  std_logic;
	Start : in  std_logic;
	Data  : in  std_logic_vector(7 downto 0);
	EOT   : out std_logic;
	TX    : out std_logic);
end RS232_TX;

architecture Behavioral of RS232_TX is

type state is (idle, startbit, senddata, stopbit);
SIGNAL current_st, next_st: state;
SIGNAL copy_data: std_logic_vector (7 downto 0);
SIGNAL enable_copy, pw_sreset, dc_sreset, dc_enable: std_logic;
SIGNAL pulse_width: std_logic_vector (8 downto 0);
CONSTANT PEOC: std_logic_vector (8 downto 0) := "010101101";
SIGNAL data_count: std_logic_vector (2 downto 0);

BEGIN
PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN 
			current_st <= idle;
		  ELSIF clk'event AND clk='1' THEN
         current_st <= next_st;
        END IF;
END PROCESS;

PROCESS (current_st, start, pulse_width, data_count)
	 BEGIN 
		enable_copy <= '0';
		pw_sreset <= '0';
		dc_sreset <= '0';
		dc_enable <= '0';
		EOT <= '0';
		TX <= '1';
		CASE current_st IS
			WHEN idle =>
				enable_copy <= '1';
				EOT <= '1';
				IF (start = '1') THEN 
					pw_sreset <= '1';
					next_st <= startbit;
				ELSE 
					next_st <= idle;
				END IF;
			WHEN startbit =>
				TX <= '0';
				IF (pulse_width = PEOC) THEN
					pw_sreset <= '1';
					dc_sreset <= '1';
					next_st <= senddata;
				ELSE
					next_st <= startbit;
				END IF;
			WHEN senddata =>
				TX <= copy_data(conv_integer(data_count));
				IF (pulse_width = PEOC) THEN
					dc_enable <= '1';
					pw_sreset <= '1';
				END IF;
				IF (data_count = "111") AND (pulse_width = PEOC) THEN
					pw_sreset <= '1';
					next_st <= stopbit;
				ELSE 
					next_st <= senddata;
				END IF;
			WHEN stopbit =>
				TX <= '1';
				IF (pulse_width = PEOC) THEN					
					next_st <= idle;
				ELSE
					next_st <= stopbit;
				END IF;
		END CASE;
END PROCESS;					

PROCESS (clk, reset)
	BEGIN 
		IF reset = '0' THEN
			copy_data <= (others=>'0');
		ELSIF clk'event AND clk = '1' THEN
			IF enable_copy = '1' THEN 
				copy_data <= data;
			END IF;
		END IF;
END PROCESS;

PROCESS (clk, reset, pw_sreset)
	BEGIN
		IF reset = '0' THEN 
			pulse_width <= (others => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF pw_sreset = '1' THEN
				pulse_width <= (others => '0');
			ELSE
				pulse_width <= pulse_width + '1';
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

