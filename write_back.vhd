lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity write_back  is
 port (
        wb1_enable_in,wb2_enable_in,memory_or_alu:in std_logic;
        wb1_address_in,wb2_address_in:in std_logic_vector(2 downto 0);
        alu_output,memory_output,reg2_value: in std_logic_vector(31 downto 0);
        wb1_enable_out,wb2_enable_out:out std_logic;
        wb1_address_out,wb2_address_out:out std_logic_vector(2 downto 0);
        output_enable_in:in std_logic;
        output_enable_out:out std_logic;
        output_data:out std_logic_vector(31 downto 0);
        wb1_value,wb2_value:out std_logic_vector(31 downto 0)
 );
end write_back;

architecture rtl of write_back is

begin
    wb1_enable_out<= wb1_enable_in;      
    wb2_enable_out<= wb2_enable_in; 
    wb1_address_out<= wb1_address_in;
    wb2_address_out<= wb2_address_in;
    wb1_value<= alu_output when memory_or_alu ='0'
    else memory_output;
    wb2_value<= reg2_value;
    output_enable_out<= output_enable_in;
    output_data<=alu_output;
end rtl;


