-------------------------------------------------------------------------------
-- Author: 	Aragon�s Orellana, Silvia
--				Garc�a Garcia, Ruy

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
	-- + Tama�o: 64 bytes
  SIGNAL contents_ram : array8_ram(63 downto 0);

BEGIN

	-- Proceso secuencial utilizado para la actualizaci�n del valor almacenado
	-- en cada direcci�n de memoria.
	-- No dispone de Reset. Es necesaria la inicializaci�n, mediante software, 
	-- de cada posici�n de memoria tras iniciar el sistema antes de su lectura.
	process (Clk)
	begin
	  if Clk'event and Clk = '1' then
		 if WriteEnable = '1' then
			contents_ram(Conv_Integer(address)) <= Databus;
		 end if;
	  end if;
	end process;

	-- L�gica combinacional necesaria para multiplexar la salida de las 
	-- posiciones de memoria hacia el bus de datos en funci�n de la direcci�n
	-- indicada en el bus de direcciones.
	-- �nicamente cuando la se�al de control WriteEnable est� activada, 
	-- almacenar� el valor del bus de datos en la posici�n de memoria cuya 
	-- direcci�n est� seleccionada en el bus de direcciones.
	-- La salida al bus de datos se mantendr� a alta impedancia siempre que la 
	-- se�al de control OutputEnable este desactivada.
	Databus <= 	contents_ram(Conv_integer(address)) when OutputEnable= '1' 
					else (others => 'Z');

END behavior;

