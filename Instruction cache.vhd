LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Instruction_Memory IS
	PORT(
		rst: IN std_logic;
		address : IN  std_logic_vector(31 DOWNTO 0);
		instruction: OUT std_logic_vector(15 downto 0));
END ENTITY Instruction_Memory;

ARCHITECTURE Instructions OF Instruction_Memory IS
	TYPE ram_type IS ARRAY(0 TO 4095) OF std_logic_vector(15 DOWNTO 0);
	SIGNAL ram : ram_type ;
BEGIN
	
	PROCESS(address,rst) IS
		BEGIN

        		instruction <= ram(to_integer(unsigned(address(11 downto 0))));
		if rst = '1' then
           		ram <= (others => (others => '0'));
       		 END if;
	END PROCESS;
	
END Instructions;
