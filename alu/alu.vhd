-------------------------------------------------------------------------------
-- Author: 	Aragonés Orellana, Silvia
--				García Garcia, Ruy

-- Project Name: 	PIC 
-- Design  Name: 	alu.vhd
-- Module  Name:	alu.vhd
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed.all;

use work.PIC_pkg.all;

entity alu is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           u_instruction : in  alu_op;
           FlagZ : out  STD_LOGIC;
           FlagC : out  STD_LOGIC;
           FlagN : out  STD_LOGIC;
           FlagE : out  STD_LOGIC;
           Index : out  STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0));
end alu;

architecture rtl of alu is
	
	signal A, B, ACC, IND : std_logic_vector(7 downto 0);
	signal A_enable, B_enable, ACC_enable, IND_enable : std_logic;
	signal a_in, b_in, acc_in, ind_in : std_logic_vector(7 downto 0);
	
	signal FlagZ_reg, FlagC_reg, FlagN_reg, FlagE_reg : std_logic;
	signal FlagZ_in, FlagC_in, FlagN_in, FlagE_in : std_logic;
	
	signal sum_out, op0, op1 : std_logic_vector(7 downto 0);

begin

	process(Clk, Reset)
	begin
		if Reset = '0' then
			A <= X"00";
			B <= X"00";
			ACC <= X"00";
			IND <= X"00";
			FlagZ_reg <= '0';
			FlagC_reg <= '0';
			FlagN_reg <= '0';
			FlagE_reg <= '0';
		elsif Clk'event and Clk = '1' then
			if A_enable = '1' then
				A <= a_in;
			else
				A <= A;
			end if;
			
			if B_enable = '1' then
				B <= b_in;
			else
				B <= B;
			end if;
			
			if ACC_enable = '1' then
				ACC <= acc_in;
			else
				ACC <= ACC;
			end if;
			
			if IND_enable = '1' then
				IND <= ind_in;
			else
				IND <= IND;
			end if;
			
			FlagZ_reg <= FlagZ_in;
			FlagC_reg <= FlagC_in;
			FlagN_reg <= FlagN_in;
			FlagE_reg <= FlagE_in;

		end if;
	end process;
	
	process(u_instruction, Databus, A, B, ACC, sum_out)
	begin
		a_in <= X"00";
		b_in <= X"00";
		acc_in <= X"00";
		ind_in <= X"00";
		
		a_enable <= '0';
		b_enable <= '0';
		acc_enable <= '0';
		ind_enable <= '0';
		
		Databus <= (others => 'Z');
		
		case u_instruction is
			when nop =>
			when op_lda =>
				a_in <= Databus;
				a_enable <= '1';
			when op_ldb =>
				b_in <= Databus;
				b_enable <= '1';
			when op_ldacc =>
				acc_in <= Databus;
				acc_enable <= '1';
			when op_ldid =>
				ind_in <= Databus;
				ind_enable <= '1';
			
			when op_mvacc2id =>
				ind_in <= ACC;
				ind_enable <= '1';	
			when op_mvacc2a =>
				a_in <= ACC;
				a_enable <= '1';	
			when op_mvacc2b =>
				b_in <= ACC;
				b_enable <= '1';

			when op_add =>
				acc_in <= sum_out(7 downto 0);
				acc_enable <= '1';
			when op_sub =>
				acc_in <=sum_out(7 downto 0);
				acc_enable <= '1';
				
			when op_shiftl =>
				acc_in <= ACC(6 downto 0)&'0';
				acc_enable <= '1';
			when op_shiftr =>
				acc_in <= '0'&ACC(7 downto 1);
				acc_enable <= '1';
				
			when op_and =>
				for i in 7 downto 0 loop
					acc_in(i) <= A(i) and B(i);
				end loop;
				acc_enable <= '1';
			when op_or =>
				for i in 7 downto 0 loop
					acc_in(i) <= A(i) or B(i);
				end loop;
				acc_enable <= '1';
			when op_xor =>
				for i in 7 downto 0 loop
					acc_in(i) <= A(i) xor B(i);
				end loop;
				acc_enable <= '1';
				
			when op_ascii2bin =>
				acc_in <= sum_out(7 downto 0);
				acc_enable <= '1';
			when op_bin2ascii =>
				acc_in <= sum_out(7 downto 0);
				acc_enable <= '1';
				
			when op_oeacc => 
				Databus <= ACC;
			when others =>	
		end case;
	end process;
	
	process(u_instruction, A, B, acc_in, sum_out, op0, op1)
	begin
		FlagZ_in <= '0';
		FlagC_in <= '0';
		FlagN_in <= '0';
		FlagE_in <= '0';

		case u_instruction is
			when nop =>
			when op_add =>
				if acc_in = X"00" then
					FlagZ_in <= '1';
				end if;
				if (sum_out(7) = '1' and op0(7) = '0' and op1(7) = '0') or
					(sum_out(7) = '0' and op0(7) = '1' and op0(7) = '1') then
					FlagC_in <= '1';
				end if;
				if op0(3) = '1' and op1(3) = '1' then
					FlagN_in <= '1';
				end if;
			when op_sub =>
				if acc_in = X"00" then
					FlagZ_in <= '1';
				end if;
				if (sum_out(7) = '1' and op0(7) = '0' and op1(7) = '1') or
					(sum_out(7) = '0' and op0(7) = '1' and op1(7) = '0') then
					FlagC_in <= '1';
				end if;
				if op0(3) = '1' and op1(3) = '1' then
					FlagN_in <= '1';
				end if;
				
			when op_and => 
				if acc_in = X"00" then
					FlagZ_in <= '1';
				end if;
				
			when op_or => 
				if acc_in = X"00" then
					FlagZ_in <= '1';
				end if;	
			when op_xor => 
				if acc_in = X"00" then
					FlagZ_in <= '1';
				end if;
				
			when op_cmpe =>
				if A = B then
					FlagZ_in <= '1';
				end if;
			when op_cmpl =>
				if A < B then
					FlagZ_in <= '1';
				end if;
			when op_cmpg =>
				if A > B then
					FlagZ_in <= '1';
				end if;
				

			when op_ascii2bin =>
				if acc_in < X"00" or acc_in > X"09" then
					FlagE_in <= '1';
				end if;
			when op_bin2ascii =>
				if acc_in < X"30" or acc_in > X"39" then
					FlagE_in <= '1';
				end if;
			
			when others =>
		end case;
	end process;
	
	process(u_instruction, A, B)
	begin
		case u_instruction is
			when op_add =>
				op0 <= A(7 downto 0);
				op1 <= B(7 downto 0);
			when op_sub =>
				op0 <= A(7 downto 0);
				op1 <= (not B(7 downto 0)) + X"01";
			when op_ascii2bin =>
				op0 <= A(7 downto 0);
				op1 <= (not X"30") + X"01";
			when op_bin2ascii =>
				op0 <= A(7 downto 0);
				op1 <= X"30";
			when others => 
				op0 <= (others => '0');
				op1 <= (others => '0');
		end case;
	end process;
	
	sum_out <= op0 + op1;
	
	Index <= IND;
	
	FlagZ <= FlagZ_reg;
	FlagC <= FlagC_reg;
	FlagN <= FlagN_reg;
	FlagE <= FlagE_reg;
	
	

end rtl;

