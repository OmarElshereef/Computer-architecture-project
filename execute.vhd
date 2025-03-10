lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity execute is port(
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
end execute;

architecture executes of execute is
    component comparator is
        port(
            reg1_b4,reg1_after: in std_logic_vector(31 downto 0);
            wrong: out std_logic
        );
    end component;

    component forwarding  is
        port (
           -- data from register file 
           reg1_address: in std_logic_vector(2 downto 0);
           reg2_address: in std_logic_vector(2 downto 0);
           reg1_data: in std_logic_vector(31 downto 0);
           reg2_data: in std_logic_vector(31 downto 0);
           -- data from execute mem buffer
           execute_reg1_address: in std_logic_vector(2 downto 0);
           execute_reg2_address: in std_logic_vector(2 downto 0);
           execute_wb1_enable: in std_logic;
           execute_alu_output:in std_logic_vector(31 downto 0);
           execute_wb2_enable: in std_logic;
           execute_reg2_data: in std_logic_vector(31 downto 0);
           execute_mem_or_alu:in std_logic;
           --data from mem wb buffer
           memory_reg1_address: in std_logic_vector(2 downto 0);
           memory_reg2_address: in std_logic_vector(2 downto 0);
           memory_wb1_enable: in std_logic;
           memory_alu_output:in std_logic_vector(31 downto 0);
           memory_wb2_enable: in std_logic;
           memory_reg2_data: in std_logic_vector(31 downto 0);
           memory_mem_or_alu:in std_logic;
           memory_mem_output:in std_logic_vector(31 downto 0);
           ----------------------------------------------------------------------------------------------------------
           operand1,operand2:out std_logic_vector(31 downto 0));   
    end component;

    component ALU is
        generic (size: integer := 32);
        port(
          OP1, OP2 : IN std_logic_vector (size-1 downto 0);
          code: IN std_logic_vector (3 downto 0);
          rst: IN std_logic;
          f : OUT std_logic_vector (size-1 downto 0);
          flags_in: IN std_logic_vector (3 downto 0);
          flags_out: OUT std_logic_vector (3 downto 0)
        );
      end component;

    component flag_register is
        port(
            rst, clk, feedback: in std_logic;
            enable: in std_logic;
            memory_feedback: in std_logic_vector(31 downto 0);
            flag_in : in std_logic_vector(3 downto 0);
            flag_out : out std_logic_vector(3 downto 0);
            JZ: in std_logic);
    end component;

    component MUX is
        port( A, B : in std_logic_vector(31 downto 0);
              Selector : in std_logic;
              Y : out std_logic_vector(31 downto 0));
    end component;

    component checker is
        port(
            prediction_bit,conditional_jump,unconditional_jump,zero_flag,wrong_comparator:in std_logic;
            reg1_data_after_forwarding,new_pc: in std_logic_vector(31 downto 0);
            right_data: out std_logic_vector(31 downto 0);
            wrong_prediction,wrong_data,flusher:out std_logic
        );
    end component;

    signal OPERAND1,OPERAND2:std_logic_vector(31 downto 0);
    signal op1_alu, op2_alu, immediate_true: std_logic_vector(31 downto 0);
    signal flags_to_alu, alu_to_flags: std_logic_vector(3 downto 0);
    signal compare_error: std_logic;
    signal write_back_flush: std_logic;
begin

    checks: checker port map(
        prediction_bit => prediction_bit,
        conditional_jump => jump_zero_enable,
        unconditional_jump => jump_enable,
        zero_flag => flags_to_alu(0),
        wrong_comparator => compare_error,
        reg1_data_after_forwarding => OPERAND1,
        new_pc => pc_data,
        right_data => write_back_data,
        wrong_prediction => write_back_predict,
        flusher => write_back_flush
    );

    compare: comparator port map(
        reg1_b4 => reg1_data,
        reg1_after => OPERAND1,
        wrong => compare_error
    );

    forward_unit: forwarding port map(
        reg1_address => reg1_addr,
        reg2_address => reg2_addr,
        reg1_data => reg1_data,
        reg2_data => reg2_data,
        execute_reg1_address => exe_reg1_addr,
        execute_reg2_address => exe_reg2_addr,
        execute_wb1_enable => exe_wb1_enable,
        execute_alu_output => exe_wb1_data,
        execute_wb2_enable => exe_wb2_enable,
        execute_reg2_data => exe_wb2_data,
        execute_mem_or_alu => exe_mem_select1,
        memory_reg1_address => mem_reg1_addr,
        memory_reg2_address => mem_reg_2_addr,
        memory_wb1_enable => mem_wb1_enable,
        memory_alu_output => mem_wb1_data,
        memory_wb2_enable => mem_wb2_enable,
        memory_reg2_data => mem_wb2_data,
        memory_mem_or_alu => exe_mem_select2,
        memory_mem_output => mem_output_forward,
        operand1 => OPERAND1,
        operand2 => OPERAND2    
    );

    OP1_MUX: MUX port map(
        A => OPERAND1,
        B => inport_data,
        Selector => is_input,
        Y => op1_alu
    );

    OP2_MUX: MUX port map(
        A => OPERAND2,
        B => immediate_true,
        Selector => is_immediate,
        Y => op2_alu
    );

    alu_main: ALU port map(
        OP1 => op1_alu,
        OP2 => op2_alu,
        code => opcode,
        rst => rst,
        f => alu_output,
        flags_in => flags_to_alu,
        flags_out => alu_to_flags
    );

    flag_reg: flag_register port map(
        rst => rst,
        clk => clk,
        feedback => flag_feedback,
        memory_feedback => mem_feedback,
        enable => flag_enable,
        flag_in => alu_to_flags,
        flag_out => flags_to_alu,
        JZ => jump_zero_enable
    );

    pc_mux: MUX port map(
        A => immediate_val,
        B => pc_data,
        Selector => jump_enable,
        Y => immediate_true
    );

    reg2_output <= OPERAND2;
    flags_data <= flags_to_alu;
    write_back_flusher <= write_back_flush;
end executes;