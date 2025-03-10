library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flag_register is
    port(
        rst, clk, feedback: in std_logic;
        enable: in std_logic;
        memory_feedback: in std_logic_vector(31 downto 0);
        flag_in : in std_logic_vector(3 downto 0);
        flag_out : out std_logic_vector(3 downto 0);
        JZ : in std_logic
        );
end entity flag_register;

architecture flags of flag_register is
begin
    process(rst, enable, clk, memory_feedback, JZ)
    variable flag_reg: std_logic_vector(3 downto 0);
    begin
        if rst = '1' then
            flag_reg := (others => '0');
        elsif feedback = '1' then
            flag_reg := memory_feedback(31 downto 28);
        elsif enable = '1' then
            flag_reg := flag_in;
        end if;
        if rising_edge(clk) then
            if JZ ='1' and flag_reg(0) = '1' then
                flag_reg(0) := '0';
            end if;
        end if;
        flag_out <= flag_reg;
    end process;
end architecture flags;