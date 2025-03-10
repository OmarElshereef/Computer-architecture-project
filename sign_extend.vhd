library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extender is
    port (
        immediate: in std_logic_vector(15 downto 0);
	    PC: in std_logic_vector(31 downto 0);
        out_value : out std_logic_vector(31 downto 0);
        clk,jump_enable: in std_logic
    );
end entity sign_extender;

architecture rtl of sign_extender is
begin
    process(clk, immediate, jump_enable, PC)
    begin
            if jump_enable = '1' then
		        out_value <= PC;
            else
                if immediate(15) = '0' then
                    out_value <= "0000000000000000" & immediate;
                else
                    out_value <= "1111111111111111" & immediate;
                end if;
            end if;
    end process;
end architecture rtl;