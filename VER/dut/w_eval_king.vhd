library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity w_eval_king is
  Port (    clk_in: in std_logic;
            reset_in : in std_logic;
            eval_finished_in: in std_logic;
            start_in : in std_logic;                              
            w_rank_in : in rank_buf;
            b_rank_in : in rank_buf;                  
            king_in : in  unsigned (6 downto 0);      
            raw_material_in: in unsigned(13 downto 0);
            raw_material_ready_in: in std_logic;
            sum_out: out signed(9 downto 0); 
            finished_out: out std_logic
            );
end w_eval_king;

architecture Behavioral of w_eval_king is
    type state_type is (idle, active_1, active_2, active_3, active_3_1, active_3_2,
                              active_6, active_7, active_8, active_8_1, active_8_2, 
                              active_center_1, active_center_2, active_center_3, 
                              finished_1, finished_2);
    signal state_reg, state_next: state_type := idle;

    signal s_w_rank: unsigned(2 downto 0):= (others => '1');
    signal s_w_rank_next: unsigned(2 downto 0):= (others => '1');
    signal s_b_rank: unsigned(2 downto 0):= (others => '0');
    signal s_b_rank_next: unsigned(2 downto 0):= (others => '0');
        
    signal s_w_sum: unsigned(4 downto 0):= (others => '0');
    signal s_w_sum_next: unsigned(4 downto 0):= (others => '0');
    signal s_b_sum: unsigned(3 downto 0):= (others => '0');
    signal s_b_sum_next: unsigned(3 downto 0):= (others => '0');
    -----------------------------------------------------------------------------
    signal s_temp : unsigned (5 downto 0):= (others => '0');
    signal s_temp_next : unsigned (5 downto 0):= (others => '0');


    signal s_king : unsigned (5 downto 0):= (others => '0');     
    signal s_king_next : unsigned (5 downto 0):= (others => '0');

    signal s_sum : signed (21 downto 0):= (others => '0');
    signal s_sum_next : signed (21 downto 0):= (others => '0');
    
    signal s_sum_out: signed(9 downto 0):= (others => '0');     
    signal s_sum_out_next: signed(9 downto 0):= (others => '0'); 

    
    signal s_finished : std_logic:= '0';
    signal s_finished_next : std_logic:= '0';
        
