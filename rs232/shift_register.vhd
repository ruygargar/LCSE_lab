----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:33:27 11/15/2013 
-- Design Name: 
-- Module Name:    ShiftRegister - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRegister is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Enable : in  STD_LOGIC;
           D : in  std_logic;
			  Q : out std_logic_vector(7 downto 0)
	 );
end ShiftRegister;

architecture Behavioral of ShiftRegister is
signal q_i : std_logic_vector (7 downto 0);
begin

PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN 
			q_i <= "00000000";
		  ELSIF clk'event AND clk='1' THEN
         IF enable = '1' THEN
				q_i <= D & q_i(7 downto 1);
			ELSE
				q_i <= q_i;
			END IF;
       END IF;
END PROCESS;

Q <= q_i;

end Behavioral;

