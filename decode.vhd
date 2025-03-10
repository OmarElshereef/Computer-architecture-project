LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity decode is port(
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
end decode;

architecture D_Phase of decode is
    component register_file is port(
            Read_address_1: in std_logic_vector (2 downto 0);
            Read_address_2: in std_logic_vector (2 downto 0);
            Write_address_1: in std_logic_vector (2 downto 0);
            Write_address_2: in std_logic_vector (2 downto 0);
            Read_port_1: out std_logic_vector (31 downto 0);
            Read_port_2: out std_logic_vector (31 downto 0);
            Write_port_1: in std_logic_vector (31 downto 0);
            Write_port_2: in std_logic_vector (31 downto 0);
            Write_enable_1,Write_enable_2,rst,clk,read_enable: in std_logic);
        end component;
    
    component sign_extender is port (
            immediate: in std_logic_vector(15 downto 0);
            PC: in std_logic_vector(31 downto 0);
            out_value : out std_logic_vector(31 downto 0);
            clk, jump_enable: in std_logic);
    end component;

    component CU is port(
        clk, rst, interrupt, restart: in std_logic;
        instruction: in std_logic_vector(15 downto 0);
        jump_enable,mem_read_enable, flag_feedback, jump_zero_enable, pc_immediate, restart_out, interrupt_out, pc_write, push_flags, mem_write, is_in_port, is_immediate, stall_Fenable, stall_Eenable, stall_Menable, flag_enable, alu_mem, WB1_enable, WB2_enable, SP_enable, SP_op, SP_select,FB_enable, FB_op, outport_enable: out std_logic;
        WB1_addr, WB2_addr: out std_logic_vector(2 downto 0);
        alu_op: out std_logic_vector(3 downto 0)
    );
    end component;

    component predictor is port(
        corrector,rst,clk:in std_logic;
        prediction_bit:out std_logic
    );
    end component;

    component predictor_mux is port(
        prediction_bit:in std_logic;
        reg1_data,new_pc: in std_logic_vector(31 downto 0);
        predicted_address: out std_logic_vector(31 downto 0)
    );
    end component;

    component flush_unit is port(
        rst: in std_logic;
        jump_flush, jump_zero_flush, predictor_state, checker_valid: in std_logic;
        fetch_flush, decode_flush: out std_logic
    );
    end component;

    signal pc_value_enable, jump_enable_between, jump_zero_enable_between: std_logic;
    signal prediction_bit: std_logic;
    signal reg1_data_wire: std_logic_vector(31 downto 0);
begin

    flusher: flush_unit port map(
        rst => rst,
        jump_flush => jump_enable_between,
        jump_zero_flush => jump_zero_enable_between,
        predictor_state => prediction_bit,
        checker_valid => checker_valid_flush,
        fetch_flush => flush_Fenable,
        decode_flush => flush_Eenable
    );

    predicts: predictor port map(
        corrector => checker_valid_predict,
        rst => rst,
        clk => clk,
        prediction_bit => prediction_bit
    );

    predictorM: predictor_mux port map(
        prediction_bit => prediction_bit,
        reg1_data => reg1_data_wire,
        new_pc => pcAdd_in,
        predicted_address => write_back_address
    );

    control: cu port map(
        clk => cu_clock,
        rst => rst,
        restart => restart,
        instruction => instruction,
        mem_write => mem_write,
        is_in_port => is_in_port,
        is_immediate => is_immediate,
        flag_enable => flag_enable,
        alu_mem => alu_mem,
        WB1_enable => WB1_enable_out,
        WB2_enable => WB2_enable_out,
        interrupt_out => interrupt_out,
        pc_write => PC_write,
        flag_feedback => flag_feedback,
        SP_enable => SP_enable,
        SP_op => SP_op,
        SP_select => SP_select,
        interrupt => interrupt,
        FB_enable => FB_enable,
        FB_op => FB_op,
        outport_enable => outport_enable,
        WB1_addr => WB1_addr_out,
        mem_read_enable => mem_read_out,
        WB2_addr => WB2_addr_out,
        alu_op => alu_op,
        push_flags => push_flags_out,
        pc_immediate => pc_value_enable,
        stall_Fenable => stall_Fenable,
        stall_Eenable => stall_Eenable,
        restart_out => restart_out,
        jump_enable => jump_enable_between,
        jump_zero_enable => jump_zero_enable_between,
        stall_Menable => stall_Menable
    );

    reg_file: register_file port map(
        Read_address_1 => reg1_addr,
        Read_address_2 => reg2_addr,
        Write_address_1 => WB1_addr_in,
        Write_address_2 => WB2_addr_in,
        Read_port_1 => reg1_data_wire,
        Read_port_2 => reg2_data,
        Write_port_1 => WB1_data,
        Write_port_2 => WB2_data,
        Write_enable_1 => WB1_enable_in,
        Write_enable_2 => WB2_enable_in,
        rst => rst,
        clk => clk,
        read_enable => '1'
    );

    sign_ext: sign_extender port map(
        immediate => immediate_value_in,
        PC => pc_in,
        out_value => immediate_value_out,
        clk => clk,
        jump_enable => pc_value_enable
    );
    prediction_bit_out <= prediction_bit;
    pcAdd_out <= pcAdd_in;
    jump_enable <= jump_enable_between;
    jump_zero_enable <= jump_zero_enable_between;
    reg1_data <= reg1_data_wire;
end D_Phase ;