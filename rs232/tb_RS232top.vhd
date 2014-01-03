
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.all;
   
entity RS232top_TB is
end RS232top_TB;

architecture Testbench of RS232top_TB is

  component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;
  
  signal Reset, Clk, Valid_D, Ack_in, TX_RDY : std_logic;
  signal TD, RD, Data_read, Full, Empty : std_logic;
  signal Data_out, Data_in : std_logic_vector(7 downto 0);

begin

  UUT: RS232top
    port map (
      Reset     => Reset,
      Clk       => Clk,
      Data_in   => Data_in,
      Valid_D   => Valid_D,
      Ack_in    => Ack_in,
      TX_RDY    => TX_RDY,
      TD        => TD,
      RD        => RD,
      Data_out  => Data_out,
      Data_read => Data_read,
      Full      => Full,
      Empty     => Empty);

  Data_in <= "10101010";
 
  -- Clock generator
  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;

  -- Reset & Start generator
  p_reset : PROCESS
  BEGIN
     reset <= '0', '1' after 10 ns;
     Valid_D <= '1', '0' after 110 ns,
                '1' after 400 ns;
     RD <= '1',
           '0' after 500 ns,    -- StartBit
           '1' after 9150 ns,   -- LSb
           '0' after 17800 ns,
           '1' after 26450 ns,
           '0' after 35100 ns,
           '1' after 43750 ns,
           '0' after 52400 ns,
           '1' after 61050 ns,
           '1' after 69700 ns,  -- MSb
           '1' after 78350 ns,  -- Stopbit
           '1' after 87000 ns;
     Data_read <= '0','1'after 88000 ns;
     wait for 100000 ns;
  END PROCESS;

end Testbench;

