library ieee;
use ieee.std_logic_1164.all;

entity fet_dec_buff is
    port(
        rst, clk,flush: in std_logic;
        instruction_in: in std_logic_vector(15 downto 0);
        reg1_addr, reg1_addr_buffer: out std_logic_vector(2 downto 0);
        reg2_addr, reg2_addr_buffer: out std_logic_vector(2 downto 0);
        instruction_out, immediate_value: out std_logic_vector(15 downto 0);
        stall_enable: in std_logic;
        PC_value_in, PC_add_in: in std_logic_vector(31 downto 0);
        PC_value_out, PC_add_out: out std_logic_vector(31 downto 0)
    );
end fet_dec_buff;

architecture arch of fet_dec_buff is
begin
    process(rst,clk)
    begin
        if rst = '1' then
            instruction_out <= (others => '0');
            reg1_addr <= (others => '0');
            reg2_addr <= (others => '0');
            reg1_addr_buffer <= (others => '0');
            reg2_addr_buffer <= (others => '0');
            immediate_value <= (others => '0');
            PC_value_out <= (others => '0');
            PC_add_out <= (others => '0');
        elsif rising_edge(clk) then
            if flush = '1' then
                instruction_out <= (others => '0');
                reg1_addr <= (others => '0');
                reg2_addr <= (others => '0');
                reg1_addr_buffer <= (others => '0');
                reg2_addr_buffer <= (others => '0');
                immediate_value <= (others => '0');
                PC_value_out <= (others => '0');
                PC_add_out <= (others => '0');
            elsif stall_enable = '0' then
                instruction_out <= instruction_in;
                reg1_addr <= instruction_in(9 downto 7);
                reg2_addr <= instruction_in(6 downto 4);
                reg1_addr_buffer <= instruction_in(9 downto 7);
                reg2_addr_buffer <= instruction_in(6 downto 4);
                immediate_value <= instruction_in;
                PC_value_out <= PC_value_in;
                PC_add_out <= PC_add_in;
            else
                null;
            end if;
        end if;
    end process;
end arch ;