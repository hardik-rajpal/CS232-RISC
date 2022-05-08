library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity RISC is
    port (
        clk:in std_logic;
        outstates:out std_logic_vector(7 downto 0)
    );
end entity RISC;
architecture rtl of RISC is
---constants
	constant ST_INIT:std_logic_vector(3 downto 0)	:="0000";
	constant ST_HK:std_logic_vector(3 downto 0)		:="0001";
	constant ST_UPD:std_logic_vector(3 downto 0)		:="0010";
	constant ST_MEMA:std_logic_vector(3 downto 0)	:="0011";
	constant ST_LMSM:std_logic_vector(3 downto 0)	:="0100";
	constant ST_LMRD:std_logic_vector(3 downto 0)	:="0101";
	constant ST_SM1:std_logic_vector(3 downto 0)	:="0110";
	constant ST_LMWB:std_logic_vector(3 downto 0)	:="0111";
	constant ST_SMW:std_logic_vector(3 downto 0)	:="1000";
	constant ST_IF:std_logic_vector(3 downto 0)		:="1001";
    constant ST_WBTR:std_logic_vector(3 downto 0)   :="1010";
    constant ST_EXE:std_logic_vector(3 downto 0)    :="1011";


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
	constant OC_TER:std_logic_vector(3 downto 0)    :="0100";
    
    ----
---components
    component registerfile is port(
		state : in std_logic_vector(3 downto 0);
		dinm : in std_logic_vector(15 downto 0);  
	  	regsela : in std_logic_vector(2 downto 0);
		regselb	: in std_logic_vector(2 downto 0);
		regselm : in std_logic_vector(2 downto 0);
		regwrite : in std_logic;
		douta : out std_logic_vector(15 downto 0);
		doutb : out std_logic_vector(15 downto 0) );
    end component;
    component alu is
        port(state:in std_logic_vector(3 downto 0);
		  inp1,inp2: in std_logic_vector(15 downto 0);
              cin: in std_logic;
              sel: in std_logic_vector(1 downto 0);
              outp: out std_logic_vector(15 downto 0);
              cout: out std_logic;
              zero: out std_logic);
    end component;
    component memory is 
        port (state : in std_logic_vector(3 downto 0);
                init: in std_logic;  
              mr  : in std_logic;   
              mw  : in std_logic;
              dataPointer   : in std_logic_vector(7 downto 0);   
              di  : in std_logic_vector(15 downto 0);   
              do  : out std_logic_vector(15 downto 0));  
      end component;
    component InstrReg is 
        port(
            irw: in std_logic;
            inp: in std_logic_vector(15 downto 0);
            opcode: out std_logic_vector(3 downto 0); -- 12-15
            immed6: out std_logic_vector(5 downto 0); --0-5
            ra: out std_logic_vector(2 downto 0); --9-11
            rb: out std_logic_vector(2 downto 0); --6-8
            rc: out std_logic_vector(2 downto 0); --3-5
            cz: out std_logic_vector(1 downto 0); --0-1 -- 0 is z and 1 is c
            immed9: out std_logic_vector(8 downto 0); --0-8
            immed8: out std_logic_vector(7 downto 0) --0-7
            );
    end component;
    component sequencer is
        port( inregnum : in std_logic_vector (3 downto 0);
        outregnum: out std_logic_vector(3 downto 0)
      );
    end component;
---
      signal state:std_logic_vector(3 downto 0):=ST_INIT;
    signal nextState:std_logic_vector(3 downto 0):=ST_HK;
---memory signals 
    signal memInit,memRead,memWrite:std_logic;
    signal memAddr:std_logic_vector(7 downto 0);
    signal memDataIn,memDataOut:std_logic_vector(15 downto 0);
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
---misc signals	
    signal tempData1:std_logic_vector(15 downto 0);
    signal tempData2:std_logic_vector(15 downto 0);
    signal prevPC:std_logic_vector(15 downto 0);
    signal index:std_logic_vector(15 downto 0):=(others=>'0');
    signal loadCurrent:std_logic:='0';
    signal lmsmAddr:std_logic_vector(15 downto 0);
