LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity PC_or_data is
    port(
        prediction_bit,conditional_jump:in std_logic;
        reg1_data,new_pc: in std_logic_vector(31 downto 0);
        predicted_address: out std_logic_vector(31 downto 0)
    );
end entity PC_or_data;

architecture rtl of PC_or_data is
begin
predicted_address <= reg1_data when conditional_jump = '0'
else reg1_data when prediction_bit ='1'
else new_pc;   
end architecture rtl;

