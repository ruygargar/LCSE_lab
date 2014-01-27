----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:17:01 01/26/2014 
-- Design Name: 
-- Module Name:    uc - Behavioral 
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
use ieee.std_logic_unsigned.all;

use work.PIC_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uc is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
           ROM_Address : out  STD_LOGIC_VECTOR (11 downto 0);
           Databus : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_Address : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_CS : out  STD_LOGIC;
           RAM_WE : out  STD_LOGIC;
           RAM_OE : out  STD_LOGIC;
           ALU_Operation : out  alu_op;
           ALU_Index : in  STD_LOGIC_VECTOR (7 downto 0);
           Flag_Z : in  STD_LOGIC;
			  Flag_C : in  STD_LOGIC;
			  Flag_N : in  STD_LOGIC;
			  Flag_E : in  STD_LOGIC;
           DMA_RQ : in  STD_LOGIC;
           DMA_ACK : out  STD_LOGIC;
           Send : out  STD_LOGIC;
           DMA_Ready : in  STD_LOGIC);
end uc;

architecture pipelined of uc is

	-- Fetch signals.
	signal I_data_i, I_add_i : std_logic_vector(11 downto 0);
	
	signal PC_reg, PC_in : std_logic_vector(11 downto 0);
	signal IR_reg : std_logic_vector(11 downto 0);
	signal LT_latch : std_logic_vector(11 downto 0);
	signal LN : std_logic; -- Literal Needed.
		
	signal PC1, jump_address, no_jump_address : std_logic_vector(11 downto 0);
	signal jumping : std_logic;
	
	-- Decode signals.
	signal Jump_reg, Jump_in : std_logic;
	signal JumpC_reg, JumpC_in : std_logic;

	signal A_op_reg, A_op_in : alu_op;
	
	signal D_ctl_reg, D_ctl_in : std_logic_vector(2 downto 0); -- CS&WE&OE
	signal D_valid_reg, D_valid_in : std_logic;
	
	signal IDN : std_logic; -- Index Needed.
	
	signal D_data_reg, D_data_in : std_logic_vector(7 downto 0);

	signal D_add_aux, D_add_aux_id : std_logic_vector(7 downto 0);
	signal D_add_reg, D_add_in : std_logic_vector(7 downto 0);
	
	signal jump_add_reg : std_logic_vector(11 downto 0);
	
	signal start_send_reg, start_send_in : std_logic;
		
	-- Execute signals.
	signal NVD_reg : std_logic; -- Not Valid Data.
	signal BR : std_logic; -- Buses Released.
	
	signal RAM_Address_i : std_logic_vector(7 downto 0);
	signal RAM_CS_i : std_logic;
	signal RAM_WE_i : std_logic;
	signal RAM_OE_i : std_logic;
	
	-- FSM Send/DMA_RQ Controller.
	type FSM_state is (idle, SND_free, SND_wait, SND_catch,
									 DMA_wait_non_jumpc, DMA_free, DMA_wait, DMA_catch);
	signal FSM_now, FSM_next : FSM_state;
	signal FF_enable : std_logic;
	
