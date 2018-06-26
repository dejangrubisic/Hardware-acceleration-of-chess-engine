----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2018 09:37:20 AM
-- Design Name: 
-- Module Name: fifo_top - Behavioral
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

entity fifo_top is
  Port (    clk_in : in std_logic;
            write_in : in std_logic;
            start_in : in std_logic;
            eval_finished_in: in std_logic;
            reset_in : in STD_LOGIC;
            data_in : in std_logic_vector(0 to 7);
            counter_in : in unsigned(2 downto 0);
            data_out : out unsigned (6 downto 0);
            last_element_out: out std_logic
            );
end fifo_top;

architecture Behavioral of fifo_top is
    signal s_piece_reduced: piece_8_4 := (others => (others => '0'));
    signal s_write_in_delayed_1: std_logic := '0';
    signal s_counter_in_delayed_1: unsigned(2 downto 0) := (others => '0');
    signal s_adder: unsigned(2 downto 0) := (others => '0');
begin
                                                                                                                   
            fifo_reduction: entity work.reduction_coder                 
            port map(   clk_in => clk_in,                                 
                        data_in => data_in,            
                        data_out => s_piece_reduced                          
                    );                                                
            fifo_reg: entity work.fifo_reg                             
            port map(   clk_in => clk_in,                                           
                        reset_in => reset_in, 
                        start_in => start_in,  
                        eval_finished_in => eval_finished_in,
                        wr_en_in => s_write_in_delayed_1,                            
                        wr_data_in => s_piece_reduced,                                 
                        counter_in => s_counter_in_delayed_1,                        
                        wr_new_elements_number_in =>  s_adder,                       
                        data_out => data_out , 
                        last_element_out => last_element_out                       
                             
            );                                                          

            process(clk_in)
            begin
                if(rising_edge(clk_in))then
                    s_write_in_delayed_1 <= write_in;                    
                    s_counter_in_delayed_1 <= counter_in;
                    
                     s_adder <=   ((("00"& data_in(0)) + ("00"&data_in(1))) + (("00"& data_in(2)) + ("00"&data_in(3)))) +
                                  ((("00"& data_in(4)) + ("00"&data_in(5))) + (("00"& data_in(6)) + ("00"&data_in(7))));
                                   
                    
                    
                end if;
            end process;


end Behavioral;
