LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity procuss is port(
    clk,rst, interrupt, restart: in std_logic;
    exception_flag_overflow, output_enable_all: out std_logic;
    input_all: in std_logic_vector(31 downto 0);
    ouput_all: out std_logic_vector(31 downto 0));
end entity procuss;

architecture finale of procuss is
    component fetch IS PORT(
		clk : IN std_logic;
		reset: IN std_logic;
		pc_enable:in std_logic;
		jmp,jz,flush,wb: in std_logic;
		reg1,predicted,corrected,wb_data:in std_logic_vector(31 downto 0);
		instruction: OUT std_logic_vector(15 downto 0);
		pc_value, pc_plus_value: OUT std_logic_vector(31 downto 0));
    END  component;

        signal pc_value_buffer, pc_plus_buffer: std_logic_vector(31 downto 0);
        signal stall_Fenable, stall_Eenable, not_stall_Fenable: std_logic:= '0';
        signal instruction_buffer: std_logic_vector(15 downto 0);
	    signal cu_clock: std_logic := '0';

    component fet_dec_buff is port(
        rst, clk,flush: in std_logic;
        instruction_in: in std_logic_vector(15 downto 0);
        reg1_addr, reg1_addr_buffer: out std_logic_vector(2 downto 0);
        reg2_addr, reg2_addr_buffer: out std_logic_vector(2 downto 0);
        instruction_out, immediate_value: out std_logic_vector(15 downto 0);
        stall_enable: in std_logic;
        PC_value_in, PC_add_in: in std_logic_vector(31 downto 0);
        PC_value_out, PC_add_out: out std_logic_vector(31 downto 0));
    end component;

        signal PC_value_decode, pc_plus_decode: std_logic_vector(31 downto 0);
        signal reg1_addr_decode, reg2_addr_decode, reg1_addr_buffer, reg2_addr_buffer: std_logic_vector(2 downto 0);
        signal immediate_value_decode, instruction_decode: std_logic_vector(15 downto 0);

    component decode is port(
        clk, rst, cu_clock, interrupt, restart: in std_logic;
        instruction: in std_logic_vector(15 downto 0);
        reg1_addr, reg2_addr : in std_logic_vector(2 downto 0);
        immediate_value_in: in std_logic_vector(15 downto 0);
        pc_in, pcAdd_in: in std_logic_vector(31 downto 0);
        WB1_enable_in, WB2_enable_in, checker_valid_predict, checker_valid_flush: in std_logic;
        WB1_data, WB2_data: in std_logic_vector(31 downto 0);
        WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
        reg1_data, reg2_data: out std_logic_vector(31 downto 0);
        immediate_value_out, write_back_address, pcAdd_out: out std_logic_vector(31 downto 0);
        flush_Fenable, flush_Eenable, mem_write,mem_read_out, flag_feedback, prediction_bit_out, jump_enable, jump_zero_enable, PC_write, restart_out, interrupt_out, push_flags_out, is_in_port, is_immediate, stall_Fenable, stall_Eenable, stall_Menable, flag_enable, alu_mem, WB1_enable_out, WB2_enable_out, SP_enable, SP_op, SP_select,FB_enable, FB_op, outport_enable: out std_logic;
        WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
        alu_op: out std_logic_vector(3 downto 0)
    );
    end component;

        signal stall_Menable, jump_enable_decode, fleg_feedback_buffer, jump_zero_enable_decode,mem_read_buffer1, prediction_bit_decode, flush_Fenable, flush_Eenable, push_flags_buffer1, restart_buffer1, interrupt_buffer1, mem_write_buffer, is_inport_buffer, is_immediate_buffer, flag_enable_buffer, PC_write_buffer, alu_mem_out_buffer, WB1_enable_buffer, WB2_enable_buffer, SP_enable_buffer, Sp_op_buffer, SP_select_buffer, FB_enable_buffer, FB_op_buffer, outport_enable_buffer: std_logic;
        signal reg1_data_buffer, reg2_data_buffer: std_logic_vector(31 downto 0);
        signal alu_op_buffer: std_logic_vector(3 downto 0);
        signal WB1_addr_buffer, WB2_addr_buffer: std_logic_vector(2 downto 0);
        signal immediate_value_buffer, pc_plus_bufferD: std_logic_vector(31 downto 0);

    component dec_exe_buff is port(
        rst, clk, flush, stall_enable, push_flags_in, restart_in, interrupt_in, mem_read_in, flag_feedback_in: in std_logic;
        jump_in, jump_zero_in, prediction_in, mem_write_in, is_inport_in, is_immediate_in, flag_enable_in, PC_write_in, alu_mem_out_in, WB1_in, WB2_in, SP_enable_in, Sp_op_in, SP_select_in, FB_enable_in, FB_op_in, outport_enable_in: in std_logic;
        reg1_data_in, reg2_data_in, pcAdd_in: in std_logic_vector(31 downto 0);
        reg1_addr_in, reg2_addr_in, WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
        ALU_op_in: in std_logic_vector(3 downto 0);
        push_flags_out, restart_out, prediction_out, interrupt_out, mem_read_out, flag_feedback_out: out std_logic;
        jump_out, jump_zero_out, mem_write_out, is_inport_out, is_immediate_out, flag_enable_out, PC_write_out, alu_mem_out_out, WB1_enable_out, WB2_enable_out, SP_enable_out, Sp_op_out, SP_select_out, FB_enable_out, FB_op_out, outport_enable_out: out std_logic;
        reg1_data_out, reg2_data_out, pcAdd_out: out std_logic_vector(31 downto 0);
        reg1_addr_out, reg2_addr_out, WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
        ALU_op_out: out std_logic_vector(3 downto 0)
    );
    end component;

        signal prediction_bit_execute, jump_enable_execute, flag_feedback_execute, mem_read_buffer2, jump_zero_enable_execute, push_flags_buffer2, restart_buffer2, interrupt_buffer2, mem_write_execute, is_inport_execute, is_immediate_execute, flag_enable_execute, PC_write_execute, alu_mem_out_execute, WB1_enable_execute, WB2_enable_execute, SP_enable_execute, Sp_op_execute, SP_select_execute, FB_enable_execute, FB_op_execute, outport_enable_execute: std_logic;
        signal reg1_data_execute, reg2_data_execute, pc_data_execute: std_logic_vector(31 downto 0);
        signal alu_op_execute: std_logic_vector(3 downto 0);
        signal WB1_addr_execute, WB2_addr_execute: std_logic_vector(2 downto 0);
        signal reg1_addr_execute, reg2_addr_execute: std_logic_vector(2 downto 0);

    component execute is port(
        rst,clk: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        reg1_addr, reg2_addr, exe_reg1_addr, exe_reg2_addr, mem_reg1_addr, mem_reg_2_addr: in std_logic_vector(2 downto 0);
        reg1_data, reg2_data, inport_data, immediate_val, pc_data, mem_feedback: in std_logic_vector(31 downto 0);
        is_input, is_immediate,flag_enable, prediction_bit, jump_enable, jump_zero_enable, flag_feedback: in std_logic;
        exe_wb1_enable, exe_wb2_enable, mem_wb1_enable, mem_wb2_enable, exe_mem_select1, exe_mem_select2: in std_logic;
        exe_wb1_data, exe_wb2_data, mem_wb1_data, mem_wb2_data, mem_output_forward: in std_logic_vector(31 downto 0);
        alu_output, reg2_output, write_back_data: out std_logic_vector(31 downto 0);
        flags_data: out std_logic_vector(3 downto 0);
        write_back_predict, write_back_flusher: out std_logic
    );
    end component;

        signal checker_write_flush, checker_write_predict: std_logic;
        signal checker_write_data, checker_write_address: std_logic_vector(31 downto 0);
        signal flags_buffer: std_logic_vector(3 downto 0);
        signal alu_output_buffer, reg2_data_buffer2: std_logic_vector(31 downto 0);
        signal exe_forwarded1_data, exe_forwarded2_data: std_logic_vector(31 downto 0);
        signal exe_forwarded1_enable, exe_forwarded2_enable, mem_alu_executeF: std_logic;
        signal exe_forwarded1_addr, exe_forwarded2_addr: std_logic_vector(2 downto 0);

    component exe_mem_buff is 
    port(
        clk, rst, push_flags_in, restart_in,stall_in, interrupt_in, mem_read_in, flag_feedback_in: in std_logic;
        mem_write_in, WB1_in, WB2_in, SP_enable_in, SP_op_in, SP_select_in, PC_write_in, alu_mem_out_in, FB_enable_in, FB_op_in, outport_enable_in: in std_logic;
        WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
        alu_in, reg2_data_in: in std_logic_vector(31 downto 0);
        push_flags_out, interrupt_out, restart_out, mem_write_out, WB1_out, WB2_out, SP_enable_out, SP_op_out, SP_select_out, PC_write_out, alu_mem_out_out, FB_enable_out, FB_op_out, outport_enable_out: out std_logic;
        WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
        alu_out, reg2_data_out: out std_logic_vector(31 downto 0);
        forwarded1_data, forwarded2_data: out std_logic_vector(31 downto 0);
        forwarded1_enable, forwarded2_enable, mem_alu_forward, mem_read_out, flag_feedback_out: out std_logic;
        forwarded1_addr, forwarded2_addr: out std_logic_vector(2 downto 0);
        flags_data_in: in std_logic_vector(3 downto 0);
        flags_data_out: out std_logic_vector(3 downto 0)
    );
    end component;

        signal flag_feedback_memory, push_flags_memory, interrupt_memory, restart_memory,mem_read_memory, mem_write_memory, SP_enable_memory, SP_op_memory, SP_select_memory, FB_enable_memory, FB_op_memory: std_logic;
        signal alu_out_memory, reg2_data_memory: std_logic_vector(31 downto 0);
        signal WB1_addr_memory, WB2_addr_memory: std_logic_vector(2 downto 0);
        signal Wb1_enable_memory, WB2_enable_memory: std_logic;
        signal alu_mem_memory, PC_write_memory, output_enable_memory: std_logic;
        signal flags_data_memory: std_logic_vector(3 downto 0);

    component memory is
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
    end component;
        
        signal mem_output_buffer, alu_out_bufferM, reg2_data_bufferM: std_logic_vector(31 downto 0);
        signal outport_enable_memory: std_logic;

    component mem_wb_buff is
        port(
            clk, rst: in std_logic;
            WB1_enable_in, WB2_enable_in, outport_enable_in, alu_mem_out_in, PC_write_in: in std_logic;
            WB1_enable_out, WB2_enable_out, outport_enable_out, alu_mem_out_out, PC_write_out: out std_logic;
            WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
            WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
            mem_in, alu_in, reg2_data_in: in std_logic_vector(31 downto 0);
            mem_out, alu_out, reg2_data_out: out std_logic_vector(31 downto 0);
            forward_enable: out std_logic;
            forward_wb1_enable, forward_wb2_enable: out std_logic;
            forward_addr1, forward_addr2: out std_logic_vector(2 downto 0);
            forward_alu, forward_mem, forward_reg2: out std_logic_vector(31 downto 0)
    );
    end component;

        signal alu_output_wb, mem_output_wb, reg2_output_wb: std_logic_vector(31 downto 0);
        signal WB1_addr_wb, WB2_addr_wb: std_logic_vector(2 downto 0);
        signal WB1_enable_wb, WB2_enable_wb, out_enable_wb, mem_alu_wb, PC_write_wb: std_logic;
        signal mem_forward_enable, mem_forward_wb1, mem_forward_wb2: std_logic;
        signal mem_forwarded_addr1, mem_forwarded_addr2: std_logic_vector(2 downto 0);
        signal mem_forwarded_alu, mem_forwarded_mem, mem_forwarded_reg2: std_logic_vector(31 downto 0);

    component write_back  is
        port (
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
    end component;
        
        signal Wb1_enable_next, WB2_enable_next: std_logic;
        signal WB1_addr_next, WB2_addr_next: std_logic_vector(2 downto 0);
        signal WB1_value_next, WB2_value_next: std_logic_vector(31 downto 0);
begin

    not_stall_Fenable <= not stall_Fenable;

    -- done --
    fetcher: fetch port map(
        clk => clk,
        reset => rst,
        pc_enable => not_stall_Fenable, --in
        instruction => instruction_buffer, --1
        pc_value => pc_value_buffer, --1
        pc_plus_value => pc_plus_buffer, --1
        reg1 => reg1_data_buffer, --3
        jmp => jump_enable_decode, --3
        jz => jump_zero_enable_decode, --3
        flush => checker_write_flush, --2
        wb => pc_write_wb, --2
        wb_data => mem_output_wb, --3
        corrected => checker_write_data, --2
        predicted => checker_write_address --3
        );

    -- done --
    fetch_decode_buffer: fet_dec_buff port map(
        rst => rst,
        clk => clk,
        flush => flush_Fenable, --2
        pc_value_in => pc_value_buffer, --1
        pc_value_out => PC_value_decode, --1
        instruction_in => instruction_buffer, --2
        reg1_addr => reg1_addr_decode, --1
        reg2_addr => reg2_addr_decode, --1
        immediate_value => immediate_value_decode, --1
        instruction_out => instruction_decode, --1
        reg1_addr_buffer => reg1_addr_buffer, --1
        reg2_addr_buffer => reg2_addr_buffer, --1
        stall_enable => stall_Fenable, --out
        PC_add_in => pc_plus_buffer, --2
        PC_add_out => pc_plus_decode --1
        );

    -- done --
    decoder: decode port map(
        clk => clk,
        rst => rst,
        flush_Fenable => flush_Fenable, --1
        flush_Eenable => flush_Eenable, --1
        restart => restart, --in
        interrupt => interrupt, --in
        interrupt_out => interrupt_buffer1, --1
        push_flags_out => push_flags_buffer1, --1
        restart_out => restart_buffer1, --1
	    cu_clock => cu_clock, --in
        instruction => instruction_decode, --2
        reg1_addr => reg1_addr_decode, --2
        reg2_addr => reg2_addr_decode, --2
        immediate_value_in => immediate_value_decode, --2
        pc_in => PC_value_decode, --2
        pcAdd_in => pc_plus_decode, --2
        pcAdd_out => pc_plus_bufferD, --1
        prediction_bit_out => prediction_bit_decode, --1
        WB1_enable_in => WB1_enable_next, --2
        WB2_enable_in => WB2_enable_next, --2
        WB1_data => WB1_value_next, --2
        WB2_data => WB2_value_next, --2
        WB1_addr_in => WB1_addr_next, --2
        WB2_addr_in => WB2_addr_next, --2
        reg1_data => reg1_data_buffer, --1
        reg2_data => reg2_data_buffer, --1
        immediate_value_out => immediate_value_buffer, --1
        mem_write => mem_write_buffer, --1
        flag_feedback => fleg_feedback_buffer, --1
        is_in_port => is_inport_buffer, --1
        is_immediate => is_immediate_buffer, --1
        stall_Fenable => stall_Fenable, --in
        stall_Eenable => stall_Eenable, --in
        flag_enable => flag_enable_buffer, --1
        alu_mem => alu_mem_out_buffer, --1
        WB1_enable_out => WB1_enable_buffer, --1
        WB2_enable_out => WB2_enable_buffer, --1
        SP_enable => SP_enable_buffer, --1
        SP_op => SP_op_buffer, --1
        SP_select => SP_select_buffer, --1
        FB_enable => FB_enable_buffer, --1
        FB_op => FB_op_buffer, --1
        outport_enable => outport_enable_buffer, --1
        WB1_addr_out => WB1_addr_buffer, --1
        WB2_addr_out => WB2_addr_buffer, --1
        alu_op => alu_op_buffer, --1
        PC_write => PC_write_buffer, --1
        jump_enable => jump_enable_decode, --1
        jump_zero_enable => jump_zero_enable_decode, --1
        checker_valid_predict => checker_write_predict, --2
        checker_valid_flush => checker_write_flush, --2
        write_back_address => checker_write_address, --1
        mem_read_out => mem_read_buffer1,
        stall_Menable => stall_Menable --1
        );
    
    -- done --
    decode_execute_buffer: dec_exe_buff port map(
        rst => rst,
        clk => clk,
        flush => flush_Eenable, --2
        pcAdd_in => pc_plus_bufferD, --2
        pcAdd_out => pc_data_execute, --1
        prediction_in => prediction_bit_decode, --2
        prediction_out => prediction_bit_execute, --1
        push_flags_in => push_flags_buffer1, --2
        push_flags_out => push_flags_buffer2, --1
        restart_in => restart_buffer1, --2
        restart_out => restart_buffer2, --1
        stall_enable => stall_Eenable, --in
        mem_write_in => mem_write_buffer, --2
        is_inport_in => is_inport_buffer, --2
        is_immediate_in => is_immediate_buffer, --2
        interrupt_in => interrupt_buffer1, --2
        interrupt_out => interrupt_buffer2, --1
        flag_enable_in => flag_enable_buffer, --2
        PC_write_in => PC_write_buffer, --2
        flag_feedback_in => fleg_feedback_buffer, --1
        flag_feedback_out => flag_feedback_execute, --1
        alu_mem_out_in => alu_mem_out_buffer, --2
        WB1_in => WB1_enable_buffer, --2
        WB2_in => WB2_enable_buffer, --2
        SP_enable_in => SP_enable_buffer, --2
        Sp_op_in => SP_op_buffer, --2
        SP_select_in => SP_select_buffer, --2
        FB_enable_in => FB_enable_buffer, --2
        FB_op_in => FB_op_buffer, --2
        outport_enable_in => outport_enable_buffer, --2
        mem_read_in => mem_read_buffer1, --2
        mem_read_out => mem_read_buffer2, --1
        reg1_data_in => reg1_data_buffer, --2
        reg2_data_in => reg2_data_buffer, --2
        reg1_addr_in => reg1_addr_buffer, --2
        reg2_addr_in => reg2_addr_buffer, --2
        WB1_addr_in => WB1_addr_buffer, --2
        WB2_addr_in => WB2_addr_buffer, --2
        ALU_op_in => alu_op_buffer, --2
        mem_write_out => mem_write_execute, --1
        is_inport_out => is_inport_execute, --1
        is_immediate_out => is_immediate_execute, --1
        flag_enable_out => flag_enable_execute, --1
        PC_write_out => PC_write_execute, --1
        alu_mem_out_out => alu_mem_out_execute, --1
        WB1_enable_out => WB1_enable_execute, --1
        WB2_enable_out => WB2_enable_execute, --1
        SP_enable_out => SP_enable_execute, --1
        Sp_op_out => SP_op_execute, --1
        SP_select_out => SP_select_execute, --1
        FB_enable_out => FB_enable_execute, --1
        FB_op_out => FB_op_execute, --1
        outport_enable_out => outport_enable_execute, --1
        reg1_data_out => reg1_data_execute, --1
        reg2_data_out => reg2_data_execute, --1
        reg1_addr_out => reg1_addr_execute, --1
        reg2_addr_out => reg2_addr_execute, --1
        WB1_addr_out => WB1_addr_execute, --1
        WB2_addr_out => WB2_addr_execute, --1
        ALU_op_out => alu_op_execute, --1
        jump_in => jump_enable_decode, --2
        jump_zero_in => jump_zero_enable_decode, --2
        jump_out => jump_enable_execute, --1
        jump_zero_out => jump_zero_enable_execute --1
        );
	
    executer: execute port map(
        rst => rst,
        clk => clk,
        opcode => alu_op_execute, --2
        reg1_addr => reg1_addr_execute, --2
        reg2_addr => reg2_addr_execute, --2
        reg1_data => reg1_data_execute, --2
        reg2_data => reg2_data_execute, --2
        pc_data => pc_data_execute, --2
        inport_data => input_all, --in
        immediate_val => immediate_value_buffer, --2
        jump_enable => jump_enable_execute, --2
        jump_zero_enable => jump_zero_enable_execute, --2
        is_input => is_inport_execute, --2
        is_immediate => is_immediate_execute, --2
        flag_enable => flag_enable_execute, --2
        alu_output => alu_output_buffer, --1
        flag_feedback => flag_feedback_memory, --2
        mem_feedback => mem_output_buffer, --2
        reg2_output => reg2_data_buffer2, --1
        exe_wb1_data => exe_forwarded1_data, --2
        exe_wb2_data => exe_forwarded2_data, --2
        exe_wb1_enable => exe_forwarded1_enable, --2
        exe_wb2_enable => exe_forwarded2_enable, --2
        exe_reg1_addr => exe_forwarded1_addr, --2
        exe_reg2_addr => exe_forwarded2_addr, --2
        exe_mem_select1 => mem_alu_executeF, --2
        exe_mem_select2 => mem_forward_enable, --2
        mem_reg1_addr => mem_forwarded_addr1, --2
        mem_reg_2_addr => mem_forwarded_addr2, --2
        mem_wb1_data => mem_forwarded_alu, --2
        mem_wb2_data => mem_forwarded_reg2, --2
        mem_output_forward => mem_forwarded_mem, --2
        mem_wb1_enable => mem_forward_wb1, --2
        mem_wb2_enable => mem_forward_wb2, --2
        flags_data => flags_buffer, --1
        prediction_bit => prediction_bit_execute, --2
        write_back_predict => checker_write_predict, --1
        write_back_flusher => checker_write_flush, --1
        write_back_data => checker_write_data --1
        );

    -- done --
    buffer3: exe_mem_buff port map(
        rst => rst,
        clk => clk,
        push_flags_in => push_flags_buffer2, --2
        push_flags_out => push_flags_memory, --1
        restart_in => restart_buffer2, --2
        restart_out => restart_memory, --1
        mem_write_in => mem_write_execute, --2
        WB1_in => WB1_enable_execute, --2
        WB2_in => WB2_enable_execute, --2
        SP_enable_in => SP_enable_execute, --2
        SP_op_in => SP_op_execute, --2
        SP_select_in => SP_select_execute, --2
        PC_write_in => PC_write_execute, --2
        interrupt_in => interrupt_buffer2, --2
        interrupt_out => interrupt_memory, --1
        alu_mem_out_in => alu_mem_out_execute, --2
        FB_enable_in => FB_enable_execute, --2
        FB_op_in => FB_op_execute, --2
        outport_enable_in => outport_enable_execute, --2
        WB1_addr_in => WB1_addr_execute, --2
        WB2_addr_in => WB2_addr_execute, --2
        flag_feedback_in => flag_feedback_execute, --2
        flag_feedback_out => flag_feedback_memory, --1
        alu_in => alu_output_buffer, --2
        reg2_data_in => reg2_data_buffer2, --2
        forwarded1_data => exe_forwarded1_data, --1
        forwarded2_data => exe_forwarded2_data, --1
        forwarded1_enable => exe_forwarded1_enable, --1
        forwarded2_enable => exe_forwarded2_enable, --1
        forwarded1_addr => exe_forwarded1_addr, --1
        forwarded2_addr => exe_forwarded2_addr, --1
        mem_write_out => mem_write_memory, --1
        WB1_out => WB1_enable_memory, --1
        WB2_out => WB2_enable_memory, --1
        SP_enable_out => SP_enable_memory, --1
        SP_op_out => SP_op_memory, --1
        SP_select_out => SP_select_memory, --1
        FB_enable_out => FB_enable_memory, --1
        FB_op_out => FB_op_memory, --1
        outport_enable_out => outport_enable_memory, --1
        WB1_addr_out => WB1_addr_memory, --1
        WB2_addr_out => WB2_addr_memory, --1
        alu_out => alu_out_memory, --1
        reg2_data_out => reg2_data_memory, --1
        alu_mem_out_out => alu_mem_memory,
        PC_write_out => PC_write_memory, --1
        mem_alu_forward => mem_alu_executeF, --1
        flags_data_in => flags_buffer, --2
        flags_data_out => flags_data_memory, --1
        mem_read_in => mem_read_buffer2, --2
        mem_read_out => mem_read_memory, --1
        stall_in => stall_Menable --2
    );

    memory_man: memory port map(
        clk_memory => clk,
        rst_memory => rst,
        interrupt_in => interrupt_memory, --2
        push_flags_in => push_flags_memory, --2
        restart_in => restart_memory, --2
        write_enable => mem_write_memory, --1
        SP_enable_memory => SP_enable_memory, --2
        SP_operand_memory => SP_op_memory, --2
        free_enable_memory => FB_enable_memory, --2
        free_busy_operand => FB_op_memory, --2
        Alu_output => alu_out_memory, --2
        reg_value => reg2_data_memory, --2
        SP_data_selector => SP_select_memory, --2
        Data_Out => mem_output_buffer, --1
        alu_data_out => alu_out_bufferM, --1
        reg2_data_out => reg2_data_bufferM, --1
        flags_data_in => flags_data_memory, --2
        mem_read_in => mem_read_memory --2
    );

    buffer4: mem_wb_buff port map(
        clk => clk,
        rst => rst,
        WB1_enable_in => WB1_enable_memory, --2
        WB2_enable_in => WB2_enable_memory, --2
        outport_enable_in => outport_enable_memory, --2
        alu_mem_out_in => alu_mem_memory, --2
        PC_write_in => PC_write_memory, --2
        WB1_addr_in => WB1_addr_memory, --2
        WB2_addr_in => WB2_addr_memory, --2
        mem_in => mem_output_buffer, --2
        alu_in => alu_out_bufferM, --2
        reg2_data_in => reg2_data_bufferM, --2
        WB1_enable_out => WB1_enable_wb, --1
        WB2_enable_out => WB2_enable_wb, --1
        outport_enable_out => out_enable_wb, --1
        WB1_addr_out => WB1_addr_wb, --1
        WB2_addr_out => WB2_addr_wb, --1
        alu_mem_out_out => mem_alu_wb, --1
        mem_out => mem_output_wb, --1
        alu_out => alu_output_wb, --1
        reg2_data_out => reg2_output_wb, --1
        forward_enable => mem_forward_enable, --1
        forward_wb1_enable => mem_forward_wb1, --1
        forward_wb2_enable => mem_forward_wb2, --1
        forward_addr1 => mem_forwarded_addr1, --1
        forward_addr2 => mem_forwarded_addr2, --1
        forward_alu => mem_forwarded_alu, --1
        forward_mem => mem_forwarded_mem, --1
        forward_reg2 => mem_forwarded_reg2, --1
        PC_write_out => PC_write_wb --1
    );

    -- done --
    writebackall: write_back port map(
        wb1_address_in => WB1_addr_wb, --2
        wb2_address_in => WB2_addr_wb, --2
        wb1_enable_in => WB1_enable_wb, --2
        wb2_enable_in => WB2_enable_wb, --2
        memory_or_alu => mem_alu_wb, --2
        alu_output => alu_output_wb, --2
        memory_output => mem_output_wb, --2
        reg2_value => reg2_output_wb, --2
        output_enable_in => out_enable_wb, --2
        output_enable_out => output_enable_all, --out
        output_data => ouput_all, --out
        wb1_value => WB1_value_next, --1
        wb2_value => WB2_value_next, --1
        wb1_enable_out => Wb1_enable_next, --1
        wb2_enable_out => WB2_enable_next, --1
        wb1_address_out => WB1_addr_next, --1
        wb2_address_out => WB2_addr_next --1
    );

	process(clk)
	begin
	if rising_edge(clk) then
		cu_clock <= not cu_clock;
	end if;
	end process;
end architecture finale;
