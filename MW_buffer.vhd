LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;



entity mem_wb_buff is
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
end entity mem_wb_buff;


architecture buff of mem_wb_buff is
    begin
        process(clk,rst)
        begin
            if rst = '1' then
                WB1_enable_out <= '0';
                WB2_enable_out <= '0';
                outport_enable_out <= '0';
                alu_mem_out_out <= '0';
                PC_write_out <= '0';
                WB1_addr_out <= (others => '0');
                WB2_addr_out <= (others => '0');
                mem_out <= (others => '0');
                alu_out <= (others => '0');
                reg2_data_out <= (others => '0');
                forward_enable <= '0';
                forward_wb1_enable <= '0';
                forward_wb2_enable <= '0';
                forward_addr1 <= (others => '0');
                forward_addr2 <= (others => '0');
                forward_alu <= (others => '0');
                forward_mem <= (others => '0');
                forward_reg2 <= (others => '0');
            elsif rising_edge(clk) then
                WB1_enable_out <= WB1_enable_in;
                WB2_enable_out <= WB2_enable_in;
                outport_enable_out <= outport_enable_in;
                alu_mem_out_out <= alu_mem_out_in;
                PC_write_out <= PC_write_in;
                WB1_addr_out <= WB1_addr_in;
                WB2_addr_out <= WB2_addr_in;
                mem_out <= mem_in;
                alu_out <= alu_in;
                reg2_data_out <= reg2_data_in;
                forward_enable <= alu_mem_out_in;
                forward_wb1_enable <= WB1_enable_in;
                forward_wb2_enable <= WB2_enable_in;
                forward_addr1 <= WB1_addr_in;
                forward_addr2 <= WB2_addr_in;
                forward_alu <= alu_in;
                forward_mem <= mem_in;
                forward_reg2 <= reg2_data_in;
            end if;
        end process;
end buff;