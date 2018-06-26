library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity b_eval_pawn is
  Port (    clk_in: in std_logic;
            start_in: in std_logic;
            reset_in : in std_logic;                
            eval_finished_in: in std_logic;                  
            b_pawn_in: in unsigned (6 downto 0);            
            w_rank_in : in rank_buf;
            b_rank_in : in rank_buf;                  
            b_last_pawn_in: in std_logic;      
            sum_out: out signed(11 downto 0); --max sum_total = 1860, 1_pawn: max = 240, min = 22
            finished_out: out std_logic
            );
end b_eval_pawn;

architecture Behavioral of b_eval_pawn is
    type state_type is (idle, active, propagate, finished);
    signal state_reg, state_next: state_type := idle;


    
    signal s_b_sum_doubled: signed(7 downto 0):= (others => '0');        
    signal s_b_sum_isolated: signed(7 downto 0):= (others => '0');        
    signal s_b_sum_backwards: signed(7 downto 0):= (others => '0');        
    signal s_b_sum_passed: signed(7 downto 0):= (others => '0'); 
    signal s_b_pawn_pcsq: signed(7 downto 0):= (others => '0');    
    signal s_b_pawn_100: signed(7 downto 0):= (others => '0');
    signal s_b_pcsq_100: signed(7 downto 0):= (others => '0');
           
    signal s_b_sum: signed(7 downto 0):= (others => '0');   --min: -30, max: 120       
    signal s_b_sum_total: signed(11 downto 0):= (others => '0');  
    
    
    --------------------------------------------------------
    signal s_b_pawn: unsigned(5 downto 0) := (others => '0');
    --------------------------------------------------------   
    signal s_b_pawn_exist: std_logic := '0';
    --------------------------------------------------------
    signal s_b_row: unsigned(2 downto 0) := (others => '0');
    signal s_b_col: unsigned(2 downto 0) := (others => '0');
    --------------------------------------------------------
    signal s_counter: unsigned(2 downto 0) := (others => '0');
    signal s_counter_next: unsigned(2 downto 0) := (others => '0');
    
    
    signal s_finished: std_logic := '0';
    signal s_finished_next: std_logic := '0';
    signal s_accumulator: signed(11 downto 0) := (others =>'0');
    signal s_accumulator_next: signed(11 downto 0) := (others =>'0');
   
    signal s_sum_out: signed(11 downto 0) := (others =>'0');
    signal s_sum_out_next: signed(11 downto 0) := (others =>'0');
    
    constant DOUBLED_PAWN_PENALTY: integer := -10;
    constant ISOLATED_PAWN_PENALTY: integer := -20;
    constant BACKWARDS_PAWN_PENALTY: integer := -8;
    constant PASSED_PAWN_BONUS: integer := 20;
