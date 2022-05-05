library IEEE;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity alu is
    --TODO add input signal to prevent zeroflag,carryflag if pc update from modification.
	port(state:in std_logic_vector(4 downto 0);
        inp1,inp2: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sel: in std_logic_vector(1 downto 0);
		  outp: out std_logic_vector(15 downto 0);
		  cout: out std_logic;
		  zero: out std_logic);
end entity;

architecture behave of alu is
    component SixteenBitRCA is
		port(xin,yin: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sum: out std_logic_vector(15 downto 0);
		  cout: out std_logic);
	end component;
    signal tempout:std_logic_vector(15 downto 0);
    signal sumout:std_logic_vector(15 downto 0);
begin
    adder:SixteenBitRCA port map(xin=>inp1,yin=>inp2,cin=>cin,sum=>sumout,cout=>cout);
    process(inp1,inp2,cin,sel,sumout)
    begin
        report "inputs: "&integer'image(to_integer(unsigned(inp1)))&","&integer'image(to_integer(unsigned(inp2)));
        if(sel = "00") then
            tempout<=sumout;
        elsif( sel = "01") then
            tempout<=not (inp1 and inp2);
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