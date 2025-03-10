   lIBRARY IEEE;
   USE IEEE.STD_LOGIC_1164.ALL;
   USE IEEE.numeric_std.all;
   
   
   entity add2  is
    port (
       sp_enable: in std_logic;
       sp_operand:in std_logic;
       sp_old:in std_logic_vector(31 downto 0);
       address_pointer:out std_logic_vector(31 downto 0);
       sp_new: out std_logic_vector(31 downto 0)
   
    );
   end add2;
   
   architecture rtl of add2 is
   begin
   sp_new<= std_logic_vector(unsigned(sp_old)+2) when sp_enable = '1' and sp_operand ='0'
   else std_logic_vector(unsigned(sp_old)-2) when sp_enable = '1' and sp_operand ='1'
   else sp_old;
   
   address_pointer<= std_logic_vector(unsigned(sp_old)+2) when sp_enable = '1' and sp_operand ='0'
   else sp_old;
   
   end rtl;