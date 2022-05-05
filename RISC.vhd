library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity RISC is
    port (
        clk:in std_logic;
        outstates:out std_logic_vector(9 downto 0)
    );
end entity RISC;
architecture rtl of RISC is
---constants
	constant ST_INIT:std_logic_vector(4 downto 0)	:="00000";
	constant ST_HK:std_logic_vector(4 downto 0)		:="00001";
	constant ST_ID:std_logic_vector(4 downto 0)		:="00010";
	constant ST_LWSW:std_logic_vector(4 downto 0)	:="00011";
	constant ST_LWRD:std_logic_vector(4 downto 0)	:="00100";
	constant ST_SWWR:std_logic_vector(4 downto 0)	:="00101";
	constant ST_LWWR:std_logic_vector(4 downto 0)	:="00110";
	constant ST_ADDI:std_logic_vector(4 downto 0)	:="00111";
	constant ST_ADDIWB:std_logic_vector(4 downto 0)	:="01000";
	constant ST_NND:std_logic_vector(4 downto 0)	:="01001";
	constant ST_ADDRG:std_logic_vector(4 downto 0)	:="01010";
	constant ST_RGWB:std_logic_vector(4 downto 0)	:="01011";
	constant ST_S12:std_logic_vector(4 downto 0)	:="01100";
	constant ST_LHI:std_logic_vector(4 downto 0)	:="01101";
	constant ST_JCMD:std_logic_vector(4 downto 0)	:="01110";
	constant ST_PSTJCMD:std_logic_vector(4 downto 0):="01111";
	constant ST_PSTJAL:std_logic_vector(4 downto 0)	:="10000";
	constant ST_PSTJLR:std_logic_vector(4 downto 0)	:="10001";
	constant ST_LMSM:std_logic_vector(4 downto 0)	:="10010";
	constant ST_LMRD:std_logic_vector(4 downto 0)	:="10011";
	constant ST_SM1:std_logic_vector(4 downto 0)	:="10100";
	constant ST_LMWB:std_logic_vector(4 downto 0)	:="10101";
	constant ST_SMW:std_logic_vector(4 downto 0)	:="10110";
	constant ST_LMSMTR:std_logic_vector(4 downto 0)	:="10111";
	constant ST_SMLP:std_logic_vector(4 downto 0)	:="11000";
----
---components
    component registerfile is port(
		state : in std_logic_vector(4 downto 0);
		dinm : in std_logic_vector(15 downto 0);  
	  	regsela : in std_logic_vector(2 downto 0);
		regselb	: in std_logic_vector(2 downto 0);
		regselm : in std_logic_vector(2 downto 0);
		regwrite : in std_logic;
		douta : out std_logic_vector(15 downto 0);
		doutb : out std_logic_vector(15 downto 0) );
    end component;
    component alu is
        port(inp1,inp2: in std_logic_vector(15 downto 0);
              cin: in std_logic;
              sel: in std_logic_vector(1 downto 0);
              outp: out std_logic_vector(15 downto 0);
              cout: out std_logic;
              zero: out std_logic);
    end component;
    component memory is 
        port (state : in std_logic_vector(4 downto 0);
                init: in std_logic;  
              mr  : in std_logic;   
              mw  : in std_logic;
              addr   : in std_logic_vector(15 downto 0);   
              di  : in std_logic_vector(15 downto 0);   
              do  : out std_logic_vector(15 downto 0));  
      end component;
---
      signal state:std_logic_vector(4 downto 0):=ST_INIT;
    signal nextState:std_logic_vector(4 downto 0):=ST_HK;
---memory signals 
    signal memInit,memRead,memWrite:std_logic;
    signal memAddr,memDataIn,memDataOut:std_logic_vector(15 downto 0);
    signal memMux:std_logic;
---
---register file signals
    signal rfDataIn,rfDataOut1,rfDataOut2:std_logic_vector(15 downto 0);
    signal rfWrite:std_logic:='0';
    signal rfSel1,rfSel2,rfSelW:std_logic_vector(2 downto 0);
---
---aLU signals
    signal aluZeroFlag,aluCarryFlag:std_logic;
    signal aluIn1,aluIn2,aluOut:std_logic_vector(15 downto 0);
    signal aluCin:std_logic;
    signal aluSel:std_logic_vector(1 downto 0);
    signal aluIn1Mux,aluIn2Mux:std_logic_vector(2 downto 0);
---
begin
    mem:memory port map(state=>state,init=>memInit,mr=>memRead,mw=>memWrite,addr=>memAddr,di=>memDataIn,do=>memDataOut);
    rf:registerfile port map(state=>state,dinm=>rfDataIn,regsela=>rfSel1,regselb=>rfSel2, regselm=>rfSelW,regwrite=>rfWrite,douta=>rfDataOut1,doutb=>rfDataOut2);
    aluInst:ALU port map(inp1=>aluIn1,inp2=>aluIn2,cin=>aluCin,sel=>aluSel,outp=>aluOut,cout=>aluCarryFlag,zero=>aluZeroFlag);
    process(clk)
    begin
        if(rising_edge(clk)) then
            state<=nextState;
        end if;
    end process;
    process(state)
    begin
        if(state = ST_INIT) then
            memInit<='1';
            memRead<='0';
            memWrite<='0';
            rfSelW<="111";
            rfDataIn<=(others=>'0');
            rfWrite<='1';
            nextState<=ST_HK;
        elsif (state = ST_HK) then
            rfWrite<='0';
            rfSel1<="111";            
            memInit<='0';
            memRead<='1';

            
        end if;
    end process;

    process(state,nextState)
    begin
        outstates(9 downto 5) <= nextState;
        outstates(4 downto 0) <= state;
    end process;
    process(memMux)
    begin
        if(memMux = '0') then
            memAddr<=rfSel1;
        elsif (memMux = '1') then
            memAddr<=aluOut;
        else
            report "udb";
        end if;
    end process;
end architecture rtl;