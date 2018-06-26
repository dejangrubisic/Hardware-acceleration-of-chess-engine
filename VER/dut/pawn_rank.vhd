----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2018 08:54:45 AM
-- Design Name: 
-- Module Name: pawn_rank - Behavioral
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

entity pawn_rank is
  Port (    clk_in: in std_logic;        
            reset_in: in std_logic;         
            start_rank_in: in std_logic;    
            w_rank_in: in unsigned(2 downto 0);                   
            b_rank_in: in unsigned(2 downto 0); 
            
            w_rank_out : out rank_buf;
            b_rank_out : out rank_buf
               
 );
end pawn_rank;

architecture Behavioral of pawn_rank is
    type state_type is (idle, active);
    signal state_reg, state_next: state_type := idle;   

    signal s_w_rank : rank_buf := (others => (others=> '0'));
    signal s_w_rank_next : rank_buf := (others => (others=> '0'));
    signal s_b_rank : rank_buf := (others => (others=> '1'));      
    signal s_b_rank_next : rank_buf := (others => (others=> '1'));
    
    
    signal s_counter: unsigned(3 downto 0) := to_unsigned(1,4);
    signal s_counter_next: unsigned(3 downto 0) := to_unsigned(1,4);
begin
    
    w_rank_out <= s_w_rank;
    b_rank_out <= s_b_rank;
    
    process(clk_in)
    begin
        if(rising_edge(clk_in))then
            if(reset_in = '1')then
                state_reg <= idle;
                s_counter <= to_unsigned(0,4);
            else
                state_reg <= state_next;
                s_counter <= s_counter_next;
                s_w_rank <= s_w_rank_next;
                s_b_rank <= s_b_rank_next;
            end if;
        end if;
    end process;
    
    process(state_reg, s_counter, start_rank_in, w_rank_in, b_rank_in, s_w_rank, s_b_rank)
    begin
    state_next <= state_reg;  
    s_w_rank_next <= s_w_rank;
    s_b_rank_next <= s_b_rank;
    s_counter_next <= to_unsigned(0,4);
      
    case state_reg is
    
    when idle =>    if(start_rank_in = '1') then   
                        state_next <= active;                     
                        s_counter_next <= to_unsigned(1,4);
                        s_w_rank_next <= (others => (others=> '0'));
                        s_b_rank_next <= (others => (others=> '1'));
                    end if;
    
    when active =>  s_counter_next <= s_counter + 1;
                    s_w_rank_next(to_integer(s_counter)) <= w_rank_in;
                    s_b_rank_next(to_integer(s_counter)) <= b_rank_in;
                    
                    if(s_counter = 8)then
                        state_next <= idle;
                        s_counter_next <= to_unsigned(0,4);
                    end if;
    end case;
        
    end process;

end Behavioral;
