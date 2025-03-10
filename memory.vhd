library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------
entity memory is
  port(
    SP_enable_memory,SP_operand_memory, interrupt_in, push_flags_in, restart_in, mem_read_in: in std_logic;
    clk_memory : IN std_logic;
    write_enable,rst_memory  : IN std_logic;
    sp_data_selector  : IN std_logic;
    free_enable_memory,free_busy_operand: IN std_logic;
    Alu_output  : IN  std_logic_vector(31 DOWNTO 0);
    reg_value: IN  std_logic_vector(31 DOWNTO 0);
    Exception_memory:OUT std_logic;
    Data_Out,alu_data_out, reg2_data_out : OUT std_logic_vector(31 DOWNTO 0);
    flags_data_in: IN std_logic_vector(3 DOWNTO 0)
  );
end memory;


architecture mem of memory is

component ram IS
PORT(
    clk: in std_logic;
    we,rst,interrupt,restart, read_enable: IN std_logic;
    free_enable,free_operand: IN std_logic;
    exception:OUT std_logic;
    address : IN  std_logic_vector(11 DOWNTO 0);
    datain  : IN  std_logic_vector(31 DOWNTO 0);
    dataout : OUT std_logic_vector(31 DOWNTO 0));
END component;

component data_mux is
    port(
        sp_data_selector: in std_logic;
        alu_output, register2: in std_logic_vector(31 downto 0);
        data: out std_logic_vector(31 downto 0)

    );
end component;
component flags_mem_mux is port(
    flags: in std_logic_vector(3 downto 0);
    alu_data: in std_logic_vector(31 downto 0);
    selector: in std_logic;
    to_mem_data: out std_logic_vector(31 downto 0)
    );
end component;
component address_mux is
    port(
        sp_enable: in std_logic;
        alu_output, SP_output: in std_logic_vector(31 downto 0);
        address: out std_logic_vector(11 downto 0)
    );
end component;

component SP is
   port (rst: IN std_logic;
   clk: IN std_logic;
   sp_in: in std_logic_vector(31 downto 0);
   sp_out: OUT std_logic_vector(31 downto 0));
end component;

component add2  is
 port (
    sp_enable: in std_logic;
    sp_operand:in std_logic;
    sp_old:in std_logic_vector(31 downto 0);
    address_pointer:out std_logic_vector(31 downto 0);
    sp_new: out std_logic_vector(31 downto 0)

 );
end component;
signal sp_in: std_logic_vector(31 downto 0);
signal sp_out: std_logic_vector(31 downto 0);
signal temp_data_pointer_sp: std_logic_vector(31 downto 0);
signal memory_write_value: std_logic_vector(31 downto 0);
signal memory_rw_address: std_logic_vector(11 downto 0);
signal flag_alu_data: std_logic_vector(31 downto 0);
begin
    flags_mux:flags_mem_mux port map(flags_data_in,Alu_output,push_flags_in,flag_alu_data);
    mux1:data_mux port map (sp_data_selector,flag_alu_data,reg_value,memory_write_value);
    usp:SP port map (rst_memory,clk_memory,sp_in,sp_out);
    add:add2 port map(SP_enable_memory,SP_operand_memory,sp_out,temp_data_pointer_sp,sp_in);
    mux2: address_mux port map(SP_enable_memory,Alu_output,temp_data_pointer_sp,memory_rw_address);
    umem: ram  port map (clk_memory,write_enable,rst_memory,interrupt_in,restart_in,mem_read_in,free_enable_memory,free_busy_operand,Exception_memory,memory_rw_address,memory_write_value,Data_Out);
    alu_data_out<= ALU_output;
    reg2_data_out<= reg_value;
end mem;