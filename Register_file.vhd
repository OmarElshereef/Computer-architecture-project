library ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity register_file is
    port(
        Read_address_1: in std_logic_vector (2 downto 0);
        Read_address_2: in std_logic_vector (2 downto 0);
        Write_address_1: in std_logic_vector (2 downto 0);
        Write_address_2: in std_logic_vector (2 downto 0);
        Read_port_1: out std_logic_vector (31 downto 0);
        Read_port_2: out std_logic_vector (31 downto 0);
        Write_port_1: in std_logic_vector (31 downto 0);
        Write_port_2: in std_logic_vector (31 downto 0);
        Write_enable_1, Write_enable_2, rst, clk, read_enable: in std_logic
    );
end register_file;

architecture registers of register_file is
    type rigs is array(0 to 7) of std_logic_vector(31 downto 0);
    signal storage: rigs;
begin
    proc1:process (clk, rst, Read_address_1, Read_address_2)
    begin
        if rst = '1' then
            storage <= (others => (others => '0'));
        else
            if Write_enable_1 = '1' then
                storage(to_integer(unsigned(Write_address_1))) <= Write_port_1;	
            end if;
            if Write_enable_2 = '1' then
                storage(to_integer(unsigned(Write_address_2))) <= Write_port_2;	
            end if;	
        end if;
    end process proc1;
    Read_port_1 <= storage(to_integer(unsigned(Read_address_1)));
    Read_port_2 <= storage(to_integer(unsigned(Read_address_2)));
end registers;