LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity spr is
	PORT (
		Clk      		: in    std_logic;
		Reset				: in 	  std_logic;
		WriteEnable		: in    std_logic;
		OutputEnable   : in    std_logic;
		Address  		: in    std_logic_vector(5 downto 0);
		Databus  		: inout std_logic_vector(7 downto 0) := (others => 'Z');
		Switches			: out   std_logic_vector(7 downto 0);
		Temp_L			: out   std_logic_vector(6 downto 0);
		Temp_H			: out   std_logic_vector(6 downto 0)
	);
end spr;

architecture Behavioral of spr is
	signal DMA_RX_BUFFER_MSB_REG : std_logic_vector (7 downto 0);
	signal DMA_RX_BUFFER_MID_REG : std_logic_vector (7 downto 0);
	signal DMA_RX_BUFFER_LSB_REG : std_logic_vector (7 downto 0);
	signal NEW_INST_REG 			  : std_logic_vector (7 downto 0);
	signal DMA_TX_BUFFER_MSB_REG : std_logic_vector (7 downto 0);
	signal DMA_TX_BUFFER_LSB_REG : std_logic_vector (7 downto 0);
	signal SWITCH_0_REG 		  	  : std_logic;
	signal SWITCH_1_REG 		  	  : std_logic;
	signal SWITCH_2_REG 		  	  : std_logic;
	signal SWITCH_3_REG 		  	  : std_logic;
	signal SWITCH_4_REG 		  	  : std_logic;
	signal SWITCH_5_REG 		  	  : std_logic;
	signal SWITCH_6_REG 		  	  : std_logic;
	signal SWITCH_7_REG 		  	  : std_logic;
	signal LEVER_0_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_1_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_2_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_3_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_4_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_5_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_6_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_7_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_8_REG 			  : std_logic_vector (3 downto 0);
	signal LEVER_9_REG 			  : std_logic_vector (3 downto 0);
	signal T_STAT_REG				  : std_logic_vector (7 downto 0);

