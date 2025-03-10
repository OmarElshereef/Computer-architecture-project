LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity address_mux is
    port(
        sp_enable: in std_logic;
        alu_output, SP_output: in std_logic_vector(31 downto 0);
        address: out std_logic_vector(11 downto 0)
    );
end entity address_mux;

architecture rtl of address_mux is
begin
address<= alu_output(11 downto 0) when sp_enable = '0'
else SP_output(11 downto 0); 
end architecture rtl;