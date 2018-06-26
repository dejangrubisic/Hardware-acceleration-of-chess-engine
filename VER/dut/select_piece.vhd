----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2018 08:51:29 PM
-- Design Name: 
-- Module Name: select_piece - Behavioral
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
use work.common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity select_piece is
        Port ( clk_in : in STD_LOGIC;
               start_in : in STD_LOGIC;
               reset_in : in STD_LOGIC;
               color_in : in STD_LOGIC_VECTOR (0 to 7);     --1b: 0 - white; 1 - black
               piece_in : in piece_8_3;                    --3b: 0 - pawn; 1 - knight; 2 - bishop; 3 - rook; 4 - queen; 5 - king; 6 - EMPTY 
               eval_finished_in: in std_logic;
               
               w_pawn_out : out unsigned (6 downto 0);      -- 6b-exist (5 downto 3)-> row from 0 to 7 ,   (2 downto 0)-> column from 0 to 7
               w_rank_out : out unsigned (2 downto 0);
               w_pawn_last_element_out: out std_logic;
               w_knight_out : out unsigned (6 downto 0);
               w_knight_last_element_out: out std_logic;
               w_bishop_out : out unsigned (6 downto 0);
               w_bishop_last_element_out: out std_logic;
               w_rook_out : out unsigned (6 downto 0);
               w_rook_last_element_out: out std_logic;
               w_queen_out : out unsigned (2 downto 0); --number of queens
               w_king_out : out unsigned (6 downto 0);
               
               b_pawn_out : out unsigned (6 downto 0);
               b_rank_out : out unsigned (2 downto 0);
               b_pawn_last_element_out: out std_logic;
               b_knight_out : out unsigned (6 downto 0);
               b_knight_last_element_out: out std_logic;               
               b_bishop_out : out unsigned (6 downto 0);
               b_bishop_last_element_out: out std_logic;               
               b_rook_out : out unsigned (6 downto 0);
               b_rook_last_element_out: out std_logic;               
               b_queen_out : out unsigned (2 downto 0);
               b_king_out : out unsigned (6 downto 0);
               
               rank_go_out: out STD_LOGIC;
               en_rd_out: out std_logic;
               addr_out: out unsigned(2 downto 0)
               );
end select_piece;

architecture Behavioral of select_piece is
type state_type is (idle, prologue, active, finished);
signal state_reg, state_next: state_type;
signal state_reg_delayed_1: state_type;

signal s_fifo_write: std_logic := '0';  -- '1' dok upisuje u fifo-e, prvih 8 taktova
signal s_fifo_write_next: std_logic := '0';  -- '1' dok upisuje u fifo-e, prvih 8 taktova
signal s_fifo_write_delayed_1: std_logic := '0';  -- '1' dok upisuje u fifo-e, prvih 8 taktova

signal s_input_count_next: unsigned(2 downto 0) := (others => '0');  --starts to count with 000 
signal s_input_count: unsigned(2 downto 0) := (others => '0');  --starts to count with 000 
signal s_input_count_delayed_1: unsigned(2 downto 0) := (others => '0');  --treba zbog king 


signal s_w_pawn: std_logic_vector(0 to 7) := (others => '0'); 
signal s_w_pawn_next: std_logic_vector(0 to 7) := (others => '0'); 
--signal s_w_pawn_adder: unsigned(2 downto 0) := (others => '0');
--signal s_w_pawn_red: piece_8_4 := (others => (others => '0'));
signal s_w_knight: std_logic_vector(0 to 7) := (others => '0');
signal s_w_knight_next: std_logic_vector(0 to 7) := (others => '0');
signal s_w_bishop: std_logic_vector(0 to 7) := (others => '0');
signal s_w_bishop_next: std_logic_vector(0 to 7) := (others => '0');
signal s_w_rook: std_logic_vector(0 to 7) := (others => '0');
signal s_w_rook_next: std_logic_vector(0 to 7) := (others => '0');
signal s_w_queen: unsigned(0 to 7) := (others => '0');
signal s_w_queen_next: unsigned(0 to 7) := (others => '0');
signal s_w_queen_out: unsigned(2 downto 0) := (others => '0');
signal s_w_king: unsigned(0 to 7) := (others => '0');
signal s_w_king_next: unsigned(0 to 7) := (others => '0');

