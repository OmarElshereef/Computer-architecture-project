LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity checker is
    port(
        prediction_bit,conditional_jump,unconditional_jump,zero_flag,wrong_comparator:in std_logic;
        reg1_data_after_forwarding,new_pc: in std_logic_vector(31 downto 0);
        right_data: out std_logic_vector(31 downto 0);
        wrong_prediction,wrong_data,flusher:out std_logic
    );
end entity checker;

architecture rtl of checker is
signal wrong_prediction_signal,wrong_data_signal : std_logic;
    begin
wrong_prediction_signal<= '0' when prediction_bit = zero_flag or conditional_jump = '0'
else '1';
wrong_data_signal <= '0' when unconditional_jump ='0' and conditional_jump = '0'
else '0' when wrong_comparator ='0'
else '1' ;
wrong_prediction <= wrong_prediction_signal;
wrong_data <= wrong_data_signal;

right_data<= "00000000000000000000000000000000" when wrong_prediction_signal ='0' and wrong_data_signal ='0'
else new_pc when wrong_prediction_signal ='1' and prediction_bit ='1'
else reg1_data_after_forwarding when (wrong_prediction_signal ='1' and prediction_bit ='0') or wrong_data_signal ='1' 
else  "00000000000000000000000000000000";


flusher<= '0' when conditional_jump='0' and unconditional_jump ='0' 
else '0' when unconditional_jump ='1' and wrong_data_signal ='0'
else '1' when unconditional_jump ='1' and wrong_data_signal ='1'
else '0' when conditional_jump ='1' and (wrong_prediction_signal = '0' and wrong_data_signal ='0')
else '1' when conditional_jump ='1' and (wrong_prediction_signal ='0' and wrong_data_signal ='1' and prediction_bit='1')
else '1' when conditional_jump ='1' and wrong_prediction_signal ='1'
else '0';


end architecture rtl;


