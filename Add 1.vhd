lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity add  is
 port (
    PC_enable: in std_logic;
    address:in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0)

 );
end add;

architecture adder of add is
begin

result <= std_logic_vector(unsigned(address)+1) when PC_enable ='1' else address;


end adder;