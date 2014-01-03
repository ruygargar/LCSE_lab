LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

ENTITY bram64 IS
	PORT (
		Clk      		: in    std_logic;
		WriteEnable		: in    std_logic;
		OutputEnable   : in    std_logic;
		Address  		: in    std_logic_vector(5 downto 0);
		Databus  		: inout std_logic_vector(7 downto 0) := (others => 'Z')
	);
END bram64;

ARCHITECTURE behavior OF bram64 IS
  SIGNAL contents_ram : array8_ram(63 downto 0);

BEGIN

	process (Clk)  -- no reset
	begin
	  if Clk'event and Clk = '1' then
		 if WriteEnable = '1' then
			contents_ram(Conv_Integer(address)) <= Databus;
		 end if;
	  end if;
	end process;

	Databus <= contents_ram(Conv_integer(address)) when OutputEnable= '1' else (others => 'Z');

END behavior;