begin
      
    finished_out <= s_finished;
    sum_out <= s_sum_out;           
    --Counter for rank and finish    
    process(clk_in)
    begin
        if(rising_edge(clk_in))then
        
            if(reset_in = '1')then
                state_reg <= idle;
                s_accumulator <= (others =>'0');                
                s_finished <= '0';
                s_sum_out <= (others => '0');
                
            else
            
            state_reg <= state_next;
            s_counter <= s_counter_next;
                   
            s_b_pawn <= b_pawn_in(5 downto 0);
            s_b_pawn_exist <= not b_pawn_in(6);
            --------------------------------------------------
            s_accumulator <= s_accumulator_next;

            --OUTPUT
            s_finished <= s_finished_next;
            s_sum_out <= s_sum_out_next;
            
            end if;
            
        end if;
    end process;  
    
    
    process(state_reg, start_in, b_last_pawn_in, s_counter, s_accumulator, s_b_sum_total, eval_finished_in)
    begin
        
    s_finished_next <= s_finished;
    s_sum_out_next <= s_sum_out;        
    s_accumulator_next <= s_accumulator + signed(s_b_sum_total);
    state_next <= state_reg;
    s_counter_next <= s_counter; 
    
    
    case state_reg is
        when idle =>        s_accumulator_next <= (others =>'0');                            
                            if(start_in = '1')then
                                state_next <= active;                                                
                                s_finished_next <= '0';
                                s_sum_out_next <= (others => '0');
                            end if;
    
        when active =>      if(b_last_pawn_in = '1')then    
                                state_next <= propagate;                             
                                s_counter_next <= to_unsigned(0, 3);                 
                            end if;                                                  
                        
        
        when propagate =>   s_counter_next <= s_counter + 1;
                            if(s_counter = 1)then    
                                state_next <= finished;  
                            end if;     
        
        when finished =>    s_finished_next <= '1';
                            s_sum_out_next <= s_accumulator;
                                            
                            if(eval_finished_in = '1')then                 
                                state_next <= idle;                                                    
                            end if;                                
                            
    end case;
    
    end process;
    
   
    ------------------------------------ BLACK PAWNS ----------------------------------------
    
    
    s_b_row <= s_b_pawn(5 downto 3);
    s_b_col <= s_b_pawn(2 downto 0);
    
    process(clk_in)
    begin
        if(rising_edge(clk_in))then
        
            s_b_sum_doubled <= (others => '0');   
            s_b_sum_isolated <= (others => '0');  
            s_b_sum_backwards <= (others => '0'); 
            s_b_sum_passed <= (others => '0');    
            s_b_pawn_pcsq <= (others => '0');      
            s_b_pawn_100 <= (others => '0');      

        
       
  
    --------------------------------------------------------------------------    
            if(b_rank_in(to_integer(s_b_col)+1) < to_integer(s_b_row) and s_b_pawn_exist = '1')then
                    s_b_sum_doubled <=  to_signed(DOUBLED_PAWN_PENALTY, 8);                
            end if;
    --------------------------------------------------------------------------
            if( b_rank_in(to_integer(s_b_col)+0) = 7 and b_rank_in(to_integer(s_b_col)+2) = 7 and s_b_pawn_exist = '1')then
                    s_b_sum_isolated <=  to_signed(ISOLATED_PAWN_PENALTY, 8);                
            
            elsif(  b_rank_in(to_integer(s_b_col)+0) > to_integer(s_b_row) and 
                    b_rank_in(to_integer(s_b_col)+2) > to_integer(s_b_row) and s_b_pawn_exist = '1')then
                    s_b_sum_backwards <=  to_signed(BACKWARDS_PAWN_PENALTY, 8);                
            end if;            
    --------------------------------------------------------------------------                       
            if( w_rank_in(to_integer(s_b_col)+0) <= to_integer(s_b_row) and 
                w_rank_in(to_integer(s_b_col)+1) <= to_integer(s_b_row) and 
                w_rank_in(to_integer(s_b_col)+2) <= to_integer(s_b_row) and s_b_pawn_exist = '1' )then
                    s_b_sum_passed <=  to_signed(to_integer(s_b_row) * PASSED_PAWN_BONUS, 8);                
            end if;
    --------------------------------------------------------------------------
            if(s_b_pawn_exist = '1')then
                s_b_pawn_pcsq <= pawn_pcsq(to_integer((not s_b_row) & s_b_col));   --(7 - s_b_row) & s_b_col --> ovo je flip u principu
                s_b_pawn_100 <= to_signed(100, 8);                                 --(7 - s_b_row) == ~s_b_row
            end if;
    --------------------------------------------------------------------------            
            s_b_sum <= (s_b_sum_doubled + s_b_sum_isolated) + (s_b_sum_backwards + s_b_sum_passed);
            s_b_pcsq_100 <= s_b_pawn_pcsq + s_b_pawn_100; 
            
            s_b_sum_total <= RESIZE(s_b_pcsq_100, s_b_sum_total'length) + RESIZE(s_b_sum, s_b_sum_total'length);     
            
        end if;
                   
    end process;

end Behavioral;