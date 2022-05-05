library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity registerfile is    
  port(
		state : in std_logic_vector(4 downto 0);
		dinm : in std_logic_vector(15 downto 0);  
	  	regsela : in std_logic_vector(2 downto 0);
		regselb	: in std_logic_vector(2 downto 0);
		regselm : in std_logic_vector(2 downto 0);
		regwrite : in std_logic;
		douta : out std_logic_vector(15 downto 0);
		doutb : out std_logic_vector(15 downto 0) );
end entity;

architecture behave of registerfile is

type t_Memory is array (0 to 7) of std_logic_vector(15 downto 0);
signal data : t_Memory := (0=>(0=>'1',1=>'1',2=>'1',others=>'0'),1=>(0=>'1',others=>'0'),others => (others => '0'));

begin
	---sensitive to all input vars => immediate response.
	process(state,regsela,regselb,regwrite,regselm,dinm)
	begin 
		for x in 0 to 7 loop
			report "reg"&integer'image(x)&" = "&integer'image(to_integer(unsigned(data(x))));
		end loop;
			if(regwrite = '1') then
				report "regwrite:"&integer'image(to_integer(unsigned(dinm)));
				--transfer the data from the register to
				if(regselm = "111") then
					data(7) <= dinm;
				elsif(regselm = "110") then
					data(6) <= dinm;
				elsif(regselm = "101") then
					data(5) <= dinm;
				elsif(regselm = "100") then
					data(4) <= dinm;
				elsif(regselm = "011") then
					data(3) <= dinm;
				elsif(regselm = "010") then
					data(2) <= dinm;
				elsif(regselm = "001") then
					data(1) <= dinm;
				elsif(regselm = "000") then
					data(0) <= dinm;
				end if;
			end if;
			
			if(regsela = "111") then
					douta <= data(7);
			elsif(regsela = "110") then
					douta <= data(6);
			elsif(regsela = "101") then
					douta <= data(5);
			elsif(regsela = "100") then
					douta <= data(4);
			elsif(regsela = "011") then
					douta <= data(3);
			elsif(regsela = "010") then
					douta <= data(2);
			elsif(regsela = "001") then
					douta <= data(1);
			elsif(regsela = "000") then
					douta <= data(0);
			end if;

			if(regselb = "111") then
					doutb <= data(7);
			elsif(regselb = "110") then
					doutb <= data(6);
			elsif(regselb = "101") then
					doutb <= data(5);
			elsif(regselb = "100") then
					doutb <= data(4);
			elsif(regselb = "011") then
					doutb <= data(3);
			elsif(regselb = "010") then
					doutb <= data(2);
			elsif(regselb = "001") then
					doutb <= data(1);
			elsif(regselb = "000") then
					doutb <= data(0);
			end if;	
	end process;
end behave;