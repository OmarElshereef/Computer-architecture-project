library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flags_mem_mux is port(
    flags: in std_logic_vector(3 downto 0);
    alu_data: in std_logic_vector(31 downto 0);
    selector: in std_logic;
    to_mem_data: out std_logic_vector(31 downto 0)
);
end flags_mem_mux;


architecture Behavioral of flags_mem_mux is
    begin
    to_mem_data <= alu_data when selector = '0' else flags & "0000000000000000000000000000";
end Behavioral;