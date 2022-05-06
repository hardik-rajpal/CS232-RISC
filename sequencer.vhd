library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 


entity sequencer is
	port( inregnum : in std_logic_vector (3 downto 0);
		  outregnum: out std_logic_vector(3 downto 0)
		);
end entity;

architecture behave of sequencer is

begin
    process(inregnum)
    begin
    case inregnum is
        when "0000" => outregnum<="0001";
        when "0001" => outregnum<="0010";
        when "0010" => outregnum<="0011";
        when "0011" => outregnum<="0100";
        when "0100" => outregnum<="0101";
        when "0101" => outregnum<="0110";
        when "0110" => outregnum<="0111";
        when "0111" => outregnum<="1000";
        when "1000" => outregnum<="0000";
		  when others => report "udb in seq";
		 end case;
    end process;
end architecture behave;