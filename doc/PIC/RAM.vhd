
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(3 downto 0);
   databus  : inout std_logic_vector(7 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

  SIGNAL contents_ram : array8_ram(15 downto 0);

BEGIN

p_ram : process (clk)  -- no reset
begin
  
  if clk'event and clk = '1' then
    if write_en = '1' then
      contents_ram(Conv_Integer(address)) <= databus;
    end if;
  end if;

end process;

databus <= contents_ram(Conv_integer(address)) when oe = '0' else (others => 'Z');

--with contents_ram()(7 downto 4) select
--Temp_H <=
--    "0000110" when "0001",  -- 1
--    "1011011" when "0010",  -- 2
--    "1001111" when "0011",  -- 3
--    "1100110" when "0100",  -- 4
--    "1101101" when "0101",  -- 5
--    "1111101" when "0110",  -- 6
--    "0000111" when "0111",  -- 7
--    "1111111" when "1000",  -- 8
--    "1101111" when "1001",  -- 9
--    "1110111" when "1010",  -- A
--    "1111100" when "1011",  -- B
--    "0111001" when "1100",  -- C
--    "1011110" when "1101",  -- D
--    "1111001" when "1110",  -- E
--    "1110001" when "1111",  -- F
--    "0111111" when others;  -- 0

END behavior;

