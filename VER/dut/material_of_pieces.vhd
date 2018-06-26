----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2018 11:41:04 AM
-- Design Name: 
-- Module Name: material_of_pieces - Behavioral
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

entity material_of_pieces is
  Generic(  white_black: natural := 0);
  Port (    clk_in: in std_logic;            
            reset_in: in std_logic;
            start_in: in std_logic;
            eval_finished_in: in std_logic;
            
            knight_in : in unsigned (6 downto 0);                      
            knight_last_element_in: in std_logic;                      
            bishop_in : in unsigned (6 downto 0);                      
            bishop_last_element_in: in std_logic;                      
            rook_in : in unsigned (6 downto 0);                        
            w_rank_in : in rank_buf; 
            b_rank_in : in rank_buf; 
            rook_last_element_in: in std_logic;                        
            queen_in : in unsigned (2 downto 0); --number of queens    
            
            raw_material_out: out unsigned(13 downto 0);
            soft_material_out: out signed(8 downto 0);
            finished_out: out std_logic                                                                                
        );
end material_of_pieces;

architecture Behavioral of material_of_pieces is
type state_type is (idle, active, finished);
signal state_reg, state_next : state_type := idle;

signal s_knight_raw : unsigned (8 downto 0) := (others => '0');
signal s_knight_soft : signed (7 downto 0) := (others => '0');                           
signal s_bishop_raw : unsigned (8 downto 0) := (others => '0');   
signal s_bishop_soft : signed (7 downto 0) := (others => '0');                           
signal s_rook_raw : unsigned (8 downto 0) := (others => '0');
signal s_rook_raw_next : unsigned (8 downto 0) := (others => '0');
signal s_rook_soft : signed (7 downto 0) := (others => '0');                             
signal s_rook_soft_pawns : signed (7 downto 0) := (others => '0');
signal s_rook_soft_seventh : signed (7 downto 0) := (others => '0');
signal s_rook_soft_next : signed (7 downto 0) := (others => '0');
signal s_queen_raw : unsigned (12 downto 0) := (others => '0'); --number of queens         
                          

signal s_raw_material_temp : unsigned (13 downto 0):= (others => '0');
signal s_raw_material : unsigned (13 downto 0):= (others => '0');
signal s_raw_material_next : unsigned (13 downto 0):= (others => '0');

signal s_soft_material_temp : signed (8 downto 0):= (others => '0');
signal s_soft_material : signed (8 downto 0):= (others => '0');
signal s_soft_material_next : signed (8 downto 0):= (others => '0');

signal s_knight_flip: unsigned(5 downto 0):= (others => '0');
signal s_bishop_flip: unsigned(5 downto 0):= (others => '0');

signal s_finished: std_logic := '0';
signal s_finished_next: std_logic := '0';

constant ROOK_OPEN_FILE_BONUS: integer := 15;        
constant ROOK_SEMI_OPEN_FILE_BONUS: integer := 10;       
constant ROOK_ON_SEVENTH_BONUS: integer := 20;       

