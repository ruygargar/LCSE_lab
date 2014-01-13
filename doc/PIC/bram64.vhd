-------------------------------------------------------------------------------
-- Author: 	Aragonés Orellana, Silvia
--				García Garcia, Ruy

-- Project Name: 	PIC 
-- Design  Name: 	ram.vhd
-- Module  Name:	bram64.vhd
-------------------------------------------------------------------------------
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
	-- RAM:
	-- + Ancho de palabra: 8 bits 	(Bus de Datos de 8 bits)
	-- + Longitud de la memoria: 64	(Bus de Direcciones de 6 bits)
	-- + Tamaño: 64 bytes
  SIGNAL contents_ram : array8_ram(63 downto 0);

BEGIN

	-- Proceso secuencial utilizado para la actualización del valor almacenado
	-- en cada dirección de memoria.
	-- No dispone de Reset. Es necesaria la inicialización, mediante software, 
	-- de cada posición de memoria tras iniciar el sistema antes de su lectura.
	process (Clk)
	begin
	  if Clk'event and Clk = '1' then
		 if WriteEnable = '1' then
			contents_ram(Conv_Integer(address)) <= Databus;
		 end if;
	  end if;
	end process;

	-- Lógica combinacional necesaria para multiplexar la salida de las 
	-- posiciones de memoria hacia el bus de datos en función de la dirección
	-- indicada en el bus de direcciones.
	-- Únicamente cuando la señal de control WriteEnable esté activada, 
	-- almacenará el valor del bus de datos en la posición de memoria cuya 
	-- dirección esté seleccionada en el bus de direcciones.
	-- La salida al bus de datos se mantendrá a alta impedancia siempre que la 
	-- señal de control OutputEnable este desactivada.
	Databus <= 	contents_ram(Conv_integer(address)) when OutputEnable= '1' 
					else (others => 'Z');

END behavior;

