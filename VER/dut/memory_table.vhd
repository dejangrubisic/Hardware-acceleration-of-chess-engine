----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2018 05:49:07 PM
-- Design Name: 
-- Module Name: memory_table - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_table is
  Port (    clk_in: in std_logic;
            reset_in: in std_logic;
            
			wr_addr_in: in unsigned(2 downto 0);  --8 x 32 polja
            wr_en_in: in std_logic;
            wr_data_in: in std_logic_vector(31 downto 0); --salje procesor 23-20 je a1, 19-16 je a2...to podesiti iz softvera
                        
            
            rd_addr_in: in unsigned(2 downto 0);
            rd_en_in: in std_logic;
			--read data convenient for eval_ip
            rd_color_out : out std_logic_vector (0 to 7); 
            rd_piece_out : out piece_8_3
            );
end memory_table;

architecture Behavioral of memory_table is

  constant init_mem: std_logic_vector(31 downto 0):= ("0"& "110"&"0"& "110"&"0"& "110"&"0"& "110"&
                                                      "0"& "110"&"0"& "110"&"0"& "110"&"0"& "110");
  
  type type_memory is array (0 to 7) of std_logic_vector(31 downto 0);
  signal s_memory: type_memory := (others => init_mem);
  
  signal s_data_out: std_logic_vector(31 downto 0) := init_mem;
  
begin

    process(clk_in)
    begin
        if(rising_edge(clk_in))then            
            if(reset_in = '1')then
                s_memory <= (others => init_mem);
            else
                if(wr_en_in = '1')then                    
                    s_memory(to_integer(wr_addr_in))<= wr_data_in;
                end if;
                
                if(rd_en_in = '1')then
                    s_data_out <= s_memory(to_integer(rd_addr_in));                    
                else
                    s_data_out <= init_mem;                         
                end if;
            end if;
        end if;
    end process;


    pin_connect: for i in 0 to 7 generate        
        rd_color_out(i) <= s_data_out(4*i + 3);
        rd_piece_out(i) <= s_data_out(4*i + 2 downto 4*i + 0);
    end generate;


end Behavioral;