begin
        
        finished_out <= s_finished;
        
        raw_material_out <= s_raw_material;
        soft_material_out <= s_soft_material;
        
        process(clk_in)
        begin
            if(rising_edge(clk_in))then
                if(reset_in = '1')then
                    state_reg <= idle;
                    s_raw_material <= (others => '0');
                    s_soft_material <= (others => '0');                    
                    s_finished <= '0';
                else
                    state_reg <= state_next;
                    s_finished <= s_finished_next;
                    
                    --Dataflow logic
                    if(knight_in(6) = '0')then
                        s_knight_raw <= to_unsigned(300, 9);
                        s_knight_soft <= knight_pcsq(to_integer(s_knight_flip));
                    else
                        s_knight_raw <= to_unsigned(0, 9);
                        s_knight_soft <= to_signed(0, 8);
                    end if;
                    
                    if(bishop_in(6) = '0')then
                        s_bishop_raw <= to_unsigned(300, 9);
                        s_bishop_soft <= bishop_pcsq(to_integer(s_bishop_flip));
                    else
                        s_bishop_raw <= to_unsigned(0, 9);
                        s_bishop_soft <= to_signed(0, 8);                    
                    end if;
                    
                    s_rook_raw <= s_rook_raw_next;    
                    s_rook_soft <= s_rook_soft_next;  
                                        
                    if(queen_in /= to_unsigned(0, 3))then                
                        s_queen_raw <= RESIZE(to_unsigned(900, 13) * RESIZE(queen_in, 13), 13);  
                    else                                    
                        s_queen_raw <= to_unsigned(0, 13);    
                    end if;       
        
                    s_raw_material_temp <=  (RESIZE(s_knight_raw,14) + RESIZE(s_bishop_raw,14 )) + ( RESIZE(s_rook_raw,14) + RESIZE(s_queen_raw,14));
                    s_raw_material <= s_raw_material_next;  
                    
                    s_soft_material_temp <= RESIZE(s_knight_soft, 9) + RESIZE(s_bishop_soft, 9) + RESIZE(s_rook_soft, 9);                     
                    s_soft_material <= s_soft_material_next;
                        
                end if;
            end if;
        end process;
        
        process(state_reg, start_in, knight_last_element_in, bishop_last_element_in, rook_last_element_in,
                s_raw_material, s_raw_material_temp, s_soft_material, s_soft_material_temp, eval_finished_in)
        begin
            
            state_next <= state_reg;            
            s_raw_material_next <= s_raw_material + s_raw_material_temp;
            s_soft_material_next <= s_soft_material + s_soft_material_temp;
            s_finished_next <= s_finished;
            
            case state_reg is
            when idle =>        if(start_in = '1')then
                                    state_next <= active;
                                    s_raw_material_next <= (others => '0');  
                                    s_soft_material_next <= (others => '0');
                                    s_finished_next <= '0';
                                end if;
            
            
            when active =>      if(knight_last_element_in = '1' and bishop_last_element_in = '1' and rook_last_element_in = '1')then
                                    s_finished_next <= '1';
                                    state_next <= finished;                                
                                end if;
            
            when finished =>    s_finished_next <= '1';                                
                                if(eval_finished_in = '1')then
                                    state_next <= idle;                     
                                end if;
            end case;
        end process;
        
------------------------------------------------------------------------------------------------------------------------        
        flip_white: if(white_black = 0)generate
           s_knight_flip <= knight_in(5 downto 0);
           s_bishop_flip <= bishop_in(5 downto 0);  
           
           process(rook_in, s_rook_soft_pawns, s_rook_soft_seventh, w_rank_in, b_rank_in )                    
           begin                                                                        
                                                                                        
           s_rook_soft_next <= s_rook_soft_pawns + s_rook_soft_seventh;  
           s_rook_soft_pawns <= (others => '0');  
           s_rook_soft_seventh <= (others => '0');
           s_rook_raw_next <= (others => '0');    
                                     
           if(rook_in(6) = '0')then                                                                             
               s_rook_raw_next <= to_unsigned(500, 9);

               if(w_rank_in(to_integer(rook_in(2 downto 0))+1) = 0) then
                      if(b_rank_in(to_integer(rook_in(2 downto 0))+1) = 7)then
                          s_rook_soft_pawns <= to_signed(ROOK_OPEN_FILE_BONUS, 8);
                      else
                          s_rook_soft_pawns <= to_signed(ROOK_SEMI_OPEN_FILE_BONUS, 8);
                      end if;
                 end if; 
                 if(rook_in(5 downto 3) = 1)then
                      s_rook_soft_seventh <= to_signed(ROOK_ON_SEVENTH_BONUS, 8);
                 end if;           
           end if;
           end process;                                                                 
       
           end generate;
        
        flip_black: if(white_black = 1)generate
           s_knight_flip <= (not knight_in(5 downto 3)) & knight_in(2 downto 0);
           s_bishop_flip <= (not bishop_in(5 downto 3)) & bishop_in(2 downto 0); 
                       
           process(rook_in, s_rook_soft_pawns, s_rook_soft_seventh, w_rank_in, b_rank_in )
           begin
           
           s_rook_soft_next <= s_rook_soft_pawns + s_rook_soft_seventh;
           s_rook_soft_pawns <= (others => '0');   
           s_rook_soft_seventh <= (others => '0');
           s_rook_raw_next <= to_unsigned(0, 9);
                              
           if(rook_in(6) = '0')then
               s_rook_raw_next <= to_unsigned(500, 9);  
           
               if(b_rank_in(to_integer(rook_in(2 downto 0))+1) = 7) then
                   if(w_rank_in(to_integer(rook_in(2 downto 0))+1) = 0)then
                       s_rook_soft_pawns <= to_signed(ROOK_OPEN_FILE_BONUS, 8);
                   else
                       s_rook_soft_pawns <= to_signed(ROOK_SEMI_OPEN_FILE_BONUS, 8);
                   end if;
               end if; 
               
               if(rook_in(5 downto 3) = 6)then
                   s_rook_soft_seventh <= to_signed(ROOK_ON_SEVENTH_BONUS, 8);
               end if;  
   
           end if;     
           end process; 
        end generate;
        
   
end Behavioral;
