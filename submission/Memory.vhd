library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 
entity Memory is 
  port (state : in std_logic_vector(3 downto 0);
		init: in std_logic;  
		mw  : in std_logic;
		mr  : in std_logic;   
        dataPointer   : in std_logic_vector(7 downto 0);   
        di  : in std_logic_vector(15 downto 0);   
        do  : out std_logic_vector(15 downto 0));  
end entity; 

architecture membehave of memory is 
	type RAM is array(0 to ((256)-1)) of std_logic_vector(15 downto 0);
	signal storage: RAM;
	begin
	process(init,mr,mw,dataPointer,storage)
		begin 
			report "dataPointer:"&integer'image(to_integer(unsigned(dataPointer)));
			if (init = '1') then
				storage(0) <= "0011000000000100"; -- LHI R0, 000000100
				storage(1) <= "0011001000000010"; -- LHI R1, 000000010
				storage(2) <= "0001000001010000"; -- ADD R2 <- R1+R0
				storage(3) <= "0000000001000001"; -- ADDI R1 <- 000001+R0
				storage(4) <= "0111010001000001"; -- SW R2 -> M[R1+000001] 
				storage(5) <= "0101011001000001"; -- LW R3 <- M[R1+000001]
				storage(6) <= "1000010011000100"; -- BEQ R2,R3 to PC+000100;				
				storage(10) <= "1001100000000010"; -- JAL R4, 0...000010;
				storage(12) <= "0010000001010000"; -- NND R2 <- R1 nand R0
				storage(13) <= "0100000001010000"; -- OC_TER

				-- storage(0) <= "1011000000000011"; -- JRI R0,000011;
				-- storage(0) <= "1010011000000000"; -- JLR R3, R0;
				-- storage(0) <= "1101001010100011"; -- LM R1, 10100011;
				-- storage(0) <= "1100001010100011"; -- SM R1, 10100011;
				
				-- storage(3) <= "0000000000000100"; 
				-- storage(1) <= "0000000001100000"; -- ADDI R1 <- 100000+R0
				-- storage(4) <= "0000000000001001"; -- 9
				-- storage(5) <= "0000000000001010"; -- 10
				-- storage(6) <= "0000000000001011"; -- 11
				-- storage(7) <= "0000000000001100"; -- 12
				

			elsif (mr = '1') then
				do <= storage(to_integer(unsigned(dataPointer)));
			end if;
			if (mw = '1') then
				report "memwr:"&integer'image(to_integer(unsigned(dataPointer)));
				storage(to_integer(unsigned(dataPointer))) <= di;
			end if;
	end process; 
	end membehave;