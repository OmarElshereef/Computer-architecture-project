LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity data_mux is
    port(
        sp_data_selector: in std_logic;
        alu_output, register2: in std_logic_vector(31 downto 0);
        data: out std_logic_vector(31 downto 0)
    );
end entity data_mux;

architecture rtl of data_mux is
begin
data<= alu_output when sp_data_selector = '0' 
else register2 ;
end architecture rtl;