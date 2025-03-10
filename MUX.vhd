library ieee;
use ieee.std_logic_1164.all;

entity MUX is
    port( A, B : in std_logic_vector(31 downto 0);
          Selector : in std_logic;
          Y : out std_logic_vector(31 downto 0));
end entity MUX;

architecture RTL of MUX is
begin
    with Selector select
        Y <= A when '0',
             B when others;
end architecture RTL;