LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity predictor_mux is
    port(
        prediction_bit:in std_logic;
        reg1_data,new_pc: in std_logic_vector(31 downto 0);
        predicted_address: out std_logic_vector(31 downto 0)
    );
end entity predictor_mux;

architecture rtl of predictor_mux is
begin
predicted_address <= reg1_data when prediction_bit = '1'
else new_pc;   
end architecture rtl;

