----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2018 07:33:41 PM
-- Design Name: 
-- Module Name: top_with_memory - Behavioral
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

entity top_with_memory is
  Port (    clk_mem_in: in std_logic;
            clk_ip_in: in std_logic;
            reset_in : in std_logic;
            --Axi Lite
            reg_data_in : in STD_LOGIC;
            start_wr_in : in STD_LOGIC;
            start_axi_out : out STD_LOGIC;            
            side_wr_in : in STD_LOGIC;
            side_axi_out : out STD_LOGIC;
            --Result
            result_axi_out : out STD_LOGIC_VECTOR(14 downto 0);--signed
            finished_axi_out : out STD_LOGIC;
            --Memory
            mem_data_in : in STD_LOGIC_VECTOR(31 downto 0);
            mem_wr_in : in STD_LOGIC;
            mem_wr_addr_in : in STD_LOGIC_VECTOR(2 downto 0)            
            );
end top_with_memory;

architecture Behavioral of top_with_memory is

signal s_start: std_logic;
signal s_side: std_logic;
signal s_result: signed(14 downto 0);
signal s_finished: std_logic;

signal s_color : std_logic_vector(0 to 7) := (others => '0');
signal s_piece : piece_8_3 := (others => (others => '0'));
signal s_mem_rd : std_logic := '0';    

  
signal s_addr:  unsigned(2 downto 0);


begin
    
    eval_ip: entity work.top_module
    Port map(   clk_in => clk_ip_in, 
                reset_in => reset_in,
                start_in => s_start,
                
                color_in => s_color,
                piece_in => s_piece,
                side_in => s_side,            
                
                en_rd_out => s_mem_rd,
                addr_out => s_addr,
                
                result_out => s_result,
                finished_out => s_finished
            );
            

    memory: entity work.memory_subsystem 
    Port map(  clk_in => clk_mem_in,
               reset_in => reset_in,
               
               reg_data_in => reg_data_in,
               auto_clear_in => s_mem_rd,
               
               start_wr_in => start_wr_in,
               start_axi_out => start_axi_out,
               start_out => s_start,
               
               side_wr_in => side_wr_in,
               side_axi_out => side_axi_out,
               side_out => s_side,
               
               result_in => std_logic_vector(s_result),
               result_axi_out => result_axi_out,           
               finished_in => s_finished,
               finished_axi_out => finished_axi_out,
               
               mem_data_in => mem_data_in,
               mem_wr_in => mem_wr_in,
               mem_wr_addr_in => mem_wr_addr_in,
               mem_rd_in => s_mem_rd,
               mem_rd_addr_in => std_logic_vector(s_addr),
               color_out => s_color,
               piece_out => s_piece
                              
               );
    

end Behavioral;
