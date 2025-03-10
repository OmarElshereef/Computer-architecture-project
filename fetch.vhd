library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY fetch IS
	PORT(
		clk : IN std_logic;
		reset: IN std_logic;
		pc_enable:in std_logic;
		jmp,jz,flush,wb: in std_logic;
		reg1,predicted,corrected,wb_data:in std_logic_vector(31 downto 0);
		instruction: OUT std_logic_vector(15 downto 0);
		pc_value, pc_plus_value: OUT std_logic_vector(31 downto 0));
END ENTITY fetch;

ARCHITECTURE rtl OF fetch IS
 component Instruction_Memory
	PORT(
		rst: IN std_logic;
		address : IN  std_logic_vector(31 DOWNTO 0);
		instruction: OUT std_logic_vector(15 DOWNTO 0));
    END component;
component PC is
 port (rst: IN std_logic;
	clk: IN std_logic;
	data_in : in std_logic_vector(31 downto 0);
	address: OUT std_logic_vector(31 downto 0));
end component;

component add  is
 port (
    PC_enable: in std_logic;
    address:in std_logic_vector(31 downto 0);
    result: out std_logic_vector(31 downto 0)

 );
end component;

component pc_selector  is
	port (
		   unconditional_jump,conditional_jump,flusher,write_back: in std_logic;
		   reg1_data,pc1,predicted_data,corrected_data,write_back_data:in std_logic_vector(31 downto 0);
		   new_pc:out  std_logic_vector(31 downto 0)
	);
   end component;
signal pc_signal: std_logic_vector(31 downto 0);
signal pc_new,added_pc: std_logic_vector(31 downto 0);

BEGIN
Instruction_Memory_inst: Instruction_Memory port map(reset, pc_signal,instruction);
PC_inst:PC port map(reset,clk,pc_new,pc_signal);
add_inst: add port map(pc_enable,pc_signal,added_pc);	
selector: pc_selector port map(jmp,jz,flush,wb,reg1,added_pc,predicted,corrected,wb_data,pc_new);
pc_value <= pc_signal;
pc_plus_value <= added_pc;
END rtl;