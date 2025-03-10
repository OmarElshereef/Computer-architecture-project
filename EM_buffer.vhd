library ieee;
use ieee.std_logic_1164.all;

entity exe_mem_buff is 
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
end exe_mem_buff;

architecture buff of exe_mem_buff is
    begin
        process(clk, rst, stall_in)
        begin
            if rst = '1' then
                mem_read_out <= '0';
                WB1_out <= '0';
                WB2_out <= '0';
                SP_enable_out <= '0';
                SP_op_out <= '0';
                SP_select_out <= '0';
                PC_write_out <= '0';
                alu_mem_out_out <= '0';
                FB_enable_out <= '0';
                FB_op_out <= '0';
                outport_enable_out <= '0';
                WB1_addr_out <= (others => '0');
                WB2_addr_out <= (others => '0');
                alu_out <= (others => '0');
                reg2_data_out <= (others => '0');
                forwarded1_addr <= (others => '0');
                forwarded2_addr <= (others => '0');
                forwarded1_data <= (others => '0');
                forwarded2_data <= (others => '0');
                forwarded1_enable <= '0';
                interrupt_out <= '0';
                forwarded2_enable <= '0';
                mem_alu_forward <= '0';
                push_flags_out <= '0';
                flag_feedback_out <= '0';
                restart_out <= '0';
                mem_write_out <= '0';
                flags_data_out <= (others => '0');
            elsif rising_edge(clk) then
                mem_write_out <= mem_write_in;
                WB1_out <= WB1_in;
                WB2_out <= WB2_in;
                SP_enable_out <= SP_enable_in;
                SP_op_out <= SP_op_in;
                SP_select_out <= SP_select_in;
                PC_write_out <= PC_write_in;
                alu_mem_out_out <= alu_mem_out_in;
                mem_read_out <= mem_read_in;
                FB_enable_out <= FB_enable_in;
                FB_op_out <= FB_op_in;
                outport_enable_out <= outport_enable_in;
                WB1_addr_out <= WB1_addr_in;
                interrupt_out <= interrupt_in;
                WB2_addr_out <= WB2_addr_in;
                alu_out <= alu_in;
                reg2_data_out <= reg2_data_in;
                forwarded1_addr <= WB1_addr_in;
                flag_feedback_out <= flag_feedback_in;
                forwarded2_addr <= WB2_addr_in;
                forwarded1_data <= alu_in;
                forwarded2_data <= reg2_data_in;
                forwarded1_enable <= WB1_in;
                forwarded2_enable <= WB2_in;
                mem_alu_forward <= alu_mem_out_in;
                restart_out <= restart_in;
                push_flags_out <= push_flags_in;
                flags_data_out <= flags_data_in;
            end if;
        end process;
end buff;