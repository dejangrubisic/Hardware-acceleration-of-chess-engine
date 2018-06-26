----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2018 05:03:28 PM
-- Design Name: 
-- Module Name: top_module - Behavioral
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

entity top_module is
  Port (    clk_in: in std_logic; 
            reset_in : in std_logic;
            start_in : in STD_LOGIC;
            
            color_in : in STD_LOGIC_VECTOR (0 to 7);     --1b: 0 - white; 1 - black
            piece_in : in piece_8_3;                     --3b: 0 - pawn; 1 - knight; 2 - bishop; 3 - rook; 4 - queen; 5 - king; 6 - EMPTY );
            side_in : in std_logic;            
            
            en_rd_out : out std_logic;
            addr_out  : out unsigned(2 downto 0);
            
            result_out: out signed(14 downto 0);
            finished_out: out std_logic
            );
            
end top_module;

architecture Behavioral of top_module is

--SELECT PIECE

signal s_w_pawn_out :  unsigned (6 downto 0);      -- 6b-exist (5 downto 3)-> row from 0 to 7 ,   (2 downto 0)-> column from 0 to 7
signal s_w_rank_out :  unsigned (2 downto 0);
signal s_w_pawn_last_element_out   : std_logic := '0';
signal s_w_knight_out :  unsigned (6 downto 0);
signal s_w_knight_last_element_out : std_logic := '0';
signal s_w_bishop_out :  unsigned (6 downto 0);
signal s_w_bishop_last_element_out : std_logic := '0';
signal s_w_rook_out :  unsigned (6 downto 0);
signal s_w_rook_last_element_out   : std_logic := '0';
signal s_w_queen_out :  unsigned (2 downto 0); --number of queens
signal s_w_king_out :  unsigned (6 downto 0);

signal s_b_pawn_out :  unsigned (6 downto 0);
signal s_b_rank_out :  unsigned (2 downto 0);
signal s_b_pawn_last_element_out   : std_logic := '0';
signal s_b_knight_out :  unsigned (6 downto 0);
signal s_b_knight_last_element_out : std_logic := '0';
signal s_b_bishop_out :  unsigned (6 downto 0);
signal s_b_bishop_last_element_out : std_logic := '0';
signal s_b_rook_out :  unsigned (6 downto 0);
signal s_b_rook_last_element_out   : std_logic := '0';
signal s_b_queen_out :  unsigned (2 downto 0);
signal s_b_king_out :  unsigned (6 downto 0);
signal s_rank_go_out : std_logic;


--EVAL PAWN                                                             
signal s_w_eval_pawn_out: signed(11 downto 0); --max sum_total = 1860, 1_pawn: max = 240, min = 22 
signal s_w_eval_pawn_finished: std_logic;

signal s_b_eval_pawn_out: signed(11 downto 0); --max sum_total = 1860, 1_pawn: max = 240, min = 22    
signal s_b_eval_pawn_finished: std_logic;                                                               

--Pawn rank
signal s_w_rank: rank_buf := (others => (others=> '0'));
signal s_b_rank: rank_buf := (others => (others=> '0'));

--MATERIAL OF PIECES
--white
signal s_w_mp_king: signed (7 downto 0):= (others => '0');  
signal s_w_king_end_finished : std_logic := '0';                
signal s_w_raw_material_out: unsigned(13 downto 0):= (others => '0');    
signal s_w_soft_material_out: signed(8 downto 0):= (others => '0');  
signal s_w_material_of_pieces_finished: std_logic := '0';   
--black          
signal s_b_mp_king: signed (7 downto 0):= (others => '0');     
signal s_b_king_end_finished : std_logic := '0';     
signal s_b_raw_material_out: unsigned(13 downto 0):= (others => '0');    
signal s_b_soft_material_out: signed(8 downto 0):= (others => '0');  
signal s_b_material_of_pieces_finished: std_logic := '0';             

--EVAL KING
--white
signal s_w_eval_king: signed(9 downto 0) := (others => '0');
signal s_w_eval_king_finished: std_logic := '0';

