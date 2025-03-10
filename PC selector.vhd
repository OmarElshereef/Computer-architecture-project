lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity pc_selector  is
 port (
        unconditional_jump,conditional_jump,flusher,write_back: in std_logic;
        reg1_data,pc1,predicted_data,corrected_data,write_back_data:in std_logic_vector(31 downto 0);
        new_pc:out  std_logic_vector(31 downto 0)
 );
end pc_selector;

architecture rtl of pc_selector   is

    begin
        new_pc<= write_back_data when write_back ='1'
        else corrected_data when flusher ='1'
        else reg1_data when unconditional_jump ='1'
        else predicted_data when conditional_jump ='1' 
        else pc1;
end rtl;