begin
    
    finished_out <= s_finished;
    sum_out <= s_sum_out;
    
    process(clk_in)
    begin
        if(rising_edge(clk_in))then
        
            if(reset_in = '1')then
                state_reg <= idle;
                
                s_king <= (others => '0');   
                s_w_rank <= (others => '0');   
                s_b_rank <= (others => '0');  
                s_w_sum <= (others => '0');   
                s_b_sum <= (others => '0');   
                s_temp <= (others => '0');  
                s_sum <= (others => '0');
                
                s_finished <= '0';
                s_sum_out <= (others => '0');  
            else
                state_reg <= state_next;
                        
                s_king <= s_king_next;
                s_w_rank <= s_w_rank_next;
                s_b_rank <= s_b_rank_next;                
                s_w_sum <= s_w_sum_next;
                s_b_sum <= s_b_sum_next;
                s_temp <= s_temp_next;
                s_sum <= s_sum_next;
                                               
                s_finished <= s_finished_next;
                s_sum_out <= s_sum_out_next;

            end if;
        end if;         
    end process;
    
    process(state_reg, start_in, s_finished, king_in, raw_material_ready_in, w_rank_in, b_rank_in,
            s_sum, s_king, s_w_rank, s_b_rank, s_w_sum, s_b_sum, s_temp, raw_material_in, eval_finished_in)
    
    begin
    state_next <= state_reg;
    s_sum_next <= s_sum;
    s_king_next <= s_king;
    
    s_w_rank_next <= (others => '1');
    s_b_rank_next <= (others => '0');                       
    ----------------------------------------------------------------------------
    s_w_sum_next <= (others => '0');
    s_b_sum_next <= (others => '0');
    
    --white
    if(s_w_rank = 5)then                                                                              
        s_w_sum_next <= to_unsigned(10, 5);                                                                                                                                                         
    elsif(s_w_rank > 0 and s_w_rank < 5)then                                                             
        s_w_sum_next <= to_unsigned(20, 5);                                                                                                                                                         
    elsif(s_w_rank = 0)then                                                                              
        s_w_sum_next <= to_unsigned(25, 5);                                                          
    end if;                                                                                           
                                                                                                      
    --black                                                                                           
    if(s_b_rank = 7)then                                                                              
        s_b_sum_next <= to_unsigned(15, 4);                                                          
    elsif(s_b_rank = 5)then                                                    
        s_b_sum_next <= to_unsigned(10, 4);                                                          
    elsif(s_b_rank = 4)then                                                    
        s_b_sum_next <= to_unsigned(5, 4);                                                                           
    end if;     
    
    s_temp_next <= RESIZE(s_w_sum,6) + RESIZE(s_b_sum, 6);
    ------------------------------------------------------
    s_finished_next <= s_finished;    
    if(raw_material_in <= 1200)then
        s_sum_out_next <= RESIZE(king_endgame_pcsq(to_integer(s_king(5 downto 0))), 10);--king_endgame_pcsq je simetrcno pa je isto za white/black
    else
        s_sum_out_next <= to_signed((to_integer(s_sum) / 3100), 10);  --ovo je s_sum/3100 sa zaokruzivanjem integer
    end if;
    ----------------------------------------------------------------------------

    case state_reg is
    
    when idle =>    if(king_in(6) = '0')then
                        s_sum_next <= RESIZE(king_pcsq(to_integer(king_in(5 downto 0))),22); 
                        s_king_next <= king_in(5 downto 0);
                        s_finished_next <= '0';
                        
                        if(king_in(2 downto 0) < 3)then
                            state_next <= active_1;
                            s_w_rank_next <= w_rank_in(1); 
                            s_b_rank_next <= b_rank_in(1);
                                                            
                        elsif(king_in(2 downto 0) > 4)then
                            state_next <= active_6;                            
                            s_w_rank_next <= w_rank_in(6);
                            s_b_rank_next <= b_rank_in(6);
                            
                        else
                            state_next <= active_center_1;
                            s_w_rank_next <= w_rank_in(to_integer(king_in(2 downto 0)));
                            s_b_rank_next <= b_rank_in(to_integer(king_in(2 downto 0)));                            
                        end if;
                    end if;
    
   when active_1 =>     state_next <= active_2;                        
                        s_w_rank_next <= w_rank_in(2); 
                        s_b_rank_next <= b_rank_in(2);
                        
   when active_2 =>     state_next <= active_3;                            
                        s_w_rank_next <= w_rank_in(3);
                        s_b_rank_next <= b_rank_in(3);
   
   when active_3 =>     state_next <= active_3_1;                            
                        s_sum_next <= s_sum - signed(RESIZE(s_temp, 22));
   
   when active_3_1 =>   state_next <= active_3_2;
                        s_sum_next <= s_sum - signed(RESIZE(s_temp, 22)); 
   
   when active_3_2 =>   state_next <= finished_1;                        
                        s_sum_next <= s_sum - signed(shift_right(RESIZE(s_temp, 22) ,1));                            
                        
   ---------------------------------------------------------------------- 
   when active_6 =>     state_next <= active_7;                          
                        s_w_rank_next <= w_rank_in(7);                   
                        s_b_rank_next <= b_rank_in(7);                   

   when active_7 =>     state_next <= active_8;                          
                        s_w_rank_next <= w_rank_in(8);                   
                        s_b_rank_next <= b_rank_in(8);                   

   when active_8 =>     state_next <= active_8_1;                        
                        s_sum_next <= s_sum - signed(shift_right(RESIZE(s_temp, 22),1)); 
                           
   when active_8_1 =>   state_next <= active_8_2;                        
                        s_sum_next <= s_sum - signed(RESIZE(s_temp, 22));            

   when active_8_2 =>   state_next <= finished_1;                         
                        s_sum_next <= s_sum - signed(RESIZE(s_temp, 22));
   ----------------------------------------------------------------------                                                                
   
   when active_center_1 =>      state_next <= active_center_2;
                                s_w_rank_next <= w_rank_in(to_integer(s_king(2 downto 0)) + 1);
                                s_b_rank_next <= b_rank_in(to_integer(s_king(2 downto 0)) + 1);
                                
                                if(s_w_rank = 0 and s_b_rank = 7)then                                                                              
                                   s_sum_next <= s_sum + to_signed(-10, 10);                                                         
                                end if;
   
   when active_center_2 =>      state_next <= active_center_3;
                                s_w_rank_next <= w_rank_in(to_integer(s_king(2 downto 0)) + 2);
                                s_b_rank_next <= b_rank_in(to_integer(s_king(2 downto 0)) + 2); 
                                if(s_w_rank = 0 and s_b_rank = 7)then                                                                              
                                   s_sum_next <= s_sum + to_signed(-10, 10);                                                         
                                end if;

   when active_center_3 =>      state_next <= finished_1;
                                if(s_w_rank = 0 and s_b_rank = 7)then                                                                              
                                   s_sum_next <= s_sum + to_signed(-10, 10);                                                         
                                end if;
    ---------------------------------------------------------------------------------------
    when finished_1 =>          if(raw_material_ready_in = '1')then
                                    state_next <= finished_2;
                                     s_sum_next <= RESIZE(s_sum * signed(RESIZE(raw_material_in, 22)), 22);                                                                     
                                end if;
                                
    when finished_2 =>          --s_sum_out_next <= s_sum / 3100; --always do this
                                s_finished_next <= '1';
                                
                                if(start_in = '1' and eval_finished_in = '1')then
                                    state_next <= idle;
                                    s_sum_next <= (others => '0');
                                    s_king_next <= (others => '0');   
                                    s_w_rank_next <= (others => '0');   
                                    s_b_rank_next <= (others => '0');  
                                    s_w_sum_next <= (others => '0');   
                                    s_b_sum_next <= (others => '0');   
                                    s_temp_next <= (others => '0');  
                                    s_finished_next <= '0';
                                end if;
    end case;
    end process;

    
            

end Behavioral;