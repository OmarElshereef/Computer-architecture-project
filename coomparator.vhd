LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity comparator is
    port(
        reg1_b4,reg1_after: in std_logic_vector(31 downto 0);
        wrong: out std_logic
    );
end entity comparator;

architecture rtl of comparator is
begin
wrong<= '0' when reg1_b4 = reg1_after 
else '1' ;  
end architecture rtl;