---
---aLU signals
    signal aluZeroFlag,aluCarryFlag:std_logic;
    signal zeroFlagMux:std_logic:='0';
    signal zeroFlag:std_logic;
    signal lwZeroFlag:std_logic;
    signal aluIn1,aluIn2,aluOut:std_logic_vector(15 downto 0);
    signal aluCin:std_logic:='0';
    signal aluSel:std_logic_vector(1 downto 0);
    signal aluIn1Mux:std_logic_vector(1 downto 0):= "00";
    signal aluIn2Mux:std_logic_vector(2 downto 0);
---
---sequencer signals
    signal inRegNum,outRegNum:std_logic_vector(3 downto 0);
---
begin
    mem:memory port map(state=>state,init=>memInit,mr=>memRead,mw=>memWrite,dataPointer=>memAddr,di=>memDataIn,do=>memDataOut);
    rf:registerfile port map(state=>state,dinm=>rfDataIn,regsela=>rfSel1,regselb=>rfSel2, regselm=>rfSelW,regwrite=>rfWrite,douta=>rfDataOut1,doutb=>rfDataOut2);
    aluInst:ALU port map(state=>state,inp1=>aluIn1,inp2=>aluIn2,cin=>aluCin,sel=>aluSel,outp=>aluOut,cout=>aluCarryFlag,zero=>aluZeroFlag);
    irInst:InstrReg port map(irw=>irw,inp=>tempInstr,opcode=>opCode,immed6=>imm6,immed8=>imm8,immed9=>imm9,ra=>raSel,rb=>rbSel,rc=>rcSel,cz=>czVal);
    seq:sequencer port map(inregnum=>inRegNum,outregnum=>outRegNum);
    process(clk)
        begin
            if(rising_edge(clk)) then
                state<=nextState;
                report "oc:"&integer'image(to_integer(unsigned(opCode)));
            end if;
    end process;
    process(state)
        begin
            if (state = ST_INIT) then
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
                aluIn1Mux<="00";
                memRead<='1';
                memWrite<='0';
                rfWrite<='0';
                rfSel1<="111";
                memInMux<='0';
                nextState<=ST_IF;
            elsif (state = ST_IF) then
                prevPC<=rfDataOut1;
                aluIn2Mux<="001";
                aluSel<="00";
                irw<='1';
                tempInstr<=memDataOut;
                nextState<=ST_UPD;
            elsif (state = ST_UPD) then
                report "oc nc:"&integer'image(to_integer(unsigned(opcode)));
                rfSelW<="111";
                rfDataIn<=aluOut;
                rfWrite<='1';
                nextState<=ST_EXE;
            elsif (state = ST_EXE) then
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
                    rfSelW<=raSel;
                    rfDataIn<=imm9_16high;
                    rfWrite<='1';
                    nextState<=ST_HK;
                elsif (opCode = OC_LW) then
                    report "oc: LW";
                    rfSelW<=raSel;
                    rfSel1<=rbSel;
                    aluIn2Mux<="011";--imm6
                    aluSel<="00";
                    memInMux<='1';
                    nextState<=ST_WBTR;
                elsif (opCode = OC_SW) then
                    report "oc: SW";
                    rfSel1<=rbSel;--send to alu;
                    rfSel2<=raSel;
                    aluIn2Mux<="011";--imm6;
                    aluSel<="00";
                    memInMux<='1';
                    nextState<=ST_WBTR;
                elsif (opCode = OC_LM) then
                    report "oc: LM";
                    aluIn1Mux<="00";
                    rfSel1<=raSel;
                    inRegNum<="1000";---initialize outregnum to 0;
                    loadCurrent<='0';
                    aluIn2Mux<="111";
                    aluSel<="00";
                    nextState<=ST_LMSM;
                elsif (opCode = OC_SM) then
                    report "oc: SM";
                    aluIn1Mux<="00";
                    rfSel1<=raSel;
                    inRegNum<="1000";---initialize outregnum to 0;
                    loadCurrent<='0';
                    aluIn2Mux<="111";
                    aluSel<="00";
                    nextState<=ST_LMSM;
                elsif (opCode = OC_BEQ) then
                    report "oc: BEQ";
                    aluIn1Mux<="10";
                    aluIn2Mux<="011";
                    aluSel<="00";
                    rfSel1<=raSel;
                    rfSel2<=rbSel;
                    nextState<=ST_WBTR;
                elsif (opCode = OC_JAL) then
                    report "oc: JAL";
                    aluIn1Mux<="10";
                    aluIn2Mux<="100";--alu gets prevpc and 9imm_16low
                    aluSel<="00";
                    rfSel1<="111";
                    nextState<=ST_MEMA;
                elsif (opCode = OC_JLR) then
                    report "oc: JLR";
                    rfSel1<="111";
                    rfSel2<=rbSel;
                    nextState<=ST_MEMA;
                elsif (opCode = OC_JRI) then
                    report "oc: JRI";
                    rfSel1<=raSel;
                    aluIn2Mux<="100";--pass imm9_16low to alu
                    aluSel<="00";
                    nextState<=ST_WBTR;
                else
                    report "op code not matched";
                    --no next state=>execution stopped.
                end if;
            elsif (state = ST_LMSM) then
                if(opcode = OC_LM) then
                    if(to_integer(unsigned(outRegNum)) = 8) then
                        nextState<=ST_HK;
                    else
                        report"rgnm:"&integer'image(to_integer(unsigned(outRegNum)));
                        report"imm8val:"&integer'image(to_integer(unsigned(imm8_16)));
                        if (imm8_16(7-to_integer(unsigned(outRegNum))) = '1') then
                            memInMux<='1';--aluout
                            loadCurrent<='1';
                            nextState<=ST_MEMA;
                        elsif (imm8_16(7-to_integer(unsigned(outRegNum))) = '0') then
                            loadCurrent<='0';
                            nextState<=ST_MEMA;
                        end if;
                    end if;
                elsif(opcode = OC_SM) then
                    memWrite<='0';
                    if(to_integer(unsigned(outRegNum)) /= 0 and loadCurrent = '1') then
                        aluIn1Mux<="11";---pass lmsmaddr to ALu
                        aluIn2Mux<="001";---pass +1 to ALU
                        aluSel<="00";
                        lmsmAddr<=aluOut;
                    end if;
                    if(to_integer(unsigned(outRegNum)) = 8) then
                        inRegNum<="1000";
                        nextState<=ST_HK;
                    else
                        if (imm8_16(7-to_integer(unsigned(outRegNum))) = '1') then
                            rfSel2<=outRegNum(2 downto 0);
                            loadCurrent<='1';
                            nextState<=ST_MEMA;
                        elsif (imm8_16(7-to_integer(unsigned(outRegNum))) = '0') then
                            loadCurrent<='0';
                            nextState<=ST_MEMA;
                        end if;
                    end if;
                end if;
            elsif (state = ST_MEMA) then
                if( opcode = OC_JAL or opcode = OC_JLR) then
                    report "rd1:"&integer'image(to_integer(unsigned(rfDataOut1)))&", rd2"&integer'image(to_integer(unsigned(rfDataOut2)));
                    rfDataIn<=rfDataOut1;
                    rfSelW<=raSel;
                    rfWrite<='1';
                    nextState<=ST_WBTR;
                elsif (opcode = OC_LM or opcode = OC_SM) then
                    if(opcode = OC_LM) then
                        if(loadCurrent = '1') then
                            report "mdo:"&integer'image(to_integer(unsigned(memDataOut)));
                            report "rgnml:"&integer'image(to_integer(unsigned(outRegNum)));
                            rfSelW<=outRegNum(2 downto 0);
                            rfDataIn<=memDataOut;
                            rfWrite<='1';
                            aluIn1Mux<="11";---pass lmsmaddr to ALu
                            aluIn2Mux<="001";---pass +1 to ALU
                            lmsmAddr<=aluOut;
                            aluSel<="00";
                        end if;
                    elsif (opcode = OC_SM) then
                        if(loadCurrent = '1') then
                            report "mdi:"&integer'image(to_integer(unsigned(rfDataOut2)));
                            report "rgnml:"&integer'image(to_integer(unsigned(outRegNum)));
                            report "maddrin:"&integer'image(to_integer(unsigned(aluOut)));
                            memDataIn<=rfDataOut2;
                            memInMux<='1';--aluout
                            memWrite<='1';
                        end if;
                    end if;
                    inRegNum<=outRegNum;
                    nextState<=ST_LMSM;
                end if;
            elsif (state = ST_WBTR) then
                if(opcode = OC_BEQ) then
                    report "rd1:"&integer'image(to_integer(unsigned(rfDataOut1)))&", rd2"&integer'image(to_integer(unsigned(rfDataOut2)));
                    if (rfDataOut1 = rfDataOut2) then
                        rfSelW<="111";
                        rfWrite<='1';
                        rfDataIn<=aluOut;
                    end if;
                elsif (opcode = OC_JRI) then
                    rfSelW<="111";
                    rfDataIn<=aluOut;
                    rfWrite<='1';
                elsif (opcode = OC_JLR) then
                    rfSelW<="111";
                    rfDataIn<=rfDataOut2;
                    rfWrite<='1';
                elsif (opcode = OC_JAL) then
                    rfSelW<="111";
                    rfDataIn<=aluOut;
                    rfWrite<='1';
                elsif(opcode = OC_LW) then
                    rfDataIn<=memDataOut;
                    zeroFlagMux<='1';
                    if(memDataOut = "0000000000000000") then
                        lwZeroFlag<='1';
                    else
                        lwZeroFlag<='0';
                    end if;
                    rfWrite<='1';
                elsif (opcode = OC_SW) then
                    memWrite<='1';
                    memDataIn<=rfDataOut2;   
