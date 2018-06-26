----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2018 07:06:04 PM
-- Design Name: 
-- Module Name: memory_subsystem - Behavioral
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

entity memory_subsystem is
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           
           reg_data_in : in STD_LOGIC;
           auto_clear_in : in STD_LOGIC;
           
           start_wr_in : in STD_LOGIC;
           start_axi_out : out STD_LOGIC;
           start_out : out STD_LOGIC;          
           
           side_wr_in : in STD_LOGIC;
           side_axi_out : out STD_LOGIC;
           side_out : out STD_LOGIC;
           
           result_in : in STD_LOGIC_VECTOR(14 downto 0);--signed
           result_axi_out : out STD_LOGIC_VECTOR(14 downto 0);--signed           
           finished_in : in STD_LOGIC;
           finished_axi_out : out STD_LOGIC;
           
           
           mem_data_in : in STD_LOGIC_VECTOR(31 downto 0);
           mem_wr_in : in STD_LOGIC;
           mem_wr_addr_in : in STD_LOGIC_VECTOR(2 downto 0);
           mem_rd_in : in STD_LOGIC;
           mem_rd_addr_in : in STD_LOGIC_VECTOR(2 downto 0);
           color_out : out STD_LOGIC_VECTOR(0 to 7);
           piece_out : out piece_8_3
            );
end memory_subsystem;

architecture Behavioral of memory_subsystem is
    signal s_start: std_logic := '0';
    signal s_side: std_logic := '0';
    signal s_result: std_logic_vector(14 downto 0) := (others => '0');
    signal s_finished: std_logic := '0';
    
begin
    --Registers to Eval_ip
    start_out <= s_start;
    side_out <= s_side;
    
    --Registers to AXI
    start_axi_out <= s_start;
    side_axi_out <= s_side;
    result_axi_out <= s_result;
    finished_axi_out <= s_finished;
    
    process(clk_in)
    begin
        if(rising_edge(clk_in))then
            if(reset_in = '1')then
                s_start    <= '0';
                s_side     <= '0';
                s_result   <= (others => '0');
                s_finished <= '0';
            else
                if(auto_clear_in = '1')then
                    s_start <= '0';
                elsif(start_wr_in = '1')then
                    s_start <= reg_data_in;                
                end if;
                
                
                if(auto_clear_in = '1')then
                    s_side <= '0';
                elsif(side_wr_in = '1')then
                    s_side <= reg_data_in;
                end if;
                 
                s_result   <= result_in; 
                s_finished <= finished_in;
            end if;
        end if;
    
    end process;

    memory: entity work.memory_table 
    Port map(   clk_in => clk_in,
                reset_in => reset_in,                
                wr_addr_in => unsigned(mem_wr_addr_in),
                wr_en_in => mem_wr_in,
                wr_data_in => mem_data_in,               
                rd_addr_in => unsigned(mem_rd_addr_in),
                rd_en_in => mem_rd_in,
                --read data convenient for eval_ip
                rd_color_out => color_out,
                rd_piece_out => piece_out
            );

end Behavioral;
