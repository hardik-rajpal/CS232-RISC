-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "05/06/2022 14:33:07"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          RISC
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY RISC_vhd_vec_tst IS
END RISC_vhd_vec_tst;
ARCHITECTURE RISC_arch OF RISC_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL outstates : STD_LOGIC_VECTOR(7 DOWNTO 0);
COMPONENT RISC
	PORT (
	clk : IN STD_LOGIC;
	outstates : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : RISC
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	outstates => outstates
	);

-- clk
t_prcs_clk: PROCESS
BEGIN
LOOP
	clk <= '0';
	WAIT FOR 500 ps;
	clk <= '1';
	WAIT FOR 500 ps;
	IF (NOW >= 100000 ps) THEN WAIT; END IF;
END LOOP;
END PROCESS t_prcs_clk;
END RISC_arch;
