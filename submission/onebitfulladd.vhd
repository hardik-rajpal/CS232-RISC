library IEEE;
use IEEE.std_logic_1164.all;
entity OnebitFullAdd is
port ( a, b, cin : in std_logic;
sum, cout: out std_logic);

end entity;
architecture archobfa of onebitfulladd is
    signal absum, c1,c2:std_logic;
    
    component onebithalfadd
        port(a,b:in std_logic; sum,cout:out std_logic);
    end component;
begin
    obha1:onebithalfadd
        port map(a=>a,b=>b,sum=>absum,cout=>c1);
    obha2:onebithalfadd
        port map(a=>cin,b=>absum,sum=>sum,cout=>c2);
    cout<= c1 or c2 ;
    
    
end architecture archobfa;