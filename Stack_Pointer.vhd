LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity SP is
port (rst: IN std_logic;
	clk: IN std_logic;
	sp_in: in std_logic_vector(31 downto 0);
	sp_out: OUT std_logic_vector(31 downto 0));
end SP;

architecture minus of SP is
	signal storage: std_logic_vector(31 downto 0) := "11111111111111111111111111111110";

begin
	process(rst,clk) is

	begin
		if rst = '1' then
			storage <= "11111111111111111111111111111110";
		elsif rising_edge(clk) then
			storage<=sp_in;
		end if;
	end process;
	sp_out<=storage;
end minus;
