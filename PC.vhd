lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity PC is
 port (rst: IN std_logic;
	clk: IN std_logic;
	data_in : in std_logic_vector(31 downto 0);
	address: OUT std_logic_vector(31 downto 0));
end PC;

architecture count of PC is
	signal storage: std_logic_vector(31 downto 0) := (others =>'0');
begin
	process(rst,clk) is
	begin
		if rst = '1' then
			storage <= (others => '0');
		elsif rising_edge(clk) then
            storage<=data_in;
		end if;
	end process;
	address<=storage;
end count;