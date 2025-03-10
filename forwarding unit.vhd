lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity forwarding  is
 port (
    -- data from register file 
    reg1_address: in std_logic_vector(2 downto 0);
    reg2_address: in std_logic_vector(2 downto 0);
    reg1_data: in std_logic_vector(31 downto 0);
    reg2_data: in std_logic_vector(31 downto 0);
    -- data from execute mem buffer
    execute_reg1_address: in std_logic_vector(2 downto 0);
    execute_reg2_address: in std_logic_vector(2 downto 0);
    execute_wb1_enable: in std_logic;
    execute_alu_output:in std_logic_vector(31 downto 0);
    execute_wb2_enable: in std_logic;
    execute_reg2_data: in std_logic_vector(31 downto 0);
    execute_mem_or_alu:in std_logic;
    --data from mem wb buffer
    memory_reg1_address: in std_logic_vector(2 downto 0);
    memory_reg2_address: in std_logic_vector(2 downto 0);
    memory_wb1_enable: in std_logic;
    memory_alu_output:in std_logic_vector(31 downto 0);
    memory_wb2_enable: in std_logic;
    memory_reg2_data: in std_logic_vector(31 downto 0);
    memory_mem_or_alu:in std_logic;
    memory_mem_output:in std_logic_vector(31 downto 0);
    ----------------------------------------------------------------------------------------------------------
    operand1,operand2:out std_logic_vector(31 downto 0));

end forwarding;

architecture rtl of forwarding   is

    begin
        operand1<= execute_alu_output when reg1_address = execute_reg1_address and execute_wb1_enable = '1' and execute_mem_or_alu = '0'
        else execute_reg2_data when reg1_address = execute_reg2_address and execute_wb2_enable ='1' and execute_mem_or_alu = '0'
        else memory_alu_output when reg1_address = memory_reg1_address and memory_wb1_enable = '1' and memory_mem_or_alu ='0'
        else memory_mem_output when reg1_address = memory_reg1_address and memory_wb1_enable = '1' and memory_mem_or_alu = '1'
        else memory_reg2_data when reg1_address = memory_reg2_address and memory_wb2_enable = '1' 
        else reg1_data ;
        operand2<= execute_alu_output when reg2_address = execute_reg1_address and execute_wb1_enable = '1' and execute_mem_or_alu = '0'
        else execute_reg2_data when reg2_address = execute_reg2_address and execute_wb2_enable ='1' and execute_mem_or_alu = '0'
        else memory_alu_output when reg2_address = memory_reg1_address and memory_wb1_enable = '1' and memory_mem_or_alu ='0'
        else memory_mem_output when reg2_address = memory_reg1_address and memory_wb1_enable = '1' and memory_mem_or_alu = '1'
        else memory_reg2_data when reg2_address = memory_reg2_address and memory_wb2_enable = '1' 
        else reg2_data ;
end rtl;