signal s_w_king_out: unsigned(6 downto 0) := "1000000";
signal s_w_king_out_next: unsigned(6 downto 0) := "1000000";

signal s_b_pawn: std_logic_vector(0 to 7) := (others => '0'); 
signal s_b_pawn_next: std_logic_vector(0 to 7) := (others => '0'); 
--signal s_b_pawn_adder: unsigned(2 downto 0) := (others => '0');
--signal s_b_pawn_red: piece_8_4 := (others => (others => '0'));
signal s_b_knight: std_logic_vector(0 to 7) := (others => '0');
signal s_b_knight_next: std_logic_vector(0 to 7) := (others => '0');
signal s_b_bishop: std_logic_vector(0 to 7) := (others => '0');
signal s_b_bishop_next: std_logic_vector(0 to 7) := (others => '0');
signal s_b_rook: std_logic_vector(0 to 7) := (others => '0');
signal s_b_rook_next: std_logic_vector(0 to 7) := (others => '0');
signal s_b_queen: unsigned(0 to 7) := (others => '0');
signal s_b_queen_next: unsigned(0 to 7) := (others => '0');
signal s_b_queen_out: unsigned(2 downto 0) := (others => '0');
signal s_b_king: unsigned(0 to 7) := (others => '0');
signal s_b_king_next: unsigned(0 to 7) := (others => '0');

signal s_b_king_out: unsigned(6 downto 0) := "1000000";
signal s_b_king_out_next: unsigned(6 downto 0) := "1000000";

signal s_addr: unsigned(2 downto 0):=(others => '0');
signal s_addr_next: unsigned(2 downto 0):=(others => '0');
signal s_en_rd: std_logic := '0';
signal s_en_rd_next: std_logic := '0';

begin
        addr_out <= s_addr;
        en_rd_out <= s_en_rd;
        rank_go_out <= s_fifo_write_delayed_1;        
--------------------------------------------------------------------------------------------------------------------
        process(clk_in)
        begin        
            if(rising_edge(clk_in) )then
                  if(reset_in = '1')then
                      state_reg <= idle;
                      s_input_count <= to_unsigned(0, 3);
                      s_fifo_write <= '0';
                      s_addr <= (others => '0');
                      s_en_rd <= '0';
                      w_king_out <= "1000000";
                      b_king_out <= "1000000";
					  w_queen_out <= (others => '0');
					  b_queen_out <= (others => '0');
                      
					  
                  else
                  
                      state_reg <= state_next;
                      state_reg_delayed_1 <= state_reg;
                      s_input_count <= s_input_count_next; 
                      s_input_count_delayed_1 <= s_input_count;
                      s_fifo_write <= s_fifo_write_next;
                      s_fifo_write_delayed_1 <= s_fifo_write;
                      s_en_rd <= s_en_rd_next;
                      s_addr <= s_addr_next;
                      
                      s_w_pawn   <= s_w_pawn_next ;    
                      s_w_knight <= s_w_knight_next ;  
                      s_w_bishop <= s_w_bishop_next ;  
                      s_w_rook   <= s_w_rook_next ;    
                      s_w_queen  <= s_w_queen_next ;
                      s_w_king  <= s_w_king_next ;   
                      s_w_king_out <= s_w_king_out_next;
                      w_king_out <= s_w_king_out;           --Zakasnjavam king_out 1 clk tako da ide uporedo sa rankom, kada se rank upise u 
                                                            -- modul w/b_rank
                      s_b_pawn   <= s_b_pawn_next ;    
                      s_b_knight <= s_b_knight_next ;  
                      s_b_bishop <= s_b_bishop_next ;  
                      s_b_rook   <= s_b_rook_next ;    
                      s_b_queen  <= s_b_queen_next ;   
                      s_b_king   <= s_b_king_next ;
                      s_b_king_out <= s_b_king_out_next;
                      b_king_out <= s_b_king_out;
                      
                      w_queen_out <= s_w_queen_out;        
                                          
                      b_queen_out <= s_b_queen_out;        
                  end if;
                                    
            end if;
        end process;        