begin

	-- Fetch Stage Logic:
	I_data_i <= ROM_Data;
	ROM_Address <= I_add_i;
	
	-- -- Program Counter and Instruction Register.
	process(Clk, Reset, PC_in, I_data_i)
	begin
		if Reset = '0' then
			PC_reg <= X"000";
			IR_reg <= X"000";
		elsif Clk'event and Clk = '1' then
			if FF_enable = '1' then
				PC_reg <= PC_in;
				IR_reg <= I_data_i;
			end if;
		end if;
	end process;
	
	-- -- Latch used to store the literal in 2-word instructions.
	process(Clk, LN, I_data_i, LT_latch)
	begin
		if Clk = '1' and LN = '1' then
			LT_latch <= I_data_i;
		else
			LT_latch <= LT_latch;
		end if;
	end process;
	
	-- -- Next PC and ROM Address combinational logic.
	PC1 <= PC_reg + X"001";
	
	jump_address <= jump_add_reg;
	no_jump_address <= PC1 when (Clk = '0' and LN = '1')
							 else PC_reg;
			 
	I_add_i <= jump_address when jumping = '1'
				  else no_jump_address;
						  
	PC_in <= I_add_i + X"001";
	
	
	-- Decode Stage Logic:
	-- -- Internal Pipeline's Registers.
	process(Clk, Reset)
	begin
		if Reset = '0' then
			A_op_reg <= nop;
			Jump_reg <= '0';
			JumpC_reg <= '0';
			
			D_ctl_reg <= "000";
			D_valid_reg <= '0';
			
			D_data_reg <= X"00";
			D_add_reg <= X"00";
			jump_add_reg <= X"000";
			
			start_send_reg  <= '0';
			
		elsif Clk'event and Clk = '1' then
			if FF_enable = '1' then
				A_op_reg <= A_op_in;
				Jump_reg <= Jump_in;
				JumpC_reg <= JumpC_in;
				
				D_ctl_reg <= D_ctl_in;
				D_valid_reg <= D_valid_in;
				
				D_data_reg <= D_data_in;
				D_add_reg <= D_add_in;
				jump_add_reg <= LT_latch;
			
				start_send_reg <= start_send_in;
			end if;
		end if;
	end process;
	
	-- -- Combinational Microinstruction Decoder.
	process(IR_reg)
	begin	
		A_op_in <= nop;
		Jump_in <= '0';
		JumpC_in <= '0';
		
		D_ctl_in <= "000";
		D_valid_in <= '1';
		
		LN <= '0';
		IDN <= '0';
		
		start_send_in <= '0';
		
		case IR_reg(7 downto 6) is
			
			when TYPE_1 =>
				case IR_reg(5 downto 0) is
					when ALU_ADD 			=>	A_op_in <= op_add;
					when ALU_SUB 			=>	A_op_in <= op_sub;
					when ALU_SHIFTL 		=>	A_op_in <= op_shiftl;
					when ALU_SHIFTR 		=>	A_op_in <= op_shiftr;
					when ALU_AND 			=>	A_op_in <= op_and;
					when ALU_OR 			=>	A_op_in <= op_or;
					when ALU_XOR 			=>	A_op_in <= op_xor;
					when ALU_CMPE			=>	A_op_in <= op_cmpe;
					when ALU_CMPG			=>	A_op_in <= op_cmpg;
					when ALU_CMPL			=>	A_op_in <= op_cmpl;
					when ALU_ASCII2BIN	=>	A_op_in <= op_ascii2bin;
					when ALU_BIN2ASCII	=>	A_op_in <= op_bin2ascii;
					when others 			=>
				end case;
			
			when TYPE_2 =>
				LN <= '1';
				case IR_reg(5 downto 0) is
					when JMP_UNCOND 		=>	Jump_in 	<= '1';
					when JMP_COND 			=>	JumpC_in <= '1';
					when others				=>
				end case;
				
			when TYPE_3 =>
				case IR_reg(5 downto 0) is
					-- LD entre registros.
					when LD&SRC_ACC&DST_A		=>	A_op_in <= op_mvacc2a;
					when LD&SRC_ACC&DST_B		=>	A_op_in <= op_mvacc2b;
					when LD&SRC_ACC&DST_INDX	=>	A_op_in <= op_mvacc2id;
					
					-- LD en registros desde dato literal.
					when LD&SRC_CONSTANT&DST_A		=>	A_op_in <= op_lda;
																LN <= '1';
					when LD&SRC_CONSTANT&DST_B		=>	A_op_in <= op_ldb;
																LN <= '1';
					when LD&SRC_CONSTANT&DST_ACC	=>	A_op_in <= op_ldacc;
																LN <= '1';
					when LD&SRC_CONSTANT&DST_INDX	=>	A_op_in <= op_ldid;
																LN <= '1';
					-- LD en registros desde dirección de memoria literal.
					when LD&SRC_MEM&DST_A		=>	A_op_in <= op_lda;
															LN <= '1';
															D_valid_in <= '0';
															D_ctl_in <= "101";
					when LD&SRC_MEM&DST_B		=>	A_op_in <= op_ldb;
															LN <= '1';
															D_valid_in <= '0';
															D_ctl_in <= "101";
					when LD&SRC_MEM&DST_ACC		=>	A_op_in <= op_ldacc;
															LN <= '1';
															D_valid_in <= '0';
															D_ctl_in <= "101";
					when LD&SRC_MEM&DST_INDX	=>	A_op_in <= op_ldid;
															LN <= '1';
															D_valid_in <= '0';
															D_ctl_in <= "101";
					-- LD en registros desde dirección de memoria indexada.
					when LD&SRC_INDXD_MEM&DST_A		=>	A_op_in <= op_lda;
																	LN <= '1';
																	IDN <= '1';
																	D_valid_in <= '0';
																	D_ctl_in <= "101";
					when LD&SRC_INDXD_MEM&DST_B		=>	A_op_in <= op_ldb;
																	LN <= '1';
																	IDN <= '1';
																	D_valid_in <= '0';
																	D_ctl_in <= "101";
					when LD&SRC_INDXD_MEM&DST_ACC	=>		A_op_in <= op_ldacc;
																	LN <= '1';
																	IDN <= '1';
																	D_valid_in <= '0';
																	D_ctl_in <= "101";
					when LD&SRC_INDXD_MEM&DST_INDX	=>	A_op_in <= op_ldid;
																	LN <= '1';
																	IDN <= '1';
																	D_valid_in <= '0';
																	D_ctl_in <= "101";
					-- WR desde registro ACC en memoria literal.
					when WR&SRC_ACC&DST_MEM		=>	A_op_in <= op_oeacc;
															LN <= '1';
															D_valid_in <= '0';
															D_ctl_in <= "110";
					-- WR desde registro ACC en memoria indexada.
					when WR&SRC_ACC&DST_INDXD_MEM		=>	A_op_in <= op_oeacc;
																	LN <= '1';
																	IDN <= '1';
																	D_valid_in <= '0';
																	D_ctl_in <= "110";
					when others =>
				end case;
				
			when TYPE_4 =>	
					start_send_in <= '1';
					
			when others =>
			
		end case;	
	end process;
	
	
		
		
	D_data_in <= LT_latch(7 downto 0);

	D_add_aux <= LT_latch(7 downto 0);
	D_add_aux_id <= LT_latch(7 downto 0) + ALU_Index;
	D_add_in <= D_add_aux_id when IDN = '1'
					else D_add_aux;
	
	-- Execute Stage Logic:
	jumping <= Jump_reg or (JumpC_reg and Flag_Z);
	
	process(Clk, Reset)
	begin
		if Reset = '0' then
			NVD_reg <= '0';
		elsif Clk'event and Clk = '1' then
			if FF_enable = '1' then
				NVD_reg <= jumping;
			end if;
		end if;
	end process;
	
	ALU_Operation <= A_op_reg when NVD_reg = '0'
						  else nop; 
	
	Databus <= D_data_reg(7 downto 0) when (D_valid_reg = '1' and BR = '0')
				  else (others => 'Z');
						  
	RAM_Address_i <= D_add_reg;
	RAM_Address <= RAM_Address_i when BR = '0'
						  else (others => 'Z');
	
	RAM_CS_i <= D_ctl_reg(2) when NVD_reg = '0'
				 else '0';		 
	RAM_CS <= RAM_CS_i when BR = '0'
				 else 'Z';
   RAM_WE_i <= D_ctl_reg(1) when NVD_reg = '0'
				 else '0';
	RAM_WE <= RAM_WE_i when BR = '0'
				 else 'Z';
   RAM_OE_i <= D_ctl_reg(0) when NVD_reg = '0'
				 else '0';
	RAM_OE <= RAM_OE_i when BR = '0'
				 else 'Z';
				 
	-- FSM Send/DMA Ack Controller:
	process(Clk, Reset)
	begin
		if Reset <= '0' then
			FSM_now <= idle;
		elsif Clk'event and Clk = '1' then
			FSM_now <= FSM_next;
		end if;
	end process;
	
	process(FSM_now, start_send_reg, DMA_Ready, DMA_RQ)
	begin
		BR <= '0';
		FF_enable <= '1';
		
		Send <= '0';
		DMA_ACK <= '0';
		
		case FSM_now is
			when idle =>
				if start_send_reg = '1' then
					FSM_next <= SND_free;
				elsif DMA_RQ = '1' then
					FSM_next <= DMA_wait_non_jumpc;
				else
					FSM_next <= idle;
				end if;
				
			when SND_free =>
				FF_enable <= '0';
				
				Send <= '1';
				if DMA_Ready <= '0' then
					FSM_next <= SND_wait;
				else
					FSM_next <= SND_free;
				end if;
	
			when SND_wait =>
				BR <= '1';
				FF_enable <= '0';
				
				Send <= '1';
				if DMA_Ready <= '1' then
					FSM_next <= SND_catch;
				else
					FSM_next <= SND_wait;
				end if;
	
			when SND_catch =>
				BR <= '1';
				FF_enable <= '0';
				
				Send <= '0';

				FSM_next <= idle;
				
			when DMA_wait_non_jumpc =>
				if JumpC_in = '1' then
					FSM_next <= DMA_wait_non_jumpc;
				else
					FSM_next <= DMA_free;
				end if;
				
			when DMA_free =>
				DMA_ACK <= '1';

				FSM_next <= DMA_wait;

	
			when DMA_wait =>
				BR <= '1';
				FF_enable <= '0';
				
				DMA_ACK <= '1';
				if DMA_RQ <= '0' then
					FSM_next <= DMA_catch;
				else
					FSM_next <= DMA_wait;
				end if;
	
			when DMA_catch =>
				BR <= '1';
				FF_enable <= '0';
				
				DMA_ACK <= '0';

				FSM_next <= idle;
		end case;
	end process;

end pipelined;

