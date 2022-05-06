library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 
entity memory is 
  port (state : in std_logic_vector(3 downto 0);
		  init: in std_logic;  
        mr  : in std_logic;   
        mw  : in std_logic;
        addr   : in std_logic_vector(15 downto 0);   
        di  : in std_logic_vector(15 downto 0);   
        do  : out std_logic_vector(15 downto 0));  
end entity; 

architecture memory_behave of memory is 
	type RAM is array(0 to ((16)-1)) of std_logic_vector(15 downto 0);
	signal mem_reg: RAM;
	begin
	process(init,mr,mw,addr,mem_reg)
		begin 
			report "addr:"&integer'image(to_integer(unsigned(addr)));
			if (init = '1') then
				mem_reg(0) <= "0011000000000100"; -- LHI R0, 000000100
				mem_reg(1) <= "0011001000000010"; -- LHI R1, 000000010
				mem_reg(2) <= "0001000001010000"; -- ADD R2 <- R1+R0
				mem_reg(3) <= "0000000001000001"; -- ADDI R1 <- 000001+R0
				mem_reg(4) <= "0111010001000001"; -- SW R2 -> M[R1+000001] 
				mem_reg(5) <= "0101011001000001"; -- LW R3 <- M[R1+000001]
				mem_reg(6) <= "1000010011000100"; -- BEQ R2,R3 to PC+000100;				
				mem_reg(10) <= "1001100000000010"; -- JAL R4, 0...000010;
				mem_reg(12) <= "0010000001010000"; -- NND R2 <- R1 nand R0
				mem_reg(13) <= "0100000001010000"; -- OC_TER

				-- mem_reg(0) <= "1011000000000011"; -- JRI R0,000011;
				-- mem_reg(0) <= "1010011000000000"; -- JLR R3, R0;
				-- mem_reg(0) <= "1101001010100011"; -- LM R1, 10100011;
				-- mem_reg(0) <= "1100001010100011"; -- SM R1, 10100011;
				
				-- mem_reg(3) <= "0000000000000100"; 
				-- mem_reg(1) <= "0000000001100000"; -- ADDI R1 <- 100000+R0
				-- mem_reg(4) <= "0000000000001001"; -- 9
				-- mem_reg(5) <= "0000000000001010"; -- 10
				-- mem_reg(6) <= "0000000000001011"; -- 11
				-- mem_reg(7) <= "0000000000001100"; -- 12
				

			elsif (mr = '1') then
				do <= mem_reg(to_integer(unsigned(addr(3 downto 0))));
			end if;
			if (mw = '1') then
				report "memwr:"&integer'image(to_integer(unsigned(addr)));
				mem_reg(to_integer(unsigned(addr(3 downto 0)))) <= di;
			end if;
--		end if;
	end process; 
	end memory_behave;