--------------------------------------------------------------------------------------------------------------------
        process(state_reg, s_input_count, start_in, color_in, piece_in, s_w_queen, s_b_queen, eval_finished_in)
        begin
        
        s_w_queen_out <= ((("00"& s_w_queen(0)) + ("00"&s_w_queen(1))) + (("00"& s_w_queen(2)) + ("00"&s_w_queen(3)))) +  
                         ((("00"& s_w_queen(4)) + ("00"&s_w_queen(5))) + (("00"& s_w_queen(6)) + ("00"&s_w_queen(7))));
        s_b_queen_out <= ((("00"& s_b_queen(0)) + ("00"&s_b_queen(1))) + (("00"& s_b_queen(2)) + ("00"&s_b_queen(3)))) + 
                         ((("00"& s_b_queen(4)) + ("00"&s_b_queen(5))) + (("00"& s_b_queen(6)) + ("00"&s_b_queen(7))));
        state_next <= state_reg;
        s_input_count_next <= to_unsigned(0, 3);
        s_fifo_write_next <= '0'; 
        --Memory control
        s_addr_next  <= (others => '0');
        s_en_rd_next <= '0';
        
            case state_reg is

            when idle =>    s_w_queen_out <= (others => '0');
                            s_b_queen_out <= (others => '0');            
                            s_fifo_write_next <= '0'; 
                            if(start_in = '1' )then     --mozda ubaciti and accelerator_finished = '1';
                                state_next <= prologue;  
                                s_addr_next <= (others => '0');
                                s_en_rd_next <= '1';                                                              
                            end if;
            
            when prologue =>   state_next <= active;                        --potrebno je pustiti jedan takt da se napuni
                               s_input_count_next <= to_unsigned(0, 3);
                               s_fifo_write_next <= '1';   
                               s_addr_next  <= to_unsigned(1, 3);
                               s_en_rd_next <= '1';             
            
            when active =>  s_input_count_next <= s_input_count + 1;
                            s_fifo_write_next <= '1';                                                
                            if(s_input_count = to_unsigned(7, 3))then 
                                s_input_count_next <= to_unsigned(0, 3); 
                                s_fifo_write_next <= '0';                               
                                state_next <= finished;                                                                                
                            end if;
                            
                            s_addr_next  <= RESIZE(s_input_count + 2, 3);
                            s_en_rd_next <= '1';  
                            
                            if(s_input_count >= to_unsigned(6, 3))then
                                s_addr_next  <= (others => '0');
                                s_en_rd_next <= '0';               
                            end if;  
            
            when finished =>    if(eval_finished_in = '1')then
                                    state_next <= idle;
                                end if;                                                       
            end case;     
        end process;
        
