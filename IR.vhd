library ieee;

use ieee.std_logic_1164.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity ir is
	port(
		  irwrite: in std_logic;
		  inp: in std_logic_vector(15 downto 0);
		  opcode: out std_logic_vector(3 downto 0); -- 12-15
		  immediate6: out std_logic_vector(5 downto 0); --0-5
		  ra: out std_logic_vector(2 downto 0); --9-11
		  rb: out std_logic_vector(2 downto 0); --6-8
		  rc: out std_logic_vector(2 downto 0); --3-5
		  cz: out std_logic_vector(1 downto 0); --0-1 -- 0 is z and 1 is c
		  immediate9: out std_logic_vector(8 downto 0); --0-8
		  immediate8: out std_logic_vector(7 downto 0) --0-7
		  );

end entity;


architecture behave of ir is
    signal instr:std_logic_vector(15 downto 0):="0000000000000000";

begin
    process(irwrite,inp)
        begin
            if(irwrite = '1') then
                instr<=inp;
                report "instr:"&integer'image(to_integer(unsigned(inp)));
            else
                report "instr not in ir. irw != 1";
            end if;
    end process;
    process(instr)
        begin
            opcode <= instr(15 downto 12);
            ra <= instr(11 downto 9);
            rb <= instr(8 downto 6);
            rc <= instr(5 downto 3);
            immediate6 <= instr(5 downto 0);
            cz <= instr(1 downto 0);
            immediate9 <= instr(8 downto 0);
            immediate8 <= instr(7 downto 0);
    end process;
end behave;