--                els
                else
                    rfDataIn<=aluOut;
                    rfWrite<='1';
                end if;
                nextState<=ST_HK;
            end if;
    end process;
    process(zeroFlagMux,aluZeroFlag,lwZeroFlag)
        begin
            if(zeroFlagMux = '0') then
                zeroFlag<=aluZeroFlag;
            elsif (zeroFlagMux = '1') then
                zeroFlag<=lwZeroFlag;
            end if;
    end process;
    process(memInMux,rfDataOut1,aluOut)
        begin
            if(memInMux = '0') then
                memAddr<=rfDataOut1(7 downto 0);
            elsif (memInMux = '1') then
                memAddr<=aluOut(7 downto 0);
            else
                report "udb";
            end if;
    end process;
    process(aluIn1Mux,aluIn2Mux,rfDataOut1,rfDataOut2,imm6_16,imm8_16,imm9_16high,imm9_16low,prevPC,lmsmAddr)
        begin
            report"aluin1: "&integer'image(to_integer(unsigned(rfDataOut1)));
            if(aluIn1Mux = "00") then
                aluIn1<=rfDataOut1;
            elsif(aluIn1Mux = "01") then
                report "inp not updated";
            elsif(aluIn1Mux = "10") then
                aluin1<=prevPC;
            elsif (aluIn1Mux = "11") then
                aluIn1<=lmsmAddr;
            end if;
            if(aluIn2Mux = "000") then
                aluIn2<=rfDataOut2;
            elsif (aluIn2Mux = "001") then
                aluIn2<=(0=>'1',others=>'0');
            elsif (aluIn2Mux = "010") then --left shift rfDataOut2 before sending to ALU
                aluIn2<=std_logic_vector(shift_left(unsigned(rfDataOut2),1)) ;
            elsif (aluIn2Mux = "011") then
                aluIn2<=imm6_16;
            elsif (aluIn2Mux = "100") then
                aluIn2<=imm9_16low;
            elsif (aluIn2Mux = "101") then
                aluIn2<=index;
            elsif (aluIn2Mux = "111") then
                aluIn2<=(others=>'0');
            else
                report "udb";
            end if;
    end process;
    process(state,nextState)
        begin
            outstates(7 downto 4) <= nextState;
            outstates(3 downto 0) <= state;
    end process;
    process(imm9)
        begin
            imm9_16high(15 downto 7)<=imm9;
            imm9_16high(6 downto 0)<=(others=>'0');
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