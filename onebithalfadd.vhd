library IEEE;
use IEEE.std_logic_1164.all;

entity OnebitHalfAdd is
port ( a, b: in std_logic;
sum, cout: out std_logic);
end entity;

architecture arch_obha of onebithalfadd is
begin
    cout<=a and b;
    sum<= a xor b;    
end architecture arch_obha;