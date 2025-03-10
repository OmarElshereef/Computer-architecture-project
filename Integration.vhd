library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Integration is
    port (
        clk_all : in std_logic;
        reset_all : in std_logic;
        in_ports : in std_logic_vector(31 downto 0);
        out_ports : out std_logic_vector(31 downto 0);
        exception : out std_logic
    );
end entity Integration;

architecture Arch_Integration of Integration is

    component fetch is
        port (
            clk : IN std_logic;
            reset: IN std_logic;
            pc_enable:in std_logic;
            instruction: OUT std_logic_vector(15 downto 0)
        );
    end component fetch;
    
    component fet_dec_buff is
        port (
            rst, clk,flush: in std_logic;
            instruction_in: in std_logic_vector(15 downto 0);
            reg1_addr: out std_logic_vector(2 downto 0);
            reg2_addr: out std_logic_vector(2 downto 0);
            instruction_out: out std_logic_vector(15 downto 0);
            stall_enable: in std_logic
        );
    end component fet_dec_buff;

    component decode is
        port (
            clk, rst, cu_clock: in std_logic;
            instruction: in std_logic_vector(15 downto 0);
            reg1_addr, reg2_addr : in std_logic_vector(2 downto 0);
            immediate_value_in: in std_logic_vector(15 downto 0);
            pc_in: in std_logic_vector(31 downto 0);
            WB1_enable_in, WB2_enable_in: in std_logic;
            WB1_data, WB2_data: in std_logic_vector(31 downto 0);
            WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
            reg1_data, reg2_data: out std_logic_vector(31 downto 0);
            immediate_value_out: out std_logic_vector(31 downto 0);
            mem_write, is_in_port, is_immediate, stall_enable, flag_enable, alu_mem, WB1_enable_out, WB2_enable_out, SP_enable, SP_op, SP_select,FB_enable, FB_op, outport_enable: out std_logic;
            WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
            alu_op: out std_logic_vector(3 downto 0)
        );
    end component decode;

    component dec_exe_buff is
        port (
            rst, clk, flush, stall_enable: in std_logic;
            mem_write_in, is_inport_in, is_immediate_in, flag_enable_in, PC_write_in, alu_mem_out_in, WB1_in, WB2_in, SP_enable_in, Sp_op_in, SP_select_in, FB_enable_in, FB_op_in, outport_enable_in: in std_logic;
            reg1_data_in, reg2_data_in: in std_logic_vector(31 downto 0);
            reg1_addr_in, reg2_addr_in, WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
            ALU_op_in: in std_logic_vector(3 downto 0);
            mem_write_out, is_inport_out, is_immediate_out, flag_enable_out, PC_write_out, alu_mem_out_out, WB1_enable_out, WB2_enable_out, SP_enable_out, Sp_op_out, SP_select_out, FB_enable_out, FB_op_out, outport_enable_out: out std_logic;
            reg1_data_out, reg2_data_out: out std_logic_vector(31 downto 0);
            reg1_addr_out, reg2_addr_out, WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
            ALU_op_out: out std_logic_vector(3 downto 0)
        );
    end component dec_exe_buff;

    component execute is
        port (
            rst,clk: in std_logic;
            opcode: in std_logic_vector(3 downto 0);
            reg1_addr, reg2_addr, exe_reg1_addr, exe_reg2_addr, mem_reg1_addr, mem_reg_2_addr: in std_logic_vector(2 downto 0);
            reg1_data, reg2_data, inport_data, immediate_val: in std_logic_vector(31 downto 0);
            is_input, is_immediate,flag_enable: in std_logic;
            exe_wb1_enable, exe_wb2_enable, mem_wb1_enable, mem_wb2_enable, exe_mem_select1, exe_mem_select2: in std_logic;
            exe_wb1_data, exe_wb2_data, mem_wb1_data, mem_wb2_data, mem_output_forward: in std_logic_vector(31 downto 0);
            alu_output, reg2_output: out std_logic_vector(31 downto 0)
        );
    end component execute;

    component exe_mem_buff is
        port(
            clk, rst: in std_logic;
            mem_write_in, WB1_in, WB2_in, SP_enable_in, SP_op_in, SP_select_in, PC_write_in, alu_mem_out_in, FB_enable_in, FB_op_in, outport_enable_in: in std_logic;
            WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
            alu_in, reg2_data_in: in std_logic_vector(31 downto 0);
            mem_read_out, WB1_out, WB2_out, SP_enable_out, SP_op_out, SP_select_out, PC_write_out, alu_mem_out_out, FB_enable_out, FB_op_out, outport_enable_out: out std_logic;
            WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
            alu_out, reg2_data_out: out std_logic_vector(31 downto 0);
            forwarded1_data, forwarded2_data: out std_logic_vector(31 downto 0);
            forwarded1_enable, forwarded2_enable: out std_logic;
            forwarded1_addr, forwarded2_addr: out std_logic_vector(2 downto 0)
        );
    end component exe_mem_buff;

    component memory is
        port (
            SP_enable_memory,SP_operand_memory: in std_logic;
            clk_memory : IN std_logic;
            write_enable,rst_memory  : IN std_logic;
            sp_data_selector  : IN std_logic;
            free_enable_memory,free_busy_operand: IN std_logic;
            Alu_output  : IN  std_logic_vector(31 DOWNTO 0);
            reg_value: IN  std_logic_vector(31 DOWNTO 0);
            Exception_memory:OUT std_logic;
            Data_Out : OUT std_logic_vector(31 DOWNTO 0)
        );
    end component memory;

    component mem_wb_buff is
        port (
            clk, rst: in std_logic;
            WB1_enable_in, WB2_enable_in, outport_enable_in, alu_mem_out_in, PC_write_in: in std_logic;
            WB1_enable_out, WB2_enable_out, outport_enable_out, alu_mem_out_out, PC_write_out: out std_logic;
            WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
            WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
            mem_in, alu_in, reg2_data_in: in std_logic_vector(31 downto 0);
            mem_out, alu_out, reg2_data_out: out std_logic_vector(31 downto 0);
            forward_enable: out std_logic;
            forward_data: out std_logic_vector(31 downto 0)
        );
    end component mem_wb_buff;

    component write_back is
        port(
            wb1_enable_in,wb2_enable_in,memory_or_alu:in std_logic;
            wb1_address_in,wb2_address_in:in std_logic_vector(2 downto 0);
            alu_output,memory_output,reg2_value: in std_logic_vector(31 downto 0);
            wb1_enable_out,wb2_enable_out:out std_logic;
            wb1_address_out,wb2_address_out:out std_logic_vector(2 downto 0);
            output_enable_in:in std_logic;
            output_enable_out:out std_logic;
            output_data:out std_logic_vector(31 downto 0);
            wb1_value,wb2_value:out std_logic_vector(31 downto 0)
        );
    end component write_back;

    --Main clock and reset signals
    signal clk_main, rst_main: std_logic;

    --Fetch out signals
    signal instruction_fetch: std_logic_vector(15 downto 0);

    --Fetch Decode Buffer out signals
    signal reg1_addr_fetchdecode, reg2_addr_fetchdecode: std_logic_vector(2 downto 0);
    signal instruction_fetchdecode: std_logic_vector(15 downto 0);

    --Decode out signals
    signal reg1_data_decode, reg2_data_decode: std_logic_vector(31 downto 0);
    signal immediate_value_out_decode: std_logic_vector(31 downto 0);
    signal mem_write_decode, is_in_port_decode, is_immediate_decode, stall_enable_decode, flag_enable_decode, alu_mem_decode, WB1_enable_out_decode, WB2_enable_out_decode, SP_enable_decode, SP_op_decode, SP_select_decode, FB_enable_decode, FB_op_decode, outport_enable_decode: std_logic;
    signal WB1_addr_out_decode, WB2_addr_out_decode: std_logic_vector(2 downto 0);
    signal alu_op_decode: std_logic_vector(3 downto 0);
    
    --Decode Execute Buffer out signals
    signal mem_write_decodeexe, is_in_port_decodeexe, is_immediate_decodeexe, flag_enable_decodeexe, PC_write_decodeexe, alu_mem_decodeexe, WB1_enable_decodeexe, WB2_enable_decodeexe, SP_enable_decodeexe, SP_op_decodeexe, SP_select_decodeexe, FB_enable_decodeexe, FB_op_decodeexe, outport_enable_decodeexe: std_logic;
    signal reg1_data_decodeexe, reg2_data_decodeexe: std_logic_vector(31 downto 0);
    signal reg1_addr_decodeexe, reg2_addr_decodeexe, WB1_addr_decodeexe, WB2_addr_decodeexe: std_logic_vector(2 downto 0);
    signal ALU_op_decodeexe: std_logic_vector(3 downto 0);

    --Execute out signals
    signal alu_output_exe, reg2_output_exe: std_logic_vector(31 downto 0);

    --Execute Memory Buffer out signals
    signal mem_write_execmem, WB1_execmem, WB2_execmem, SP_enable_execmem, SP_op_execmem, SP_select_execmem, PC_write_execmem, alu_mem_execmem, FB_enable_execmem, FB_op_execmem, outport_enable_execmem: std_logic;
    signal WB1_addr_execmem, WB2_addr_execmem: std_logic_vector(2 downto 0);
    signal alu_out_execmem, reg2_data_execmem: std_logic_vector(31 downto 0);
    signal forwarded1_data_execmem, forwarded2_data_execmem: std_logic_vector(31 downto 0);
    signal forwarded1_enable_execmem, forwarded2_enable_execmem: std_logic;
    signal forwarded1_addr_execmem, forwarded2_addr_execmem: std_logic_vector(2 downto 0);

    --Memory out signals
    signal exception_mem: std_logic;
    signal data_out_mem: std_logic_vector(31 downto 0);

    --Memory Write Back Buffer out signals
    signal WB1_enable_memwb, WB2_enable_memwb, outport_enable_memwb, alu_mem_out_memwb, PC_write_memwb: std_logic;
    signal WB1_addr_memwb, WB2_addr_memwb: std_logic_vector(2 downto 0);
    signal mem_out_memwb, alu_out_memwb, reg2_data_memwb: std_logic_vector(31 downto 0);
    signal forward_enable_memwb: std_logic;
    signal forward_data_memwb: std_logic_vector(31 downto 0);

    --Write Back out signals
    signal wb1_enable_wb, wb2_enable_wb, memory_or_alu_wb: std_logic;
    signal wb1_address_wb, wb2_address_wb: std_logic_vector(2 downto 0);
    signal output_enable_wb: std_logic;
    signal output_data_wb: std_logic_vector(31 downto 0);
    signal wb1_value_wb, wb2_value_wb: std_logic_vector(31 downto 0);

    begin
    fetch1 : fetch port map(
        --IN
        clk => clk_main,
        reset => rst_main,
        pc_enable => '1',
        --OUT
        instruction => instruction_fetch
    );
    FD_Buff : fet_dec_buff port map(
        --IN
        clk => clk_main,
        rst => rst_main,
        flush => '0',
        instruction_in => instruction_fetch,
        --OUT
        reg1_addr => reg1_addr_fetchdecode,
        reg2_addr => reg2_addr_fetchdecode,
        instruction_out => instruction_fetchdecode,
        stall_enable => stall_enable_decode
    );
    decode1 : decode port map(
        --IN
        clk => clk_main,
        rst => rst_main,
        cu_clock => clk_main,
        instruction => instruction_fetchdecode,
        reg1_addr => reg1_addr_fetchdecode,
        reg2_addr => reg2_addr_fetchdecode,
        immediate_value_in => immediate_value_decode,
        pc_in => "00000000000000000000000000000000",
        WB1_enable_in => wb1_enable_wb,
        WB2_enable_in => wb2_enable_wb,
        WB1_data => wb1_value_wb,
        WB2_data => wb2_value_wb,
        WB1_addr_in => wb1_address_wb,
        WB2_addr_in => wb2_address_wb,
        --OUT
        reg1_data => reg1_data_decode,
        reg2_data => reg2_data_decode,
        immediate_value_out => immediate_value_out_decode,
        mem_write => mem_write_decode,
        is_in_port => is_in_port_decode,
        is_immediate => is_immediate_decode,
        stall_enable => stall_enable_decode,
        flag_enable => flag_enable_decode,
        alu_mem => alu_mem_decode,
        WB1_enable_out => WB1_enable_out_decode,
        WB2_enable_out => WB2_enable_out_decode,
        SP_enable => SP_enable_decode,
        SP_op => SP_op_decode,
        SP_select => SP_select_decode,
        FB_enable => FB_enable_decode,
        FB_op => FB_op_decode,
        outport_enable => outport_enable_decode,
        WB1_addr_out => WB1_addr_out_decode,
        WB2_addr_out => WB2_addr_out_decode,
        alu_op => alu_op_decode
    );

    DE_Buffer : dec_exe_buff port map(
        --IN
        rst => rst_main,
        clk => clk_main,
        flush => '0',
        stall_enable => stall_enable_decode,
        mem_write_in => mem_write_decode,
        is_inport_in => is_in_port_decode,
        is_immediate_in => is_immediate_decode,
        flag_enable_in => flag_enable_decode,
        PC_write_in => '0',
        alu_mem_out_in => alu_mem_decode,
        WB1_in => WB1_enable_out_decode,
        WB2_in => WB2_enable_out_decode,
        SP_enable_in => SP_enable_decode,
        Sp_op_in => SP_op_decode,
        SP_select_in => SP_select_decode,
        FB_enable_in => FB_enable_decode,
        FB_op_in => FB_op_decode,
        outport_enable_in => outport_enable_decode,
        reg1_data_in => reg1_data_decode,
        reg2_data_in => reg2_data_decode,
        reg1_addr_in => reg1_addr_fetchdecode,
        reg2_addr_in => reg2_addr_fetchdecode,
        WB1_addr_in => WB1_addr_out_decode,
        WB2_addr_in => WB2_addr_out_decode,
        ALU_op_in => alu_op_decode,
        --OUT
        mem_write_out => mem_write_decodeexe,
        is_inport_out => is_in_port_decodeexe,
        is_immediate_out => is_immediate_decodeexe,
        flag_enable_out => flag_enable_decodeexe,
        PC_write_out => PC_write_decodeexe,
        alu_mem_out_out => alu_mem_decodeexe,
        WB1_enable_out => WB1_enable_decodeexe,
        WB2_enable_out => WB2_enable_decodeexe,
        SP_enable_out => SP_enable_decodeexe,
        Sp_op_out => SP_op_decodeexe,
        SP_select_out => SP_select_decodeexe,
        FB_enable_out => FB_enable_decodeexe,
        FB_op_out => FB_op_decodeexe,
        outport_enable_out => outport_enable_decodeexe,
        reg1_data_out => reg1_data_decodeexe,
        reg2_data_out => reg2_data_decodeexe,
        reg1_addr_out => reg1_addr_decodeexe,
        reg2_addr_out => reg2_addr_decodeexe,
        WB1_addr_out => WB1_addr_decodeexe,
        WB2_addr_out => WB2_addr_decodeexe,
        ALU_op_out => ALU_op_decodeexe
    );
    execute1 : execute port map(
        --IN
        rst => rst_main,
        clk => clk_main,
        opcode => ALU_op_decodeexe,
        reg1_addr => reg1_addr_decodeexe,
        reg2_addr => reg2_addr_decodeexe,
        exe_reg1_addr => reg1_addr_decodeexe,
        exe_reg2_addr => reg2_addr_decodeexe,
        mem_reg1_addr => reg1_addr_fetchdecode,
        mem_reg_2_addr => reg2_addr_fetchdecode,
        reg1_data => reg1_data_decodeexe,
        reg2_data => reg2_data_decodeexe,
        inport_data => in_ports,
        immediate_val => immediate_value_out_decode,
        is_input => is_in_port_decodeexe,
        is_immediate => is_immediate_decodeexe,
        flag_enable => flag_enable_decodeexe,
        exe_wb1_enable => WB1_enable_decodeexe,
        exe_wb2_enable => WB2_enable_decodeexe,
        mem_wb1_enable => WB1_enable_memwb,
        mem_wb2_enable => WB2_enable_memwb,
        --exe_mem_select1 => '0',
        --exe_mem_select2 => '0',
        --exe_wb1_data => wb1_value_wb,
        --exe_wb2_data => wb2_value_wb,
        --mem_wb1_data => wb1_value_wb,
        --mem_wb2_data => wb2_value_wb,
        --OUT
        alu_output => alu_output_exe,
        reg2_output => reg2_output_exe
    );
    EM_Buffer : exe_mem_buff port map(
        --IN
        clk => clk_main,
        rst => rst_main,
        mem_write_in => mem_write_decodeexe,
        WB1_in => WB1_enable_decodeexe,
        WB2_in => WB2_enable_decodeexe,
        SP_enable_in => SP_enable_decodeexe,
        SP_op_in => SP_op_decodeexe,
        SP_select_in => SP_select_decodeexe,
        PC_write_in => PC_write_decodeexe,
        alu_mem_out_in => alu_mem_decodeexe,
        FB_enable_in => FB_enable_decodeexe,
        FB_op_in => FB_op_decodeexe,
        outport_enable_in => outport_enable_decodeexe,
        WB1_addr_in => WB1_addr_decodeexe,
        WB2_addr_in => WB2_addr_decodeexe,
        alu_in => alu_output_exe,
        reg2_data_in => reg2_output_exe,
        --OUT
        mem_read_out => mem_write_execmem,
        WB1_out => WB1_execmem,
        WB2_out => WB2_execmem,
        SP_enable_out => SP_enable_execmem,
        SP_op_out => SP_op_execmem,
        SP_select_out => SP_select_execmem,
        PC_write_out => PC_write_execmem,
        alu_mem_out_out => alu_mem_execmem,
        FB_enable_out => FB_enable_execmem,
        FB_op_out => FB_op_execmem,
        outport_enable_out => outport_enable_execmem,
        WB1_addr_out => WB1_addr_execmem,
        WB2_addr_out => WB2_addr_execmem,
        alu_out => alu_out_execmem,
        reg2_data_out => reg2_data_execmem,
        forwarded1_data => forwarded1_data_execmem,
        forwarded2_data => forwarded2_data_execmem,
        forwarded1_enable => forwarded1_enable_execmem,
        forwarded2_enable => forwarded2_enable_execmem,
        forwarded1_addr => forwarded1_addr_execmem,
        forwarded2_addr => forwarded2_addr_execmem
    );
    Memory1 : memory port map(
        --IN
        SP_enable_memory => SP_enable_execmem,
        SP_operand_memory => SP_op_execmem,
        clk_memory => clk_main,
        --write_enable => '0',
        rst_memory => rst_main,
        sp_data_selector => SP_select_execmem,
        --free_enable_memory => FB_enable_execmem,
        --free_busy_operand => FB_op_execmem,
        Alu_output => alu_out_execmem,
        reg_value => reg2_data_execmem,
        --OUT
        Exception_memory => exception_mem,
        Data_Out => data_out_mem
    );
    MW_Buffer : mem_wb_buff port map(
        --IN
        clk => clk_main,
        rst => rst_main,
        WB1_enable_in => WB1_execmem,
        WB2_enable_in => WB2_execmem,
        outport_enable_in => outport_enable_execmem,
        alu_mem_out_in => alu_mem_execmem,
        PC_write_in => PC_write_execmem,
        WB1_addr_in => WB1_addr_execmem,
        WB2_addr_in => WB2_addr_execmem,
        mem_in => data_out_mem,
        alu_in => alu_out_execmem,
        reg2_data_in => reg2_data_execmem,
        --OUT
        WB1_enable_out => WB1_enable_memwb,
        WB2_enable_out => WB2_enable_memwb,
        outport_enable_out => outport_enable_memwb,
        alu_mem_out_out => alu_mem_out_memwb,
        PC_write_out => PC_write_memwb,
        WB1_addr_out => WB1_addr_memwb,
        WB2_addr_out => WB2_addr_memwb,
        mem_out => mem_out_memwb,
        alu_out => alu_out_memwb,
        reg2_data_out => reg2_data_memwb,
        forward_enable => forward_enable_memwb,
        forward_data => forward_data_memwb
    );
end architecture Arch_Integration;