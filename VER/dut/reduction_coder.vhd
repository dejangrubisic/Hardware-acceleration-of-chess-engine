----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
--        Radi tako sto ocitava koji su po redu biti = '1' od data_in, koja je u principu
--        adresa podatka. Ova memorija zauzima 1 kB
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reduction_coder is
  Port (    clk_in: in std_logic;
            data_in: in std_logic_vector(0 to 7);
            data_out: out  piece_8_4
            
            );
end reduction_coder;

architecture Behavioral of reduction_coder is

 signal data_in_reversed: std_logic_vector(0 to 7);

begin
    labela:for i in 0 to 7 generate
        data_in_reversed(i) <= data_in(7-i);  
    end generate;
                          
    process(clk_in)
    begin
        if(rising_edge(clk_in))then
        
            for i in 0 to 7 loop
                data_out(i) <= reduction_coder_mem(to_integer(unsigned(data_in_reversed)))(31-4*i downto 28-4*i);            
            end loop;

        end if;
                   
    end process;
end Behavioral;
