-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
--
-- Description: Fifo radi na sledeci nacin:
--    Reset je u principu i_wr_en = '0', a kada je i_wr_en = '1' onda svaki takt
--    fifo izbacuje po jedan clan, i upisuje paralelno nove podatke na kraj starih
--      podaci su uvek tipa X"1", X"5", X"7", X"0", X"0", X"0", X"0", X"0"
--      ako ima podataka /= 0 oni su na pocetku od manjeg ka vecem. Ukupni broj podataka
--      je uvek < 8, broj figura na tabli je <8   
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity fifo_reg is
  generic (
    g_WIDTH : natural := 4;
    g_DEPTH : integer := 8
    );
  port (
    clk_in      : in std_logic;
    reset_in : in STD_LOGIC;
    start_in : in std_logic;
    eval_finished_in: in std_logic;
    -- FIFO Write Interface
    wr_en_in   : in  std_logic;
    wr_data_in : in  piece_8_4;
    counter_in : in unsigned(2 downto 0);
    wr_new_elements_number_in: in unsigned(2 downto 0);
    
    -- FIFO Read Interface
    data_out : out unsigned(g_WIDTH+3-1 downto 0);
    last_element_out: out std_logic
    );
end fifo_reg;
 
architecture rtl of fifo_reg is
    type state_type is (idle, active, more_elements_left, finished);
    signal state_reg, state_next: state_type := idle;
    
    
  type t_FIFO_DATA is array (0 to g_DEPTH-1) of unsigned(g_WIDTH+3-1 downto 0);
  signal s_FIFO_DATA : t_FIFO_DATA := (others => "1000000");
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal s_FIFO_COUNT : unsigned(2 downto 0) := to_unsigned(0, 3);
  signal s_FIFO_NEXT_COUNT : unsigned(2 downto 0) := to_unsigned(0, 3);
  signal s_FIFO_NEXT_COUNT_delayed_1 : unsigned(2 downto 0) := to_unsigned(0, 3);
  signal s_elements_left: unsigned(2 downto 0):= (others => '0'); 
  signal s_elements_left_next: unsigned(2 downto 0):= (others => '0');
--  signal s_last_element: std_logic :=  '0'; 
  signal s_last_element_next: std_logic :=  '0';
  signal s_counter_in_delayed: unsigned(2 downto 0);
    
begin
  p_CONTROL : process (clk_in) is
  begin
    if rising_edge(clk_in) then
    ------------------------------------
        --shifting in fifo
      for i in 0 to 6 loop                    
        s_FIFO_DATA(i) <= s_FIFO_DATA(i+1); 
      end loop;      
        s_FIFO_DATA(7) <= "1000000";                                 
    ------------------------------------
      if wr_en_in = '0' then
        s_FIFO_COUNT <= to_unsigned(0, 3);                      
      else
        -- Registers the input data when there is a write
    
        --Pretpostavka u jednom redu najvise moze biti 8 istih figura, mada prilicno ne moguce
        
         if(wr_data_in(0)(3) = '0')then
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)) <= wr_data_in(0)& counter_in;                        
         end if;
         
         if(wr_data_in(1)(3) = '0')then       
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)+1) <= wr_data_in(1)& counter_in;   
         end if;                                         
         
         if(wr_data_in(2)(3) = '0')then       
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)+2) <= wr_data_in(2)& counter_in;   
         end if;                                         
         
         if(wr_data_in(3)(3) = '0')then       
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)+3) <= wr_data_in(3)& counter_in;   
         end if;                                         
         
         if(wr_data_in(4)(3) = '0')then       
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)+4) <= wr_data_in(4)& counter_in;   
         end if;                                         
         
         if(wr_data_in(5)(3) = '0')then       
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)+5) <= wr_data_in(5)& counter_in;   
         end if;                                         
         
         if(wr_data_in(6)(3) = '0')then       
            s_FIFO_DATA(to_integer(s_FIFO_COUNT)+6) <= wr_data_in(6)& counter_in;   
         end if;                                         
         
         if(wr_data_in(7)(3) = '0')then       
             s_FIFO_DATA(to_integer(s_FIFO_COUNT)+7) <= wr_data_in(7)& counter_in;   
         end if; 
          
         if(s_FIFO_COUNT = to_unsigned(0, 3) and wr_new_elements_number_in = to_unsigned(0, 3))then   --u empty, pa ostani na 1
             s_FIFO_COUNT <= to_unsigned(0, 3);
         else
             s_FIFO_COUNT <= s_FIFO_NEXT_COUNT - 1;
         end if;
         
      end if;                           -- sync write
    end if;                             -- rising_edge(clk_in)
  end process p_CONTROL;
   
   --the last element
   process(clk_in)
   begin
        if(rising_edge(clk_in))then
        
        s_counter_in_delayed <= counter_in;
        s_FIFO_NEXT_COUNT_delayed_1 <= s_FIFO_NEXT_COUNT;
        
        
            if(reset_in = '1')then
                state_reg <= idle;
                last_element_out <= '0';
                s_elements_left <= (others => '0');
                
            else            
                state_reg <= state_next;
                last_element_out <= s_last_element_next;
                s_elements_left <= s_elements_left_next;
                        
            end if;
        end if;
   end process;
   
   s_FIFO_NEXT_COUNT <= s_FIFO_COUNT + wr_new_elements_number_in;
   
   process(state_reg, start_in, s_counter_in_delayed, s_FIFO_NEXT_COUNT, s_FIFO_NEXT_COUNT_delayed_1, s_elements_left, eval_finished_in)
   begin
        state_next <= state_reg;
        s_elements_left_next <= (others => '0');
        
        case(state_reg) is
        
        when idle =>    if(start_in = '1')then
                            state_next <= active;
                        end if;
                        
        when active =>  s_last_element_next <= '0';
                        if(s_counter_in_delayed = 7 )then                             
                             if( s_FIFO_NEXT_COUNT_delayed_1 /= 0) then
                                s_elements_left_next <= s_FIFO_NEXT_COUNT_delayed_1-1;
                                state_next <= more_elements_left;
                                
                             else
                                state_next <= finished;
                                s_last_element_next <= '1'; 
                                s_elements_left_next <= (others => '0');
                             end if;
                             
                             
                        end if;
        
        when more_elements_left =>  s_last_element_next <= '0';
                                    s_elements_left_next <= s_elements_left - 1 ;
                                    if(s_elements_left = 0)then                             
                                         state_next <= finished;
                                         s_last_element_next <= '1'; 
                                         s_elements_left_next <= (others => '0');
                                    end if;
                        
        when finished =>            s_last_element_next <= '1'; 
                                    s_elements_left_next <= (others => '0'); 
                                    state_next <= state_reg;
                                    if( eval_finished_in = '1')then
                                        state_next <= idle;
                                        s_last_element_next <= '0';
                                    end if;
        end case;

   end process;
   
   
   
   
  data_out <= s_FIFO_DATA(0);
 
end rtl;