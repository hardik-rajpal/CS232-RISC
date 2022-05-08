library ieee;
use ieee.std_logic_1164.all;

entity SixteenBitRCA is

	port(xin,yin: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sum: out std_logic_vector(15 downto 0);
		  cout: out std_logic);

end entity;


architecture arith of SixteenBitRCA is
	component onebitfulladd is
		port(a,b,cin: in std_logic;
		     cout,sum: out std_logic);
	end component;
	signal ctemp: std_logic_vector(15 downto 0);
	
begin
	a1: onebitfulladd port map(xin(0), yin(0),cin,ctemp(1), sum(0));
	a2: onebitfulladd port map(xin(1), yin(1),ctemp(1),ctemp(2), sum(1));
	a3: onebitfulladd port map(xin(2), yin(2),ctemp(2),ctemp(3), sum(2));
	a4: onebitfulladd port map(xin(3), yin(3),ctemp(3),ctemp(4), sum(3));
	a5: onebitfulladd port map(xin(4), yin(4),ctemp(4),ctemp(5), sum(4));
	a6: onebitfulladd port map(xin(5), yin(5),ctemp(5),ctemp(6), sum(5));
	a7: onebitfulladd port map(xin(6), yin(6),ctemp(6),ctemp(7), sum(6));
	a8: onebitfulladd port map(xin(7), yin(7),ctemp(7),ctemp(8), sum(7));
	a9: onebitfulladd port map(xin(8), yin(8),ctemp(8),ctemp(9), sum(8));
	a10: onebitfulladd port map(xin(9), yin(9),ctemp(9),ctemp(10), sum(9));
	a11: onebitfulladd port map(xin(10), yin(10),ctemp(10),ctemp(11), sum(10));
	a12: onebitfulladd port map(xin(11), yin(11),ctemp(11),ctemp(12), sum(11));
	a13: onebitfulladd port map(xin(12), yin(12),ctemp(12),ctemp(13), sum(12));
	a14: onebitfulladd port map(xin(13), yin(13),ctemp(13),ctemp(14), sum(13));
	a15: onebitfulladd port map(xin(14), yin(14),ctemp(14),ctemp(15), sum(14));
	a16: onebitfulladd port map(xin(15), yin(15),ctemp(15),cout, sum(15));
end arith;