--------------------------------------------------------------------------------------------------------------------
        pieces_on_row: for i in 0 to 7 generate
        
            process(color_in, piece_in)
            begin   
            
                --if(start_in = '1' and )then
                
                        s_w_pawn_next(i) <= '0';
                        s_w_knight_next(i) <= '0';
                        s_w_bishop_next(i) <= '0';
                        s_w_rook_next(i) <= '0';
                        s_w_queen_next(i) <= '0';
                        s_w_king_next(i) <= '0';                         
                        
                        s_b_pawn_next(i) <= '0';
                        s_b_knight_next(i) <= '0'; 
                        s_b_bishop_next(i) <= '0'; 
                        s_b_rook_next(i) <= '0';   
                        s_b_queen_next(i) <= '0';
                        s_b_king_next(i) <= '0';                          
                        
                --if(state_reg = active)then    
            
                    case(color_in(i)&piece_in(i)) is
                    -------------------------- white ------------------------------------------------------------------
                    when "0000" =>  --PAWN
                                    s_w_pawn_next(i) <= '1';
                                    
                    when "0001" =>  --KNIGHT
                                    s_w_knight_next(i) <= '1';
                    when "0010" =>  --BISHOP
                                    s_w_bishop_next(i) <= '1';
                    when "0011" =>  --ROOK
                                    s_w_rook_next(i) <= '1';
                    when "0100" =>  --QUEEN
                                    s_w_queen_next(i) <= '1';
                    when "0101" =>  --KING
                                    s_w_king_next(i) <= '1';
                    
                    --------------------------- black ------------------------------------------------------------------                
                    when "1000" =>  --PAWN 
                                    s_b_pawn_next(i) <= '1';        
                    when "1001" =>  --KNIGHT        
                                    s_b_knight_next(i) <= '1';       
                    when "1010" =>  --BISHOP        
                                    s_b_bishop_next(i) <= '1';       
                    when "1011" =>  --ROOK        
                                    s_b_rook_next(i) <= '1';       
                    when "1100" =>  --QUEEN        
                                    s_b_queen_next(i) <= '1';       
                    when "1101" =>  --KING  
                                    s_b_king_next(i) <= '1';
      
                    --------------------------------------------------------------------------------------------                                           
                    when others =>         
                                       
                    end case;                                                             
              -- end if;        
            end process;
            
        end generate;
        
        ------------------------------------- white -----------------------------------------------------------
        w_rank: entity work.rank
        generic map(white_black => 0)
        port map(   clk_in => clk_in,
                    data_in => std_logic_vector(s_w_pawn),
                    data_out => w_rank_out
                    );        
        w_pawn_fifo: entity work.fifo_top  
        port map(   clk_in => clk_in, 
                    start_in => start_in,
                    eval_finished_in => eval_finished_in,
                    write_in => s_fifo_write_delayed_1,
                    reset_in => reset_in,
                    data_in  => s_w_pawn,
                    counter_in => s_input_count_delayed_1,
                    data_out => w_pawn_out,
                    last_element_out => w_pawn_last_element_out 
                );
        w_knight_fifo: entity work.fifo_top  
        port map(   clk_in => clk_in, 
                    start_in => start_in,
                    eval_finished_in => eval_finished_in,
                    write_in => s_fifo_write_delayed_1,
                    reset_in => reset_in,
                    data_in  => s_w_knight,
                    counter_in => s_input_count_delayed_1,
                    data_out => w_knight_out ,
                    last_element_out => w_knight_last_element_out  
                );  
        w_bishop_fifo: entity work.fifo_top            
        port map(   clk_in => clk_in,        
                    start_in => start_in,      
                    eval_finished_in => eval_finished_in,  
                    write_in => s_fifo_write_delayed_1, 
                    reset_in => reset_in,
                    data_in  => s_w_bishop,            
                    counter_in => s_input_count_delayed_1, 
                    data_out => w_bishop_out ,
                    last_element_out => w_bishop_last_element_out                               
                );                                   
        w_rook_fifo: entity work.fifo_top            
        port map(   clk_in => clk_in,    
                    start_in => start_in,         
                    eval_finished_in => eval_finished_in,   
                    write_in => s_fifo_write_delayed_1, 
                    reset_in => reset_in,
                    data_in  => s_w_rook,            
                    counter_in => s_input_count_delayed_1, 
                    data_out => w_rook_out ,
                    last_element_out => w_rook_last_element_out                               
                );                                   
        s_w_king_out_next <=    "0" & "000" & s_input_count_delayed_1 when s_w_king(0) = '1' and state_reg_delayed_1 = active else
                                "0" & "001" & s_input_count_delayed_1 when s_w_king(1) = '1' and state_reg_delayed_1 = active else
                                "0" & "010" & s_input_count_delayed_1 when s_w_king(2) = '1' and state_reg_delayed_1 = active else
                                "0" & "011" & s_input_count_delayed_1 when s_w_king(3) = '1' and state_reg_delayed_1 = active else
                                "0" & "100" & s_input_count_delayed_1 when s_w_king(4) = '1' and state_reg_delayed_1 = active else
                                "0" & "101" & s_input_count_delayed_1 when s_w_king(5) = '1' and state_reg_delayed_1 = active else
                                "0" & "110" & s_input_count_delayed_1 when s_w_king(6) = '1' and state_reg_delayed_1 = active else
                                "0" & "111" & s_input_count_delayed_1 when s_w_king(7) = '1' and state_reg_delayed_1 = active else
                                "1" & "000" & "000";
                                                                                 
        ------------------------------------- black -----------------------------------------------------------                    
        b_rank: entity work.rank
        generic map(white_black => 1)
        port map(   clk_in => clk_in,
                    data_in => std_logic_vector(s_b_pawn),
                    data_out => b_rank_out 
                    );
        b_pawn_fifo: entity work.fifo_top  
        port map(   clk_in => clk_in, 
                    start_in => start_in,
                    eval_finished_in => eval_finished_in,
                    write_in => s_fifo_write_delayed_1,
                    reset_in => reset_in,
                    data_in  => s_b_pawn,
                    counter_in => s_input_count_delayed_1,
                    data_out => b_pawn_out ,
                    last_element_out => b_pawn_last_element_out                      
                );
        b_knight_fifo: entity work.fifo_top          
        port map(   clk_in => clk_in,    
                    start_in => start_in,         
                    eval_finished_in => eval_finished_in,   
                    write_in => s_fifo_write_delayed_1, 
                    reset_in => reset_in,
                    data_in  => s_b_knight,          
                    counter_in => s_input_count_delayed_1, 
                    data_out => b_knight_out ,
                    last_element_out => b_knight_last_element_out                             
                );                                   
        b_bishop_fifo: entity work.fifo_top          
        port map(   clk_in => clk_in,    
                    start_in => start_in,    
                    eval_finished_in => eval_finished_in,
                    write_in => s_fifo_write_delayed_1, 
                    reset_in => reset_in,
                    data_in  => s_b_bishop,          
                    counter_in => s_input_count_delayed_1, 
                    data_out => b_bishop_out ,
                    last_element_out => b_bishop_last_element_out                             
                );                                   
        b_rook_fifo: entity work.fifo_top            
        port map(   clk_in => clk_in,    
                    start_in => start_in,       
                    eval_finished_in => eval_finished_in,     
                    write_in => s_fifo_write_delayed_1, 
                    reset_in => reset_in,
                    data_in  => s_b_rook,            
                    counter_in => s_input_count_delayed_1, 
                    data_out => b_rook_out ,
                    last_element_out => b_rook_last_element_out                               
                );                                   
        s_b_king_out_next <=    "0" & "000" & s_input_count_delayed_1 when s_b_king(0) = '1' and state_reg_delayed_1 = active else
                                "0" & "001" & s_input_count_delayed_1 when s_b_king(1) = '1' and state_reg_delayed_1 = active else
                                "0" & "010" & s_input_count_delayed_1 when s_b_king(2) = '1' and state_reg_delayed_1 = active else
                                "0" & "011" & s_input_count_delayed_1 when s_b_king(3) = '1' and state_reg_delayed_1 = active else
                                "0" & "100" & s_input_count_delayed_1 when s_b_king(4) = '1' and state_reg_delayed_1 = active else
                                "0" & "101" & s_input_count_delayed_1 when s_b_king(5) = '1' and state_reg_delayed_1 = active else
                                "0" & "110" & s_input_count_delayed_1 when s_b_king(6) = '1' and state_reg_delayed_1 = active else
                                "0" & "111" & s_input_count_delayed_1 when s_b_king(7) = '1' and state_reg_delayed_1 = active else
                                "1" & "000" & "000";
                                                 
                    
                    
                    
end Behavioral;
