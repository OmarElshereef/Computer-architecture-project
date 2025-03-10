library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
  generic (size: integer := 32);
  port(
    OP1, OP2 : IN std_logic_vector (size-1 downto 0);
    code: IN std_logic_vector (3 downto 0);
    rst: IN std_logic;
    f : OUT std_logic_vector (size-1 downto 0);
    flags_in: IN std_logic_vector (3 downto 0);
    flags_out: OUT std_logic_vector (3 downto 0)
  );
end ALU;

architecture arch3 of ALU is
begin
  process(code, OP1, OP2, rst, flags_in)
    variable result: signed(size-1 downto 0);
    variable temp_flags: std_logic_vector (3 downto 0);
  begin
    if rst = '1' then
      result := (others => '0');
      temp_flags := (others => '0');
    else
      case code is
        when "0000" => result := signed(OP1); -- IN Rdst
        when "0010" => result := signed(OP1) and signed(OP2); -- AND OP1 and OP2
        when "0011" => result := signed(OP1) or signed(OP2); -- OR OP1 and OP2
        when "0100" => result := signed(OP1) xor signed(OP2); -- XOR OP1 and OP2
        when "0101" => result := not signed(OP1); -- NOT OP1
        when "0110" => result := signed(OP1) - signed(OP2); -- compare OP1 and OP2
        when "1000" => result := signed(OP1) + signed(OP2); -- add OP1 and OP2
        when "1001" => result := signed(OP1) - signed(OP2); -- subtract OP1 and OP2
        when "1010" => result := signed(OP1) + 1; -- increment
        when "1011" => result := signed(OP1) - 1; -- decrement
        when "1100" => result := - signed(OP1); -- NEG OP1
        when "1101" => result := signed(OP2) + 1; --inc OP2
        when "1111" => result := (others => '0'); -- reset
        when others => result := signed(OP2); -- default case
      end case;


      if (code = "0000" or code = "0001" or code = "1101" or code ="1111") then
        temp_flags := flags_in;
      else
        if result = 0 then
          temp_flags(0) := '1'; -- zero flag
        else
          temp_flags(0) := '0';
        end if;
        
        if result < 0 then
          temp_flags(1) := '1'; -- sign flag
        else
          temp_flags(1) := '0';
        end if;
        
        if code(3) = '1' and code(0) = '0' and unsigned(result) < unsigned(OP1) then
          temp_flags(2) := '1'; -- carry flag
        elsif code(3) = '1' and code(0) /= '0' and unsigned(result) > unsigned(OP1) then
          temp_flags(2) := '1'; -- carry flag
        else
          temp_flags(2) := flags_in(2);
        end if;
        
        if code(3) = '1' and ((signed(OP1) >= 0 and signed(OP2) >= 0 and signed(result) < 0) or 
                              (signed(OP1) < 0 and signed(OP2) < 0 and signed(result) >= 0)) then
          temp_flags(3) := '1'; -- overflow flag
        else
          temp_flags(3) := flags_in(3);
        end if;
      end if;
    end if;
    f <= std_logic_vector(result);
    flags_out <= temp_flags;
  end process;
end arch3;