----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2018 03:36:59 PM
-- Design Name: 
-- Module Name: w_choose_king - Behavioral
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

entity choose_king is
  Port (    clk_in: in std_logic;            
            king_end_game_in: in signed (7 downto 0);
            king_end_game_in_finished: in std_logic;            
            king_eval_in: in signed(9 downto 0); 
            king_eval_in_finished: in std_logic;            

            opponent_raw_material_finished_in: in std_logic;            
            opponent_raw_material_in: in unsigned(13 downto 0);
            
            king_out: out signed(9 downto 0);
            choose_king_finished: out std_logic
            );
end choose_king;

architecture Behavioral of choose_king is

begin
        process(clk_in)
        begin
            if(rising_edge(clk_in))then
                            
                choose_king_finished <= king_end_game_in_finished and king_eval_in_finished and opponent_raw_material_finished_in ;
                                
                if(opponent_raw_material_in <= 1200)then
                    king_out <= RESIZE(king_end_game_in, 10);
                else
                    king_out <= king_eval_in;
                end if;
                
            end if;
        end process;

end Behavioral;
