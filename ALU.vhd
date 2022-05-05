library IEEE;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity alu is
	port(inp1,inp2: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sel: in std_logic_vector(1 downto 0);
		  outp: out std_logic_vector(15 downto 0);
		  cout: out std_logic;
		  zero: out std_logic);
end entity;

architecture behave of alu is
    signal tempout:std_logic_vector(15 downto 0);
begin
    process(inp1,inp2,cin,sel)
    begin
        if(sel = "00") then
            tempout<=inp1+inp2;--TODO:take in cin.
            cout<='1';--TODO fix this with real adder
        else
            report "udb";
        end if;
	end process;	
    process(tempout)
    begin
        outp<=tempout;
        if(tempout = "0000000000000000") then
            zero<='1';
        else
            zero<='0';
        end if;
    end process;
end behave;