library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 
entity memory is 
  port (state : in std_logic_vector(4 downto 0);
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
	process(state,init,mr,mw,addr)
		begin 
			report "addr:"&integer'image(to_integer(unsigned(addr)));
			if (init = '1') then
				mem_reg(0) <= "0011000101101010"; -- LHI R0, 101101010
				mem_reg(1) <= "0011001011010101"; -- LHI R1, 011010101
				mem_reg(2) <= "0011010101010111"; -- LHI R2, 101010111
				mem_reg(3) <= "0011011101010111"; -- LHI R3, 101010111
			elsif (mr = '1') then
				do <= mem_reg(to_integer(unsigned(addr(3 downto 0))));
			end if;
			if (mw = '1') then
				mem_reg(to_integer(unsigned(addr(3 downto 0)))) <= di;
			end if;
--		end if;
	end process; 
	end memory_behave;