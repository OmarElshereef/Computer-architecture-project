LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity predictor is
    port(
        corrector,rst,clk:in std_logic;
        prediction_bit:out std_logic
    );
end entity predictor;

architecture rtl of predictor is
    TYPE state_type IS (taken,not_taken);
    SIGNAL state : state_type;

    begin
        process(clk,rst)
        begin
            if rst = '1' then 
                state <= taken;
		        prediction_bit<='1';
            elsif rising_edge(clk) then 
                CASE state IS
                    when taken =>
                        if corrector = '1' then 
                            state <= not_taken;
                            prediction_bit<='0';
                        else
                            state<= taken;
                            prediction_bit<='1';
                        end if ;
                    when not_taken=>
                        if corrector = '1' then 
                            state <= taken;
                            prediction_bit<='1';
                        else
                            state<= not_taken;
                            prediction_bit<='0';
                        end if ;
                    WHEN OTHERS =>
                        state <= taken;
                        prediction_bit<='1';
                 end case ;
            end if;
        end process;

end architecture rtl;