begin
	process (Clk, Reset)
	begin
	  if Reset = '0' then
			DMA_RX_BUFFER_MSB_REG  <= X"00";
			DMA_RX_BUFFER_MID_REG  <= X"00";
			DMA_RX_BUFFER_LSB_REG  <= X"00";
			NEW_INST_REG 			  <= X"00";
			DMA_TX_BUFFER_MSB_REG  <= X"00";
			DMA_TX_BUFFER_LSB_REG  <= X"00";
			SWITCH_0_REG 		  	  <= '0';
			SWITCH_1_REG 		  	  <= '0';
			SWITCH_2_REG 		  	  <= '0';
			SWITCH_3_REG 		  	  <= '0';
			SWITCH_4_REG 		  	  <= '0';
			SWITCH_5_REG 		  	  <= '0';
			SWITCH_6_REG 		  	  <= '0';
			SWITCH_7_REG 		  	  <= '0';
			LEVER_0_REG 			  <= X"0";
			LEVER_1_REG 			  <= X"0";
			LEVER_2_REG 			  <= X"0";
			LEVER_3_REG 			  <= X"0";
			LEVER_4_REG 			  <= X"0";
			LEVER_5_REG 			  <= X"0";
			LEVER_6_REG 			  <= X"0";
			LEVER_7_REG 			  <= X"0";
			LEVER_8_REG 			  <= X"0";
			LEVER_9_REG 			  <= X"0";
			T_STAT_REG				  <= X"20";
		elsif Clk'event and Clk = '1' then
		 if WriteEnable = '1' then
			case Address is
				when DMA_RX_BUFFER_MSB(5 downto 0) 		 => DMA_RX_BUFFER_MSB_REG 	<= Databus;
				when DMA_RX_BUFFER_MID(5 downto 0) 		 => DMA_RX_BUFFER_MID_REG 	<= Databus;
				when DMA_RX_BUFFER_LSB(5 downto 0) 		 => DMA_RX_BUFFER_LSB_REG 	<= Databus;
				when NEW_INST(5 downto 0) 			  		 => NEW_INST_REG 				<= Databus;
				when DMA_TX_BUFFER_MSB(5 downto 0) 		 => DMA_TX_BUFFER_MSB_REG 	<= Databus;
				when DMA_TX_BUFFER_LSB(5 downto 0) 		 => DMA_TX_BUFFER_LSB_REG 	<= Databus;
				when SWITCH_BASE(5 downto 0) 				 => SWITCH_0_REG				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000001") => SWITCH_1_REG 				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000010") => SWITCH_2_REG 				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000011") => SWITCH_3_REG 				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000100") => SWITCH_4_REG 				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000101") => SWITCH_5_REG 				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000110") => SWITCH_6_REG 				<= Databus(0);
				when (SWITCH_BASE(5 downto 0)+"000111") => SWITCH_7_REG 				<= Databus(0);
				when LEVER_BASE(5 downto 0) 				 => LEVER_0_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000001")	 => LEVER_1_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000010")	 => LEVER_2_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000011")	 => LEVER_3_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000100")	 => LEVER_4_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000101")	 => LEVER_5_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000110")	 => LEVER_6_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"000111")	 => LEVER_7_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"001000")	 => LEVER_8_REG				<= Databus(3 downto 0);
				when (LEVER_BASE(5 downto 0)+"001001")	 => LEVER_9_REG				<= Databus(3 downto 0);
				when T_STAT(5 downto 0)	 					 => T_STAT_REG				<= Databus;
				when others =>
			end case;
		 end if;
	  end if;
	end process;
	
	process (OutputEnable, Address, DMA_RX_BUFFER_MSB_REG, DMA_RX_BUFFER_MID_REG, DMA_RX_BUFFER_LSB_REG, NEW_INST_REG,
				DMA_TX_BUFFER_MSB_REG, DMA_TX_BUFFER_LSB_REG, SWITCH_0_REG, SWITCH_1_REG, SWITCH_2_REG, SWITCH_3_REG,
				SWITCH_4_REG, SWITCH_5_REG, SWITCH_6_REG, SWITCH_7_REG, LEVER_0_REG, LEVER_1_REG, LEVER_2_REG, LEVER_3_REG,
				LEVER_4_REG, LEVER_5_REG, LEVER_6_REG, LEVER_7_REG, LEVER_8_REG, LEVER_9_REG, T_STAT_REG)
	begin
		if OutputEnable = '1' then
			case Address is
				when DMA_RX_BUFFER_MSB(5 downto 0) 		 => Databus <= DMA_RX_BUFFER_MSB_REG;
				when DMA_RX_BUFFER_MID(5 downto 0) 		 => Databus <= DMA_RX_BUFFER_MID_REG;
				when DMA_RX_BUFFER_LSB(5 downto 0) 		 => Databus <= DMA_RX_BUFFER_LSB_REG;
				when NEW_INST(5 downto 0) 			  		 => Databus <= NEW_INST_REG;
				when DMA_TX_BUFFER_MSB(5 downto 0) 		 => Databus <= DMA_TX_BUFFER_MSB_REG;
				when DMA_TX_BUFFER_LSB(5 downto 0) 		 => Databus <= DMA_TX_BUFFER_LSB_REG;
				when SWITCH_BASE(5 downto 0) 				 => Databus <= "0000000"&SWITCH_0_REG;
				when (SWITCH_BASE(5 downto 0)+"000001") => Databus <= "0000000"&SWITCH_1_REG;
				when (SWITCH_BASE(5 downto 0)+"000010") => Databus <= "0000000"&SWITCH_2_REG;
				when (SWITCH_BASE(5 downto 0)+"000011") => Databus <= "0000000"&SWITCH_3_REG;
				when (SWITCH_BASE(5 downto 0)+"000100") => Databus <= "0000000"&SWITCH_4_REG;
				when (SWITCH_BASE(5 downto 0)+"000101") => Databus <= "0000000"&SWITCH_5_REG;
				when (SWITCH_BASE(5 downto 0)+"000110") => Databus <= "0000000"&SWITCH_6_REG;
				when (SWITCH_BASE(5 downto 0)+"000111") => Databus <= "0000000"&SWITCH_7_REG;
				when LEVER_BASE(5 downto 0) 				 => Databus <= "0000"&LEVER_0_REG;
				when (LEVER_BASE(5 downto 0)+"000001")	 => Databus <= "0000"&LEVER_1_REG;
				when (LEVER_BASE(5 downto 0)+"000010")	 => Databus <= "0000"&LEVER_2_REG;
				when (LEVER_BASE(5 downto 0)+"000011")	 => Databus <= "0000"&LEVER_3_REG;
				when (LEVER_BASE(5 downto 0)+"000100")	 => Databus <= "0000"&LEVER_4_REG;
				when (LEVER_BASE(5 downto 0)+"000101")	 => Databus <= "0000"&LEVER_5_REG;
				when (LEVER_BASE(5 downto 0)+"000110")	 => Databus <= "0000"&LEVER_6_REG;
				when (LEVER_BASE(5 downto 0)+"000111")	 => Databus <= "0000"&LEVER_7_REG;
				when (LEVER_BASE(5 downto 0)+"001000")	 => Databus <= "0000"&LEVER_8_REG;
				when (LEVER_BASE(5 downto 0)+"001001")	 => Databus <= "0000"&LEVER_9_REG;
				when T_STAT(5 downto 0)	 					 => Databus <= T_STAT_REG;
				when others 									 => Databus <= (others => '0');
			end case;
		else
			Databus <= (others => 'Z');
		end if;
	end process;

	Switches <= SWITCH_7_REG&SWITCH_6_REG&SWITCH_5_REG&SWITCH_4_REG&SWITCH_3_REG&SWITCH_2_REG&SWITCH_1_REG&SWITCH_0_REG;

	with T_STAT_REG(7 downto 4) select
		Temp_H <=
			 "0000110" when "0001",  -- 1
			 "1011011" when "0010",  -- 2
			 "1001111" when "0011",  -- 3
			 "1100110" when "0100",  -- 4
			 "1101101" when "0101",  -- 5
			 "1111101" when "0110",  -- 6
			 "0000111" when "0111",  -- 7
			 "1111111" when "1000",  -- 8
			 "1101111" when "1001",  -- 9
			 "1110111" when "1010",  -- A
			 "1111100" when "1011",  -- B
			 "0111001" when "1100",  -- C
			 "1011110" when "1101",  -- D
			 "1111001" when "1110",  -- E
			 "1110001" when "1111",  -- F
			 "0111111" when others;  -- 0
			 
	with T_STAT_REG(3 downto 0) select
		Temp_L <=
			 "0000110" when "0001",  -- 1
			 "1011011" when "0010",  -- 2
			 "1001111" when "0011",  -- 3
			 "1100110" when "0100",  -- 4
			 "1101101" when "0101",  -- 5
			 "1111101" when "0110",  -- 6
			 "0000111" when "0111",  -- 7
			 "1111111" when "1000",  -- 8
			 "1101111" when "1001",  -- 9
			 "1110111" when "1010",  -- A
			 "1111100" when "1011",  -- B
			 "0111001" when "1100",  -- C
			 "1011110" when "1101",  -- D
			 "1111001" when "1110",  -- E
			 "1110001" when "1111",  -- F
			 "0111111" when others;  -- 0

end Behavioral;

