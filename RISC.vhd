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
	constant ST_IF:std_logic_vector(4 downto 0)		:="11001";
    constant ST_WBTR:std_logic_vector(4 downto 0)   :="11010";
    constant ST_ADDL:std_logic_vector(4 downto 0)   :="11011";

    constant OC_ADDR:std_logic_vector(3 downto 0)	:="0001";
	constant OC_ADDI:std_logic_vector(3 downto 0)	:="0000";
	constant OC_NND:std_logic_vector(3 downto 0)	:="0010";
	constant OC_LHI:std_logic_vector(3 downto 0)	:="0011";
	constant OC_LW:std_logic_vector(3 downto 0)		:="0101";
	constant OC_SW:std_logic_vector(3 downto 0)		:="0111";
	constant OC_LM:std_logic_vector(3 downto 0)		:="1101";
	constant OC_SM:std_logic_vector(3 downto 0)		:="1100";
	constant OC_JAL:std_logic_vector(3 downto 0)	:="1001";
	constant OC_JLR:std_logic_vector(3 downto 0)	:="1010";
    constant OC_JRI:std_logic_vector(3 downto 0)    :="1011";
	constant OC_BEQ:std_logic_vector(3 downto 0)	:="1000";
	
    
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
        port(state:in std_logic_vector(4 downto 0);
		  inp1,inp2: in std_logic_vector(15 downto 0);
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
    component IR is 
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
    end component;
---
      signal state:std_logic_vector(4 downto 0):=ST_INIT;
    signal nextState:std_logic_vector(4 downto 0):=ST_HK;
---memory signals 
    signal memInit,memRead,memWrite:std_logic;
    signal memAddr,memDataIn,memDataOut:std_logic_vector(15 downto 0);
    signal memInMux:std_logic;
    signal memOutDemux:std_logic;
    signal tempMemData:std_logic_vector(15 downto 0);
---
---instr reg signals
    signal tempInstr:std_logic_vector(15 downto 0);
    signal irW:std_logic;
    signal opCode:std_logic_vector(3 downto 0);
    signal imm6:std_logic_vector(5 downto 0);
    signal raSel:std_logic_vector(2 downto 0);
    signal rbSel:std_logic_vector(2 downto 0); 
    signal rcSel:std_logic_vector(2 downto 0); 
    signal czVal:std_logic_vector(1 downto 0);
    signal imm9:std_logic_vector(8 downto 0);
    signal imm8:std_logic_vector(7 downto 0);
    signal imm6_16,imm9_16low,imm9_16high,imm8_16:std_logic_vector(15 downto 0);
---
---register file signals
    signal rfDataIn,rfDataOut1,rfDataOut2:std_logic_vector(15 downto 0);
    signal rfWrite:std_logic:='0';
    signal rfSel1,rfSel2,rfSelW:std_logic_vector(2 downto 0);
---
---aLU signals
    signal aluZeroFlag,aluCarryFlag:std_logic;
    signal aluIn1,aluIn2,aluOut:std_logic_vector(15 downto 0);
    signal aluCin:std_logic:='0';
    signal aluSel:std_logic_vector(1 downto 0);
    signal aluIn1Mux,aluIn2Mux:std_logic_vector(2 downto 0);
---
begin
    mem:memory port map(state=>state,init=>memInit,mr=>memRead,mw=>memWrite,addr=>memAddr,di=>memDataIn,do=>memDataOut);
    rf:registerfile port map(state=>state,dinm=>rfDataIn,regsela=>rfSel1,regselb=>rfSel2, regselm=>rfSelW,regwrite=>rfWrite,douta=>rfDataOut1,doutb=>rfDataOut2);
    aluInst:ALU port map(state=>state,inp1=>aluIn1,inp2=>aluIn2,cin=>aluCin,sel=>aluSel,outp=>aluOut,cout=>aluCarryFlag,zero=>aluZeroFlag);
    irInst:IR port map(irwrite=>irw,inp=>tempInstr,opcode=>opCode,immediate6=>imm6,immediate8=>imm8,immediate9=>imm9,ra=>raSel,rb=>rbSel,rc=>rcSel,cz=>czVal);
    process(clk)
        begin
            if(rising_edge(clk)) then
                state<=nextState;
                report "oc:"&integer'image(to_integer(unsigned(opCode)));
            end if;
    end process;
    process(state)
        begin
            if(state = ST_INIT) then
                report "rfd1"&integer'image(to_integer(unsigned(rfDataOut1)));
                --initialize memory contents
                memInit<='1';
                memRead<='0';
                memWrite<='0';
                ---initialize pc to 0:
                rfSelW<="111";
                rfDataIn<=(others=>'0');
                rfWrite<='1';
                nextState<=ST_HK;
            elsif (state = ST_HK) then
                memInit<='0';
                memRead<='1';
                memWrite<='0';
                rfWrite<='0';
                rfSel1<="111";
                memInMux<='1';
                nextState<=ST_IF;
            elsif (state = ST_IF) then
                aluIn2Mux<="001";
                aluSel<="00";
                irw<='1';
                tempInstr<=memDataOut;
                nextState<=ST_ID;
            elsif (state=ST_ID) then
                report "oc nc:"&integer'image(to_integer(unsigned(opcode)));
                rfSelW<="111";
                rfDataIn<=aluOut;
                rfWrite<='1';
                nextState<=ST_HK;
                if(opCode = OC_ADDR) then
                    report "oc: addR";
                    rfWrite<='0';
                    rfSel1<=raSel;
                    rfSel2<=rbSel;
                    rfSelW<=rcSel;
                    aluSel<="00";--addition selected
                    if(czVal = "00") then
                        nextState<=ST_WBTR;--last state
                        aluIn2Mux<="000";--rfDataOut2 goes into alu
                    elsif (czVal = "01" and aluZeroFlag = '1') then
                        nextState<=ST_WBTR;--last state
                        aluIn2Mux<="000";--rfDataOut2 goes into alu
                    elsif (czVal = "10" and aluCarryFlag = '1') then
                        nextState<=ST_WBTR;
                        aluIn2Mux<="000";--rfDataOut2 goes into alu
                    elsif (czVal = "11") then
                        aluIn2Mux<="010";--left shifted rfDataOut2 goes into alu
                        nextState<=ST_WBTR;
                    else
                        nextState<=ST_HK;
                    end if;
                elsif (opCode = OC_ADDI) then
                    report "oc: addI";
                    rfWrite<='0';
                    rfSel1<=raSel;
                    rfSelW<=rbSel;
                    aluIn2Mux<="011";
                    aluSel<="00";
                    nextState<=ST_WBTR;
                elsif (opCode = OC_NND) then
                    report "oc: NND";
                    rfWrite<='0';
                    rfSel1<=raSel;
                    rfSel2<=rbSel;
                    rfSelW<=rcSel;
                    aluSel<="01";--nand selected
                    aluIn2Mux<="000";
                    if(czVal = "00") then
                        nextState<=ST_WBTR;--last state
                    elsif (czVal = "01" and aluZeroFlag = '1') then
                        nextState<=ST_WBTR;--last state
                    elsif (czVal = "10" and aluCarryFlag = '1') then
                        nextState<=ST_WBTR;
                    else
                        nextState<=ST_HK;
                    end if;
                    nextState<=ST_WBTR;
                elsif (opCode = OC_LHI) then
                    report "oc: LHI";

                elsif (opCode = OC_LW) then
                    report "oc: LW";

                elsif (opCode = OC_SW) then
                    report "oc: SW";
                
                elsif (opCode = OC_LM) then
                    report "oc: LM";
                
                elsif (opCode = OC_SM) then
                    report "oc: SM";
                
                elsif (opCode = OC_BEQ) then
                    report "oc: BEQ";
                
                elsif (opCode = OC_JAL) then
                    report "oc: JAL";
                elsif (opCode = OC_JLR) then
                    report "oc: JLR";

                elsif (opCode = OC_JRI) then
                    report "oc: JRI";
                else
                    report "op code not matched";
                end if;
            elsif (state = ST_WBTR) then
                rfDataIn<=aluOut;
                rfWrite<='1';
                nextState<=ST_HK;
            end if;
    end process;
    process(memInMux,rfDataOut1,aluOut)
        begin
            if(memInMux = '0') then
                memAddr<=rfDataOut1;
            elsif (memInMux = '1') then
                memAddr<=aluOut;
            else
                report "udb";
            end if;
    end process;
    process(aluIn1Mux,aluIn2Mux,rfDataOut1,rfDataOut2)
        begin
            report"aluin1: "&integer'image(to_integer(unsigned(rfDataOut1)));
            aluIn1<=rfDataOut1;
            if(aluIn2Mux = "000") then
                aluIn2<=rfDataOut2;
            elsif (aluIn2Mux = "001") then
                aluIn2<=(0=>'1',others=>'0');
            elsif (aluIn2Mux = "010") then --left shift rfDataOut2 before sending to ALU
                aluIn2<=std_logic_vector(shift_left(unsigned(rfDataOut2),1)) ;
            elsif (aluIn2Mux = "011") then
                aluIn2<=imm6_16;
            else
                report "udb";
            end if;
    end process;
    -- process(memDataOut)
    --     begin
    --         if(memOutDemux = '0') then
    --             irw<='1';
    --             tempInstr<=memDataOut;
    --         else
    --             tempMemData<=memDataOut;
    --         end if;
    -- end process;
    process(state,nextState)
        begin
            outstates(9 downto 5) <= nextState;
            outstates(4 downto 0) <= state;
    end process;
    process(imm9)
        begin
            imm9_16high(15 downto 7)<=imm9;
            imm9_16high(5 downto 0)<=(others=>'0');
            imm9_16low(8 downto 0)<=imm9;
            imm9_16low(15 downto 9)<=(others=>'0');
    end process;
    process(imm8)
        begin
            imm8_16(7 downto 0)<=imm8;
            imm8_16(15 downto 8)<=(others=>'0');
    end process;
    process(imm6)
        begin
            imm6_16(5 downto 0)<=imm6;
            imm6_16(15 downto 6)<=(others=>'0');
    end process;

end architecture rtl;