----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2018 09:06:10 PM
-- Design Name: 
-- Module Name: one_hot_coder - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rank is
    Generic(white_black: natural := 0);
    Port ( clk_in : in std_logic;
           data_in : in std_logic_vector (0 to 7);
           data_out : out unsigned(2 downto 0) 
           );   
end rank;

architecture Behavioral of rank is

begin
----------------------------------------------------------------------------------------
    white: if white_black = 0 generate --white
        process(clk_in)        
        begin
        
            if(rising_edge(clk_in))then
            
                data_out <= (others => '1');    --not started yet
            
                if(data_in(6) = '1')then
                    data_out <= to_unsigned(6, 3);
                
                elsif(data_in(5) = '1')then
                    data_out <= to_unsigned(5, 3);
                
                elsif(data_in(4) = '1')then
                    data_out <= to_unsigned(4, 3);
                    
                elsif(data_in(3) = '1')then
                    data_out <= to_unsigned(3, 3);
                    
                elsif(data_in(2) = '1')then
                    data_out <= to_unsigned(2, 3);
                    
                elsif(data_in(1) = '1')then
                    data_out <= to_unsigned(1, 3); 
                else
                    data_out <= to_unsigned(0, 3);
                end if;            
            end if;            
        end process;
    end generate;
----------------------------------------------------------------------------------------
    black: if white_black = 1 generate --black       
    process(clk_in)                              
    begin                                                                                         
            if(rising_edge(clk_in))then              
                                                     
                data_out <= (others => '0');      -- not started yet   
                                                     
                if(data_in(1) = '1')then             
                    data_out <= to_unsigned(1, 3);   
                                                     
                elsif(data_in(2) = '1')then          
                    data_out <= to_unsigned(2, 3);   
                                                     
                elsif(data_in(3) = '1')then          
                    data_out <= to_unsigned(3, 3);   
                                                     
                elsif(data_in(4) = '1')then          
                    data_out <= to_unsigned(4, 3);   
                                                     
                elsif(data_in(5) = '1')then          
                    data_out <= to_unsigned(5, 3);   
                                                     
                elsif(data_in(6) = '1')then          
                    data_out <= to_unsigned(6, 3); 
                else
                    data_out <= to_unsigned(7, 3);
                end if;                              
            end if;                                  
        end process;                                 
    end generate;                                    
----------------------------------------------------------------------------------------

end Behavioral;