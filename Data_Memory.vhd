LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ram IS 
	PORT(
		clk: in std_logic;
		we,rst,interrupt,restart, read_enable: IN std_logic;
		free_enable,free_operand: IN std_logic;
		exception:OUT std_logic;
		address : IN  std_logic_vector(11 DOWNTO 0);
		datain  : IN  std_logic_vector(31 DOWNTO 0);
		dataout : OUT std_logic_vector(31 DOWNTO 0));
END ENTITY ram;

ARCHITECTURE sync_ram_a OF ram IS

	TYPE ram_type IS ARRAY(0 TO 4095) OF std_logic_vector(15 DOWNTO 0);
	TYPE one_bit_array IS ARRAY(0 TO 4095) OF std_logic_vector(0 to 0);
	SIGNAL free : one_bit_array;
	SIGNAL ram : ram_type ;
	BEGIN
		PROCESS(clk,rst,we,read_enable) IS
		variable dataout_signal:std_logic_vector(31 DOWNTO 0);
		variable exception_signal: std_logic;
			BEGIN
				if rst = '1' then
					ram <= (others => (others => '0'));
					free <= (others => (others => '0'));
					exception_signal :='0';
				else
					if (rising_edge(read_enable) or read_enable = '1') then 
						if interrupt = '1' then
							dataout_signal(15 downto 0) := ram(to_integer(unsigned(std_logic_vector'("00000000000000010"))));
							dataout_signal(31 downto 16) := ram(to_integer(unsigned(std_logic_vector'("00000000000000011"))));
							exception_signal := '0';
						elsif  restart = '1' then
							dataout_signal(15 downto 0) := ram(to_integer(unsigned(std_logic_vector'("00000000000000000"))));
							dataout_signal(31 downto 16) := ram(to_integer(unsigned(std_logic_vector'("00000000000000001"))));
							exception_signal := '0';
						else
							dataout_signal(15 downto 0) := ram(to_integer(unsigned(address)));
							dataout_signal(31 downto 16) := ram(to_integer(unsigned(address))+1);
							exception_signal := '0';
						end if ;
					end if;
					if we='1' then
						if free(to_integer(unsigned(address)))(0)='0' and free(to_integer(unsigned(address))+1)(0)='0'  then
							ram(to_integer(unsigned(address))) <= datain(15 DOWNTO 0);
							ram(to_integer(unsigned(address))+1) <= datain(31 DOWNTO 16);
							exception_signal := '0';
						else
							exception_signal := '1';
						end if ;
					
					elsif free_enable='1' then
						if free_operand='1' then
							free(to_integer(unsigned(address)))(0)<='1';
							free(to_integer(unsigned(address))+1)(0)<='1';
							exception_signal :='0';
						else
							free(to_integer(unsigned(address)))(0)<='0';
							free(to_integer(unsigned(address))+1)(0)<='0';
							exception_signal :='0';
						end if ;
					else
						exception_signal :='0';
					end if ;
				END if;
				if exception_signal = '0' then
					dataout<= dataout_signal;
				else
					dataout<="00000000000000000000000000000000";
				end if;
				exception<= exception_signal;
		END PROCESS;
END sync_ram_a;