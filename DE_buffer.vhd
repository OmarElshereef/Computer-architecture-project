library ieee;
use ieee.std_logic_1164.all;

entity dec_exe_buff is
    port(
        rst, clk, flush, stall_enable, push_flags_in, restart_in, interrupt_in, mem_read_in, flag_feedback_in: in std_logic;
        jump_in, jump_zero_in, prediction_in, mem_write_in, is_inport_in, is_immediate_in, flag_enable_in, PC_write_in, alu_mem_out_in, WB1_in, WB2_in, SP_enable_in, Sp_op_in, SP_select_in, FB_enable_in, FB_op_in, outport_enable_in: in std_logic;
        reg1_data_in, reg2_data_in, pcAdd_in: in std_logic_vector(31 downto 0);
        reg1_addr_in, reg2_addr_in, WB1_addr_in, WB2_addr_in: in std_logic_vector(2 downto 0);
        ALU_op_in: in std_logic_vector(3 downto 0);
        push_flags_out, restart_out, prediction_out, interrupt_out, mem_read_out: out std_logic;
        jump_out, jump_zero_out, mem_write_out, is_inport_out, is_immediate_out, flag_feedback_out, flag_enable_out, PC_write_out, alu_mem_out_out, WB1_enable_out, WB2_enable_out, SP_enable_out, Sp_op_out, SP_select_out, FB_enable_out, FB_op_out, outport_enable_out: out std_logic;
        reg1_data_out, reg2_data_out, pcAdd_out: out std_logic_vector(31 downto 0);
        reg1_addr_out, reg2_addr_out, WB1_addr_out, WB2_addr_out: out std_logic_vector(2 downto 0);
        ALU_op_out: out std_logic_vector(3 downto 0)
    ); 
end entity dec_exe_buff;

architecture do of dec_exe_buff is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg1_data_out <= (others => '0');
            reg2_data_out <= (others => '0');
            reg1_addr_out <= (others => '0');
            reg2_addr_out <= (others => '0');
            pcAdd_out <= (others => '0');
            jump_out <= '0';
            jump_zero_out <= '0';
            is_immediate_out <= '0';
            is_inport_out <= '0';
            WB1_enable_out <= '0';
            WB2_enable_out <= '0';
            WB1_addr_out <= (others => '0');
            WB2_addr_out <= (others => '0');
            ALU_op_out <= (others => '0');
            flag_enable_out <= '0';
            PC_write_out <= '0';
            alu_mem_out_out <= '0';
            mem_write_out <= '0';
            flag_feedback_out <= '0';
            SP_enable_out <= '0';
            Sp_op_out <= '0';
            SP_select_out <= '0';
            mem_read_out <= '0';
            FB_enable_out <= '0';
            FB_op_out <= '0';
            outport_enable_out <= '0';
            push_flags_out <= '0';
            restart_out <= '0';
            prediction_out <= '0';
            interrupt_out <= '0';
        elsif rising_edge(clk) then
            if flush = '1' then
                reg1_data_out <= (others => '0');
                reg2_data_out <= (others => '0');
                reg1_addr_out <= (others => '0');
                reg2_addr_out <= (others => '0');
                pcAdd_out <= (others => '0');
                jump_out <= '0';
                jump_zero_out <= '0';
                is_immediate_out <= '0';
                is_inport_out <= '0';
                WB1_enable_out <= '0';
                mem_read_out <= '0';
                WB2_enable_out <= '0';
                interrupt_out <= '0';
                WB1_addr_out <= (others => '0');
                WB2_addr_out <= (others => '0');
                ALU_op_out <= (others => '0');
                flag_enable_out <= '0';
                PC_write_out <= '0';
                flag_feedback_out <= '0';
                alu_mem_out_out <= '0';
                mem_write_out <= '0';
                SP_enable_out <= '0';
                Sp_op_out <= '0';
                SP_select_out <= '0';
                FB_enable_out <= '0';
                FB_op_out <= '0';
                outport_enable_out <= '0';
                push_flags_out <= '0';
                restart_out <= '0';
                prediction_out <= '0';
            elsif stall_enable = '0' then
                reg1_data_out <= reg1_data_in;
                reg2_data_out <= reg2_data_in;
                reg1_addr_out <= reg1_addr_in;
                reg2_addr_out <= reg2_addr_in;
                pcAdd_out <= pcAdd_in;
                is_immediate_out <= is_immediate_in;
                is_inport_out <= is_inport_in;
                WB1_enable_out <= WB1_in;
                WB2_enable_out <= WB2_in;
                WB1_addr_out <= WB1_addr_in;
                WB2_addr_out <= WB2_addr_in;
                ALU_op_out <= ALU_op_in;
                mem_read_out <= mem_read_in;
                flag_feedback_out <= flag_feedback_in;
                flag_enable_out <= flag_enable_in;
                PC_write_out <= PC_write_in;
                alu_mem_out_out <= alu_mem_out_in;
                mem_write_out <= mem_write_in;
                SP_enable_out <= SP_enable_in;
                Sp_op_out <= Sp_op_in;
                SP_select_out <= SP_select_in;
                FB_enable_out <= FB_enable_in;
                FB_op_out <= FB_op_in;
                jump_out <= jump_in;
                jump_zero_out <= jump_zero_in;
                interrupt_out <= interrupt_in;
                outport_enable_out <= outport_enable_in;
                push_flags_out <= push_flags_in;
                restart_out <= restart_in;
                prediction_out <= prediction_in;
            else
                interrupt_out <= '0';
                restart_out <= '0';
            end if;
        end if;
    end process;
end do ;