--black
signal s_b_eval_king: signed(9 downto 0) := (others => '0');
signal s_b_eval_king_finished: std_logic := '0';

--ADDER
signal s_adder_finished : std_logic := '0';

begin
        finished_out <= s_adder_finished;
        
        module_select_pieces: entity work.select_piece
        port map ( clk_in => clk_in,
                   start_in => start_in,
                   reset_in => reset_in,
                   color_in => color_in,
                   piece_in => piece_in,
                   eval_finished_in => s_adder_finished,
                   
                   w_pawn_out   => s_w_pawn_out   ,
                   w_rank_out   => s_w_rank_out   ,
                   w_pawn_last_element_out => s_w_pawn_last_element_out,
                   w_knight_out => s_w_knight_out ,
                   w_knight_last_element_out => s_w_knight_last_element_out ,                  
                   w_bishop_out => s_w_bishop_out ,
                   w_bishop_last_element_out => s_w_bishop_last_element_out ,
                   w_rook_out   => s_w_rook_out   ,
                   w_rook_last_element_out => s_w_rook_last_element_out ,
                   w_queen_out  => s_w_queen_out  ,
                   w_king_out   => s_w_king_out   ,
                   
                   b_pawn_out   => s_b_pawn_out   ,
                   b_rank_out   => s_b_rank_out   ,
                   b_pawn_last_element_out => s_b_pawn_last_element_out,       
                   b_knight_out => s_b_knight_out ,                          
                   b_knight_last_element_out => s_b_knight_last_element_out ,  
                   b_bishop_out => s_b_bishop_out ,                          
                   b_bishop_last_element_out => s_b_bishop_last_element_out ,  
                   b_rook_out   => s_b_rook_out   ,                          
                   b_rook_last_element_out => s_b_rook_last_element_out ,                         
                   b_queen_out  => s_b_queen_out  ,
                   b_king_out   => s_b_king_out   ,                   
                   rank_go_out => s_rank_go_out,
                   en_rd_out => en_rd_out,
                   addr_out  => addr_out 
                   );

        module_w_eval_pawn: entity work.w_eval_pawn
        port map ( clk_in       => clk_in ,
                   start_in=> start_in,
                   reset_in => reset_in,
                   eval_finished_in => s_adder_finished,
                   w_pawn_in    => s_w_pawn_out ,
                   w_rank_in => s_w_rank,
                   b_rank_in => s_b_rank,                   
                   w_last_pawn_in => s_w_pawn_last_element_out ,
                   sum_out      => s_w_eval_pawn_out ,
                   finished_out => s_w_eval_pawn_finished 
                   );
                   
       module_b_eval_pawn: entity work.b_eval_pawn
       port map ( clk_in       => clk_in ,
                  start_in=> start_in,
                  reset_in => reset_in,
                  eval_finished_in => s_adder_finished,
                  b_pawn_in    => s_b_pawn_out ,
                  w_rank_in => s_w_rank,
                  b_rank_in => s_b_rank,                   
                  b_last_pawn_in => s_b_pawn_last_element_out ,
                  sum_out      => s_b_eval_pawn_out ,
                  finished_out => s_b_eval_pawn_finished 
                  );
                   
      module_pawn_rank: entity work.pawn_rank
      port map  (  clk_in => clk_in,
                   reset_in => reset_in,      
                   start_rank_in => s_rank_go_out,
                   w_rank_in => s_w_rank_out,
                   b_rank_in => s_b_rank_out,                    
                   w_rank_out => s_w_rank,
                   b_rank_out => s_b_rank      
                );  
      module_w_material_of_pieces: entity work.material_of_pieces
      generic map(  white_black => 0)
      port map   (  clk_in => clk_in,             
                    reset_in => reset_in,
                    eval_finished_in => s_adder_finished,
                    start_in => start_in,   
                    knight_in => s_w_knight_out,                      
                    knight_last_element_in => s_w_knight_last_element_out ,                    
                    bishop_in => s_w_bishop_out,                     
                    bishop_last_element_in => s_w_bishop_last_element_out ,     
                    rook_in => s_w_rook_out   ,                      
                    w_rank_in => s_w_rank,
                    b_rank_in => s_b_rank,
                    rook_last_element_in => s_w_rook_last_element_out ,                           
                    queen_in  => s_w_queen_out  ,      
                    raw_material_out   =>   s_w_raw_material_out,
                    soft_material_out =>   s_w_soft_material_out,
                    finished_out       =>   s_w_material_of_pieces_finished                                                             
              ); 
     module_b_material_of_pieces: entity work.material_of_pieces
     generic map(  white_black => 1)
     port map   (  clk_in => clk_in,             
                   reset_in => reset_in, 
                   eval_finished_in => s_adder_finished,
                   start_in => start_in,                        
                   knight_in => s_b_knight_out,                      
                   knight_last_element_in => s_b_knight_last_element_out ,                    
                   bishop_in => s_b_bishop_out,                     
                   bishop_last_element_in => s_b_bishop_last_element_out ,     
                   rook_in => s_b_rook_out   ,                      
                   w_rank_in => s_w_rank,
                   b_rank_in => s_b_rank,
                   rook_last_element_in => s_b_rook_last_element_out ,                           
                   queen_in  => s_b_queen_out  ,    
                   raw_material_out   =>   s_b_raw_material_out,          
                   soft_material_out =>   s_b_soft_material_out,        
                   finished_out       =>   s_b_material_of_pieces_finished                                            
                                                                    
             );       
     module_w_eval_king: entity work.w_eval_king
     port map(     clk_in => clk_in,                                           
                   reset_in => reset_in,  
                   eval_finished_in => s_adder_finished,
                   start_in => start_in,                       
                   w_rank_in => s_w_rank,                         
                   b_rank_in => s_b_rank,                         
                   king_in => s_w_king_out,
                   raw_material_in => s_b_raw_material_out,     --opponent material
                   raw_material_ready_in => s_b_material_of_pieces_finished,
                   sum_out => s_w_eval_king,                 
                   finished_out => s_w_eval_king_finished                          
               );      
     module_b_eval_king: entity work.b_eval_king
     port map(     clk_in => clk_in,                                           
                   reset_in => reset_in,
                   eval_finished_in => s_adder_finished,
                   start_in => start_in,            
                   w_rank_in => s_w_rank,                         
                   b_rank_in => s_b_rank,                         
                   king_in => s_b_king_out,
                   raw_material_in => s_w_raw_material_out,     --opponent material
                   raw_material_ready_in => s_w_material_of_pieces_finished,
                   sum_out => s_b_eval_king,                 
                   finished_out => s_b_eval_king_finished                          
               ); 
               
     module_adder: entity work.adder
     port map(     clk_in => clk_in,
                   start_in => start_in,
                   reset_in => reset_in,
                   side_in => side_in,
                   w_pawn_in => s_w_eval_pawn_out ,    
                   w_pawn_finished_in => s_w_eval_pawn_finished, 
                   w_raw_material_in => s_w_raw_material_out,  
                   w_soft_material_in => s_w_soft_material_out,     
                   w_material_finished_in => s_w_material_of_pieces_finished,
                   w_king_in => s_w_eval_king, --s_w_choose_king,
                   w_king_finished_in => s_w_eval_king_finished, --s_w_choose_king_finished,           
                   
                   b_pawn_in => s_b_eval_pawn_out ,    
                   b_pawn_finished_in => s_b_eval_pawn_finished,         
                   b_raw_material_in => s_b_raw_material_out,   
                   b_soft_material_in => s_b_soft_material_out, 
                   b_material_finished_in => s_b_material_of_pieces_finished,  
                   b_king_in => s_b_eval_king, --s_b_choose_king,          
                   b_king_finished_in => s_b_eval_king_finished, --s_b_choose_king_finished,          
                   
                   finished_out => s_adder_finished,
                   result_out => result_out
              );                                 
                                                                         
end Behavioral;
