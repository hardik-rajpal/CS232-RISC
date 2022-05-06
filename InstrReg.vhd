library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity InstrReg is
	port(
        opCode: out std_logic_vector(3 downto 0);
        irw: in std_logic;
        inp: in std_logic_vector(15 downto 0);
        immed6: out std_logic_vector(5 downto 0);
        immed9: out std_logic_vector(8 downto 0);
        immed8: out std_logic_vector(7 downto 0) 
        ra: out std_logic_vector(2 downto 0);
        rb: out std_logic_vector(2 downto 0);
        rc: out std_logic_vector(2 downto 0);
        cz: out std_logic_vector(1 downto 0);
		  );

end entity;


architecture behave of InstrReg is
    signal instr:std_logic_vector(15 downto 0):="0000000000000000";

begin
    process(irw,inp)
        begin
            if(irw = '1') then
                instr<=inp;
                report "instr:"&integer'image(to_integer(unsigned(inp)));
            else
                report "instr not in InstrReg. irw != 1";
            end if;
    end process;
    process(instr)
        begin
            opcode <= instr(15 downto 12);
            ra <= instr(11 downto 9);
            rb <= instr(8 downto 6);
            rc <= instr(5 downto 3);
            immed6 <= instr(5 downto 0);
            cz <= instr(1 downto 0);
            immed9 <= instr(8 downto 0);
            immed8 <= instr(7 downto 0);
    end process;
end behave;