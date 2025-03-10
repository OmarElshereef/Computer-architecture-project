lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity flush_unit is port(
    rst: in std_logic;
    jump_flush, jump_zero_flush, predictor_state, checker_valid: in std_logic;
    fetch_flush, decode_flush: out std_logic
);
end flush_unit;

architecture flush_unit_arch of flush_unit is
begin
    process(rst, jump_flush, jump_zero_flush, predictor_state, checker_valid)
    begin
        if rst = '1' then
            fetch_flush <= '0';
            decode_flush <= '0';
        elsif checker_valid = '1' then
            fetch_flush <= '1';
            decode_flush <= '1';
        elsif jump_flush = '1' then
            fetch_flush <= '1';
            decode_flush <= '0';
        elsif jump_zero_flush = '1' then
            if predictor_state = '1' then
                fetch_flush <= '1';
                decode_flush <= '0';
            else
                fetch_flush <= '0';
                decode_flush <= '0';
            end if;
        else
            fetch_flush <= '0';
            decode_flush <= '0';
        end if;
    end process;
end flush_unit_arch;
