library IEEE;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity alu is
	port(state:in std_logic_vector(4 downto 0);
        inp1,inp2: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sel: in std_logic_vector(1 downto 0);
		  outp: out std_logic_vector(15 downto 0);
		  cout: out std_logic;
		  zero: out std_logic);
end entity;

architecture behave of alu is
    signal tempout:std_logic_vector(15 downto 0);
begin
    process(state,inp1,inp2,cin,sel)
    begin
        report "called";
        if(sel = "00") then
            report "add:"&integer'image(to_integer(unsigned(inp1)))&", "&integer'image(to_integer(unsigned(inp2)));
            tempout<=inp1+inp2;--TODO:take in cin.
            cout<='1';--TODO fix this with real adder
        else
            report "udb";
        end if;
	end process;	
    process(tempout)
    begin
        report "tout:"&integer'image(to_integer(unsigned(tempout)));
        outp<=tempout;
        if(tempout = "0000000000000000") then
            zero<='1';
        else
            zero<='0';
        end if;
    end process;
end behave;